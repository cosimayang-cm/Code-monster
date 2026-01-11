# Code Monster #1 優化建議

## 當前實作狀態

基於 monster1.md 規格的基礎實作已完成，所有功能正常運作。

**已確認設計決策**：
- ✅ 停用策略：採用**連鎖停用**（Cascade Disable）- 符合真實車輛物理特性
- 🎯 下一步：應用 **TDD + SOLID 原則**進行重構

---

## 1. SOLID 原則分析與改進

### 1.1 當前違反 SOLID 的地方

#### ❌ Single Responsibility Principle (SRP)
**問題**：
- `Car` 類別承擔過多職責：
  - 管理 16 個元件實例
  - 管理功能啟用狀態
  - 驗證相依性（透過 DependencyValidator）
  - 處理連鎖停用邏輯
  - 控制引擎和中控電腦

**改進**：
```swift
// 分離職責到專門的管理器
FeatureStateManager      // 管理功能啟用狀態
ComponentLifecycleManager // 管理元件生命週期
CascadeDisableHandler    // 處理連鎖停用邏輯
Car (Facade)             // 只作為統一介面
```

#### ❌ Open/Closed Principle (OCP)
**問題**：
- `setFeatureEnabled()` 使用 switch statement，新增功能需修改此方法
- 停用策略硬編碼，無法擴展

**改進**：
```swift
// 使用 Dictionary 映射，避免 switch
private let featureComponents: [Feature: FeatureToggleComponent]

// 支援策略擴展
protocol DisableStrategy {
    func disable(_ feature: Feature, context: FeatureContext) -> Result<[Feature], FeatureError>
}
```

#### ❌ Liskov Substitution Principle (LSP)
**當前狀態**：✅ 良好
- 所有元件都正確實作 `CarComponent` protocol

#### ❌ Interface Segregation Principle (ISP)
**問題**：
- `CarComponent` protocol 可能對某些元件過於簡化
- 缺乏「可 Toggle」與「不可 Toggle」元件的區分

**改進**：
```swift
protocol CarComponent {
    var name: String { get }
}

protocol ToggleableComponent: CarComponent {
    var isEnabled: Bool { get set }
}

protocol StatefulComponent: CarComponent {
    var isActive: Bool { get }
    func turnOn()
    func turnOff()
}
```

#### ❌ Dependency Inversion Principle (DIP)
**問題**：
- `Car` 直接依賴具體類別 `DependencyValidator()`
- 無法注入 Mock 進行單元測試

**改進**：
```swift
protocol DependencyValidating {
    func validateEnable(...) -> Result<Void, FeatureError>
    func getDependentFeatures(...) -> [Feature]
}

class Car {
    private let validator: DependencyValidating
    
    init(validator: DependencyValidating = DependencyValidator()) {
        self.validator = validator
    }
}
```

---

## 2. 設計模式應用建議

### 1.1 關注點分離

**目前問題**：
- `Car` 類別承擔太多職責（管理元件 + 管理功能狀態 + 驗證相依性）

**改善方案**：
```
DependencyGraph (已有)
  └─ 專門管理功能相依關係

FeatureToggleManager (新增)
  └─ 專門管理功能開關狀態

ComponentStateManager (新增)
  └─ 管理元件運行狀態

Car (簡化)
  └─ 作為 Facade，整合上述服務
```

### 2.1 Strategy Pattern - 連鎖停用處理 ⭐

**目的**：將連鎖停用邏輯獨立成策略，符合 OCP

```swift
protocol DisableStrategy {
    /// 停用功能並處理依賴者
    /// - Returns: 所有被停用的功能列表
    func disable(_ feature: Feature, context: FeatureContext) -> Result<[Feature], FeatureError>
}

class CascadeDisableStrategy: DisableStrategy {
    func disable(_ feature: Feature, context: FeatureContext) -> Result<[Feature], FeatureError> {
        // 遞迴停用所有依賴者
        var disabled: [Feature] = []
        let dependents = context.getDependents(of: feature)
        
        for dependent in dependents {
            let result = disable(dependent, context: context)
            if case .success(let features) = result {
                disabled.append(contentsOf: features)
            }
        }
        
        context.setEnabled(feature, false)
        disabled.append(feature)
        return .success(disabled)
    }
}

// 未來可擴展：拒絕停用策略（用於特殊情境）
class StrictDisableStrategy: DisableStrategy {
    func disable(_ feature: Feature, context: FeatureContext) -> Result<[Feature], FeatureError> {
        let dependents = context.getDependents(of: feature)
        if !dependents.isEmpty {
            return .failure(.cannotDisable(feature: feature, dependentFeatures: dependents))
        }
        context.setEnabled(feature, false)
        return .success([feature])
    }
}
```

**優點**：
- ✅ 符合 OCP：新增策略不需修改現有程式碼
- ✅ 可測試性：可獨立測試每種策略
- ✅ 彈性：可在運行時切換策略（如測試模式 vs 生產模式）

### 2.2 Observer Pattern - 功能狀態變化通知 ✅

**目的**：解耦功能狀態變化與 UI 更新

**優化方案**：使用 **CarEventPublisher** 分離通知職責（符合 SRP）

```swift
/// 事件類型定義
enum CarEvent {
    case centralComputerTurnedOn
    case centralComputerTurnedOff
    case engineStarted
    case engineStopped
    case featureEnabled(Feature)
    case featureDisabled(Feature)
    case featuresCascadeDisabled([Feature])
}

/// 觀察者協定
protocol CarEventObserver: AnyObject {
    func carDidChangeState(_ event: CarEvent)
}

/// 專門負責事件發布與觀察者管理 (SRP)
class CarEventPublisher {
    private var observers: [WeakObserver] = []
    
    func addObserver(_ observer: CarEventObserver) { ... }
    func removeObserver(_ observer: CarEventObserver) { ... }
    func publish(_ event: CarEvent) { ... }
}

class Car {
    private let eventPublisher: CarEventPublisher
    
    init(eventPublisher: CarEventPublisher = CarEventPublisher(), ...) {
        self.eventPublisher = eventPublisher
    }
    
    func enableFeature(...) {
        // 業務邏輯
        eventPublisher.publish(.featureEnabled(feature))
    }
}
```

**優點**：
- ✅ **SRP**：Car 專注車輛邏輯，Publisher 專注通知機制
- ✅ **依賴注入**：可注入 mock publisher 進行測試
- ✅ **擴展性**：未來可加入事件過濾、延遲通知、事件日誌等
- ✅ **記憶體安全**：使用 weak reference 避免循環引用

**應用場景**：
- UI 即時更新功能按鈕狀態
- 記錄功能使用日誌
- 觸發功能變化的動畫效果

### 2.3 Repository Pattern - 相依性資料管理 ✅

**目的**：分離相依性定義與驗證邏輯

```swift
protocol DependencyRepository {
    func getDependencyRule(for feature: Feature) -> DependencyRule?
    func getAllDependencyRules() -> [Feature: DependencyRule]
}

// 記憶體實作（目前使用）
class InMemoryDependencyRepository: DependencyRepository {
    private let dependencies: [Feature: DependencyRule]
    
    func getDependencyRule(for feature: Feature) -> DependencyRule? {
        return dependencies[feature]
    }
}

// 未來可擴展：從 JSON/YAML 載入
class ConfigFileDependencyRepository: DependencyRepository {
    init(configPath: String) { ... }
}
```

### 2.4 Builder + Factory Pattern - 車輛配置管理 ⭐

**目的**：支援不同車型配置，移除硬編碼的 components

**當前問題**：
- Car 硬編碼持有 16 個 components
- 無法支援選配（所有車都是全配）
- 違反 OCP：新增功能必須修改 Car 類別
- `setFeatureEnabled()` 的 switch statement 難以維護

**改進方案**：使用 Builder Pattern（自定義配置） + Factory Pattern（預設車型）

```swift
// 1️⃣ 車輛配置
struct CarConfiguration {
    let features: [Feature]
}

// 2️⃣ Builder Pattern - 靈活自定義
class CarConfigurationBuilder {
    private var features: Set<Feature> = []
    
    func add(_ feature: Feature) -> Self {
        features.insert(feature)
        return self
    }
    
    func addAll(_ features: [Feature]) -> Self {
        self.features.formUnion(features)
        return self
    }
    
    func remove(_ feature: Feature) -> Self {
        features.remove(feature)
        return self
    }
    
    func build() -> CarConfiguration {
        CarConfiguration(features: Array(features))
    }
}

// 3️⃣ Factory Pattern - 預設車型配置
extension CarConfiguration {
    static func basic() -> CarConfiguration {
        CarConfigurationBuilder()
            .addAll([.airConditioner, .navigation, .bluetooth])
            .build()
    }
    
    static func luxury() -> CarConfiguration {
        CarConfigurationBuilder()
            .addAll([.airConditioner, .navigation, .bluetooth, 
                     .entertainment, .rearCamera, .surroundView,
                     .blindSpotDetection, .frontRadar, .parkingAssist])
            .build()
    }
    
    static func full() -> CarConfiguration {
        CarConfigurationBuilder()
            .addAll(Feature.allCases)
            .build()
    }
}

// 4️⃣ Car 使用 Dictionary 管理 components
class Car {
    // 移除硬編碼
    // private let airConditioner = AirConditioner() ❌
    
    // 改用 Dictionary
    private var featureComponents: [Feature: ToggleableComponent] = [:]
    
    init(configuration: CarConfiguration = .full(), ...) {
        // 根據配置安裝 components
        configuration.features.forEach { feature in
            featureComponents[feature] = ComponentFactory.create(feature)
        }
    }
    
    private func setFeatureEnabled(_ feature: Feature, enabled: Bool) {
        // 不再需要 switch
        featureComponents[feature]?.isEnabled = enabled
    }
}

// 使用範例
let basicCar = Car(configuration: .basic())
let luxuryCar = Car(configuration: .luxury())
let customCar = Car(configuration: CarConfigurationBuilder()
    .addAll([.airConditioner, .navigation])
    .add(.autoPilot)
    .build()
)
```

**優點**：
- ✅ **支援選配**：不同車型不同配置
- ✅ **符合 OCP**：新增功能不修改 Car 類別
- ✅ **移除 switch statement**：改用 Dictionary lookup
- ✅ **Fluent API**：Builder 提供鏈式呼叫
- ✅ **預設配置**：Factory 提供常用車型
- ✅ **靈活性**：可自由組合功能

**優點3*：
- ✅ 符合 SRP：驗證邏輯與資料儲存分離
- ✅ 可測試性：可注入不同的相依性配置進行測試
- ✅ 彈性：支援不同車型有不同的相依性規則

### 2.4 Factory Pattern - 功能元件創建

**目的**：統一元件創建，避免 Car 類別直接管理 16 個元件實例

```swift
protocol FeatureComponentFactory {
    func createComponent(for feature: Feature) -> FeatureToggleComponent
}

class DefaultFeatureComponentFactory: FeatureComponentFactory {
    func createComponent(for feature: Feature) -> FeatureToggleComponent {
        switch feature {
        case .airConditioner: return AirConditioner()
        case .navigation: return NavigationSystem()
        // ...
        }
    }
}

class Car {
    private let componentFactory: FeatureComponentFactory
    private lazy var components: [Feature: FeatureToggleComponent] = {
        Feature.allCases.reduce(into: [:]) { result, feature in
            result[feature] = componentFactory.createComponent(for: feature)
        }
    }()
}
```

### 2.5 State Pattern - 引擎/中控電腦狀態管理

**目的**：明確定義狀態轉換規則

```swift
protocol ComponentState {
    var isActive: Bool { get }
    func turnOn(context: StatefulComponentContext) -> ComponentState
    func turnOff(context: StatefulComponentContext) -> ComponentState
}

class EngineStoppedState: ComponentState {
    func turnOn(context: StatefulComponentContext) -> ComponentState {
        // 可加入啟動檢查邏輯（如電池電量）
        return EngineRunningState()
    }
}

class EngineRunningState: ComponentState {
    func turnOff(context: StatefulComponentContext) -> ComponentState {
        // 自動停用需要引擎的功能
        context.disableFeaturesRequiringEngine()
        return EngineStoppedState()
    }
}
```

---

## 3. 語意設計優化 ⭐ 核心改進

### 2.1 Available vs Enabled 分離

**目前設計問題**：
```swift
car.enableFeature(.airConditioner)
// 同時做兩件事：
// 1. 檢查條件是否滿足 (available)
// 2. 啟用功能 (enabled)
// 語意混淆
```

**建議改進**：

#### Protocol 設計
```swift
protocol FeatureToggleComponent: CarComponent {
    var feature: Feature { get }
    var isAvailable: Bool { get }  // 條件是否滿足，可被啟用
    var isEnabled: Bool { get set } // 使用者是否主動啟用
}
```

#### API 設計
```swift
// 查詢功能是否可用（條件滿足）
func isFeatureAvailable(_ feature: Feature) -> Bool
4. TDD 測試策略

### 5.1 測試金字塔

```
         ┌─────────────────────┐
         │  Integration Tests  │ 5-10% - Car 整體行為測試
         ├─────────────────────┤
         │   Unit Tests        │ 70-80% - 各個元件、策略、驗證器
         ├─────────────────────┤
         │  Protocol Tests     │ 10-15% - 確保符合 SOLID
         └─────────────────────┘
```

### 4.2 單元測試清單

#### 相依性驗證測試
```swift
class DependencyValidatorTests: XCTestCase {
   6. 重構實作路徑（TDD 方式）

### Phase 1: 建立測試基礎設施 🧪

**目標**：保護現有功能，為重構打下基礎

1. ✅ 定義所有 Protocols（符合 ISP）
   - `DependencyValidating`
   - `DisableStrategy`
   - `DependencyRepository`
   - `FeatureToggleComponent`

2. ✅ 為現有功能撰寫測試
   - 相依性驗證測試（12 個功能）
   - 連鎖停用測試
   - 中控電腦/引擎整合測試

3. ✅ 建立 Mock 物件
   - `MockDependencyValidator`
   - `MockCarEventObserver`
   - `MockDependencyRepository`

**完成標準**：所有現有功能都有測試覆蓋，測試全部通過

---

### Phase 2: 核心重構（符合 SOLID）🔧

**目標**：在測試保護下重構，確保行為不變

1. ✅ Dependency Inversion (DIP)
   - 將 `DependencyValidator` 改為 protocol 注入
   - 將 `DisableStrategy` 抽象化並注入

2. ✅ Single Responsibility (SRP)
   - 提取 `FeatureStateManager` 管理功能狀態
   - 提取 `CascadeDisableHandler` 處理連鎖邏輯

3. ✅ Open/Closed (OCP)
   - 移除 `setFeatureEnabled` 的 switch statement
   - 使用 Dictionary 映射 Feature → Component

4. ✅ Repository Pattern 實作
   - 建立 `InMemoryDependencyRepository`
   - 將相依性規則從 Validator 移到 Repository

**完成標準**：所有測試仍然通過，程式碼符合 SOLID

---

### Phase 3: 語意優化（Available vs Enabled）✨

**目標**：提升 API 語意清晰度

1. ✅ 定義新的 Protocols
   ```swift
   protocol FeatureAvailability {
       var isAvailable: Bool { get }
   }
   
   protocol FeatureToggle {
       var isEnabled: Bool { get set }
   }
   ```

2. ✅ 實作 Availability 計算邏輯
   - 動態檢查相依條件是否滿足
   -🔴 必須實作（Phase 1-2）
1. **TDD 測試基礎設施** - 保護現有功能
2. **依賴注入 (DIP)** - 提升可測試性
3. **職責分離 (SRP)** - 降低複雜度
4. **Repository Pattern** - 分離資料與邏輯

### 🟡 重要改進（Phase 3）
5. **Available vs Enabled 分離** - 核心語意優化
6. **Strategy Pattern** - 連鎖停用邏輯獨立
7. **移除 Switch Statement (OCP)** - 提升擴展性

### 🟢 進階優化（Phase 4，可選）
8. Observer Pattern - 事件通知系統
9. State Pattern - 狀態機管理
10. Factory Pattern - 元件創建統一化
11. 錯誤處理擴充 - 更詳細的錯誤訊息

---

## 8. UI 整合考量 🎨

### 8.1 為什麼重構後加 UI 會很容易？

當前的重構計劃完美支援未來的 UI 開發，原因如下：

#### 1️⃣ **解耦設計** - 業務邏輯與 UI 完全分離

```swift
// ✅ 業務邏輯在 Car 類別（完全獨立，可單元測試）
let car = Car()
car.enableFeature(.airConditioner)

// ✅ UI 只負責：
// - 顯示狀態
// - 處理使用者點擊
// - 訂閱狀態變化
class CarControlViewController: UIViewController {
    private let car = Car()  // 依賴業務邏輯
    private var buttons: [Feature: UIButton] = [:]
}
```

**優點**：
- 業務邏輯可以在沒有 UI 的情況下完整測試
- UI 改版不影響業務邏輯
- 可以輕鬆支援多種 UI（iOS、macOS、watchOS）

---

#### 2️⃣ **Observer Pattern** - 自動 UI 更新

```swift
extension CarControlViewController: CarEventObserver {
    
    // 功能啟用時，UI 自動更新
    func car(_ car: Car, didEnableFeature feature: Feature) {
        updateButton(for: feature, enabled: true)
        showToast("\(feature.displayName) 已開啟 ✅")
    }
    
    // 功能被連鎖停用時，UI 自動更新並提示
    func car(_ car: Car, didDisableFeature feature: Feature, cascaded: Bool) {
        updateButton(for: feature, enabled: false)
        
        if cascaded {
            showToast("\(feature.displayName) 因依賴關閉而自動停用 ⚠️")
        }
    }
    
    // 功能變為可用時（如中控電腦開啟），按鈕變亮
    func car(_ car: Car, featureBecameAvailable feature: Feature) {
        buttons[feature]?.isEnabled = true
        buttons[feature]?.alpha = 1.0
    }
    
    // 功能變為不可用時（如中控電腦關閉），按鈕變灰
    func car(_ car: Car, featureBecameUnavailable feature: Feature) {
        buttons[feature]?.isEnabled = false
        buttons[feature]?.alpha = 0.5
    }
}
```

**優點**：
- ✅ 不需要手動刷新 UI
- ✅ 狀態變化自動同步到所有 Observer
- ✅ 支援多個 UI 元件同時訂閱（如主畫面 + 設定畫面）

---

#### 3️⃣ **Available vs Enabled** - 完美映射 UI 狀態

```swift
private func updateButton(for feature: Feature) {
    guard let button = buttons[feature] else { return }
    
    // Available → 按鈕是否可點擊（灰色 vs 正常）
    let available = car.isFeatureAvailable(feature)
    button.isEnabled = available
    button.alpha = available ? 1.0 : 0.5
    
    // Enabled → 按鈕視覺狀態（已開啟 vs 未開啟）
    let enabled = car.isFeatureEnabled(feature)
    button.backgroundColor = enabled ? .systemGreen : .systemGray
    button.setTitle(enabled ? "✓ \(feature.displayName)" : feature.displayName, for: .normal)
}
```

**UI 狀態對照表**：

| Car 狀態 | available | enabled | 按鈕外觀 | 可點擊 | 說明 |
|---------|-----------|---------|----------|--------|------|
| 1️⃣ | ❌ false | ❌ false | 灰色暗淡 | ❌ | 條件不滿足，無法開啟 |
| 2️⃣ | ✅ true | ❌ false | 正常未選取 | ✅ | 可以開啟，但使用者未啟用 |
| 3️⃣ | ✅ true | ✅ true | 綠色已選取 | ✅ | 正在運作中 |

**優點**：
- ✅ 使用者清楚知道「不能點」vs「可以點但沒開」
- ✅ 避免使用者困惑：「為什麼冷氣按鈕是灰色？」→ 因為中控電腦關閉

---

#### 4️⃣ **錯誤處理** - 友好的使用者提示

```swift
@IBAction func featureButtonTapped(_ sender: UIButton) {
    guard let feature = getFeature(from: sender) else { return }
    
    if car.isFeatureEnabled(feature) {
        // 停用功能
        car.disableFeature(feature)
        
    } else {
        // 啟用功能
        let result = car.enableFeature(feature)
        
        switch result {
        case .success:
            // Observer 會自動更新 UI
            break
            
        case .failure(let error):
            // 顯示友好的錯誤訊息
            switch error {
            case .dependencyNotMet(let feature, let missing):
                showAlert(
                    title: "無法啟用 \(feature.displayName)",
                    message: "需要先啟用：\(missing.joined(separator: "、"))"
                )
                
            case .centralComputerOff:
                showAlert(
                    title: "中控電腦未開啟",
                    message: "請先開啟中控電腦"
                )
                
            case .engineNotRunning:
                showAlert(
                    title: "引擎未啟動",
                    message: "此功能需要引擎運行"
                )
                
            default:
                showAlert(title: "錯誤", message: error.localizedDescription)
            }
        }
    }
}
```

---

### 8.2 UI 狀態流程圖

```
【初始狀態】中控電腦關閉
┌─────────────────────────────────────┐
│  功能控制面板                        │
├─────────────────────────────────────┤
│  中控電腦：❌ OFF                    │
│  引擎：    ❌ 停止                   │
├─────────────────────────────────────┤
│  [  冷氣系統  ] 🚫 灰色不可點        │ ← unavailable
│  [  導航系統  ] 🚫 灰色不可點        │ ← unavailable  
│  [  自動駕駛  ] 🚫 灰色不可點        │ ← unavailable
└─────────────────────────────────────┘

          ⬇ 使用者點擊：開啟中控電腦
          ⬇ Observer 收到通知：featureBecameAvailable

【中控電腦開啟】
┌─────────────────────────────────────┐
│  功能控制面板                        │
├─────────────────────────────────────┤
│  中控電腦：✅ ON                     │
│  引擎：    ❌ 停止                   │
├─────────────────────────────────────┤
│  [  冷氣系統  ] 💡 可點擊            │ ← available, not enabled
│  [  導航系統  ] 💡 可點擊            │ ← available, not enabled
│  [  自動駕駛  ] 🚫 灰色不可點        │ ← unavailable (需要引擎)
└─────────────────────────────────────┘

          ⬇ 使用者點擊：冷氣系統
          ⬇ Observer 收到通知：didEnableFeature

【冷氣開啟】
┌─────────────────────────────────────┐
│  [✓ 冷氣系統 ] ✅ 綠色已開啟         │ ← available & enabled
│  [  導航系統  ] 💡 可點擊            │
│  [  自動駕駛  ] 🚫 灰色不可點        │
└─────────────────────────────────────┘
          Toast: "冷氣系統 已開啟 ✅"

          ⬇ 使用者點擊：關閉中控電腦
          ⬇ Observer 收到通知：didDisableFeature (cascaded: true)

【中控電腦關閉 - 連鎖停用】
┌─────────────────────────────────────┐
│  中控電腦：❌ OFF                    │
│  引擎：    ❌ 停止                   │
├─────────────────────────────────────┤
│  [  冷氣系統  ] 🚫 灰色不可點        │ ← 自動變 unavailable + disabled
│  [  導航系統  ] 🚫 灰色不可點        │
│  [  自動駕駛  ] 🚫 灰色不可點        │
└─────────────────────────────────────┘
          Toast: "冷氣系統 因依賴關閉而自動停用 ⚠️"
```

---

### 8.3 UI 實作範例（完整版）

```swift
class CarControlViewController: UIViewController {
    
    // MARK: - Properties
    
    private let car = Car()  // 重構後的 Car，符合 SOLID
    private var featureButtons: [Feature: UIButton] = [:]
    
    // MARK: - UI Components
    
    @IBOutlet weak var centralComputerSwitch: UISwitch!
    @IBOutlet weak var engineSwitch: UISwitch!
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 訂閱 Car 的狀態變化
        car.addObserver(self)
        
        // 初始化所有按鈕狀態
        updateAllButtons()
        updateStatusLabel()
    }
    
    // MARK: - Actions
    
    @IBAction func centralComputerSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            car.turnOnCentralComputer()
        } else {
            car.turnOffCentralComputer()
        }
        updateStatusLabel()
    }
    
    @IBAction func engineSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            car.startEngine()
        } else {
            car.stopEngine()
        }
        updateStatusLabel()
    }
    
    @IBAction func featureButtonTapped(_ sender: UIButton) {
        guard let feature = getFeature(from: sender) else { return }
        
        if car.isFeatureEnabled(feature) {
            car.disableFeature(feature)
        } else {
            let result = car.enableFeature(feature)
            handleEnableResult(result, for: feature)
        }
    }
    
    // MARK: - UI Updates
    
    private func updateAllButtons() {
        for feature in Feature.allCases {
            updateButton(for: feature)
        }
    }
    
    private func updateButton(for feature: Feature) {
        guard let button = featureButtons[feature] else { return }
        
        let available = car.isFeatureAvailable(feature)
        let enabled = car.isFeatureEnabled(feature)
        
        // 設定可點擊狀態
        button.isEnabled = available
        button.alpha = available ? 1.0 : 0.5
        
        // 設定視覺狀態
        button.backgroundColor = enabled ? .systemGreen : .systemGray4
        let title = enabled ? "✓ \(feature.displayName)" : feature.displayName
        button.setTitle(title, for: .normal)
    }
    
    private func updateStatusLabel() {
        let computerStatus = car.isCentralComputerOn ? "ON 💻" : "OFF"
        let engineStatus = car.isEngineRunning ? "RUNNING 🏃" : "STOPPED"
        let enabledCount = car.getEnabledFeatures().count
        
        statusLabel.text = """
        中控電腦: \(computerStatus)
        引擎: \(engineStatus)
        已啟用功能: \(enabledCount) 個
        """
    }
    
    private func handleEnableResult(_ result: Result<Void, FeatureError>, for feature: Feature) {
        switch result {
        case .success:
            break  // Observer 會自動更新
            
        case .failure(let error):
            showErrorAlert(for: error, feature: feature)
        }
    }
    
    private func showErrorAlert(for error: FeatureError, feature: Feature) {
        let alert: (title: String, message: String)
        
        switch error {
        case .dependencyNotMet(_, let missing):
            alert = (
                title: "無法啟用 \(feature.displayName)",
                message: "需要先啟用：\n\(missing.joined(separator: "\n"))"
            )
            
        case .centralComputerOff:
            alert = (
                title: "中控電腦未開啟",
                message: "請先開啟中控電腦"
            )
            
        case .engineNotRunning:
            alert = (
                title: "引擎未啟動",
                message: "此功能需要引擎運行"
            )
            
        default:
            alert = (
                title: "錯誤",
                message: error.localizedDescription
            )
        }
        
        let alertController = UIAlertController(
            title: alert.title,
            message: alert.message,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "確定", style: .default))
        present(alertController, animated: true)
    }
}

// MARK: - CarEventObserver

extension CarControlViewController: CarEventObserver {
    
    func car(_ car: Car, didEnableFeature feature: Feature) {
        updateButton(for: feature)
        updateStatusLabel()
        showToast("✅ \(feature.displayName) 已開啟", duration: 2.0)
    }
    
    func car(_ car: Car, didDisableFeature feature: Feature, cascaded: Bool) {
        updateButton(for: feature)
        updateStatusLabel()
        
        let message = cascaded
            ? "⚠️ \(feature.displayName) 因依賴關閉而自動停用"
            : "🔴 \(feature.displayName) 已關閉"
        
        showToast(message, duration: 2.0)
    }
    
    func car(_ car: Car, featureBecameAvailable feature: Feature) {
        updateButton(for: feature)
    }
    
    func car(_ car: Car, featureBecameUnavailable feature: Feature) {
        updateButton(for: feature)
    }
}
```

---

### 8.4 UI 整合的關鍵優勢

| 優勢 | 重構前 | 重構後 |
|------|--------|--------|
| **UI 更新** | 需手動刷新所有相關按鈕 | Observer 自動通知 |
| **狀態同步** | 容易不一致 | 自動同步到所有 Observer |
| **錯誤提示** | 只有 print | 結構化錯誤 + UI 提示 |
| **按鈕狀態** | 只有 on/off | available + enabled 雙狀態 |
| **連鎖停用提示** | 無提示 | 自動顯示 Toast |
| **測試** | 需要 UI 測試 | 業務邏輯可獨立測試 |

---

### 8.5 未來擴展性

重構後的架構支援：

1. **多平台 UI**
   - iOS App
   - watchOS App  
   - macOS App
   - SwiftUI 版本
   
2. **多種互動方式**
   - 語音控制（Siri）
   - Widget
   - Today Extension
   
3. **遠端控制**
   - 透過網路 API 控制
   - Car 的狀態變化透過 Observer 同步到 UI

**所有這些都不需要修改核心業務邏輯！**

---

## 9. 設計決策總結

### ✅ 已確認
- **停用策略**：連鎖停用（符合真實車輛行為）
- **開發方法**：TDD（測試驅動開發）
- **設計原則**：SOLID 五大原則
- **主要模式**：Strategy、Repository、Observer

### 📋 待實作
- Phase 1: 測試基礎設施
- Phase 2: SOLID 重構
- Phase 3: 語意優化
- Phase 4: 進階功能（可選）

### 🎯 預期效果
- ✅ **可測試性**：100% 單元測試覆蓋率
- ✅ **可維護性**：職責清晰，易於修改
- ✅ **可擴展性**：新增功能不需修改現有程式碼
- ✅ **語意清晰**：Available vs Enabled 明確區分
- ✅ **符合 SOLID**：每個類別職責單一，依賴抽象而非實作_ car: Car, didDisableFeature feature: Feature, cascaded: Bool) {
        disabledFeatures.append((feature, cascaded))
    }
}
```

### 4.4 TDD 開發流程

```
1. 🔴 RED: 寫一個失敗的測試
   └─ 例如：testAutoPilot_RequiresThreeFeatures()

2. 🟢 GREEN: 寫最少的程式碼讓測試通過
   └─ 在 DependencyValidator 中加入規則

3. 🔵 REFACTOR: 重構以符合 SOLID
   └─ 提取到 DependencyRepository

4. 重複步驟 1-3
```

---

## 5
// 取得所有可用功能列表
func getAvailableFeatures() -> [Feature]

// 啟用功能（只有 available 的才能 enable）
func enableFeature(_ feature: Feature) -> Result<Void, FeatureError>
```

#### 使用情境
```swift
// 情境 1: 中控關閉
car.isFeatureAvailable(.airConditioner)  // false
car.enableFeature(.airConditioner)       // 失敗

// 情境 2: 中控開啟，但使用者未啟用
car.turnOnCentralComputer()
car.isFeatureAvailable(.airConditioner)  // true (條件滿足)
car.isFeatureEnabled(.airConditioner)    // false (使用者未啟用)

// 情境 3: 使用者啟用
car.enableFeature(.airConditioner)
car.isFeatureAvailable(.airConditioner)  // true
car.isFeatureEnabled(.airConditioner)    // true (正在運作)

// 情境 4: 中控關閉，自動變 unavailable
car.turnOffCentralComputer()
car.isFeatureAvailable(.airConditioner)  // false (條件不滿足)
car.isFeatureEnabled(.airConditioner)    // false (自動停用)
```

#### 優點
- ✅ 語意清晰：available = 可以用，enabled = 正在用
- ✅ UI 提示：可顯示「此功能現在可以啟用」
- ✅ 錯誤訊息更明確：「功能不可用」vs「啟用失敗」
- ✅ 狀態管理更精確

#### 實作重點
```swift
class Car {
    // 動態計算 available 狀態
    func updateAvailability() {
        for feature in Feature.allCases {
            let result = dependencyValidator.validateEnable(
                feature: feature,
                centralComputerOn: centralComputer.isActive,
                engineRunning: engine.isActive,
                enabledFeatures: enabledFeatures
            )
            
            if case .success = result {
                // 條件滿足 → available
            } else {
                // 條件不滿足 → unavailable
                // 如果之前已啟用，自動停用
                if enabledFeatures.contains(feature) {
                    disableFeatureQuietly(feature)
                }
            }
        }
    }
}
```

---

## 3. 錯誤處理擴充

### 3.1 更詳細的 FeatureError

**建議擴充**：
```swift
enum FeatureError: Error {
    case dependencyNotMet(feature: Feature, missingDependencies: [String])
    case cannotDisable(feature: Feature, dependentFeatures: [Feature])
    case componentNotAvailable(component: String)
    case featureNotAvailable(feature: Feature, reason: String)  // 新增
    case centralComputerOff
    case engineNotRunning
    case conflictingFeatures(feature: Feature, conflicts: [Feature])  // 新增
}
```

---

## 4. 事件通知系統

### 4.1 Observer Pattern

**目前問題**：
- 功能被連鎖停用時，只有 print 輸出
- 外部無法監聽狀態變化

**建議**：
```swift
protocol CarEventDelegate: AnyObject {
    func car(_ car: Car, didEnableFeature feature: Feature)
    func car(_ car: Car, didDisableFeature feature: Feature)
    func car(_ car: Car, featureBecameAvailable feature: Feature)
    func car(_ car: Car, featureBecameUnavailable feature: Feature)
}
```

---

## 5. 狀態機模式

**建議**：
- 使用狀態機管理 Engine/CentralComputer 狀態
- 明確定義狀態轉換規則

```swift
enum EngineState {
    case stopped
    case starting
    case running
    case stopping
}
```

---

## 6. 測試性改進

### 6.1 依賴注入

**目前**：
```swift
class Car {
    private let dependencyValidator = DependencyValidator()  // 硬編碼
}
```

**建議**：
```swift
class Car {
    private let dependencyValidator: DependencyValidating
    
    init(dependencyValidator: DependencyValidating = DependencyValidator()) {
        self.dependencyValidator = dependencyValidator
    }
}
```

**優點**：
- 可注入 Mock 進行測試
- 更易於單元測試

---

## 實作優先順序

### 高優先級 🔴
1. **Available vs Enabled 分離** - 改善核心語意
2. 錯誤處理擴充 - 更好的使用者體驗

### 中優先級 🟡
3. 停用策略模式 - 增加彈性
4. 事件通知系統 - 支援 UI 整合

### 低優先級 🟢
5. 相依性設定檔化 - 易於維護
6. 狀態機模式 - 更嚴謹的狀態管理
7. 依賴注入 - 提升測試性

---

## 總結

目前實作已完整符合 monster1.md 規格，所有核心功能正常運作。

上述優化建議著重於：
- **語意清晰度**（available vs enabled）
- **架構彈性**（策略模式、依賴注入）
- **可維護性**（設定檔化、事件系統）
- **使用者體驗**（更好的錯誤訊息、狀態提示）

可根據實際需求選擇性實作。

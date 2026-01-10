# Code Monster #1 優化建議

## 當前實作狀態

基於 monster1.md 規格的基礎實作已完成，所有功能正常運作。以下是未來可優化的方向。

---

## 1. 架構改進建議

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

### 1.2 停用策略模式

**目前實作**：
- 採用「方案 B」連鎖停用

**建議**：使用策略模式，支援動態切換
```swift
protocol DisableStrategy {
    func disable(_ feature: Feature, in car: Car) -> Result<Void, FeatureError>
}

class CascadeDisableStrategy: DisableStrategy { ... }  // 連鎖停用
class BlockDisableStrategy: DisableStrategy { ... }    // 拒絕停用
```

### 1.3 相依性定義方式

**目前實作**：
- 相依性在 `DependencyValidator` 中硬編碼

**建議改進**：
```swift
// 使用設定檔或 DSL 定義
let dependencies = [
    .airConditioner: [.centralComputer],
    .autoPilot: [.laneKeeping, .emergencyBraking, .surroundView]
]
```

**優點**：
- 更易維護
- 可動態載入不同配置
- 易於測試不同相依關係

---

## 2. 語意設計優化 ⭐ NEW

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

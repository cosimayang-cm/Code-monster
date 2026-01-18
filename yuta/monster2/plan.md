# 計畫：簡化 Monster2 Popup Response Chain 架構

**Feature**: [spec.md](./spec.md)
**Created**: 2025-01-18
**Updated**: 2025-01-18
**Pattern**: Chain of Responsibility（簡化版）

---

## 問題分析

### 當前架構層次統計

**核心組件數量：**
- 4 個 Protocol（PopupHandling, PopupPresenting, PopupViewController, PredictionServiceProtocol）
- 6 個 Handler（BasePopupHandler + 5 個具體 Handler）
- 5 個 ViewController
- 2 個 Manager（PopupChainManager, UserStateManager）
- 1 個 Builder（UserContextBuilder）
- 1 個 Presenter（PopupPresenter）
- 1 個 Service（MockPredictionService）
- 2 個 Model（UserContext, PopupChainError）

**總計：22 個類別/結構**

### 作業原始要求回顧

根據 `monster2.md` 的設計要求：
1. 定義 Protocol（處理器介面）
2. 實作各種 Handler（5 個彈窗處理器）
3. 串接 Handler Chain
4. 建立 Manager（組裝 chain）
5. 可擴展性

**作業核心需求：Chain of Responsibility 模式 + 5 個彈窗**

### 過度設計的組件

#### ❌ 不必要的抽象層（針對學習作業）：

1. **PopupPresenter**
   - 原因：作業重點是 Chain 邏輯，不是 UI 呈現
   - 影響：增加 1 個 Protocol + 1 個類別

2. **UserContextBuilder**
   - 原因：UserContext 只是簡單的 5 個布林值結構
   - 影響：增加非同步複雜度、逾時處理

3. **PredictionServiceProtocol + MockPredictionService**
   - 原因：作業不需要真實的網路查詢
   - 影響：增加 1 個 Protocol + 1 個類別

4. **PopupViewController Protocol**
   - 原因：5 個 ViewController 可以直接實作，不需要共用協定
   - 影響：增加 1 個 Protocol

5. **UserStateManager**
   - 原因：UserDefaults 可以直接在 Handler 中使用
   - 影響：增加 1 個類別

6. **SafeUserContextBuilder + 完整錯誤處理**
   - 原因：作業環境不需要生產級錯誤處理
   - 影響：增加複雜度

7. **5 個完整的 ViewController**
   - 原因：作業重點是 Chain 邏輯，UI 可以用 print() 模擬
   - 影響：增加 5 個類別 + UIKit 依賴

---

## 簡化方案：最小化設計（方案 A）

### 保留組件

1. PopupHandling Protocol
2. BasePopupHandler
3. 5 個具體 Handler（簡化版，使用 print()）
4. PopupChainManager（外部注入版）
5. UserContext struct

**總計：9 個檔案（vs 原本 22 個類別）**

### 移除組件

- PopupPresenter + PopupPresenting Protocol
- UserContextBuilder
- PredictionServiceProtocol + MockPredictionService
- PopupViewController Protocol
- UserStateManager
- 5 個 ViewController
- SafeUserContextBuilder
- PopupChainError enum

---

## 檔案結構

```
Sources/
├── Protocols/
│   └── PopupHandling.swift
├── Handlers/
│   ├── BasePopupHandler.swift
│   ├── TutorialHandler.swift
│   ├── InterstitialAdHandler.swift
│   ├── NewFeatureHandler.swift
│   ├── DailyCheckInHandler.swift
│   └── PredictionResultHandler.swift
├── Models/
│   └── UserContext.swift
└── PopupChainManager.swift
```

---

## 核心組件實作

### 1. PopupHandling.swift

```swift
import Foundation

/// 彈窗處理協定，定義責任鏈的核心行為
/// 每個處理器可以選擇處理請求或傳遞給下一個處理器
protocol PopupHandling: AnyObject {
    /// 鏈中的下一個處理器
    var next: PopupHandling? { get set }

    /// 判斷此處理器是否應該處理當前的使用者上下文
    /// - Parameter context: 當前使用者上下文
    /// - Returns: 如果應該處理則返回 true，否則返回 false
    func shouldHandle(_ context: UserContext) -> Bool

    /// 處理請求或傳遞給下一個處理器
    /// - Parameters:
    ///   - context: 當前使用者上下文
    ///   - completion: 處理完成後的回調
    func handle(_ context: UserContext, completion: @escaping () -> Void)
}

// MARK: - 預設實作

extension PopupHandling {
    /// 設定鏈中的下一個處理器
    /// - Parameter handler: 下一個處理器
    /// - Returns: 返回傳入的處理器，支援鏈式呼叫
    @discardableResult
    func setNext(_ handler: PopupHandling) -> PopupHandling {
        next = handler
        return handler
    }
}
```

### 2. BasePopupHandler.swift

```swift
import Foundation

/// 提供預設責任鏈行為的抽象基礎類別
class BasePopupHandler: PopupHandling {

    // MARK: - 屬性

    weak var next: PopupHandling?

    // MARK: - PopupHandling

    func shouldHandle(_ context: UserContext) -> Bool {
        fatalError("子類別必須覆寫 shouldHandle(_:)")
    }

    func handle(_ context: UserContext, completion: @escaping () -> Void) {
        if shouldHandle(context) {
            showPopup { [weak self] in
                self?.passToNext(context, completion: completion)
            }
        } else {
            passToNext(context, completion: completion)
        }
    }

    // MARK: - 抽象方法

    /// 向使用者顯示彈窗（子類別必須覆寫）
    /// - Parameter completion: 彈窗關閉時呼叫的回調
    func showPopup(completion: @escaping () -> Void) {
        fatalError("子類別必須覆寫 showPopup(completion:)")
    }

    // MARK: - 私有方法

    private func passToNext(_ context: UserContext, completion: @escaping () -> Void) {
        guard let next = next else {
            completion()
            return
        }
        next.handle(context, completion: completion)
    }
}
```

### 3. UserContext.swift

```swift
import Foundation

/// 表示當前使用者的狀態，用於彈窗決策
struct UserContext {
    var hasSeenTutorial: Bool
    var hasSeenInterstitialAd: Bool
    var hasSeenNewFeature: Bool
    var hasCheckedInToday: Bool
    var hasPredictionResult: Bool
}
```

### 4. 具體 Handler 實作

#### TutorialHandler.swift

```swift
import Foundation

/// 處理新手教學彈窗的顯示邏輯
final class TutorialHandler: BasePopupHandler {

    // MARK: - PopupHandling

    override func shouldHandle(_ context: UserContext) -> Bool {
        return !context.hasSeenTutorial
    }

    override func showPopup(completion: @escaping () -> Void) {
        print("[彈窗] 新手教學")
        // 模擬使用者看完教學
        UserDefaults.standard.set(true, forKey: "hasSeenTutorial")
        completion()
    }
}
```

#### InterstitialAdHandler.swift

```swift
import Foundation

/// 處理插頁式廣告彈窗的顯示邏輯
final class InterstitialAdHandler: BasePopupHandler {

    // MARK: - PopupHandling

    override func shouldHandle(_ context: UserContext) -> Bool {
        return !context.hasSeenInterstitialAd
    }

    override func showPopup(completion: @escaping () -> Void) {
        print("[彈窗] 插頁式廣告")
        UserDefaults.standard.set(true, forKey: "hasSeenInterstitialAd")
        completion()
    }
}
```

#### NewFeatureHandler.swift

```swift
import Foundation

/// 處理新功能公告彈窗的顯示邏輯
final class NewFeatureHandler: BasePopupHandler {

    // MARK: - PopupHandling

    override func shouldHandle(_ context: UserContext) -> Bool {
        return !context.hasSeenNewFeature
    }

    override func showPopup(completion: @escaping () -> Void) {
        print("[彈窗] 新功能公告")
        UserDefaults.standard.set(true, forKey: "hasSeenNewFeature")
        completion()
    }
}
```

#### DailyCheckInHandler.swift

```swift
import Foundation

/// 處理每日簽到彈窗的顯示邏輯
final class DailyCheckInHandler: BasePopupHandler {

    // MARK: - PopupHandling

    override func shouldHandle(_ context: UserContext) -> Bool {
        return !context.hasCheckedInToday
    }

    override func showPopup(completion: @escaping () -> Void) {
        print("[彈窗] 每日簽到")
        // 標記今日已簽到
        UserDefaults.standard.set(Date(), forKey: "lastCheckInDate")
        completion()
    }
}
```

#### PredictionResultHandler.swift

```swift
import Foundation

/// 處理猜多空結果彈窗的顯示邏輯
final class PredictionResultHandler: BasePopupHandler {

    // MARK: - PopupHandling

    override func shouldHandle(_ context: UserContext) -> Bool {
        return context.hasPredictionResult
    }

    override func showPopup(completion: @escaping () -> Void) {
        print("[彈窗] 猜多空結果")
        completion()
    }
}
```

### 5. PopupChainManager.swift

```swift
import Foundation

/// 管理彈窗處理器鏈的執行
/// 注意：Manager 不知道具體有哪些 Handler，透過外部注入保持職責單一
final class PopupChainManager {

    // MARK: - 屬性

    private let firstHandler: PopupHandling?

    // MARK: - 初始化

    /// 從外部注入 Handler 列表並組裝成鏈
    /// - Parameter handlers: 依優先順序排列的 Handler 陣列
    init(handlers: [PopupHandling]) {
        guard !handlers.isEmpty else {
            self.firstHandler = nil
            return
        }

        // 依序串接成鏈
        for i in 0..<handlers.count - 1 {
            handlers[i].setNext(handlers[i + 1])
        }

        self.firstHandler = handlers.first
    }

    // MARK: - 公開方法

    /// 開始執行彈窗鏈的檢查流程
    /// - Parameters:
    ///   - context: 當前使用者上下文
    ///   - completion: 鏈執行完成時呼叫的回調
    func startChain(with context: UserContext, completion: @escaping () -> Void) {
        firstHandler?.handle(context, completion: completion) ?? completion()
    }
}
```

---

## 使用方式

### 基本使用範例

```swift
import Foundation

// 1. 組裝 Handler 列表（在 AppDelegate 或 SceneDelegate 中）
let popupHandlers: [PopupHandling] = [
    TutorialHandler(),
    InterstitialAdHandler(),
    NewFeatureHandler(),
    DailyCheckInHandler(),
    PredictionResultHandler()
]

// 2. 建立 Manager（注入 handlers）
let popupManager = PopupChainManager(handlers: popupHandlers)

// 3. 輔助函數：檢查今日是否已簽到
func checkIfTodayCheckedIn() -> Bool {
    guard let lastCheckInDate = UserDefaults.standard.object(forKey: "lastCheckInDate") as? Date else {
        return false
    }
    return Calendar.current.isDateInToday(lastCheckInDate)
}

// 4. 建立 context
let context = UserContext(
    hasSeenTutorial: UserDefaults.standard.bool(forKey: "hasSeenTutorial"),
    hasSeenInterstitialAd: UserDefaults.standard.bool(forKey: "hasSeenInterstitialAd"),
    hasSeenNewFeature: UserDefaults.standard.bool(forKey: "hasSeenNewFeature"),
    hasCheckedInToday: checkIfTodayCheckedIn(),
    hasPredictionResult: false  // 簡化為固定值，實際專案可從 API 查詢
)

// 5. 啟動鏈
popupManager.startChain(with: context) {
    print("✅ 彈窗檢查完成")
}
```

### 預期輸出（首次開啟 App）

```
[彈窗] 新手教學
[彈窗] 插頁式廣告
[彈窗] 新功能公告
[彈窗] 每日簽到
✅ 彈窗檢查完成
```

---

## 測試

### Handler 單元測試範例

```swift
import XCTest

final class TutorialHandlerTests: XCTestCase {
    private var sut: TutorialHandler!

    override func setUp() {
        super.setUp()
        sut = TutorialHandler()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testShouldHandle_WhenTutorialNotSeen_ReturnsTrue() {
        // Given
        let context = UserContext(
            hasSeenTutorial: false,
            hasSeenInterstitialAd: true,
            hasSeenNewFeature: true,
            hasCheckedInToday: true,
            hasPredictionResult: false
        )

        // When
        let result = sut.shouldHandle(context)

        // Then
        XCTAssertTrue(result)
    }

    func testShouldHandle_WhenTutorialAlreadySeen_ReturnsFalse() {
        // Given
        let context = UserContext(
            hasSeenTutorial: true,
            hasSeenInterstitialAd: true,
            hasSeenNewFeature: true,
            hasCheckedInToday: true,
            hasPredictionResult: false
        )

        // When
        let result = sut.shouldHandle(context)

        // Then
        XCTAssertFalse(result)
    }
}
```

### 整合測試範例

```swift
import XCTest

final class ChainIntegrationTests: XCTestCase {
    private var manager: PopupChainManager!

    override func setUp() {
        super.setUp()
        // 組裝測試用的 Handler 鏈
        let handlers: [PopupHandling] = [
            TutorialHandler(),
            InterstitialAdHandler(),
            NewFeatureHandler(),
            DailyCheckInHandler(),
            PredictionResultHandler()
        ]
        manager = PopupChainManager(handlers: handlers)
    }

    override func tearDown() {
        manager = nil
        super.tearDown()
    }

    func testStartChain_WhenAllConditionsMet_ShowsAllPopupsInOrder() {
        // Given
        let context = UserContext(
            hasSeenTutorial: false,
            hasSeenInterstitialAd: false,
            hasSeenNewFeature: false,
            hasCheckedInToday: false,
            hasPredictionResult: true
        )
        let expectation = expectation(description: "鏈執行完成")

        // When
        manager.startChain(with: context) {
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)
        // 驗證所有 5 個彈窗都顯示（檢查 console 輸出）
    }

    func testStartChain_WhenNoConditionsMet_CompletesImmediately() {
        // Given
        let context = UserContext(
            hasSeenTutorial: true,
            hasSeenInterstitialAd: true,
            hasSeenNewFeature: true,
            hasCheckedInToday: true,
            hasPredictionResult: false
        )
        let expectation = expectation(description: "鏈執行完成")

        // When
        manager.startChain(with: context) {
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)
        // 驗證沒有彈窗顯示（console 無輸出）
    }

    func testStartChain_WithEmptyHandlers_CompletesImmediately() {
        // Given
        let emptyManager = PopupChainManager(handlers: [])
        let context = UserContext(
            hasSeenTutorial: false,
            hasSeenInterstitialAd: false,
            hasSeenNewFeature: false,
            hasCheckedInToday: false,
            hasPredictionResult: false
        )
        let expectation = expectation(description: "鏈執行完成")

        // When
        emptyManager.startChain(with: context) {
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)
        // 驗證空鏈也能正常完成
    }
}
```

---

## 與作業要求的對照

| 作業要求 | 方案 A 是否滿足 |
|---------|----------------|
| 1. 定義 Protocol | ✅ PopupHandling |
| 2. 實作各種 Handler | ✅ 5 個具體 Handler |
| 3. 串接 Handler Chain | ✅ setNext() |
| 4. 建立 Manager | ✅ PopupChainManager |
| 5. 可擴展性 | ✅ 新增 Handler 不需修改現有代碼 |

**結論：方案 A 完全滿足作業要求，且更聚焦於核心學習目標。**

---

## 架構討論：Manager 的職責

### 關鍵決策：外部注入 Handlers（推薦）

```swift
final class PopupChainManager {
    private let firstHandler: PopupHandling?

    // 從外部注入已組裝好的 handlers
    init(handlers: [PopupHandling]) {
        guard !handlers.isEmpty else {
            self.firstHandler = nil
            return
        }

        for i in 0..<handlers.count - 1 {
            handlers[i].setNext(handlers[i + 1])
        }

        self.firstHandler = handlers.first
    }

    func startChain(with context: UserContext, completion: @escaping () -> Void) {
        firstHandler?.handle(context, completion: completion) ?? completion()
    }
}

// 使用時（在 AppDelegate 或測試中）
let popupManager = PopupChainManager(handlers: [
    TutorialHandler(),
    InterstitialAdHandler(),
    NewFeatureHandler(),
    DailyCheckInHandler(),
    PredictionResultHandler()
])
```

**優點：**
- ✅ Manager 完全不知道有哪些 Handler
- ✅ 易於測試（可注入 Mock Handlers）
- ✅ 符合單一職責原則
- ✅ Handler 列表可以輕易調整順序或增減

**職責邊界：**
- Manager 不決定「是否顯示」（Handler.shouldHandle）
- Manager 不處理「顯示內容」（Handler.showPopup）
- Manager 只負責「組裝順序」和「執行流程」

---

## 擴展性範例

新增第 6 個 Handler 只需：

```swift
/// 新處理器：評分提示
final class RatingPromptHandler: BasePopupHandler {
    override func shouldHandle(_ context: UserContext) -> Bool {
        return context.shouldShowRatingPrompt
    }

    override func showPopup(completion: @escaping () -> Void) {
        print("[彈窗] 評分提示")
        completion()
    }
}

// 使用時只需加入陣列
let popupHandlers: [PopupHandling] = [
    TutorialHandler(),
    InterstitialAdHandler(),
    NewFeatureHandler(),
    DailyCheckInHandler(),
    PredictionResultHandler(),
    RatingPromptHandler()  // 新增
]

// 現有的處理器和 Manager 不需要任何修改！
```

---

## Implementation Checklist

### 核心組件
- [ ] 建立 PopupHandling protocol
- [ ] 建立 BasePopupHandler
- [ ] 建立 UserContext model
- [ ] 建立 PopupChainManager（外部注入版）

### Handler 實作
- [ ] 實作 TutorialHandler
- [ ] 實作 InterstitialAdHandler
- [ ] 實作 NewFeatureHandler
- [ ] 實作 DailyCheckInHandler
- [ ] 實作 PredictionResultHandler

### 測試
- [ ] 撰寫 Handler 單元測試
- [ ] 撰寫鏈整合測試
- [ ] 驗證可擴展性（新增第 6 個 handler）

### 文件
- [ ] 更新 README.md 使用說明
- [ ] 加入架構圖解

---

## 最終設計優勢

1. **聚焦學習目標**
   - 從 22 個類別降到 9 個檔案
   - 核心是 Chain of Responsibility 模式
   - 不被周邊設施分散注意力

2. **保持可擴展性**
   - 依然可以輕易新增第 6、7 個 Handler
   - Chain 組裝邏輯清晰
   - 符合開放封閉原則

3. **測試更簡單**
   - 不需要 Mock UI 元件
   - 測試重點在 shouldHandle 和 Chain 流程
   - 整合測試直接驗證 console 輸出

4. **符合單一職責**
   - Manager 只負責組裝和執行
   - Handler 只負責判斷和顯示
   - UserContext 只是數據載體

**適用場景：Code Monster 學習作業**

如果是實際生產專案，可根據需求逐步加入：
- UserStateManager（統一狀態管理）
- PopupPresenter（UI 呈現層）
- 完整的 ViewController
- 錯誤處理機制
- 異步服務整合

但對於學習 Chain of Responsibility 模式，這個簡化版本已經完全足夠。

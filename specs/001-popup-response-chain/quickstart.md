# Quickstart: Popup Response Chain System

**Date**: 2026-01-16
**Feature**: 001-popup-response-chain

---

## Overview

本文件提供彈窗連鎖顯示系統的快速入門指南，包含基本使用方式和測試範例。

---

## 基本使用

### 1. 建立依賴

```swift
// 建立狀態儲存庫
let repository = UserDefaultsPopupStateRepository()

// 建立日誌記錄器
let logger = ConsoleLogger()

// 建立彈窗呈現器（可選，nil = 僅記錄不顯示）
let presenter = AlertPopupPresenter()
```

### 2. 建立用戶資訊

```swift
// 從你的認證系統取得用戶資訊
let userInfo = UserInfo(
    memberId: currentUser.id,
    hasSeenTutorial: currentUser.hasCompletedOnboarding,
    hasSeenAd: false,
    hasSeenNewFeature: false,
    lastCheckInDate: currentUser.lastCheckIn,
    hasPredictionResult: predictionService.hasUnreadResult
)
```

### 3. 建立並啟動彈窗鏈

```swift
// 建立執行上下文
let context = PopupContext(
    userInfo: userInfo,
    stateRepository: repository,
    presenter: presenter,
    logger: logger
)

// 建立管理器
let manager = PopupChainManager(context: context)

// 啟動彈窗鏈（通常在 App 啟動時呼叫）
manager.startPopupChain()
```

### 4. 整合到 App 生命週期

```swift
// SceneDelegate.swift
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    private var popupCoordinator: PopupChainCoordinator?

    func sceneDidBecomeActive(_ scene: UIScene) {
        popupCoordinator?.triggerIfNeeded()
    }
}

// PopupChainCoordinator.swift
class PopupChainCoordinator {
    private var hasTriggeredThisSession = false
    private let manager: PopupChainManager

    func triggerIfNeeded() {
        guard !hasTriggeredThisSession else { return }
        hasTriggeredThisSession = true
        manager.startPopupChain()
    }
}
```

---

## 監聽事件

```swift
class MyViewController: UIViewController, PopupEventObserver {

    override func viewDidLoad() {
        super.viewDidLoad()
        popupEventPublisher.addObserver(self)
    }

    func popupChain(didPublish event: PopupEvent) {
        switch event {
        case .popupWillShow(let type):
            print("即將顯示: \(type.displayName)")
        case .popupDidShow(let type):
            print("已顯示: \(type.displayName)")
        case .popupDidDismiss(let type):
            print("已關閉: \(type.displayName)")
        case .chainCompleted:
            print("彈窗鏈已完成")
        default:
            break
        }
    }
}
```

---

## 測試範例

### 單元測試：Handler 邏輯

```swift
func testTutorialHandler_WhenNotSeen_ShowsPopup() {
    // Given
    let repository = InMemoryPopupStateRepository()
    let presenter = MockPopupPresenter()
    let context = PopupContext(
        userInfo: .newUser,
        stateRepository: repository,
        presenter: presenter,
        logger: MockLogger()
    )
    let handler = TutorialPopupHandler()

    // When
    let result = handler.handle(context: context)

    // Then
    XCTAssertEqual(result, .success(.shown(.tutorial)))
    XCTAssertEqual(presenter.presentedTypes, [.tutorial])
}

func testTutorialHandler_WhenAlreadySeen_Skips() {
    // Given
    let repository = InMemoryPopupStateRepository()
    _ = repository.markAsShown(type: .tutorial, memberId: "1")

    let context = PopupContext(
        userInfo: UserInfo(
            memberId: "1",
            hasSeenTutorial: true,
            hasSeenAd: false,
            hasSeenNewFeature: false,
            lastCheckInDate: nil,
            hasPredictionResult: false
        ),
        stateRepository: repository,
        presenter: MockPopupPresenter(),
        logger: MockLogger()
    )
    let handler = TutorialPopupHandler()

    // When
    let result = handler.handle(context: context)

    // Then
    XCTAssertEqual(result, .success(.skipped))
}
```

### 整合測試：完整鏈

```swift
func testPopupChain_NewUser_ShowsTutorialThenTerminates() {
    // Given
    let repository = InMemoryPopupStateRepository()
    let presenter = MockPopupPresenter()
    let context = PopupContext(
        userInfo: .newUser,
        stateRepository: repository,
        presenter: presenter,
        logger: MockLogger()
    )
    let manager = PopupChainManager(context: context)

    // When
    manager.startPopupChain()
    presenter.simulateDismiss(.tutorial)

    // Then: 只顯示 Tutorial，鏈終止
    XCTAssertEqual(presenter.presentedTypes, [.tutorial])
}

func testPopupChain_ReturningUser_ShowsFullSequence() {
    // Given
    let repository = InMemoryPopupStateRepository()
    _ = repository.markAsShown(type: .tutorial, memberId: "2")

    let presenter = MockPopupPresenter()
    let context = PopupContext(
        userInfo: .returningUser,
        stateRepository: repository,
        presenter: presenter,
        logger: MockLogger()
    )
    let manager = PopupChainManager(context: context)

    // When
    manager.startPopupChain()
    presenter.simulateDismiss(.interstitialAd)
    presenter.simulateDismiss(.dailyCheckIn)

    // Then
    XCTAssertEqual(presenter.presentedTypes, [
        .interstitialAd,
        .dailyCheckIn
    ])
}
```

### 錯誤降級測試

```swift
func testPopupChain_RepositoryFailure_ContinuesChain() {
    // Given
    let repository = FaultyMockRepository(failOn: .tutorial)
    let presenter = MockPopupPresenter()
    let logger = SpyLogger()
    let context = PopupContext(
        userInfo: .newUser,
        stateRepository: repository,
        presenter: presenter,
        logger: logger
    )
    let manager = PopupChainManager(context: context)

    // When
    manager.startPopupChain()

    // Then: 跳過 Tutorial，繼續下一個
    XCTAssertTrue(logger.containsError("Failed to read state for tutorial"))
    XCTAssertEqual(presenter.presentedTypes.first, .interstitialAd)
}
```

---

## Mock 範例

### MockPopupPresenter

```swift
class MockPopupPresenter: PopupPresenter {
    var presentedTypes: [PopupType] = []
    var currentPopupType: PopupType?
    var isPresenting: Bool { currentPopupType != nil }

    private var dismissCallbacks: [PopupType: () -> Void] = [:]

    func present(type: PopupType, from viewController: UIViewController, completion: @escaping () -> Void) {
        presentedTypes.append(type)
        currentPopupType = type
        dismissCallbacks[type] = completion
    }

    func dismiss(type: PopupType) {
        currentPopupType = nil
    }

    func simulateDismiss(_ type: PopupType) {
        currentPopupType = nil
        dismissCallbacks[type]?()
        dismissCallbacks.removeValue(forKey: type)
    }
}
```

### InMemoryPopupStateRepository

```swift
class InMemoryPopupStateRepository: PopupStateRepository {
    private var userStates: [String: [PopupType: PopupState]] = [:]

    func getState(for type: PopupType, memberId: String) -> Result<PopupState, PopupError> {
        if let state = userStates[memberId]?[type] {
            return .success(state)
        }
        return .success(PopupState(type: type))
    }

    func updateState(_ state: PopupState, memberId: String) -> Result<Void, PopupError> {
        if userStates[memberId] == nil {
            userStates[memberId] = [:]
        }
        userStates[memberId]?[state.type] = state
        return .success(())
    }

    func markAsShown(type: PopupType, memberId: String) -> Result<Void, PopupError> {
        let newState = PopupState(
            type: type,
            hasShown: true,
            lastShownDate: Date(),
            showCount: 1
        )
        return updateState(newState, memberId: memberId)
    }

    func resetUser(memberId: String) {
        userStates[memberId] = nil
    }

    func resetAll() {
        userStates.removeAll()
    }
}
```

---

## 新增彈窗類型

要新增一個新的彈窗類型：

1. **在 PopupType 新增 case**:

```swift
enum PopupType: String, CaseIterable {
    // ... 現有 cases
    case newPromotion = "newPromotion"  // 新增

    var priority: Int {
        switch self {
        // ... 現有 cases
        case .newPromotion: return 6  // 新增優先順序
        }
    }
}
```

2. **建立新的 Handler**:

```swift
class NewPromotionPopupHandler: BasePopupHandler {
    override var popupType: PopupType { .newPromotion }

    override func shouldShow(context: PopupContext) -> Bool {
        // 你的條件邏輯
        return context.userInfo.hasActivePromotion
    }
}
```

3. **在 ChainManager 中註冊**:

```swift
// PopupChainManager.swift
private func buildChain() -> PopupHandler {
    let handlers: [PopupHandler] = [
        TutorialPopupHandler(),
        InterstitialAdPopupHandler(),
        NewFeaturePopupHandler(),
        DailyCheckInPopupHandler(),
        PredictionResultPopupHandler(),
        NewPromotionPopupHandler()  // 新增
    ]
    // ... 串接邏輯
}
```

完成！無需修改任何現有 Handler。

---

## 常見問題

### Q: 彈窗不顯示？

檢查：
1. `presenter` 是否為 nil
2. `userInfo` 的狀態旗標是否正確
3. 是否已在同一 session 觸發過

### Q: 狀態沒有持久化？

檢查：
1. 是否使用 `UserDefaultsPopupStateRepository`
2. `memberId` 是否一致
3. App 是否被完全終止（而非背景）

### Q: 如何重置狀態用於測試？

```swift
repository.resetAll()  // 重置所有用戶
repository.resetUser(memberId: "1")  // 重置特定用戶
```

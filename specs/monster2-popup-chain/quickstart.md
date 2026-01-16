# Quickstart: 彈窗連鎖顯示機制 (Popup Response Chain)

**Date**: 2026-01-16
**Feature**: [spec.md](./spec.md)

---

## Overview

彈窗連鎖顯示機制讓用戶進入主畫面時，系統按照優先順序依序檢查並顯示彈窗。

**Priority Order**: 新手教學 → 插頁式廣告 → 新功能公告 → 每日簽到 → 猜多空結果

---

## Quick Integration

### 1. 初始化 PopupChainManager

```swift
import UIKit
import Combine

class MainViewController: UIViewController {

    private let popupChainManager: PopupChainManager
    private var cancellables = Set<AnyCancellable>()

    init() {
        // ⚠️ 重要：陣列順序即優先順序！
        // 索引越小越優先，新增彈窗只需插入到正確位置
        let handlers: [PopupHandler] = [
            TutorialPopupHandler(),       // [0] 最優先
            InterstitialAdHandler(),      // [1]
            NewFeaturePopupHandler(),     // [2]
            DailyCheckInHandler(),        // [3]
            PredictionResultHandler()     // [4] 最後
        ]

        // 初始化管理器（不會重新排序，直接使用陣列順序）
        self.popupChainManager = PopupChainManager(handlers: handlers)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
```

### 2. 啟動彈窗鏈

```swift
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    // 進入主畫面時啟動彈窗檢查 (FR-001)
    popupChainManager.startChain(on: self)
}
```

### 3. 監聽彈窗狀態（可選）

```swift
private func setupBindings() {
    popupChainManager.$currentPopup
        .receive(on: DispatchQueue.main)
        .sink { [weak self] popupType in
            if let type = popupType {
                print("正在顯示: \(type.rawValue)")
            }
        }
        .store(in: &cancellables)

    popupChainManager.$isRunning
        .receive(on: DispatchQueue.main)
        .sink { [weak self] isRunning in
            if !isRunning {
                print("彈窗鏈結束")
            }
        }
        .store(in: &cancellables)
}
```

---

## Implementing a Custom PopupHandler

### Example: Tutorial Popup Handler

```swift
final class TutorialPopupHandler: PopupHandler {

    let popupType: PopupType = .tutorial

    func shouldDisplay(state: PopupUserState) -> Bool {
        // 只在用戶從未看過新手教學時顯示
        return !state.hasSeenTutorial
    }

    func display(on viewController: UIViewController, completion: @escaping (PopupResult) -> Void) {
        let alert = UIAlertController(
            title: "歡迎使用",
            message: "讓我們開始新手教學吧！",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "開始", style: .default) { _ in
            // TODO: 顯示完整教學流程
            completion(.completed)
        })

        alert.addAction(UIAlertAction(title: "跳過", style: .cancel) { _ in
            completion(.dismissed)
        })

        viewController.present(alert, animated: true)
    }

    func updateState(storage: PopupStateStorage) {
        storage.markTutorialSeen()
    }
}
```

### Example: Daily Check-In Handler

```swift
final class DailyCheckInHandler: PopupHandler {

    let popupType: PopupType = .dailyCheckIn

    func shouldDisplay(state: PopupUserState) -> Bool {
        // 今日尚未簽到才顯示
        return !state.hasCheckedInToday()
    }

    func display(on viewController: UIViewController, completion: @escaping (PopupResult) -> Void) {
        let alert = UIAlertController(
            title: "每日簽到",
            message: "點擊領取今日獎勵！",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "簽到", style: .default) { _ in
            // TODO: 執行簽到邏輯
            completion(.completed)
        })

        alert.addAction(UIAlertAction(title: "稍後再說", style: .cancel) { _ in
            completion(.dismissed)
        })

        viewController.present(alert, animated: true)
    }

    func updateState(storage: PopupStateStorage) {
        storage.markDailyCheckIn()
    }
}
```

### Example: Interstitial Ad Handler (with daily limit)

```swift
final class InterstitialAdHandler: PopupHandler {

    let popupType: PopupType = .interstitialAd

    func shouldDisplay(state: PopupUserState) -> Bool {
        // FR-012: 每日最多顯示 1 次
        return !state.hasShownAdToday()
    }

    func display(on viewController: UIViewController, completion: @escaping (PopupResult) -> Void) {
        // TODO: 顯示插頁式廣告
        // 假設使用第三方廣告 SDK
        completion(.completed)
    }

    func updateState(storage: PopupStateStorage) {
        storage.markAdShown()
    }
}
```

---

## Testing

### Unit Test Example

```swift
import XCTest
@testable import CarSystem

final class PopupChainManagerTests: XCTestCase {

    func testMaxPopupsLimit() {
        // Arrange
        let mockStorage = MockPopupStateStorage()
        let handlers = [
            MockPopupHandler(type: .tutorial, shouldShow: true),
            MockPopupHandler(type: .interstitialAd, shouldShow: true),
            MockPopupHandler(type: .newFeature, shouldShow: true),
            MockPopupHandler(type: .dailyCheckIn, shouldShow: true),  // 不應顯示
            MockPopupHandler(type: .predictionResult, shouldShow: true)  // 不應顯示
        ]
        let manager = PopupChainManager(handlers: handlers, stateStorage: mockStorage)

        // Act
        let viewController = UIViewController()
        manager.startChain(on: viewController)

        // Assert - FR-010: 最多顯示 3 個
        XCTAssertEqual(manager.displayedCount, 3)
    }

    func testPopupPriorityOrder() {
        // Arrange
        let mockStorage = MockPopupStateStorage()
        // 陣列順序即優先順序：tutorial 在前，所以優先
        let handlers = [
            MockPopupHandler(type: .tutorial, shouldShow: true),    // [0] 先
            MockPopupHandler(type: .dailyCheckIn, shouldShow: true) // [1] 後
        ]
        let manager = PopupChainManager(handlers: handlers, stateStorage: mockStorage)

        // Act & Assert - FR-002: 陣列第一個元素最優先
        manager.startChain(on: UIViewController())
        XCTAssertEqual(manager.currentPopup, .tutorial)
    }
}
```

---

## File Structure

```
CarSystem/PopupChain/
├── Protocols/
│   ├── PopupChainItem.swift
│   └── PopupHandler.swift
├── Models/
│   ├── PopupType.swift
│   ├── PopupChainError.swift
│   └── PopupState.swift
├── Handlers/
│   ├── TutorialPopupHandler.swift
│   ├── InterstitialAdHandler.swift
│   ├── NewFeaturePopupHandler.swift
│   ├── DailyCheckInHandler.swift
│   └── PredictionResultHandler.swift
├── Services/
│   ├── PopupChainManager.swift
│   └── PopupStateStorage.swift
└── Views/
    └── PopupPresenter.swift
```

---

## Key Requirements Reference

| Requirement | Implementation |
|-------------|----------------|
| FR-001 | `startChain()` called in `viewDidAppear` |
| FR-002 | 陣列順序即優先順序，索引越小越優先 |
| FR-003 | Single `currentPopup` at a time |
| FR-004 | `proceedToNext()` after popup closes |
| FR-005 | `PopupUserState` + `PopupStateStorage` |
| FR-006 | Protocol-based handlers, 新增只需插入陣列正確位置 |
| FR-010 | `maxPopupsPerSession = 3` |
| FR-011 | `case .failed: proceedToNext()` |
| FR-012 | `hasShownAdToday()` check |

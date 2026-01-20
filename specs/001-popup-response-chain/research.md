# Research: Popup Response Chain System

**Date**: 2026-01-16
**Feature**: 001-popup-response-chain

## Overview

本文件記錄實作彈窗連鎖顯示系統的技術研究與設計決策。

---

## 1. Chain of Responsibility Pattern in Swift

### Decision
採用 Protocol-based Chain of Responsibility，每個 Handler 透過 `next` 屬性串接。

### Rationale
- Swift 的 Protocol 機制支援清晰的抽象定義
- 符合 SOLID 原則中的 OCP（新增 Handler 不需修改現有程式碼）
- 可透過依賴注入實現高可測試性

### Alternatives Considered

| 方案 | 優點 | 缺點 | 決策 |
|------|------|------|------|
| Class Inheritance Chain | 簡單實作 | 違反組合優於繼承原則 | ❌ 拒絕 |
| Protocol Chain | 靈活、可測試 | 稍複雜 | ✅ 採用 |
| Closure Chain | 極簡 | 難以擴展和測試 | ❌ 拒絕 |
| State Machine | 狀態清晰 | 過度工程 | ❌ 拒絕 |

### Implementation Pattern

```swift
protocol PopupHandler: AnyObject {
    var next: PopupHandler? { get set }
    func handle(context: PopupContext) -> Result<PopupHandleResult, PopupError>
}

enum PopupHandleResult {
    case shown(PopupType)      // 顯示了彈窗，等待關閉
    case skipped               // 條件不符，跳過
    case chainTerminated       // 終止鏈（Tutorial 專用）
}
```

---

## 2. State Persistence Strategy

### Decision
使用 UserDefaults 封裝於 Repository Pattern 中，支援多帳號隔離。

### Rationale
- UserDefaults 對簡單鍵值資料足夠高效（< 10ms 讀寫）
- Repository 抽象允許測試時替換為 InMemory 實作
- Key 格式 `popup_{memberId}_{popupType}` 自然隔離多帳號

### Alternatives Considered

| 方案 | 優點 | 缺點 | 決策 |
|------|------|------|------|
| UserDefaults + Repository | 簡單、可測試 | 無加密 | ✅ 採用 |
| CoreData | 結構化查詢 | 過度工程 | ❌ 拒絕 |
| Keychain | 安全 | 效能差、API 複雜 | ❌ 拒絕 |
| File Storage | 靈活 | 需手動序列化 | ❌ 拒絕 |

### Key Schema

```text
popup_{memberId}_tutorial        → Bool (hasShown)
popup_{memberId}_interstitialAd  → Bool (hasShown)
popup_{memberId}_newFeature      → Bool (hasShown)
popup_{memberId}_dailyCheckIn    → String (lastShownDate: "yyyy-MM-dd")
popup_{memberId}_predictionResult → Bool (hasShown, resets externally)
```

---

## 3. Observer Pattern for UI Notifications

### Decision
自訂輕量級 Observer Pattern，使用 weak reference 避免記憶體洩漏。

### Rationale
- 規格要求 UI 可監聽彈窗事件（FR-012）
- NotificationCenter 對業務邏輯過於鬆散
- Combine 需要 iOS 13+ 且增加複雜度

### Alternatives Considered

| 方案 | 優點 | 缺點 | 決策 |
|------|------|------|------|
| Custom Observer Protocol | 型別安全、可測試 | 需實作管理邏輯 | ✅ 採用 |
| NotificationCenter | 系統內建 | 型別不安全、難測試 | ❌ 拒絕 |
| Combine | 響應式、強大 | 學習曲線、iOS 13+ | ❌ 拒絕 |
| Delegation | 簡單 | 只支援單一觀察者 | ❌ 拒絕 |

### Implementation Pattern

```swift
protocol PopupEventObserver: AnyObject {
    func popupChain(didPublish event: PopupEvent)
}

class PopupEventPublisher {
    private var observers: [WeakObserver] = []

    func addObserver(_ observer: PopupEventObserver) { ... }
    func removeObserver(_ observer: PopupEventObserver) { ... }
    func publish(_ event: PopupEvent) { ... }
}
```

---

## 4. Error Handling Strategy

### Decision
使用 Swift Result Type，失敗時記錄錯誤並繼續執行鏈。

### Rationale
- 規格明確要求「失敗不中斷」（FR-009）
- Result Type 強制處理錯誤路徑
- 避免 try-catch 的隱式錯誤傳播

### Alternatives Considered

| 方案 | 優點 | 缺點 | 決策 |
|------|------|------|------|
| Result Type + Degradation | 明確、可組合 | 稍冗長 | ✅ 採用 |
| throws/try | Swift 原生 | 錯誤傳播不明確 | ❌ 拒絕 |
| Optional + nil | 極簡 | 丟失錯誤資訊 | ❌ 拒絕 |

### Error Types

```swift
enum PopupError: Error {
    case repositoryReadFailed(PopupType)
    case repositoryWriteFailed(PopupType)
    case presenterCreationFailed
    case invalidState(String)
}
```

---

## 5. Popup Transition Timing

### Decision
使用 `DispatchQueue.main.asyncAfter` 實現 0.3-0.5 秒延遲。

### Rationale
- 規格明確要求延遲（FR-014）
- GCD 是 iOS 標準非同步機制
- 簡單可靠，無需額外依賴

### Implementation

```swift
func scheduleNextPopup(after delay: TimeInterval = 0.3) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
        self?.checkNextHandler()
    }
}
```

---

## 6. Testing Strategy

### Decision
採用 Protocol-based Mocking，無第三方測試框架。

### Rationale
- XCTest 內建功能足夠
- Protocol 抽象自然支援 Mock 注入
- 減少外部依賴

### Mock Types Required

| Mock | 用途 |
|------|------|
| MockPopupStateRepository | 測試 Handler 邏輯 |
| MockPopupPresenter | 驗證彈窗顯示 |
| SpyPopupEventObserver | 捕獲事件發布 |
| MockLogger | 驗證錯誤記錄 |
| FaultyMockRepository | 測試錯誤降級 |

---

## 7. Trigger Timing Implementation

### Decision
在 `SceneDelegate.sceneDidBecomeActive` 或 `AppDelegate.applicationDidBecomeActive` 中觸發，使用旗標確保單次執行。

### Rationale
- 規格要求每次 App 啟動（冷啟動或背景恢復）執行一次（FR-013）
- `didBecomeActive` 涵蓋兩種啟動情境
- Session-scoped 旗標防止重複觸發

### Implementation

```swift
class PopupChainCoordinator {
    private var hasTriggeredThisSession = false

    func triggerIfNeeded() {
        guard !hasTriggeredThisSession else { return }
        hasTriggeredThisSession = true
        popupChainManager.startPopupChain()
    }
}
```

---

## Summary

所有技術決策已確認，無 NEEDS CLARIFICATION 項目。可進入 Phase 1 設計階段。

| 領域 | 決策 | 狀態 |
|------|------|------|
| 設計模式 | Chain of Responsibility (Protocol-based) | ✅ 確認 |
| 狀態儲存 | UserDefaults + Repository Pattern | ✅ 確認 |
| 事件通知 | Custom Observer Pattern | ✅ 確認 |
| 錯誤處理 | Result Type + Degradation | ✅ 確認 |
| 過渡延遲 | GCD asyncAfter | ✅ 確認 |
| 測試策略 | XCTest + Protocol Mocks | ✅ 確認 |
| 觸發時機 | didBecomeActive + Session Flag | ✅ 確認 |

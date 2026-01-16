# Data Model: Popup Response Chain System

**Date**: 2026-01-16
**Feature**: 001-popup-response-chain

---

## Entity Relationship Diagram

```text
┌─────────────────┐       ┌─────────────────┐
│    UserInfo     │       │   PopupState    │
├─────────────────┤       ├─────────────────┤
│ memberId        │──┐    │ type            │
│ hasSeenTutorial │  │    │ hasShown        │
│ hasSeenAd       │  │    │ lastShownDate   │
│ hasSeenNewFeature│ │    │ showCount       │
│ lastCheckInDate │  │    └─────────────────┘
│ hasPredictionResult│           │
└─────────────────┘  │           │
                     │           │
                     └───────────┼──── keyed by memberId + type
                                 │
┌─────────────────┐              │
│   PopupType     │◄─────────────┘
├─────────────────┤
│ tutorial        │
│ interstitialAd  │
│ newFeature      │
│ dailyCheckIn    │
│ predictionResult│
└─────────────────┘

┌─────────────────┐       ┌─────────────────┐
│  PopupContext   │───────│ PopupHandler    │
├─────────────────┤       ├─────────────────┤
│ userInfo        │       │ next            │
│ stateRepository │       │ handle(context) │
│ presenter       │       └─────────────────┘
│ logger          │              │
└─────────────────┘              │ implements
                                 ▼
                    ┌────────────────────────┐
                    │ TutorialPopupHandler   │
                    │ InterstitialAdHandler  │
                    │ NewFeatureHandler      │
                    │ DailyCheckInHandler    │
                    │ PredictionResultHandler│
                    └────────────────────────┘

┌─────────────────┐
│   PopupEvent    │
├─────────────────┤
│ popupWillShow   │
│ popupDidShow    │
│ popupWillDismiss│
│ popupDidDismiss │
│ chainCompleted  │
└─────────────────┘
```

---

## Entities

### PopupType

**Description**: 彈窗類型枚舉，定義所有支援的彈窗種類及其優先順序。

| Field | Type | Description |
|-------|------|-------------|
| rawValue | String | 唯一識別碼 |
| priority | Int | 優先順序（1=最高） |
| displayName | String | 顯示名稱 |
| resetPolicy | ResetPolicy | 重置策略 |

**Enum Cases**:

| Case | Priority | Reset Policy | Description |
|------|----------|--------------|-------------|
| tutorial | 1 | permanent | 新手教學（顯示後終止鏈） |
| interstitialAd | 2 | permanent | 插頁式廣告 |
| newFeature | 3 | permanent | 新功能公告 |
| dailyCheckIn | 4 | daily | 每日簽到 |
| predictionResult | 5 | onNewResult | 猜多空結果 |

**Validation Rules**:
- CaseIterable 支援遍歷所有類型
- priority 必須唯一且連續

---

### PopupState

**Description**: 追蹤特定用戶的特定彈窗狀態。

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| type | PopupType | 彈窗類型 | Required |
| hasShown | Bool | 是否已顯示過 | Default: false |
| lastShownDate | Date? | 最後顯示日期 | Optional |
| showCount | Int | 顯示次數 | >= 0, Default: 0 |

**State Transitions**:

```text
[Initial] ──show()──> [Shown]
   │                     │
   │                     │ (daily reset)
   │                     ▼
   └──────────────── [Reset] ───> [Initial]
```

**Validation Rules**:
- showCount 必須 >= 0
- hasShown == true 時，lastShownDate 不應為 nil

---

### UserInfo

**Description**: 用戶身份與彈窗相關狀態旗標，由外部系統傳入。

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| memberId | String | 用戶唯一識別碼 | Required, non-empty |
| hasSeenTutorial | Bool | 已看過新手教學 | Default: false |
| hasSeenAd | Bool | 已看過插頁式廣告 | Default: false |
| hasSeenNewFeature | Bool | 已看過新功能公告 | Default: false |
| lastCheckInDate | Date? | 最後簽到日期 | Optional |
| hasPredictionResult | Bool | 是否有預測結果待顯示 | Default: false |

**Predefined Profiles (Testing)**:

| Profile | memberId | Description |
|---------|----------|-------------|
| newUser | "1" | 全新用戶，未看過任何彈窗 |
| returningUser | "2" | 回訪用戶，已看過 Tutorial |
| experiencedUser | "3" | 老用戶，已看過 Tutorial + Ad |
| checkedInUser | "4" | 已簽到用戶，今日已簽到 |
| allCompletedUser | "5" | 全部完成，已看過所有彈窗 |

**Validation Rules**:
- memberId 不可為空字串
- 測試用 memberId 使用整數序列（1, 2, 3...）確保可重現性

---

### PopupContext

**Description**: 執行彈窗鏈時的上下文環境，包含所有必要依賴。

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| userInfo | UserInfo | 當前用戶資訊 | Required |
| stateRepository | PopupStateRepository | 狀態儲存庫 | Required |
| presenter | PopupPresenter? | 彈窗呈現器 | Optional (nil = 無 UI) |
| logger | Logger | 日誌記錄器 | Required |

**Validation Rules**:
- presenter 為 nil 時，系統仍應正常運作（僅記錄錯誤）

---

### PopupError

**Description**: 彈窗操作錯誤類型。

| Case | Description | Recovery Action |
|------|-------------|-----------------|
| repositoryReadFailed(PopupType) | 讀取狀態失敗 | 跳過該彈窗，繼續鏈 |
| repositoryWriteFailed(PopupType) | 寫入狀態失敗 | 記錄錯誤，繼續鏈 |
| presenterCreationFailed | 呈現器創建失敗 | 跳過顯示，繼續鏈 |
| invalidState(String) | 無效狀態 | 記錄錯誤，繼續鏈 |

---

### PopupEvent

**Description**: 彈窗生命週期事件，用於通知觀察者。

| Case | Associated Value | Timing |
|------|------------------|--------|
| popupWillShow(PopupType) | 即將顯示的彈窗類型 | 顯示前 |
| popupDidShow(PopupType) | 已顯示的彈窗類型 | 顯示後 |
| popupWillDismiss(PopupType) | 即將關閉的彈窗類型 | 關閉前 |
| popupDidDismiss(PopupType) | 已關閉的彈窗類型 | 關閉後 |
| chainCompleted | 無 | 鏈結束時 |

---

### PopupHandleResult

**Description**: Handler 處理結果，指示下一步動作。

| Case | Description | Next Action |
|------|-------------|-------------|
| shown(PopupType) | 顯示了彈窗 | 等待用戶關閉 |
| skipped | 條件不符，跳過 | 立即檢查下一個 |
| chainTerminated | 終止鏈 | 結束檢查（Tutorial 專用） |

---

## Storage Schema

### UserDefaults Keys

```text
Format: popup_{memberId}_{popupType}

Examples:
- popup_1_tutorial          → Bool
- popup_1_interstitialAd    → Bool
- popup_1_newFeature        → Bool
- popup_1_dailyCheckIn      → String ("2026-01-16")
- popup_1_predictionResult  → Bool
```

### Reset Policies

| Policy | Behavior | Affected Types |
|--------|----------|----------------|
| permanent | 永不重置 | tutorial, interstitialAd, newFeature |
| daily | 每日重置 | dailyCheckIn |
| onNewResult | 有新結果時重置 | predictionResult |

---

## Protocols

### PopupHandler

```swift
protocol PopupHandler: AnyObject {
    var next: PopupHandler? { get set }
    func handle(context: PopupContext) -> Result<PopupHandleResult, PopupError>
}
```

### PopupStateRepository

```swift
protocol PopupStateRepository {
    func getState(for type: PopupType, memberId: String) -> Result<PopupState, PopupError>
    func updateState(_ state: PopupState, memberId: String) -> Result<Void, PopupError>
    func markAsShown(type: PopupType, memberId: String) -> Result<Void, PopupError>
    func resetUser(memberId: String)
    func resetAll()
}
```

### PopupPresenter

```swift
protocol PopupPresenter: AnyObject {
    func present(type: PopupType, from viewController: UIViewController, completion: @escaping () -> Void)
    func dismiss(type: PopupType)
}
```

### PopupEventObserver

```swift
protocol PopupEventObserver: AnyObject {
    func popupChain(didPublish event: PopupEvent)
}
```

### Logger

```swift
protocol Logger {
    func log(_ message: String, level: LogLevel)
}

enum LogLevel {
    case debug, info, warning, error
}
```

---

## Invariants

1. **Chain Order**: Handlers 必須按 priority 順序串接
2. **Single Display**: 同一時間最多顯示一個彈窗
3. **Tutorial Termination**: Tutorial 顯示後必須終止鏈
4. **Ad Exclusivity**: interstitialAd 和 newFeature 互斥顯示
5. **State Isolation**: 不同 memberId 的狀態完全隔離
6. **Graceful Degradation**: 任何錯誤不應中斷整個鏈

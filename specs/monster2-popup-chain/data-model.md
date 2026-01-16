# Data Model: 彈窗連鎖顯示機制 (Popup Response Chain)

**Date**: 2026-01-16
**Feature**: [spec.md](./spec.md)

---

## Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         PopupChainManager                           │
│  (Orchestrator - manages the popup display chain)                   │
├─────────────────────────────────────────────────────────────────────┤
│  - currentPopup: PopupType?                                         │
│  - displayedCount: Int                                              │
│  - handlers: [PopupHandler]  ← 陣列順序即優先順序                     │
│  + startChain() -> Result<Void, PopupChainError>                    │
│  + proceedToNext()                                                  │
│  + cancelChain()                                                    │
└───────────────────────────────┬─────────────────────────────────────┘
                                │ manages (ordered array)
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         <<Protocol>>                                │
│                         PopupHandler                                │
├─────────────────────────────────────────────────────────────────────┤
│  + popupType: PopupType                                             │
│  + shouldDisplay(state: PopupUserState) -> Bool                     │
│  + display(on: UIViewController, completion: (PopupResult) -> Void) │
└───────────────────────────────┬─────────────────────────────────────┘
                                │ implemented by
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  handlers array order (FR-002):                                     │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐   │
│  │ [0] Tutorial│→│[1] Ad       │→│[2] Feature  │→│[3] CheckIn  │→  │
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘   │
│                                                   ┌─────────────┐   │
│                                                 →│[4] Prediction│   │
│                                                   └─────────────┘   │
└─────────────────────────────────────────────────────────────────────┘

                                │ reads/writes
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       PopupStateStorage                             │
│  (UserDefaults persistence layer)                                   │
├─────────────────────────────────────────────────────────────────────┤
│  + load() -> PopupUserState                                         │
│  + save(_ state: PopupUserState)                                    │
│  + markTutorialSeen()                                               │
│  + markDailyCheckIn()                                               │
│  + markAdShown()                                                    │
│  + markFeatureSeen(id: String)                                      │
│  + markPredictionNotified(id: String)                               │
└───────────────────────────────┬─────────────────────────────────────┘
                                │ persists
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       PopupUserState                                │
│  (Codable struct for UserDefaults)                                  │
├─────────────────────────────────────────────────────────────────────┤
│  + hasSeenTutorial: Bool                                            │
│  + lastCheckInDate: Date?                                           │
│  + lastAdShownDate: Date?                                           │
│  + seenFeatureAnnouncements: Set<String>                            │
│  + notifiedPredictionResults: Set<String>                           │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Entities

### 1. PopupType (Enum)

| Field | Type | Description |
|-------|------|-------------|
| `tutorial` | case | 新手教學彈窗 |
| `interstitialAd` | case | 插頁式廣告彈窗 |
| `newFeature` | case | 新功能公告彈窗 |
| `dailyCheckIn` | case | 每日簽到彈窗 |
| `predictionResult` | case | 猜多空結果彈窗 |

**Validation Rules**:
- 優先順序由 `handlers` 陣列順序決定，無需額外屬性
- 新增彈窗只需插入陣列正確位置

**Priority Order** (FR-002) - 由陣列索引決定:
```
handlers[0]: tutorial
handlers[1]: interstitialAd
handlers[2]: newFeature
handlers[3]: dailyCheckIn
handlers[4]: predictionResult
```

---

### 2. PopupUserState (Codable Struct)

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `hasSeenTutorial` | Bool | false | 用戶是否看過新手教學 |
| `lastCheckInDate` | Date? | nil | 上次簽到日期 |
| `lastAdShownDate` | Date? | nil | 上次顯示廣告日期 |
| `seenFeatureAnnouncements` | Set<String> | [] | 已看過的新功能公告 ID |
| `notifiedPredictionResults` | Set<String> | [] | 已通知的猜多空結果 ID |

**Validation Rules**:
- 日期比較使用 Calendar.isDateInToday()
- ID 使用 String 類型以支援不同來源格式
- 所有欄位皆有預設值，確保新用戶正常運作

**State Transitions**:
```
┌──────────────────┐     markTutorialSeen()     ┌──────────────────┐
│ hasSeenTutorial  │ ─────────────────────────▶ │ hasSeenTutorial  │
│     = false      │                            │     = true       │
└──────────────────┘                            └──────────────────┘
       (永久狀態，不會重置)

┌──────────────────┐     markDailyCheckIn()     ┌──────────────────┐
│ lastCheckInDate  │ ─────────────────────────▶ │ lastCheckInDate  │
│     = nil        │                            │   = Date()       │
└──────────────────┘                            └──────────────────┘
       (每日重置判斷：!isDateInToday)

┌──────────────────┐     markAdShown()          ┌──────────────────┐
│ lastAdShownDate  │ ─────────────────────────▶ │ lastAdShownDate  │
│     = nil        │                            │   = Date()       │
└──────────────────┘                            └──────────────────┘
       (每日重置判斷：!isDateInToday) (FR-012)
```

---

### 3. PopupResult (Enum)

| Field | Type | Description |
|-------|------|-------------|
| `completed` | case | 用戶完成彈窗互動（如完成教學） |
| `dismissed` | case | 用戶關閉彈窗 |
| `failed(Error)` | case | 彈窗顯示失敗 |

**Usage**:
- `completed` 和 `dismissed` 都會繼續檢查下一個彈窗
- `failed` 會跳過當前彈窗繼續下一個（FR-011）

---

### 4. PopupChainError (Enum)

| Case | Description | Recovery |
|------|-------------|----------|
| `maxPopupsReached` | 已達單次 3 個上限（FR-010） | 正常結束鏈 |
| `popupDisplayFailed` | 彈窗顯示失敗 | 跳過繼續（FR-011） |
| `chainInterrupted` | 鏈被外部中斷 | 結束鏈 |
| `storageError` | UserDefaults 讀寫錯誤 | 使用預設值繼續 |

---

### 5. PopupChainManager (Class)

| Property | Type | Description |
|----------|------|-------------|
| `currentPopup` | PopupType? | 當前顯示的彈窗類型（@Published） |
| `displayedCount` | Int | 本次已顯示的彈窗數量（@Published） |
| `isRunning` | Bool | 彈窗鏈是否正在執行（@Published） |
| `handlers` | [PopupHandler] | 按優先順序排列的處理器陣列 |
| `stateStorage` | PopupStateStorage | 狀態存儲服務 |

| Method | Signature | Description |
|--------|-----------|-------------|
| `startChain` | `(on: UIViewController) -> Result<Void, PopupChainError>` | 開始彈窗鏈檢查 |
| `proceedToNext` | `() -> Void` | 繼續檢查下一個彈窗 |
| `cancelChain` | `() -> Void` | 取消彈窗鏈 |

**Invariants**:
- `displayedCount` <= 3 (FR-010)
- 同時只有一個 `currentPopup` 非 nil (FR-003)
- `handlers` 陣列順序即優先順序，索引越小越優先 (FR-002)

---

### 6. PopupHandler (Protocol)

| Property | Type | Description |
|----------|------|-------------|
| `popupType` | PopupType | 處理的彈窗類型 |

| Method | Signature | Description |
|--------|-----------|-------------|
| `shouldDisplay` | `(state: PopupUserState) -> Bool` | 判斷是否應顯示 |
| `display` | `(on: UIViewController, completion: @escaping (PopupResult) -> Void)` | 執行顯示 |
| `updateState` | `(storage: PopupStateStorage) -> Void` | 更新用戶狀態 |

**Note**: 優先順序由 `PopupChainManager.handlers` 陣列順序決定，Handler 本身不需要 priority 屬性。

---

### 7. PopupStateStorage (Class)

| Property | Type | Description |
|----------|------|-------------|
| `userDefaults` | UserDefaults | 存儲實例 |
| `storageKey` | String | UserDefaults key |

| Method | Signature | Description |
|--------|-----------|-------------|
| `load` | `() -> PopupUserState` | 讀取狀態 |
| `save` | `(_ state: PopupUserState) -> Void` | 儲存狀態 |
| `markTutorialSeen` | `() -> Void` | 標記已看教學 |
| `markDailyCheckIn` | `() -> Void` | 標記今日已簽到 |
| `markAdShown` | `() -> Void` | 標記今日已顯示廣告 |
| `markFeatureSeen` | `(id: String) -> Void` | 標記已看新功能 |
| `markPredictionNotified` | `(id: String) -> Void` | 標記已通知結果 |

---

## Relationships

| From | To | Relationship | Cardinality |
|------|-----|--------------|-------------|
| PopupChainManager | PopupHandler | manages | 1:N |
| PopupChainManager | PopupStateStorage | uses | 1:1 |
| PopupHandler | PopupUserState | reads | N:1 |
| PopupStateStorage | PopupUserState | persists | 1:1 |
| PopupHandler | PopupType | identifies | 1:1 |

---

## Data Volume Assumptions

| Entity | Expected Count | Storage Size |
|--------|---------------|--------------|
| PopupType | 5 (fixed) | N/A (enum) |
| PopupHandler | 5 instances | ~1KB memory |
| PopupUserState | 1 per user | <500 bytes |
| Feature IDs | ~10-20 | ~200 bytes |
| Prediction IDs | ~50-100 | ~500 bytes |

**Total UserDefaults footprint**: < 2KB per user

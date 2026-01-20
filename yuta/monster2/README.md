# Code Monster 作業2：彈窗連鎖顯示機制 (Popup Response Chain)

## 作業概述

實作一個**彈窗連鎖顯示系統**，當用戶進入 App 主畫面時，依優先順序檢查並顯示各種彈窗（新手教學、廣告、公告等），每次只顯示一個，關閉後自動檢查下一個。

**設計模式**：Chain of Responsibility

---

## 設計思路

### 問題分析

傳統做法可能會寫出這樣的程式碼：

```swift
// ❌ 不好的做法：巢狀 if-else，難以維護
if !hasSeenTutorial {
    showTutorial {
        if !hasSeenAd {
            showAd {
                if !hasSeenFeature {
                    // ... 無限巢狀
                }
            }
        }
    }
}
```

**問題**：
- 新增彈窗需要修改現有程式碼
- 巢狀結構難以閱讀和測試
- 違反 Open-Closed Principle

### 解決方案：Chain of Responsibility

將每種彈窗封裝成獨立的 Handler，串成一條鏈：

```
[Tutorial] → [Ad] → [Feature] → [CheckIn] → [Prediction] → 完成
     ↓         ↓        ↓          ↓            ↓
   顯示？    顯示？   顯示？     顯示？       顯示？
```

每個 Handler 只負責：
1. 判斷自己是否要顯示
2. 顯示完成後，交給下一個 Handler

---

## 架構演進

### 第一版：傳統 Class 繼承（已棄用）

```swift
// 傳統 OOP 做法
class BasePopupHandler {
    func shouldHandle(_ context: UserContext) -> Bool {
        fatalError("子類別必須覆寫")  // ⚠️ Runtime 才會發現錯誤
    }
}

class TutorialHandler: BasePopupHandler {
    override func shouldHandle(_ context: UserContext) -> Bool { ... }
}
```

**問題**：
- `fatalError` 是 runtime 錯誤，編譯期不會警告
- 強迫使用 class，無法用 struct
- 不夠 Swift-like

### 最終版：Protocol + Struct（目前採用）

```swift
// Swift-like 做法
protocol PopupHandling {
    func shouldHandle(_ context: UserContext) -> Bool  // 編譯期強制實作
    func show(completion: @escaping () -> Void)
}

struct TutorialHandler: PopupHandling {
    func shouldHandle(_ context: UserContext) -> Bool {
        !context.hasSeenTutorial
    }
    
    func show(completion: @escaping () -> Void) {
        print("[彈窗] 新手教學")
        completion()
    }
}
```

**優點**：
- 編譯期安全（忘記實作會編譯失敗）
- 可以用 struct（Value Type）
- 沒有繼承，沒有 `fatalError`
- 符合 Protocol-Oriented Programming

---

## 架構圖

```
┌─────────────────────────────────────────────────────────────┐
│                        使用端                                │
│                                                             │
│   let handlers = [TutorialHandler(), AdHandler(), ...]     │
│   let manager = PopupChainManager(handlers: handlers)       │
│   manager.startChain(with: context) { ... }                │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   PopupChainManager                         │
│                                                             │
│   - 接收外部組裝好的 handlers                                │
│   - 負責依序執行 Chain                                       │
│   - 不知道具體有哪些 Handler（解耦）                          │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   PopupHandling (Protocol)                  │
│                                                             │
│   func shouldHandle(_ context: UserContext) -> Bool         │
│   func show(completion: @escaping () -> Void)              │
└─────────────────────────────────────────────────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   ▼                   ▼
   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
   │ Tutorial    │     │ Ad          │     │ Feature     │  ...
   │ Handler     │     │ Handler     │     │ Handler     │
   └─────────────┘     └─────────────┘     └─────────────┘
```

---

## 檔案結構

```
Sources/
├── Protocols/
│   └── PopupHandling.swift         # Protocol 定義
├── Handlers/
│   ├── TutorialHandler.swift       # 新手教學（struct）
│   ├── InterstitialAdHandler.swift # 插頁式廣告
│   ├── NewFeatureHandler.swift     # 新功能公告
│   ├── DailyCheckInHandler.swift   # 每日簽到
│   └── PredictionResultHandler.swift # 猜多空結果
├── Models/
│   └── UserContext.swift           # 使用者狀態
└── PopupChainManager.swift         # 鏈管理器

Tests/
├── HandlerTests/                   # 單元測試（10 個）
├── IntegrationTests/               # 整合測試（5 個）
└── ExtensibilityTests/             # 擴展性測試（2 個）
```

**總計**：8 個源碼檔案、17 個測試

---

## 使用方式

```swift
// 1. 外部組裝 Handler（決定順序和組合）
let handlers: [any PopupHandling] = [
    TutorialHandler(),
    InterstitialAdHandler(),
    NewFeatureHandler(),
    DailyCheckInHandler(),
    PredictionResultHandler()
]

// 2. 建立 Manager（注入 handlers）
let manager = PopupChainManager(handlers: handlers)

// 3. 建立使用者狀態
let context = UserContext(
    hasSeenTutorial: false,
    hasSeenInterstitialAd: false,
    hasSeenNewFeature: false,
    hasCheckedInToday: false,
    hasPredictionResult: true
)

// 4. 委派 Manager 執行
manager.startChain(with: context) {
    print("✅ 彈窗檢查完成")
}
```

### 輸出結果

```
[彈窗] 新手教學
[彈窗] 插頁式廣告
[彈窗] 新功能公告
[彈窗] 每日簽到
[彈窗] 猜多空結果
✅ 彈窗檢查完成
```

---

## 彈窗優先順序

| 順序 | 彈窗類型 | Handler | 顯示條件 |
|:----:|----------|---------|----------|
| 1 | 新手教學 | `TutorialHandler` | 尚未看過教學 |
| 2 | 插頁式廣告 | `InterstitialAdHandler` | 尚未看過廣告 |
| 3 | 新功能公告 | `NewFeatureHandler` | 尚未看過公告 |
| 4 | 每日簽到 | `DailyCheckInHandler` | 今日尚未簽到 |
| 5 | 猜多空結果 | `PredictionResultHandler` | 有預測結果 |

---

## 擴展性示範

新增第 6 個彈窗，**不需要修改任何現有程式碼**：

```swift
// 1. 建立新的 Handler
struct RatingPromptHandler: PopupHandling {
    func shouldHandle(_ context: UserContext) -> Bool {
        context.shouldShowRating
    }
    
    func show(completion: @escaping () -> Void) {
        print("[彈窗] 評分提示")
        completion()
    }
}

// 2. 加入陣列即可
let handlers: [any PopupHandling] = [
    TutorialHandler(),
    InterstitialAdHandler(),
    NewFeatureHandler(),
    DailyCheckInHandler(),
    PredictionResultHandler(),
    RatingPromptHandler()  // ← 新增
]
```

---

## 測試策略

### 單元測試（10 個）

每個 Handler 測試 `shouldHandle()` 的兩種情境：

```swift
func testShouldHandle_WhenNotSeen_ReturnsTrue() {
    let handler = TutorialHandler()
    let context = UserContext(hasSeenTutorial: false)
    
    XCTAssertTrue(handler.shouldHandle(context))
}

func testShouldHandle_WhenSeen_ReturnsFalse() {
    let handler = TutorialHandler()
    let context = UserContext(hasSeenTutorial: true)
    
    XCTAssertFalse(handler.shouldHandle(context))
}
```

### 整合測試（5 個）

測試完整 Chain 的執行：
- 所有條件符合 → 顯示全部
- 所有條件不符 → 不顯示任何
- 部分條件符合 → 只顯示符合的
- 空 handlers → 正常完成
- 只有第一個符合 → 只顯示第一個

### 擴展性測試（2 個）

驗證 Open-Closed Principle：
- 新增 Handler 不影響現有 Handler
- 6 個 Handler 的 Chain 能正確執行

---

## 設計原則

| 原則 | 實踐方式 |
|------|----------|
| **Single Responsibility** | 每個 Handler 只負責一種彈窗 |
| **Open-Closed** | 新增彈窗只需新增 Handler，不修改現有程式碼 |
| **Dependency Inversion** | Manager 依賴 Protocol，不依賴具體 Handler |
| **Protocol-Oriented** | 用 Protocol + Struct，非 Class 繼承 |

---

## 執行測試

```bash
cd yuta/monster2
swift test
```

預期結果：**17 個測試全部通過**

---

## 相關文件

| 文件 | 說明 |
|------|------|
| [spec.md](./spec.md) | 功能規格（需求定義） |
| [plan.md](./plan.md) | 技術規劃（架構設計） |
| [tasks.md](./tasks.md) | 任務清單（實作步驟） |

---

## 學習心得

1. **Chain of Responsibility** 適合處理「依序檢查、逐一處理」的場景
2. **Protocol + Struct** 比 **Class 繼承** 更 Swift-like
3. **外部組裝、內部執行** 的模式讓系統更靈活、更易測試
4. 好的設計應該讓「新增功能」變成「加一行程式碼」而非「改一堆程式碼」

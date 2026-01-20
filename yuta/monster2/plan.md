# 計畫：Monster2 Popup Response Chain 架構（Protocol-Oriented 版本）

**Feature**: [spec.md](./spec.md)
**Created**: 2025-01-18
**Updated**: 2025-01-18
**Pattern**: Chain of Responsibility（Protocol-Oriented Programming）

---

## 設計理念

### 目標

1. **乾淨的使用語法**：`TutorialHandler()` 而非冗長的 closure
2. **編譯期安全**：沒有 `fatalError`，忘記實作會編譯失敗
3. **Swift 風格**：Protocol + Struct，非 Class 繼承

### 比較三種做法

| 做法 | 使用語法 | fatalError | 可用 struct |
|------|---------|-----------|-------------|
| Class 繼承 | `TutorialHandler()` ✅ | ❌ 有 | ❌ |
| Struct + Closure | 冗長 ❌ | ✅ 無 | ✅ |
| **Protocol + Struct** | `TutorialHandler()` ✅ | ✅ 無 | ✅ |

---

## 檔案結構

```
Sources/
├── Models/
│   └── UserContext.swift           # 使用者狀態
├── Protocols/
│   └── PopupHandling.swift         # Handler 協定
├── Handlers/
│   ├── TutorialHandler.swift
│   ├── InterstitialAdHandler.swift
│   ├── NewFeatureHandler.swift
│   ├── DailyCheckInHandler.swift
│   └── PredictionResultHandler.swift
└── PopupChainManager.swift         # 彈窗鏈管理器
```

**總計：8 個檔案**

---

## 核心組件實作

### 1. UserContext.swift

```swift
import Foundation

/// 使用者狀態，用於彈窗顯示決策
struct UserContext {
    var hasSeenTutorial: Bool
    var hasSeenInterstitialAd: Bool
    var hasSeenNewFeature: Bool
    var hasCheckedInToday: Bool
    var hasPredictionResult: Bool
    
    init(
        hasSeenTutorial: Bool = false,
        hasSeenInterstitialAd: Bool = false,
        hasSeenNewFeature: Bool = false,
        hasCheckedInToday: Bool = false,
        hasPredictionResult: Bool = false
    ) {
        self.hasSeenTutorial = hasSeenTutorial
        self.hasSeenInterstitialAd = hasSeenInterstitialAd
        self.hasSeenNewFeature = hasSeenNewFeature
        self.hasCheckedInToday = hasCheckedInToday
        self.hasPredictionResult = hasPredictionResult
    }
}
```

### 2. PopupHandling.swift

```swift
import Foundation

/// 彈窗處理協定
/// 定義每個 Handler 必須實作的方法（編譯期強制）
protocol PopupHandling {
    /// 判斷是否應該顯示此彈窗
    func shouldHandle(_ context: UserContext) -> Bool
    
    /// 顯示彈窗，完成後呼叫 completion
    func show(completion: @escaping () -> Void)
}
```

### 3. TutorialHandler.swift

```swift
import Foundation

/// 新手教學彈窗處理器
struct TutorialHandler: PopupHandling {
    
    func shouldHandle(_ context: UserContext) -> Bool {
        !context.hasSeenTutorial
    }
    
    func show(completion: @escaping () -> Void) {
        print("[彈窗] 新手教學")
        UserDefaults.standard.set(true, forKey: "hasSeenTutorial")
        completion()
    }
}
```

### 4. InterstitialAdHandler.swift

```swift
import Foundation

/// 插頁式廣告彈窗處理器
struct InterstitialAdHandler: PopupHandling {
    
    func shouldHandle(_ context: UserContext) -> Bool {
        !context.hasSeenInterstitialAd
    }
    
    func show(completion: @escaping () -> Void) {
        print("[彈窗] 插頁式廣告")
        UserDefaults.standard.set(true, forKey: "hasSeenInterstitialAd")
        completion()
    }
}
```

### 5. NewFeatureHandler.swift

```swift
import Foundation

/// 新功能公告彈窗處理器
struct NewFeatureHandler: PopupHandling {
    
    func shouldHandle(_ context: UserContext) -> Bool {
        !context.hasSeenNewFeature
    }
    
    func show(completion: @escaping () -> Void) {
        print("[彈窗] 新功能公告")
        UserDefaults.standard.set(true, forKey: "hasSeenNewFeature")
        completion()
    }
}
```

### 6. DailyCheckInHandler.swift

```swift
import Foundation

/// 每日簽到彈窗處理器
struct DailyCheckInHandler: PopupHandling {
    
    func shouldHandle(_ context: UserContext) -> Bool {
        !context.hasCheckedInToday
    }
    
    func show(completion: @escaping () -> Void) {
        print("[彈窗] 每日簽到")
        UserDefaults.standard.set(Date(), forKey: "lastCheckInDate")
        completion()
    }
}
```

### 7. PredictionResultHandler.swift

```swift
import Foundation

/// 猜多空結果彈窗處理器
struct PredictionResultHandler: PopupHandling {
    
    func shouldHandle(_ context: UserContext) -> Bool {
        context.hasPredictionResult
    }
    
    func show(completion: @escaping () -> Void) {
        print("[彈窗] 猜多空結果")
        completion()
    }
}
```

### 8. PopupChainManager.swift

```swift
import Foundation

/// 彈窗鏈管理器
/// 負責執行外部組裝好的 Handler 鏈
final class PopupChainManager {
    
    private let handlers: [any PopupHandling]
    
    init(handlers: [any PopupHandling]) {
        self.handlers = handlers
    }
    
    func startChain(with context: UserContext, completion: @escaping () -> Void) {
        runNext(index: 0, context: context, completion: completion)
    }
    
    private func runNext(index: Int, context: UserContext, completion: @escaping () -> Void) {
        guard index < handlers.count else {
            completion()
            return
        }
        
        let handler = handlers[index]
        
        if handler.shouldHandle(context) {
            handler.show { [weak self] in
                self?.runNext(index: index + 1, context: context, completion: completion)
            }
        } else {
            runNext(index: index + 1, context: context, completion: completion)
        }
    }
}
```

---

## 使用方式

```swift
// 1. 外部組裝 Handler
let handlers: [any PopupHandling] = [
    TutorialHandler(),
    InterstitialAdHandler(),
    NewFeatureHandler(),
    DailyCheckInHandler(),
    PredictionResultHandler()
]

// 2. 建立 Manager（注入 handlers）
let manager = PopupChainManager(handlers: handlers)

// 3. 建立 Context
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

### 預期輸出（首次開啟 App）

```
[彈窗] 新手教學
[彈窗] 插頁式廣告
[彈窗] 新功能公告
[彈窗] 每日簽到
[彈窗] 猜多空結果
✅ 彈窗檢查完成
```

---

## 測試

### Handler 單元測試

```swift
import XCTest

final class TutorialHandlerTests: XCTestCase {
    
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
}
```

### Chain 整合測試

```swift
import XCTest

final class PopupChainRunnerTests: XCTestCase {
    
    func testRun_WhenAllConditionsMet_Completes() {
        let handlers: [any PopupHandling] = [
            TutorialHandler(),
            InterstitialAdHandler(),
            NewFeatureHandler(),
            DailyCheckInHandler(),
            PredictionResultHandler()
        ]
        let context = UserContext(
            hasSeenTutorial: false,
            hasSeenInterstitialAd: false,
            hasSeenNewFeature: false,
            hasCheckedInToday: false,
            hasPredictionResult: true
        )
        let expectation = expectation(description: "Chain completed")
        
        PopupChainRunner.run(handlers: handlers, context: context) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testRun_WithEmptyHandlers_CompletesImmediately() {
        let expectation = expectation(description: "Chain completed")
        
        PopupChainRunner.run(handlers: [], context: UserContext()) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
}
```

---

## 擴展性

### 新增第 6 個 Handler

```swift
// 1. 建立新的 struct
struct RatingPromptHandler: PopupHandling {
    
    func shouldHandle(_ context: UserContext) -> Bool {
        context.shouldShowRating  // 需在 UserContext 新增此屬性
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
    RatingPromptHandler()  // 新增
]
```

**不需要修改任何現有程式碼！**

---

## 與作業要求的對照

| 作業要求 | 是否滿足 | 實作方式 |
|---------|---------|---------|
| 1. 定義 Protocol | ✅ | `PopupHandling` protocol |
| 2. 實作各種 Handler | ✅ | 5 個 struct |
| 3. 串接 Handler Chain | ✅ | `PopupChainRunner.run()` |
| 4. 建立 Manager | ✅ | `PopupChainRunner`（或可包成 class） |
| 5. 可擴展性 | ✅ | 新增 struct + 加入陣列 |

---

## 設計優勢

1. **乾淨的使用語法**
   ```swift
   let handlers = [TutorialHandler(), InterstitialAdHandler(), ...]
   ```

2. **編譯期安全**
   - Protocol 強制實作 `shouldHandle` 和 `show`
   - 忘記實作 → 編譯失敗（不是 runtime crash）

3. **無繼承、無 fatalError**
   - 每個 Handler 是獨立的 struct
   - 沒有 BasePopupHandler 基底類別

4. **符合 Swift 風格**
   - Protocol-Oriented Programming
   - Value Type（struct）優先

5. **易於測試**
   - struct 是 value type，好建立、好比較
   - 不需要 mock class

---

## Implementation Checklist

### 核心組件
- [ ] UserContext struct
- [ ] PopupHandling protocol
- [ ] TutorialHandler struct
- [ ] InterstitialAdHandler struct
- [ ] NewFeatureHandler struct
- [ ] DailyCheckInHandler struct
- [ ] PredictionResultHandler struct
- [ ] PopupChainManager

### 測試
- [ ] Handler 單元測試（10 個）
- [ ] Chain 整合測試（5 個）
- [ ] 擴展性測試（2 個）

### 文件
- [ ] 更新 README.md
- [ ] 更新 tasks.md

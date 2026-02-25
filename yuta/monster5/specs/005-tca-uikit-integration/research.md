# Research: TCA + UIKit 整合實戰

**Feature**: Monster 5 - TCA + UIKit Integration
**Date**: 2026-02-13

---

## R1: TCA + UIKit 整合模式

### Decision: 使用 `observe {}` closure 模式

### Rationale
TCA 1.7+ 引入了 `observe {}` API，專為 UIKit 設計。此 API 會自動追蹤 closure 內存取的 state 屬性，僅在相關屬性變化時重新執行 closure，效能優於傳統 Combine `sink` 方式。

### Alternatives Considered
| Alternative | Why Rejected |
|------------|--------------|
| Combine `store.publisher.sink` | TCA 1.7+ 前的舊模式，需手動管理 subscription，容易遺漏 state 變化 |
| ViewStore (舊版) | TCA 1.0+ 已棄用 ViewStore，改用 `observe {}` |
| SwiftUI `WithPerceptionTracking` | 本作業要求 UIKit，不適用 |

### Key Implementation Pattern
```swift
// 在 ViewController 中
override func viewDidLoad() {
    super.viewDidLoad()
    observe { [weak self] in
        guard let self else { return }
        // 存取 store.state 屬性，自動追蹤變化
        loginButton.isEnabled = store.isFormValid && !store.isLoading
        activityIndicator.isAnimating = store.isLoading
    }
}
```

---

## R2: TCA 導航模式選擇

### Decision: Stack-based Navigation (Home→Detail) + Root Replacement (Login→Home)

### Rationale
- **Stack-based**: Home→Detail 為標準 push/pop 導航，`StackState` + `StackAction` 天然對應 `UINavigationController`
- **Root Replacement**: Login→Home 為根畫面切換，不需要 navigation stack，由 AppCoordinator 直接替換 `window.rootViewController`

### Alternatives Considered
| Alternative | Why Rejected |
|------------|--------------|
| Tree-based (全部用 `@Presents`) | Home→Detail 需要 stack 語義（可能多層 push），Tree-based 較適合 modal/sheet |
| 全 Stack-based（含 Login） | Login 不是 stack 的一部分，強制放入 stack 會導致 back button 問題 |
| UIKit delegate pattern（不用 TCA 導航） | 失去 TCA 導航狀態的可測試性 |

### Key Implementation Pattern
```swift
// HomeFeature - Stack Navigation
@Reducer
struct HomeFeature {
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
    }

    @Reducer
    enum Path {
        case postDetail(PostDetailFeature)
    }
}
```

---

## R3: 狀態同步策略

### Decision: Delegate Action 模式

### Rationale
TCA 官方推薦使用 Delegate Action 進行子→父通訊。PostDetailFeature 透過 `.delegate(.interactionUpdated(...))` 通知 HomeFeature，HomeFeature 在 `path` action 中攔截並更新自己的 `interactions` state。此模式：
- 避免 shared mutable state
- 保持單向資料流
- 完全可測試（TestStore 可驗證 delegate action）

### Alternatives Considered
| Alternative | Why Rejected |
|------------|--------------|
| Shared State (`@Shared`) | TCA 1.7+ 支援，但對此簡單場景過度設計；delegate 更明確 |
| NotificationCenter | 非 TCA 慣例，繞過架構，難以測試 |
| Callback closure | 不符合 TCA 的 Action-driven 設計哲學 |

---

## R4: Error Auto-dismiss 實作

### Decision: `@Dependency(\.continuousClock)` + `cancellable` Effect

### Rationale
使用 TCA 的 `ContinuousClock` 依賴搭配 `cancellable` modifier：
- 生產環境使用真實時鐘（3 秒延遲）
- 測試環境使用 `TestClock`，可精確控制時間
- `CancelID` 確保：手動 dismiss 或重新登入時取消舊計時器

### Alternatives Considered
| Alternative | Why Rejected |
|------------|--------------|
| DispatchQueue.main.asyncAfter | 無法在測試中控制時間 |
| Timer.publish (Combine) | 需額外管理 subscription，不如 TCA Effect 優雅 |
| UIView.animate delay | UI 層處理邏輯，違反單向資料流 |

### Key Implementation Pattern
```swift
case .loginResponse(.failure(let error)):
    state.errorMessage = error.localizedDescription
    return .run { send in
        try await clock.sleep(for: .seconds(3))
        await send(.errorAutoDismissTimerFired)
    }
    .cancellable(id: CancelID.errorAutoDismiss)
```

---

## R5: AppCoordinator 設計

### Decision: 集中式 Coordinator 管理所有 UIKit 導航

### Rationale
UIKit 的導航操作（push/pop/root replacement）不應在 TCA Reducer 中執行。AppCoordinator 觀察 Store 狀態變化，將狀態映射到 UIKit 導航操作。

### Alternatives Considered
| Alternative | Why Rejected |
|------------|--------------|
| VC 自行處理導航 | 分散導航邏輯，難以追蹤和測試 |
| Router pattern | 對此規模過度設計 |
| 每個 Feature 自帶 Coordinator | 增加複雜度，此專案只有 2 層導航 |

### Key Observations
- AppCoordinator 使用 Combine `publisher` 觀察 `isAuthenticated` 和 `home.path`
- `isAuthenticated` 變化 → root VC 切換
- `path.count` 變化 → push/pop PostDetailVC

---

## R6: 持久化策略

### Decision: UserDefaults + JSONEncoder/JSONDecoder

### Rationale
互動數據結構簡單（`[Int: PostInteraction]`），資料量小（最多 100 篇文章），UserDefaults 完全足夠。JSONEncoder 可直接序列化 Codable struct。

### Alternatives Considered
| Alternative | Why Rejected |
|------------|--------------|
| CoreData | 過度設計，無需關聯查詢 |
| FileManager + JSON file | 功能與 UserDefaults 相同但需更多 boilerplate |
| Realm/SwiftData | 引入額外依賴，不符合學習專案的簡潔原則 |
| `@Shared(.fileStorage)` TCA | TCA 內建持久化，但此作業目標是學習自訂 Dependency Client |

---

## R7: DummyJSON API 特性

### Decision: 直接使用 URLSession，自訂 AuthError 解析

### Rationale
DummyJSON 的錯誤回應格式為 `{"message": "Invalid credentials"}`，需要自訂 error 解析。不需要額外 HTTP library。

### API Details
- **Login**: POST `https://dummyjson.com/auth/login`
  - Body: `{"username": "...", "password": "...", "expiresInMins": 30}`
  - 成功: HTTP 200 + User JSON
  - 失敗: HTTP 400 + `{"message": "..."}`
  - 測試帳號: `emilys` / `emilyspass`

- **Posts**: GET `https://jsonplaceholder.typicode.com/posts`
  - 回應: 100 篇 Post JSON array
  - 無認證需求

### Key Implementation Note
兩個 API 來自不同服務（dummyjson vs jsonplaceholder），Post 的 userId 與 Login 的 User.id 無實際關聯。

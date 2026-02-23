# Technical Research: TCA + UIKit 整合實戰

**Feature**: feature/monster5-tca-uikit-integration
**Date**: 2026-02-17

## Research Questions

### RQ-001: TCA + UIKit 整合模式 — observe vs ViewStore

**Question**: TCA 1.7+ 與 UIKit 整合時，應使用 `observe { }` 還是舊版 `ViewStore`？

**Findings**:

| 模式 | TCA 版本 | 特性 | 狀態 |
|------|----------|------|------|
| ViewStore + sink | < 1.7 | 使用 Combine publisher 訂閱 | 已棄用 |
| observe { } | 1.7+ | 使用 Swift Observation 框架 | 推薦 |

`observe { }` 模式優勢：
- 自動追蹤讀取的 state 屬性，只在相關屬性變更時觸發
- 不需手動管理 Cancellable
- 與 SwiftUI 的 `@Observable` 一致的心智模型
- 在 `viewDidLoad` 中設定一次即可

```swift
// 推薦模式
observe { [weak self] in
    guard let self else { return }
    self.usernameField.text = store.username
    self.loginButton.isEnabled = !store.isLoading
}
```

**Decision**: 使用 TCA 1.7+ 的 `observe { }` 模式，這是官方推薦的 UIKit 整合方式。

---

### RQ-002: TCA 導航模式選擇 — Tree-based vs Stack-based

**Question**: 本專案應使用 Tree-based 還是 Stack-based 導航？

**Findings**:

| 模式 | 適用場景 | 工具 |
|------|----------|------|
| Tree-based | 固定的父子關係導航（如 present modal、alert） | `@Presents` + `PresentationAction` + `ifLet` |
| Stack-based | 動態的堆疊導航（如 NavigationStack push/pop） | `StackState` + `StackAction` + `forEach` |

本專案導航流程：
```
Login → (success) → Posts List → (tap cell) → Post Detail
```

分析：
- Login → Posts List：登入成功後的一次性轉場，像是 root 切換
- Posts List → Post Detail：標準的 Navigation push/pop

**Decision**: 使用 **Stack-based Navigation**（`StackState` + `StackAction`）。理由：
1. Posts List → Detail 是典型的 push/pop 堆疊導航
2. 登入成功後可將 Navigation root 切換為 Posts List
3. Stack-based 對 UINavigationController 更自然

---

### RQ-003: TCA Dependency 注入與測試

**Question**: 如何設計 Dependency 以利測試替換？

**Findings**:

TCA 使用 `@Dependency` 屬性包裝器搭配 `DependencyKey` 協定：

```swift
// 定義 Client
struct AuthClient {
    var login: @Sendable (String, String) async throws -> User
}

// 註冊為 DependencyKey
extension AuthClient: DependencyKey {
    static let liveValue = AuthClient(
        login: { username, password in
            // 真實 API 呼叫
        }
    )
    static let testValue = AuthClient(
        login: { _, _ in .mock }
    )
}

// 在 Reducer 中使用
@Dependency(\.authClient) var authClient
```

**Decision**: 定義三個 Client Dependency：
1. `AuthClient` — 登入 API
2. `PostsClient` — 取得文章列表 API
3. `StorageClient` — Local Storage 讀寫

---

### RQ-004: 父子 Feature 狀態同步策略

**Question**: Post Detail 的按讚狀態如何同步回 Posts List？

**Findings**:

在 TCA 中有幾種狀態同步策略：

| 策略 | 說明 | 優點 | 缺點 |
|------|------|------|------|
| Shared State | 父子 Feature 共用同一份 State | 自動同步 | 緊耦合 |
| Delegate Action | 子 Feature 發送 delegate action 給父 Feature | 解耦 | 需額外 Action |
| @Shared | TCA 1.7+ 的 @Shared 屬性包裝器 | 自動同步且解耦 | 較新 API |

**Decision**: 採用 **Shared State** 搭配 **IdentifiedArray** 策略：
- Posts List 持有 `IdentifiedArrayOf<PostDetailFeature.State>`
- 點擊 Cell 時將對應的 State 傳入 Detail
- Detail 的操作直接修改 IdentifiedArray 中的元素
- 返回列表時 State 已同步更新

這種方式最直觀，因為 Detail 操作的就是列表中的同一份 State。

---

### RQ-005: Error Toast 實作方式

**Question**: UIKit 中如何實作自動消失的 Error Toast？

**Findings**:

| 方案 | 說明 | 複雜度 |
|------|------|--------|
| 自訂 UIView + Animation | 手寫 Toast View，使用 UIView.animate | 中 |
| UILabel + Timer | 簡單 UILabel 加 3 秒 Timer | 低 |
| Third-party (SwiftMessages) | 使用第三方套件 | 低（但增加依賴）|

**Decision**: 自訂簡單 Toast UIView：
- 使用 UIView 子類，背景色 + 文字
- 使用 UIView.animate 淡入淡出
- TCA Side Effect 中使用 `try await Task.sleep(for: .seconds(3))` 觸發自動關閉 Action

---

### RQ-006: Local Storage 資料格式

**Question**: 互動數據應如何在 UserDefaults 中儲存？

**Findings**:

| 方案 | 說明 | 優點 | 缺點 |
|------|------|------|------|
| Key 分散儲存 | 每個互動一個 key（如 `like_1`, `like_2`） | 簡單 | key 爆炸 |
| JSON 整包儲存 | 序列化整個 Dictionary 為 JSON | 結構化 | 需序列化 |
| Codable 物件 | 自訂 Codable struct 儲存 | 型別安全 | 稍複雜 |

**Decision**: 使用 **Codable 物件 JSON 整包儲存**：
```swift
struct PostInteractionStore: Codable {
    var interactions: [Int: PostInteraction]  // key = postId
}
```
- 使用 `JSONEncoder`/`JSONDecoder` 序列化
- 儲存在 UserDefaults 的單一 key `"post_interactions"` 下
- 提供型別安全的存取介面

---

### RQ-007: UITableView Cell 中的 Action 傳遞

**Question**: UITableView Cell 中的按讚/分享按鈕事件如何傳遞到 TCA Store？

**Findings**:

| 方案 | 說明 |
|------|------|
| Closure callback | Cell 提供 closure，ViewController 在 cellForRowAt 中綁定 |
| Delegate | Cell 定義 delegate protocol |
| TCA Store 直接傳入 Cell | 將 child store 傳給 Cell |

**Decision**: 使用 **Closure callback** 模式：
- Cell 提供 `onLikeTapped`、`onShareTapped` closure
- ViewController 在 `cellForRowAt` 中設定 closure，呼叫 `store.send()`
- 簡單直接，不需要額外 protocol

---

### RQ-008: DummyJSON Auth API 錯誤回應格式

**Question**: DummyJSON API 在登入失敗時回傳什麼格式？

**Findings**:

成功回應 (200):
```json
{
  "id": 1,
  "username": "emilys",
  "email": "emily.johnson@x.dummyjson.com",
  "firstName": "Emily",
  "lastName": "Johnson",
  "gender": "female",
  "image": "https://dummyjson.com/icon/emilys/128",
  "accessToken": "eyJhbGciOi...",
  "refreshToken": "eyJhbGciOi..."
}
```

失敗回應 (400):
```json
{
  "message": "Invalid credentials"
}
```

**Decision**: 定義兩個 Codable Model：
- `LoginResponse`: 成功時解析
- `APIError`: 失敗時解析，取出 message 顯示給使用者

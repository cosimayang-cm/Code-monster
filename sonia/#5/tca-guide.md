# TCA + UIKit 完整教學指南

以 Monster5 專案為範例，涵蓋 TCA 所有核心概念。

---

## 目錄

1. [TCA 核心概念](#1-tca-核心概念)
2. [TCA vs MVVM](#2-tca-vs-mvvm)
3. [Store 與 Scope](#3-store-與-scope)
4. [observe 與效能](#4-observe-與效能)
5. [KeyPath 與 CaseKeyPath](#5-keypath-與-casekeypath)
6. [Effect 與 Swift Concurrency](#6-effect-與-swift-concurrency)
7. [Structured Concurrency 與自動取消](#7-structured-concurrency-與自動取消)
8. [TestStore 測試](#8-teststore-測試)
9. [實戰注意事項](#9-實戰注意事項)

---

## 1. TCA 核心概念

TCA 就是一台**自動販賣機**：

```
┌─────────────────────────────┐
│        自動販賣機 (Store)      │
│                             │
│  State   → 螢幕顯示什麼       │
│  Action  → 按了哪個按鈕       │
│  Reducer → 內部規則           │
│  Effect  → 跟外面溝通         │
└─────────────────────────────┘
```

### State = 現在的狀況

State 是「畫面上該顯示什麼」的描述：

```swift
@ObservableState
struct State: Equatable {
    var username = ""        // 使用者名稱欄位
    var password = ""        // 密碼欄位
    var isLoading = false    // 有沒有在轉圈圈
    var errorMessage: String? // 有沒有錯誤訊息
}
```

### Action = 發生了什麼事

Action 是使用者的操作或外部回傳的結果：

```swift
enum Action {
    case usernameChanged(String)        // 使用者打了名字
    case loginTapped                    // 使用者按了登入
    case loginResponse(Result<...>)     // 伺服器回應
}
```

### Reducer = 遊戲規則

Reducer 定義「某件事發生後，狀況要怎麼變」：

```swift
Reduce { state, action in
    switch action {
    case .loginTapped:
        state.isLoading = true                          // 同步改 State
        return .run { send in                           // 非同步副作用
            let result = try await authClient.login(...)
            await send(.loginResponse(result))          // 結果送回 Reducer
        }
    case let .loginResponse(.success(response)):
        state.isLoading = false
        return .none                                    // 沒有副作用
    }
}
```

### Store = 把以上全部裝在一起

```swift
let store = Store(initialState: LoginFeature.State()) {
    LoginFeature()
}
```

Store 是主持人：保管 State、接收 Action、查規則書（Reducer）、更新畫面。

### Effect = 需要等的事情

```swift
// 做完要回報
return .run { send in
    let posts = try await api.fetchPosts()
    await send(.postsResponse(posts))
}

// 做完不用回報（fire-and-forget）
return .run { _ in
    try storage.save(interaction)
}

// 不用做任何事
return .none
```

### Dependency = 做事的工具人

```swift
@Dependency(\.authClient) var authClient       // 負責登入
@Dependency(\.postsClient) var postsClient     // 負責抓文章
@Dependency(\.storageClient) var storageClient // 負責存檔
```

好處是測試時可以換成假的：

```swift
// 真的環境
static let liveValue = PostsClient(fetchPosts: { /* 真的呼叫 API */ })

// 測試環境
static let testValue = PostsClient()
```

---

## 2. TCA vs MVVM

### MVVM — ViewModel 大權在握

```swift
class PostsListViewModel {
    @Published var posts: [PostWithInteraction] = []

    func likeTapped(postId: Int) {
        posts[index].isLiked.toggle()     // 改狀態
        storage.save(...)                  // 存檔
        analytics.track("liked")           // 追蹤
        // 想做什麼都行，沒人阻止你
    }
}
```

### TCA — 一切照規矩來

```swift
case let .likeTapped(postId):
    // 同步改 State（在 Reduce 裡面）
    state.posts[index].interaction.isLiked.toggle()

    // 副作用（回傳 Effect，不能偷改 state）
    return .run { [interaction = state.posts[index].interaction] _ in
        try storageClient.saveInteraction(interaction)
    }
```

### 關鍵差異

| | MVVM | TCA |
|---|---|---|
| **狀態在哪** | ViewModel 的 `@Published`，散落各處 | `State` struct，集中一個地方 |
| **誰能改狀態** | 任何 method 都能直接改 | **只有 Reducer** 能改 |
| **副作用** | ViewModel 裡直接呼叫 | 必須回傳 `Effect` |
| **外部依賴** | 自己注入或 singleton | `@Dependency` 統一管理 |
| **資料流** | 雙向（View ↔ ViewModel） | **單向**（View → Action → Reducer → State → View） |
| **測試** | Mock service，驗證屬性 | `TestStore`，逐步驗證每個 State 變化 |

### 什麼時候選哪個

| 情境 | 建議 |
|---|---|
| 小功能、快速原型 | MVVM |
| 多人協作、長期維護 | TCA |
| 狀態複雜、多畫面同步 | TCA |
| 團隊不熟 functional programming | MVVM |

> **MVVM 像寫作文，自由發揮；TCA 像填表格，每一格都規定好要填什麼。**

---

## 3. Store 與 Scope

### 全貌：Monster5 的 Store 結構

```
┌─ AppFeature.Store ──────────────────────────────┐
│  State {                                         │
│    login: LoginFeature.State        ← 登入頁資料  │
│    postsList: PostsListFeature.State ← 文章列表   │
│    postDetail: PostDetailFeature.State? ← 文章詳情│
│    isLoggedIn: Bool                              │
│  }                                               │
└──────────────────────────────────────────────────┘
```

整個 App 只有**一個大 Store**。但每個 VC 不需要看到全部。

### Scope = 給每個頁面一副專屬眼鏡

```
               大 Store（AppFeature）
        ┌──────────┬───────────┬───────────┐
        │  login   │ postsList │postDetail │
        └────┬─────┴─────┬─────┴─────┬─────┘
         scope 切       scope 切    scope 切
             │           │           │
             ▼           ▼           ▼
        ┌─────────┐ ┌──────────┐ ┌──────────┐
        │ LoginVC  │ │PostsListVC│ │PostDetailVC│
        │只看到     │ │只看到      │ │只看到      │
        │username  │ │posts     │ │post      │
        │password  │ │isLoading │ │interaction│
        └─────────┘ └──────────┘ └──────────┘
```

### 型別決定你看得到什麼

```swift
// AppCoordinator 持有大 Store（上帝視角）
let store: StoreOf<AppFeature>
store.login.username      // ✅
store.postsList.posts     // ✅
store.postDetail          // ✅

// PostsListVC 持有 scope 過的小 Store
let store: StoreOf<PostsListFeature>
store.posts               // ✅
store.isLoading           // ✅
store.login.username      // ❌ 編譯錯誤！型別上根本不存在
```

### AppCoordinator 怎麼切 scope

```swift
// AppCoordinator.swift
override func viewDidLoad() {
    super.viewDidLoad()

    let loginVC = LoginViewController(
        store: store.scope(state: \.login, action: \.login)
    )
    setViewControllers([loginVC], animated: false)
}
```

### Action 的自動包裝

```
LoginVC 送出:    .loginTapped
                    │
        scope 自動包裝（action: \.login）
                    │
                    ▼
AppFeature 收到:  .login(.loginTapped)
                    │
        Scope(state: \.login, action: \.login) { LoginFeature() }
                    │
                    ▼
LoginFeature 處理:  .loginTapped → state.isLoading = true
                    │
        state 更新寫回 AppFeature.State.login
                    │
                    ▼
LoginVC 的 observe 偵測到 → 畫面更新
```

### Optional State 的 scope

PostDetail 是有時存在、有時不存在的：

```swift
var postDetail: PostDetailFeature.State?   // optional

// scope 出來也是 optional
if let detailStore = store.scope(state: \.postDetail, action: \.postDetail) {
    // 有值 → push
    pushViewController(PostDetailViewController(store: detailStore), animated: true)
}
// nil → 不 push
```

### Reducer Scope vs store.scope()

兩個不同的東西，各司其職：

```swift
// Reducer 裡的 Scope — 定義「誰處理邏輯」
Scope(state: \.player1, action: \.player1) {
    PlayerFeature()  // .player1 的 Action 交給 PlayerFeature 處理
}

// VC 裡的 store.scope() — 定義「誰看得到什麼」
let player1VC = PlayerViewController(
    store: store.scope(state: \.player1, action: \.player1)
    //     切出只看得到 player1 的小 Store
)
```

兩者用同一組 key path，必須對應：

```
Reducer 的 Scope       store.scope()
「Action 怎麼處理」     「VC 看到什麼」
     \.player1      ←→    \.player1
```

### Key Path vs Closure Scoping（重要陷阱）

```swift
// ❌ closure 抓快照 — State 永遠不更新
store.scope(state: { _ in capturedState }, action: { ... })
// 像拍了一張照片，之後看的永遠是那張照片

// ✅ key path 抓路徑 — 每次都拿最新值
store.scope(state: \.postsList, action: \.postsList)
// 像給了一個地址，每次都去那個地址看最新狀況
```

> Monster5 之前的 bug 就是用了 closure scoping，導致 PostsListVC 永遠看到空的 State。

---

## 4. observe 與效能

### observe 只追蹤你「讀了什麼」

```swift
observe { [weak self] in
    guard let self else { return }
    let isLoading = store.isLoading       // 追蹤 isLoading
    let posts = store.posts               // 追蹤 posts
    // login.username → 沒讀，不追蹤
    // postDetail → 沒讀，不追蹤
}
```

### 什麼時候 observe 會重新執行

```
事件                       PostsListVC    PostDetailVC   AppCoordinator
                           的 observe     的 observe     的 observe
────────────────────────────────────────────────────────────────
使用者打帳號                  —              —              —
(login.username 變)        沒追蹤          沒追蹤          沒追蹤

登入成功                     —              —              重執行
(isLoggedIn 變)            沒追蹤          沒追蹤          有追蹤

API 回傳文章                 重執行          —              —
(postsList.posts 變)       有追蹤          沒追蹤          沒追蹤

使用者在詳情按讚              重執行          重執行          重執行
(postDetail + postsList)   posts 被同步   interaction 變  但沒事要做
```

### 注意：別在 observe 裡讀不需要的東西

```swift
// ❌ 碰了整個 store，任何屬性變都會觸發
observe { [weak self] in
    let _ = store
    self?.tableView.reloadData()
}

// ✅ 只讀需要的
observe { [weak self] in
    let posts = store.posts
    let isLoading = store.isLoading
}
```

> **scope 本身零成本，observe 的成本取決於你讀了多少屬性，不是大 Store 有多大。**

---

## 5. KeyPath 與 CaseKeyPath

State 和 Action 各自定義自己的 key path：

```swift
@Reducer
struct GameFeature {
    @ObservableState
    struct State: Equatable {
        var player1 = PlayerFeature.State(name: "Alice")  // → \.player1 (KeyPath)
        var player2 = PlayerFeature.State(name: "Bob")    // → \.player2 (KeyPath)
    }

    enum Action {
        case player1(PlayerFeature.Action)  // → \.player1 (CaseKeyPath)
        case player2(PlayerFeature.Action)  // → \.player2 (CaseKeyPath)
    }
}
```

寫 `Scope(state: \.player1, action: \.player1)` 時，兩個 `\.player1` 是不同的東西：

```swift
Scope(
    state:  \.player1,  // KeyPath<State, PlayerFeature.State>     ← struct 屬性
    action: \.player1   // CaseKeyPath<Action, PlayerFeature.Action> ← enum case
)
```

Swift 靠型別推斷分辨放在 `state:` 位置的是 KeyPath，放在 `action:` 位置的是 CaseKeyPath。

### CaseKeyPath 是 Swift 原生的

從 **Swift 5.9** 開始支援，不是 TCA 自己的東西：

```swift
// Swift 5.9 之前：TCA 用 pointfree 自己的 CasePath 套件
Scope(state: \.player1, action: /GameFeature.Action.player1)

// Swift 5.9 之後：用原生 CaseKeyPath
Scope(state: \.player1, action: \.player1)
```

---

## 6. Effect 與 Swift Concurrency

### 現在的 TCA 不用 Combine

```
TCA 0.x（早期）              TCA 1.0+（現在）
──────────────              ──────────────
Effect = Combine Publisher   Effect = async/await 包裝

return Effect.future {       return .run { send in
  callback(.success(...))      let data = try await api.fetch()
}                              await send(.response(data))
                             }
```

### Effect 的三種用法

```swift
// 1. 不用做任何副作用
return .none

// 2. 做完要送 Action 回來
return .run { send in
    let posts = try await api.fetchPosts()
    await send(.postsResponse(posts))
}

// 3. 做完不用送 Action（fire-and-forget）
return .run { _ in
    try storage.save(interaction)
}
```

---

## 7. Structured Concurrency 與自動取消

### Effect.run 就是一個 child Task

```swift
case .onAppear:
    state.isLoading = true
    return .run { send in                         // TCA 開一個 Task
        let result = try await postsClient.fetchPosts()  // 在 Task 裡跑
        await send(.postsResponse(result))
    }
```

### 自動取消：ifLet + optional state

```swift
// AppFeature.swift
Reduce { ... }
    .ifLet(\.postDetail, action: \.postDetail) {
        PostDetailFeature()
    }
```

```
使用者進入 PostDetail → Effect 開始跑
使用者按返回 → state.postDetail = nil
            → ifLet 偵測到 nil → 自動 cancel 所有 Effect ✅
```

**不用手動取消。** 如果是 MVVM，你要自己 `cancellables.removeAll()`。

### 手動取消：cancel(id:) + cancelInFlight

搜尋時，打新字就取消上一次搜尋：

```swift
case let .queryChanged(query):
    state.query = query
    return .run { send in
        try await Task.sleep(for: .milliseconds(300))  // debounce
        let results = try await api.search(query)
        await send(.searchResponse(results))
    }
    .cancellable(id: CancelID.search, cancelInFlight: true)
    //                                  ▲ 上一次還在跑？自動取消
```

```
打 "S"   → Task 1 啟動
打 "Sw"  → Task 1 取消 → Task 2 啟動
打 "Swi" → Task 2 取消 → Task 3 啟動
停 300ms → Task 3 完成 → 回傳結果
```

### 多個 Effect 並行：.merge

```swift
case .onAppear:
    return .merge(
        .run { send in
            let posts = try await postsClient.fetchPosts()
            await send(.postsLoaded(posts))
        },
        .run { send in
            let user = try await userClient.fetchProfile()
            await send(.profileLoaded(user))
        }
    )
    // 兩個 Task 同時跑，誰先完成誰先回
    // 功能被取消時，兩個 Task 都自動取消
```

---

## 8. TestStore 測試

### 核心規則：逐步驗證每一個 State 變化

```swift
func testLikeTapped() async {
    // 1. 建立 TestStore
    let store = TestStore(
        initialState: PostsListFeature.State(
            posts: [
                PostWithInteraction(
                    post: Post(userId: 1, id: 1, title: "Hello", body: "World"),
                    interaction: PostInteraction(postId: 1, likeCount: 0)
                )
            ]
        )
    ) {
        PostsListFeature()
    } withDependencies: {
        // 2. 注入假依賴
        $0.storageClient.saveInteraction = { _ in }
    }

    // 3. 送 Action，驗每個 State 變化
    await store.send(.likeTapped(postId: 1)) {
        $0.posts[id: 1]?.interaction.isLiked = true   // 必須寫
        $0.posts[id: 1]?.interaction.likeCount = 1    // 必須寫，少一行就報錯
    }
}
```

### Effect 回傳 Action 用 receive 接

```swift
func testOnAppearFetchesPosts() async {
    let mockPosts = [Post(userId: 1, id: 1, title: "Hello", body: "World")]

    let store = TestStore(
        initialState: PostsListFeature.State()
    ) {
        PostsListFeature()
    } withDependencies: {
        $0.postsClient.fetchPosts = { mockPosts }
        $0.storageClient.loadAllInteractions = { [:] }
    }

    // send：驗同步 State 變化
    await store.send(.onAppear) {
        $0.isLoading = true
    }

    // receive：驗 Effect 回傳的 Action 造成的 State 變化
    await store.receive(\.postsResponse.success) {
        $0.isLoading = false
        $0.posts = [
            PostWithInteraction(
                post: mockPosts[0],
                interaction: PostInteraction(postId: 1)
            )
        ]
    }
}
```

### 測試時間：TestClock

Monster5 的「錯誤訊息 3 秒後自動消失」不用真的等 3 秒：

```swift
func testErrorAutoDismisses() async {
    let clock = TestClock()

    let store = TestStore(
        initialState: LoginFeature.State()
    ) {
        LoginFeature()
    } withDependencies: {
        $0.authClient.login = { _, _ in throw AuthError.loginFailed("Wrong") }
        $0.continuousClock = clock
    }

    await store.send(.loginTapped) {
        $0.isLoading = true
    }

    await store.receive(\.loginResponse.failure) {
        $0.isLoading = false
        $0.errorMessage = "Wrong"
    }

    // 時間快轉 3 秒（實際 0 秒完成）
    await clock.advance(by: .seconds(3))

    await store.receive(\.dismissError) {
        $0.errorMessage = nil
    }
}
```

### TestStore 的完整檢查清單

```
送了 Action → State 有變？ → 你在 send { } 裡寫出每個變化了嗎？    → 沒寫到 ❌
Effect 回傳 Action        → 你有寫 receive 接嗎？                → 沒接 ❌
receive 裡的 State 變化   → 你寫出每個變化了嗎？                  → 沒寫到 ❌
測試結束時                 → 還有 Effect 在飛？                   → 有 ❌
```

> **TestStore 是超嚴格的閱卷老師——每一步都要寫出來，漏寫就是零分。**

---

## 9. 實戰注意事項

### 9.1 Reducer 的執行順序

`body` 裡的排列順序 = 執行順序，**先寫的先跑**：

```swift
var body: some ReducerOf<Self> {
    Scope(state: \.login, action: \.login) { LoginFeature() }              // 1st
    Scope(state: \.postsList, action: \.postsList) { PostsListFeature() }  // 2nd
    Reduce { state, action in ... }                                        // 4th
        .ifLet(\.postDetail, action: \.postDetail) { PostDetailFeature() } // 3rd (ifLet 子先跑)
}
```

Monster5 靠這個順序實現同步——PostDetailFeature 先更新 interaction，Reduce 再讀取已更新的值同步回 postsList。

### 9.2 除錯神器：_printChanges()

```swift
var body: some ReducerOf<Self> {
    Reduce { state, action in ... }
        ._printChanges()  // Console 印出每個 Action 造成的 State diff
}
```

```
received action:
  PostsListFeature.Action.likeTapped(postId: 1)
- posts[id: 1].interaction.isLiked: false
+ posts[id: 1].interaction.isLiked: true
```

上線前記得拿掉。

### 9.3 State 必須是 struct

```swift
// ✅ struct（value type，可以比較前後差異）
@ObservableState
struct State: Equatable { var score = 0 }

// ❌ class（reference type，改了還是同一個物件，比不出差異）
class State { ... }
```

TCA 靠值比較知道 State 有沒有變。TestStore 也是存一份 copy 跟改完的比。

### 9.4 Action 裡避免放不能比較的東西

```swift
// Error 不符合 Equatable，TestStore 無法直接比對
enum Action {
    case response(Result<[Post], Error>)
}

// 解法：receive 用 key path 匹配，不比對 Error 值
await store.receive(\.postsResponse.success) { ... }
```

### 9.5 Effect 裡不能直接改 State

```swift
// ❌ Effect 閉包裡碰不到 state
return .run { send in
    state.isLoading = true  // 編譯錯誤
}

// ✅ 先同步改 State，Effect 裡只做副作用
case .onAppear:
    state.isLoading = true                              // 在 Reduce 裡改 State
    return .run { send in
        let posts = try await api.fetch()               // 在 Effect 裡做副作用
        await send(.postsResponse(posts))               // 結果用 Action 送回
    }
```

**強制分離：Reduce 裡面改 State，Effect 裡面做副作用。**

### 9.6 用 @Shared 跨功能共享狀態

不相關的功能需要讀同一個值時：

```swift
@ObservableState
struct State: Equatable {
    @Shared(.appStorage("isOnboarded")) var isOnboarded = false
    // 任何功能都能讀寫，自動同步，底層用 UserDefaults
}
```

---

## 完整流程圖（以 Monster5 按讚為例）

```
使用者在列表按了 ❤️
      │
      ▼
PostsListVC: store.send(.likeTapped(postId: 1))
      │
      │  scope 包裝
      ▼
AppFeature 收到: .postsList(.likeTapped(postId: 1))
      │
      │  Scope(\.postsList) 轉交
      ▼
PostsListFeature Reducer:
  1. state.posts[1].interaction.isLiked = true
  2. state.posts[1].interaction.likeCount += 1
  3. return .run { storageClient.saveInteraction(...) }
      │                    │
      ▼                    ▼
 State 更新           Effect: 存到 UserDefaults
      │
      ▼
 PostsListVC observe 觸發
 → tableView.reloadData()
 → 🤍 0  變成  ❤️ 1
```

---

## 一句話總結

> **TCA 就是：畫面 (State) 只能透過事件 (Action) 按照規則 (Reducer) 來改變。所有的改變都有跡可循。**

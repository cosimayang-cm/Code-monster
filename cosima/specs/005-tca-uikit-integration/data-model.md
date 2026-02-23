# Data Model: TCA + UIKit 整合實戰

**Feature**: feature/monster5-tca-uikit-integration
**Date**: 2026-02-17

## Entity Relationship Diagram

```
┌──────────────┐       ┌──────────────┐       ┌───────────────────┐
│  AppFeature  │──────►│ LoginFeature │       │   PostsFeature    │
│   (State)    │──────►│   (State)    │       │     (State)       │
└──────────────┘       └──────────────┘       └────────┬──────────┘
       │                      │                        │
       │ navigation           │ user                   │ posts (IdentifiedArray)
       ▼                      ▼                        ▼
┌──────────────┐       ┌──────────────┐       ┌───────────────────┐
│  StackState  │       │     User     │       │ PostDetailFeature │
│  (Path)      │       │              │       │     (State)       │
└──────────────┘       └──────────────┘       └────────┬──────────┘
                                                       │
                                                       │ interaction
                                                       ▼
                                              ┌───────────────────┐
                                              │  PostInteraction  │
                                              │                   │
                                              └────────┬──────────┘
                                                       │
                                                       │ comments
                                                       ▼
                                              ┌───────────────────┐
                                              │     Comment       │
                                              └───────────────────┘
```

## Core Entities

### 1. User (API Response Model)

登入成功後 API 回傳的用戶資訊。

```swift
struct User: Codable, Equatable {
    let id: Int
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let gender: String
    let image: String
    let accessToken: String
    let refreshToken: String
}
```

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| id | Int | ✅ | 用戶唯一 ID |
| username | String | ✅ | 帳號名稱 |
| email | String | ✅ | 電子信箱 |
| firstName | String | ✅ | 名 |
| lastName | String | ✅ | 姓 |
| gender | String | ✅ | 性別 |
| image | String | ✅ | 頭像 URL |
| accessToken | String | ✅ | JWT access token |
| refreshToken | String | ✅ | JWT refresh token |

---

### 2. Post (API Response Model)

文章列表 API 回傳的文章資料。

```swift
struct Post: Codable, Equatable, Identifiable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}
```

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| userId | Int | ✅ | 發文者 ID |
| id | Int | ✅ | 文章唯一 ID |
| title | String | ✅ | 文章標題 |
| body | String | ✅ | 文章內容 |

---

### 3. PostInteraction (Local Model)

每篇文章的互動數據，本地儲存。

```swift
struct PostInteraction: Codable, Equatable {
    var postId: Int
    var likeCount: Int
    var isLiked: Bool
    var comments: [Comment]
    var shareCount: Int
}
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| postId | Int | - | 對應的文章 ID |
| likeCount | Int | 0 | 按讚總數 |
| isLiked | Bool | false | 當前使用者是否已按讚 |
| comments | [Comment] | [] | 留言列表 |
| shareCount | Int | 0 | 分享次數 |

---

### 4. Comment (Local Model)

使用者留言資料。

```swift
struct Comment: Codable, Equatable, Identifiable {
    let id: UUID
    let postId: Int
    let content: String
    let createdAt: Date
}
```

| Property | Type | Description |
|----------|------|-------------|
| id | UUID | 留言唯一 ID |
| postId | Int | 對應的文章 ID |
| content | String | 留言文字 |
| createdAt | Date | 建立時間 |

---

### 5. APIError (Error Model)

API 錯誤回應模型。

```swift
struct APIError: Codable, Equatable, Error {
    let message: String
}
```

---

### 6. PostInteractionStore (Storage Model)

互動數據的整包儲存格式，用於 UserDefaults 序列化。

```swift
struct PostInteractionStore: Codable {
    var interactions: [Int: PostInteraction]  // key = postId
}
```

---

## TCA Feature States

### 7. LoginFeature.State

```swift
@ObservableState
struct State: Equatable {
    var username: String = ""
    var password: String = ""
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var user: User? = nil
}
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| username | String | "" | 帳號輸入值 |
| password | String | "" | 密碼輸入值 |
| isLoading | Bool | false | 是否正在載入 |
| errorMessage | String? | nil | 錯誤訊息 |
| user | User? | nil | 登入成功後的用戶資訊 |

---

### 8. PostsFeature.State

```swift
@ObservableState
struct State: Equatable {
    var posts: IdentifiedArrayOf<PostDetailFeature.State> = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
}
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| posts | IdentifiedArrayOf<PostDetailFeature.State> | [] | 文章列表（含互動資料） |
| isLoading | Bool | false | 是否正在載入 |
| errorMessage | String? | nil | 錯誤訊息 |

---

### 9. PostDetailFeature.State

```swift
@ObservableState
struct State: Equatable, Identifiable {
    let post: Post
    var interaction: PostInteraction
    var commentText: String = ""
    
    var id: Int { post.id }
}
```

| Property | Type | Description |
|----------|------|-------------|
| post | Post | 文章資料（唯讀） |
| interaction | PostInteraction | 互動數據（可寫） |
| commentText | String | 留言輸入框文字 |

---

### 10. AppFeature.State (Navigation)

```swift
@ObservableState
struct State: Equatable {
    var path = StackState<Path.State>()
    var login = LoginFeature.State()
}

@Reducer
enum Path {
    case posts(PostsFeature)
    case postDetail(PostDetailFeature)
}
```

---

## TCA Actions

### LoginFeature.Action

```swift
enum Action: BindableAction {
    case binding(BindingAction<State>)
    case loginButtonTapped
    case loginResponse(Result<User, Error>)
    case dismissError
}
```

### PostsFeature.Action

```swift
enum Action {
    case onAppear
    case postsResponse(Result<[Post], Error>)
    case postTapped(id: Int)
    case post(id: PostDetailFeature.State.ID, action: PostDetailFeature.Action)
}
```

### PostDetailFeature.Action

```swift
enum Action {
    case toggleLike
    case addComment
    case commentTextChanged(String)
    case shareTapped
    case saveInteraction
}
```

### AppFeature.Action

```swift
enum Action {
    case login(LoginFeature.Action)
    case path(StackActionOf<Path>)
}
```

---

## TCA Dependencies

### AuthClient

```swift
struct AuthClient {
    var login: @Sendable (String, String) async throws -> User
}
```

### PostsClient

```swift
struct PostsClient {
    var fetchPosts: @Sendable () async throws -> [Post]
}
```

### StorageClient

```swift
struct StorageClient {
    var loadInteractions: @Sendable () -> [Int: PostInteraction]
    var saveInteractions: @Sendable ([Int: PostInteraction]) -> Void
}
```

---

## API Contracts

### Login API

| 項目 | 值 |
|------|-----|
| Method | POST |
| URL | https://dummyjson.com/auth/login |
| Content-Type | application/json |
| Request Body | `{ "username": "...", "password": "...", "expiresInMins": 30 }` |
| Success (200) | User JSON |
| Error (400) | `{ "message": "Invalid credentials" }` |

### Posts API

| 項目 | 值 |
|------|-----|
| Method | GET |
| URL | https://jsonplaceholder.typicode.com/posts |
| Success (200) | `[Post]` JSON Array (100 items) |

# Data Model: TCA + UIKit 整合實戰

**Feature**: Monster 5 - TCA + UIKit Integration
**Date**: 2026-02-13

---

## Entities

### User

| Field | Type | Description |
|-------|------|-------------|
| id | Int | 使用者 ID (from API) |
| username | String | 使用者名稱 |
| email | String | 電子郵件 |
| firstName | String | 名 |
| lastName | String | 姓 |
| gender | String | 性別 |
| image | String | 頭像 URL |
| accessToken | String | JWT access token |
| refreshToken | String | JWT refresh token |

**Protocols**: `Equatable`, `Codable`, `Sendable`
**Source**: DummyJSON Auth API response

```swift
struct User: Equatable, Codable, Sendable {
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

---

### Post

| Field | Type | Description |
|-------|------|-------------|
| userId | Int | 作者 ID |
| id | Int | 文章 ID (Identifiable) |
| title | String | 文章標題 |
| body | String | 文章內容 |

**Protocols**: `Equatable`, `Codable`, `Sendable`, `Identifiable`
**Source**: JSONPlaceholder Posts API response

```swift
struct Post: Equatable, Codable, Sendable, Identifiable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}
```

---

### Comment

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | 唯一識別碼 (local generated) |
| text | String | 留言內容 |
| createdAt | Date | 建立時間 |

**Protocols**: `Equatable`, `Codable`, `Sendable`, `Identifiable`
**Source**: 本地建立，無 API 來源

```swift
struct Comment: Equatable, Codable, Sendable, Identifiable {
    let id: UUID
    let text: String
    let createdAt: Date
}
```

---

### PostInteraction

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| isLiked | Bool | false | 是否已按讚 |
| likeCount | Int | 0 | 按讚數 |
| comments | [Comment] | [] | 留言列表 |
| shareCount | Int | 0 | 分享數 |

**Computed Properties**:
- `commentCount: Int` → `comments.count`

**Protocols**: `Equatable`, `Codable`, `Sendable`
**Source**: 本地建立 + UserDefaults 持久化

```swift
struct PostInteraction: Equatable, Codable, Sendable {
    var isLiked: Bool = false
    var likeCount: Int = 0
    var comments: [Comment] = []
    var shareCount: Int = 0

    var commentCount: Int { comments.count }
}
```

---

## Relationships

```text
User ──(1:N theoretically)──> Post     (via userId, but not enforced locally)
Post ──(1:1)──> PostInteraction        (via interactions[post.id])
PostInteraction ──(1:N)──> Comment     (embedded array)
```

### Relationship Notes
- `User` 與 `Post` 的 userId 關聯僅為 API 資料，本地不做 join
- `PostInteraction` 透過 `[Int: PostInteraction]` dictionary 與 Post.id 對應
- `Comment` 內嵌於 `PostInteraction.comments`，不獨立存儲

---

## State Structures (TCA)

### AppFeature.State

```swift
@ObservableState
struct State {
    var login = LoginFeature.State()
    var home: HomeFeature.State?

    var isAuthenticated: Bool { home != nil }
}
```

### LoginFeature.State

```swift
@ObservableState
struct State {
    var username = ""
    var password = ""
    var isLoading = false
    var errorMessage: String?
    var user: User?

    var isFormValid: Bool { !username.isEmpty && !password.isEmpty }
}
```

### HomeFeature.State

```swift
@ObservableState
struct State {
    var posts: IdentifiedArrayOf<Post> = []
    var interactions: [Int: PostInteraction] = [:]
    var isLoading = false
    var errorMessage: String?
    var path = StackState<HomeFeature.Path.State>()
    var hasLoadedPosts = false
}
```

### PostDetailFeature.State

```swift
@ObservableState
struct State {
    let post: Post
    var interaction: PostInteraction
    var commentText = ""
    var shouldFocusComment = false
}
```

---

## Storage Schema

### UserDefaults

| Key | Type | Content |
|-----|------|---------|
| `"postInteractions"` | Data (JSON) | `[Int: PostInteraction]` serialized |

### Serialization
- **Encode**: `JSONEncoder().encode(interactions)` → `UserDefaults.standard.set(data, forKey:)`
- **Decode**: `UserDefaults.standard.data(forKey:)` → `JSONDecoder().decode([Int: PostInteraction].self, from:)`
- **Fallback**: Decode failure → return `[:]` (empty dictionary)

---

## Validation Rules

| Rule | Context | Behavior |
|------|---------|----------|
| `isFormValid` | LoginFeature | `!username.isEmpty && !password.isEmpty` |
| Empty comment | PostDetailFeature | `submitComment` 應檢查 `!commentText.trimmingCharacters(in: .whitespaces).isEmpty` |
| Duplicate onAppear | HomeFeature | `hasLoadedPosts` flag 防止重複 API 呼叫 |
| Like toggle | PostDetailFeature | `isLiked ? likeCount - 1 : likeCount + 1` 確保計數一致 |

---

## State Transitions

### Login Flow

```text
[Initial] ──loginButtonTapped──> [Loading] ──success──> [Authenticated]
                                           ──failure──> [Error] ──3s──> [Initial]
                                                                ──dismiss──> [Initial]
```

### Post Interaction Flow

```text
[Default: isLiked=false, likeCount=0]
  ──toggleLike──> [Liked: isLiked=true, likeCount=1]
  ──toggleLike──> [Default: isLiked=false, likeCount=0]

[comments=[]]
  ──submitComment──> [comments=[newComment, ...existing]]

[shareCount=0]
  ──shareTapped──> [shareCount=1]
```

### App Navigation Flow

```text
[Login Screen]
  ──loginSucceeded──> [Home Screen (posts list)]
    ──postTapped──> [PostDetail (shouldFocusComment: false)]
    ──commentTapped──> [PostDetail (shouldFocusComment: true)]
      ──back──> [Home Screen (synced state)]
```

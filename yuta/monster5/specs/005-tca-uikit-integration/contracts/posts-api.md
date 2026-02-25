# API Contract: PostsClient

## Fetch Posts

### Endpoint

```
GET https://jsonplaceholder.typicode.com/posts
```

### Request

**Headers**: None required

### Response - Success (HTTP 200)

```json
[
    {
        "userId": 1,
        "id": 1,
        "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
        "body": "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"
    },
    {
        "userId": 1,
        "id": 2,
        "title": "qui est esse",
        "body": "est rerum tempore vitae\nsequi sint nihil reprehenderit dolor beatae ea dolores neque\nfugiat blanditiis voluptate porro vel nihil molestiae ut reiciendis\nqui aperiam non debitis possimus qui neque nisi nulla"
    }
]
```

**Total**: 100 posts (userId 1-10, id 1-100)

### Response Schema

| Field | Type | Description |
|-------|------|-------------|
| userId | Int | 作者 ID (1-10) |
| id | Int | 文章 ID (1-100) |
| title | String | 文章標題 |
| body | String | 文章內容（含換行符 `\n`） |

### TCA Dependency Client

```swift
@DependencyClient
struct PostsClient: Sendable {
    var fetchPosts: @Sendable () async throws -> [Post]
}

extension PostsClient: DependencyKey {
    static let liveValue: Self = .init(
        fetchPosts: {
            let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode([Post].self, from: data)
        }
    )
}
```

### Test Curl

```bash
curl https://jsonplaceholder.typicode.com/posts
```

## StorageClient (Local Persistence)

### TCA Dependency Client

```swift
@DependencyClient
struct StorageClient: Sendable {
    var loadInteractions: @Sendable () -> [Int: PostInteraction] = { [:] }
    var saveInteractions: @Sendable ([Int: PostInteraction]) -> Void
}

extension StorageClient: DependencyKey {
    static let liveValue: Self = .init(
        loadInteractions: {
            guard let data = UserDefaults.standard.data(forKey: "postInteractions"),
                  let interactions = try? JSONDecoder().decode([Int: PostInteraction].self, from: data)
            else { return [:] }
            return interactions
        },
        saveInteractions: { interactions in
            guard let data = try? JSONEncoder().encode(interactions) else { return }
            UserDefaults.standard.set(data, forKey: "postInteractions")
        }
    )
}
```

### Storage Key

| Key | Type | Content |
|-----|------|---------|
| `"postInteractions"` | Data | JSON encoded `[Int: PostInteraction]` |

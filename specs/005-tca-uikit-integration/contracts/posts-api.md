# API Contract: Posts

**Base URL**: `https://jsonplaceholder.typicode.com`
**Documentation**: https://jsonplaceholder.typicode.com/

## GET /posts

Fetches all posts (100 items).

### Request

```
GET https://jsonplaceholder.typicode.com/posts
```

No authentication required. No query parameters.

### Success Response (200)

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

**Total items**: 100 posts

| Field | Type | Description |
|-------|------|-------------|
| userId | Int | Author's user ID (1-10) |
| id | Int | Unique post ID (1-100) |
| title | String | Post title |
| body | String | Post body (may contain \n for line breaks) |

### Error Scenarios

| Scenario | Expected Response |
|----------|-------------------|
| Network timeout | URLError (no HTTP response) |
| Server error | 500 status code |
| DNS failure | URLError.cannotFindHost |

### Swift Model Mapping

```swift
struct Post: Codable, Equatable, Identifiable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}
```

### Notes

- This API is read-only; no authentication required
- Response is always the full list (no pagination)
- Body text contains `\n` characters that should be preserved in detail view but may be stripped/truncated in list preview
- No interaction data (likes, comments, shares) from API — these are local-only

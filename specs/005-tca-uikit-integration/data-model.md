# Data Model: TCA + UIKit Login & Posts App

**Feature**: 005-tca-uikit-integration
**Date**: 2026-02-10

## Entities

### User

Represents an authenticated user returned by the login API.

| Field | Type | Description |
|-------|------|-------------|
| id | Int | Unique user identifier |
| username | String | Login username |
| email | String | User email address |
| firstName | String | First name |
| lastName | String | Last name |
| gender | String | User gender |
| image | String (URL) | Profile image URL |

### LoginResponse

Full response from the login API, extends User with tokens.

| Field | Type | Description |
|-------|------|-------------|
| (all User fields) | — | Inherited from User |
| accessToken | String | JWT access token |
| refreshToken | String | JWT refresh token |

**Protocols**: `Codable`, `Equatable`

### Post

Represents an article fetched from the posts API.

| Field | Type | Description |
|-------|------|-------------|
| id | Int | Unique post identifier (1-100) |
| userId | Int | Author's user ID |
| title | String | Post title |
| body | String | Full post body text |

**Protocols**: `Codable`, `Equatable`, `Identifiable`

### PostInteraction

Represents local interaction data for a specific post. Stored in UserDefaults.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| postId | Int | — | Foreign key to Post.id |
| isLiked | Bool | false | Whether the user has liked this post |
| likeCount | Int | 0 | Total like count |
| commentCount | Int | 0 | Total comment count |
| shareCount | Int | 0 | Total share count |

**Protocols**: `Codable`, `Equatable`

**Storage**: Encoded as `[Int: PostInteraction]` dictionary (keyed by postId) → JSON Data → UserDefaults

### PostWithInteraction

Composite type combining remote Post data with local interaction data. Used in TCA State.

| Field | Type | Description |
|-------|------|-------------|
| post | Post | The remote post data |
| interaction | PostInteraction | Local interaction state |

**Protocols**: `Equatable`, `Identifiable` (id delegates to post.id)

**Note**: This is a value type used in TCA State, not persisted directly.

## Entity Relationships

```
LoginResponse (API)
    └── User (extracted after login, stored in app state)

Post (API, read-only)
    ├── PostInteraction (local, 1:1 per post)
    └── PostWithInteraction (composite, in-memory)
```

## State Transitions

### Login State Machine

```
idle → loading → success (navigate to posts)
                → error (show toast) → idle (after 3s auto-dismiss)
```

### Posts List State Machine

```
idle → loading → loaded (display posts)
              → error (full-screen error + retry button)
                  → loading (retry tapped)
```

### Post Interaction State Machine

```
not_liked ⟷ liked (toggle on each tap)
commentCount: monotonically increasing (0, 1, 2, ...)
shareCount: monotonically increasing (0, 1, 2, ...)
```

## Validation Rules

- **Username/Password**: Non-empty strings required (login button disabled otherwise)
- **Post.id**: Positive integer, unique within the posts list
- **PostInteraction.likeCount**: Non-negative integer, increments/decrements with isLiked toggle
- **PostInteraction.commentCount**: Non-negative integer, increments only
- **PostInteraction.shareCount**: Non-negative integer, increments only

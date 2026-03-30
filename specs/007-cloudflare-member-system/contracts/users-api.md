# API Contract: Users

**Base URL**: `{WORKER_URL}/api/users`
**Authentication**: 所有端點需要 `Authorization: Bearer <access_token>`

## GET /api/users/me

取得當前使用者 Profile。

### Request

```
GET /api/users/me
Authorization: Bearer <access_token>
```

### Success Response (200)

```json
{
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "name": "John Doe",
    "bio": "Hello, I'm John.",
    "avatar_url": "https://api.example.com/api/users/me/avatar",
    "role": "user",
    "is_active": true,
    "created_at": "2026-03-20T10:00:00.000Z",
    "updated_at": "2026-03-20T12:00:00.000Z"
  }
}
```

### Error Responses

| Status | Code | Condition |
|--------|------|-----------|
| 401 | UNAUTHORIZED | token 無效或過期 |
| 401 | ACCOUNT_DISABLED | 帳號已停用 |

---

## PUT /api/users/me

更新當前使用者 Profile。

### Request

```
PUT /api/users/me
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Body**:
```json
{
  "name": "John Doe Updated",
  "bio": "Updated bio text"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| name | String | No | 顯示名稱，max 100 chars |
| bio | String | No | 個人簡介，max 500 chars |

### Success Response (200)

```json
{
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "name": "John Doe Updated",
    "bio": "Updated bio text",
    "avatar_url": null,
    "role": "user",
    "is_active": true,
    "created_at": "2026-03-20T10:00:00.000Z",
    "updated_at": "2026-03-20T13:00:00.000Z"
  }
}
```

### Error Responses

| Status | Code | Condition |
|--------|------|-----------|
| 400 | VALIDATION_ERROR | name 超過 100 字或 bio 超過 500 字 |
| 401 | UNAUTHORIZED | token 無效 |

---

## POST /api/users/me/avatar

上傳頭像到 R2。

### Request

```
POST /api/users/me/avatar
Authorization: Bearer <access_token>
Content-Type: multipart/form-data
```

**Form Data**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| avatar | File | Yes | 圖片檔案，≤5MB，image/jpeg \| image/png \| image/webp |

### Success Response (200)

```json
{
  "data": {
    "avatar_url": "https://pub-example.r2.dev/avatars/550e8400/profile.webp"
  }
}
```

### Error Responses

| Status | Code | Condition |
|--------|------|-----------|
| 400 | INVALID_FILE_TYPE | 非允許的圖片格式 |
| 400 | FILE_TOO_LARGE | 檔案超過 5MB |
| 401 | UNAUTHORIZED | token 無效 |

**R2 Side Effect**: 檔案存入 public bucket 的 `avatars/{userId}/{uuid}.{ext}`

---

## PUT /api/users/me/password

修改密碼。

### Request

```
PUT /api/users/me/password
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Body**:
```json
{
  "currentPassword": "OldPass123",
  "newPassword": "NewPass456"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| currentPassword | String | Yes | 當前密碼 |
| newPassword | String | Yes | 新密碼（符合強度要求） |

### Success Response (200)

```json
{
  "data": {
    "message": "Password updated successfully."
  }
}
```

### Error Responses

| Status | Code | Condition |
|--------|------|-----------|
| 400 | INVALID_CREDENTIALS | 舊密碼不正確 |
| 400 | VALIDATION_ERROR | 新密碼不符強度要求 |
| 401 | UNAUTHORIZED | token 無效 |

---

## GET /api/users/me/login-history

查詢登入歷史。

### Request

```
GET /api/users/me/login-history?page=1&pageSize=20
Authorization: Bearer <access_token>
```

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| page | Number (query) | 1 | 頁碼 |
| pageSize | Number (query) | 20 | 每頁筆數 |

### Success Response (200)

```json
{
  "data": [
    {
      "id": "...",
      "method": "email",
      "ip_address": "1.2.3.4",
      "user_agent": "Mozilla/5.0 ...",
      "created_at": "2026-03-20T10:00:00.000Z"
    }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "total": 42,
    "totalPages": 3
  }
}
```

---

## GET /api/users/me/oauth-accounts

列出已連結的 OAuth 帳號。

### Request

```
GET /api/users/me/oauth-accounts
Authorization: Bearer <access_token>
```

### Success Response (200)

```json
{
  "data": [
    {
      "id": "...",
      "provider": "google",
      "provider_email": "user@gmail.com",
      "created_at": "2026-03-20T10:00:00.000Z"
    },
    {
      "id": "...",
      "provider": "github",
      "provider_email": "user@github.com",
      "created_at": "2026-03-21T10:00:00.000Z"
    }
  ]
}
```

---

## DELETE /api/users/me/oauth-accounts/:provider

解除 OAuth 連結。

### Request

```
DELETE /api/users/me/oauth-accounts/google
Authorization: Bearer <access_token>
```

| Param | Type | Description |
|-------|------|-------------|
| provider | String (path) | `google` 或 `github` |

### Success Response (200)

```json
{
  "data": {
    "message": "OAuth account unlinked successfully."
  }
}
```

### Error Responses

| Status | Code | Condition |
|--------|------|-----------|
| 400 | LAST_LOGIN_METHOD | 這是唯一的登入方式，不可移除 |
| 404 | NOT_FOUND | 該 provider 未連結 |
| 401 | UNAUTHORIZED | token 無效 |

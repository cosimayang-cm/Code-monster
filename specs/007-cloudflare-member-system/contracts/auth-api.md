# API Contract: Auth

**Base URL**: `{WORKER_URL}/api/auth`

## POST /api/auth/register

註冊新帳號。

### Request

```
POST /api/auth/register
Content-Type: application/json
```

**Body**:
```json
{
  "email": "user@example.com",
  "password": "MyPass123"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| email | String | Yes | 有效 email 格式 |
| password | String | Yes | ≥8 字元、含大小寫字母與數字 |

### Success Response (201)

```json
{
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "user@example.com",
      "name": null,
      "bio": null,
      "avatar_url": null,
      "role": "user",
      "is_active": true,
      "created_at": "2026-03-20T10:00:00.000Z"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

### Error Responses

| Status | Code | Condition |
|--------|------|-----------|
| 400 | VALIDATION_ERROR | email 格式無效或密碼不符要求 |
| 409 | CONFLICT | email 已註冊 |

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Password must be at least 8 characters with uppercase, lowercase, and numbers"
  }
}
```

---

## POST /api/auth/login

帳號登入。

### Request

```
POST /api/auth/login
Content-Type: application/json
```

**Body**:
```json
{
  "email": "user@example.com",
  "password": "MyPass123"
}
```

### Success Response (200)

```json
{
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "user@example.com",
      "name": "John",
      "bio": "Hello world",
      "avatar_url": "https://api.example.com/avatars/...",
      "role": "user",
      "is_active": true,
      "created_at": "2026-03-20T10:00:00.000Z"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

### Error Responses

| Status | Code | Condition |
|--------|------|-----------|
| 401 | INVALID_CREDENTIALS | email 或密碼錯誤 |
| 401 | ACCOUNT_DISABLED | 帳號已停用 |

---

## POST /api/auth/refresh

換發 access token。

### Request

```
POST /api/auth/refresh
Content-Type: application/json
```

**Body**:
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}
```

### Success Response (200)

```json
{
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

### Error Responses

| Status | Code | Condition |
|--------|------|-----------|
| 400 | INVALID_TOKEN | refresh token 無效或過期 |
| 401 | ACCOUNT_DISABLED | 帳號已停用 |

---

## POST /api/auth/forgot-password

忘記密碼，產生 reset link（測試模式，直接回傳在 response body）。

### Request

```
POST /api/auth/forgot-password
Content-Type: application/json
```

**Body**:
```json
{
  "email": "user@example.com"
}
```

### Success Response (200)

即使 email 不存在也回傳成功（防止 email 枚舉）。但只有 email 存在時，resetLink 才包含有效 token。

```json
{
  "data": {
    "message": "If the email exists, a reset link has been generated.",
    "resetLink": "https://staging.monster7.pages.dev/reset-password?token=abc123def456"
  }
}
```

**KV Side Effect**: `reset:<token>` → `{ "userId": "..." }`, TTL 1800s

---

## POST /api/auth/reset-password

使用 reset token 重設密碼。

### Request

```
POST /api/auth/reset-password
Content-Type: application/json
```

**Body**:
```json
{
  "token": "abc123def456",
  "password": "NewPass456"
}
```

### Success Response (200)

```json
{
  "data": {
    "message": "Password has been reset successfully."
  }
}
```

### Error Responses

| Status | Code | Condition |
|--------|------|-----------|
| 400 | INVALID_TOKEN | token 無效、已使用或已過期 |
| 400 | VALIDATION_ERROR | 新密碼不符強度要求 |

**KV Side Effect**: reset token 使用後立即從 KV 刪除。

---

## GET /api/auth/oauth/:provider

發起 OAuth 登入流程。

### Request

```
GET /api/auth/oauth/google
GET /api/auth/oauth/github
```

| Param | Type | Description |
|-------|------|-------------|
| provider | String (path) | `google` 或 `github` |

### Response (302 Redirect)

Redirect 到 OAuth provider 的授權頁面。State 參數存入 KV（TTL 10 分鐘）。

**KV Side Effect**: `oauth_state:<state>` → `{ "provider": "google" }`, TTL 600s

---

## GET /api/auth/oauth/:provider/callback

OAuth callback，處理授權回傳。

### Request

```
GET /api/auth/oauth/google/callback?code=xxx&state=yyy
```

| Param | Type | Description |
|-------|------|-------------|
| code | String (query) | OAuth authorization code |
| state | String (query) | CSRF state parameter |

### Response (302 Redirect)

驗證 state（KV）→ 交換 token → 取得 user info → 登入/註冊/連結 → redirect 到前端帶 token。

Redirect to: `{PAGES_URL}/auth/callback?accessToken=xxx&refreshToken=yyy`

### Error Scenarios

| Condition | Behavior |
|-----------|----------|
| state 不符（KV 查無或不匹配） | Redirect to `{PAGES_URL}/login?error=oauth_failed` |
| OAuth provider 回傳錯誤 | Redirect to `{PAGES_URL}/login?error=oauth_failed` |

**KV Side Effect**: state 驗證後立即從 KV 刪除。

---

## Token Specifications

### Access Token (JWT)

| Field | Value |
|-------|-------|
| Algorithm | HS256 |
| Expiry | 15 minutes |
| Payload | `{ sub, email, role, type: "access" }` |

### Refresh Token (JWT)

| Field | Value |
|-------|-------|
| Algorithm | HS256 |
| Expiry | 7 days |
| Payload | `{ sub, type: "refresh" }` |

### Password Requirements

| Rule | Requirement |
|------|------------|
| Minimum length | 8 characters |
| Uppercase | At least 1 uppercase letter |
| Lowercase | At least 1 lowercase letter |
| Number | At least 1 digit |

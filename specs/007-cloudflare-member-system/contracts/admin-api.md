# API Contract: Admin

**Base URL**: `{WORKER_URL}/api/admin`
**Authentication**: 所有端點需要 `Authorization: Bearer <access_token>` + `role: admin`

## GET /api/admin/users

使用者列表（分頁）。

### Request

```
GET /api/admin/users?page=1&pageSize=20&search=john
Authorization: Bearer <admin_access_token>
```

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| page | Number (query) | 1 | 頁碼 |
| pageSize | Number (query) | 20 | 每頁筆數（max 100） |
| search | String (query) | — | 搜尋 email 或 name（optional） |

### Success Response (200)

```json
{
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "user@example.com",
      "name": "John Doe",
      "role": "user",
      "is_active": true,
      "created_at": "2026-03-20T10:00:00.000Z"
    }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

### Error Responses

| Status | Code | Condition |
|--------|------|-----------|
| 401 | UNAUTHORIZED | token 無效 |
| 403 | FORBIDDEN | 非 admin 角色 |

---

## GET /api/admin/users/:id

使用者詳情（含 OAuth 連結 + 最近登入歷史）。

### Request

```
GET /api/admin/users/550e8400-e29b-41d4-a716-446655440000
Authorization: Bearer <admin_access_token>
```

### Success Response (200)

```json
{
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "name": "John Doe",
    "bio": "Hello",
    "avatar_url": "https://...",
    "role": "user",
    "is_active": true,
    "created_at": "2026-03-20T10:00:00.000Z",
    "updated_at": "2026-03-20T12:00:00.000Z",
    "oauthAccounts": [
      {
        "provider": "google",
        "provider_email": "john@gmail.com",
        "created_at": "2026-03-20T10:00:00.000Z"
      }
    ],
    "recentLogins": [
      {
        "method": "email",
        "ip_address": "1.2.3.4",
        "user_agent": "Mozilla/5.0 ...",
        "created_at": "2026-03-20T10:00:00.000Z"
      }
    ]
  }
}
```

### Error Responses

| Status | Code | Condition |
|--------|------|-----------|
| 404 | NOT_FOUND | 使用者不存在 |
| 403 | FORBIDDEN | 非 admin |

---

## PUT /api/admin/users/:id/role

變更使用者角色。

### Request

```
PUT /api/admin/users/550e8400-e29b-41d4-a716-446655440000/role
Authorization: Bearer <admin_access_token>
Content-Type: application/json
```

**Body**:
```json
{
  "role": "admin"
}
```

| Field | Type | Required | Values |
|-------|------|----------|--------|
| role | String | Yes | `user` or `admin` |

### Success Response (200)

```json
{
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "role": "admin",
    "updated_at": "2026-03-20T14:00:00.000Z"
  }
}
```

### Error Responses

| Status | Code | Condition |
|--------|------|-----------|
| 400 | VALIDATION_ERROR | role 值不是 user 或 admin |
| 404 | NOT_FOUND | 使用者不存在 |
| 403 | FORBIDDEN | 非 admin |

---

## PUT /api/admin/users/:id/status

啟用/停用帳號。

### Request

```
PUT /api/admin/users/550e8400-e29b-41d4-a716-446655440000/status
Authorization: Bearer <admin_access_token>
Content-Type: application/json
```

**Body**:
```json
{
  "is_active": false
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| is_active | Boolean | Yes | true = 啟用, false = 停用 |

### Success Response (200)

```json
{
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "is_active": false,
    "updated_at": "2026-03-20T14:00:00.000Z"
  }
}
```

### Error Responses

| Status | Code | Condition |
|--------|------|-----------|
| 404 | NOT_FOUND | 使用者不存在 |
| 403 | FORBIDDEN | 非 admin |

**Side Effect**: 被停用的帳號，auth middleware 的 is_active 檢查會立即阻擋。

---

## GET /api/admin/dashboard/stats

統計數據概覽。

### Request

```
GET /api/admin/dashboard/stats
Authorization: Bearer <admin_access_token>
```

### Success Response (200)

```json
{
  "data": {
    "totalUsers": 150,
    "todayRegistrations": 5,
    "activeUsers7d": 89,
    "disabledUsers": 3,
    "oauthLinkedRatio": 0.42,
    "logins24h": 67
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| totalUsers | Number | 系統所有使用者 |
| todayRegistrations | Number | 今日新註冊（UTC 00:00 起算） |
| activeUsers7d | Number | 7 天內有登入的使用者 |
| disabledUsers | Number | is_active = false 的使用者 |
| oauthLinkedRatio | Number (0-1) | 有連結 OAuth 的使用者佔比 |
| logins24h | Number | 最近 24 小時的登入記錄數 |

---

## GET /api/admin/dashboard/activity

全站活動日誌。

### Request

```
GET /api/admin/dashboard/activity?page=1&pageSize=20&method=email&from=2026-03-19&to=2026-03-20
Authorization: Bearer <admin_access_token>
```

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| page | Number (query) | 1 | 頁碼 |
| pageSize | Number (query) | 20 | 每頁筆數 |
| method | String (query) | — | 篩選登入方式：email / google / github |
| from | String (query) | — | 起始日期 (ISO date, inclusive) |
| to | String (query) | — | 結束日期 (ISO date, inclusive) |

### Success Response (200)

```json
{
  "data": [
    {
      "id": "...",
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "user_email": "user@example.com",
      "user_name": "John Doe",
      "method": "email",
      "ip_address": "1.2.3.4",
      "user_agent": "Mozilla/5.0 ...",
      "created_at": "2026-03-20T10:00:00.000Z"
    }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "total": 500,
    "totalPages": 25
  }
}
```

### Error Responses

| Status | Code | Condition |
|--------|------|-----------|
| 403 | FORBIDDEN | 非 admin |

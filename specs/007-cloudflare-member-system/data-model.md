# Data Model: Monster7 Member — Cloudflare 全端會員系統

**Feature**: 007-cloudflare-member-system
**Date**: 2026-03-20

## Entity Relationship Diagram

```text
┌──────────────────┐
│      users       │
│──────────────────│
│ id (PK, UUID)    │
│ email (UNIQUE)   │
│ password_hash    │
│ name             │
│ bio              │
│ avatar_url       │
│ role             │
│ is_active        │
│ created_at       │
│ updated_at       │
└──────┬───────────┘
       │ 1
       │
       ├──────────────── 0..N ──┐
       │                        │
       ▼                        ▼
┌──────────────────┐   ┌──────────────────┐
│  oauth_accounts  │   │  login_history   │
│──────────────────│   │──────────────────│
│ id (PK, UUID)    │   │ id (PK, UUID)    │
│ user_id (FK)     │   │ user_id (FK)     │
│ provider         │   │ method           │
│ provider_id      │   │ ip_address       │
│ provider_email   │   │ user_agent       │
│ created_at       │   │ created_at       │
└──────────────────┘   └──────────────────┘

UNIQUE(provider, provider_id)
```

## KV Storage

```text
┌─────────────────────────────┐
│      KV Namespace           │
│─────────────────────────────│
│ reset:<token>    → user_id  │  TTL: 30 min
│ oauth_state:<s>  → state    │  TTL: 10 min
└─────────────────────────────┘
```

## R2 Storage

```text
┌─────────────────────────────┐
│   R2 Public Bucket          │
│─────────────────────────────│
│ avatars/<user_id>/<uuid>.ext│  Max 5MB, image/*
└─────────────────────────────┘
```

---

## Entities

### User (users table)

D1 SQLite database 的核心 entity，代表系統中的會員帳號。

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| id | TEXT (UUID) | 主鍵，使用 crypto.randomUUID() | Required, Primary Key |
| email | TEXT | 登入帳號 | Required, UNIQUE, valid email format |
| password_hash | TEXT | PBKDF2 密碼雜湊 | Nullable（OAuth-only 使用者可無密碼） |
| name | TEXT | 顯示名稱 | Nullable, max 100 chars |
| bio | TEXT | 個人簡介 | Nullable, max 500 chars |
| avatar_url | TEXT | 頭像公開 R2 URL | Nullable |
| role | TEXT | 角色 | Required, DEFAULT 'user', enum: 'user' \| 'admin' |
| is_active | INTEGER | 帳號啟用狀態 | Required, DEFAULT 1 (SQLite boolean) |
| created_at | TEXT | 建立時間 | Required, ISO 8601 format |
| updated_at | TEXT | 更新時間 | Required, ISO 8601 format |

**Validation Rules**:
- email: 必須符合 RFC 5322 email 格式
- password_hash: 註冊時必須提供，OAuth-only 帳號可為 null
- role: 只允許 'user' 或 'admin'
- is_active: 0 (停用) 或 1 (啟用)

**State Transitions**:

```
Role:     user ──(admin 變更)──→ admin
                                   │
          user ←──(admin 變更)─────┘

Status:   active ──(admin 停用)──→ inactive
                                      │
          active ←──(admin 啟用)──────┘
```

### OAuthAccount (oauth_accounts table)

代表使用者連結的 OAuth 第三方帳號。

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| id | TEXT (UUID) | 主鍵 | Required, Primary Key |
| user_id | TEXT | 關聯使用者 ID | Required, FK → users.id, ON DELETE CASCADE |
| provider | TEXT | OAuth 提供者 | Required, enum: 'google' \| 'github' |
| provider_id | TEXT | OAuth 提供者的使用者 ID | Required |
| provider_email | TEXT | OAuth 取得的 email | Nullable |
| created_at | TEXT | 建立時間 | Required, ISO 8601 format |

**Constraints**: `UNIQUE(provider, provider_id)` — 同一 provider 的同一使用者只能連結一次。

**Validation Rules**:
- provider: 只允許 'google' 或 'github'
- 一個 user 最多各連結一個 Google 和一個 GitHub 帳號

### LoginHistory (login_history table)

記錄每次登入事件，用於安全監控與 Admin 活動日誌。

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| id | TEXT (UUID) | 主鍵 | Required, Primary Key |
| user_id | TEXT | 關聯使用者 ID | Required, FK → users.id, ON DELETE CASCADE |
| method | TEXT | 登入方式 | Required, enum: 'email' \| 'google' \| 'github' |
| ip_address | TEXT | 登入 IP | Required |
| user_agent | TEXT | 瀏覽器 User Agent | Required |
| created_at | TEXT | 登入時間 | Required, ISO 8601 format |

---

## D1 Migration SQL

### 0001_create_users.sql

```sql
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT,
    name TEXT,
    bio TEXT,
    avatar_url TEXT,
    role TEXT NOT NULL DEFAULT 'user',
    is_active INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_is_active ON users(is_active);
CREATE INDEX idx_users_created_at ON users(created_at);
```

### 0002_create_oauth_accounts.sql

```sql
CREATE TABLE IF NOT EXISTS oauth_accounts (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    provider TEXT NOT NULL,
    provider_id TEXT NOT NULL,
    provider_email TEXT,
    created_at TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE(provider, provider_id)
);

CREATE INDEX idx_oauth_user_id ON oauth_accounts(user_id);
CREATE INDEX idx_oauth_provider_id ON oauth_accounts(provider, provider_id);
```

### 0003_create_login_history.sql

```sql
CREATE TABLE IF NOT EXISTS login_history (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    method TEXT NOT NULL,
    ip_address TEXT NOT NULL,
    user_agent TEXT NOT NULL,
    created_at TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_login_history_user_id ON login_history(user_id);
CREATE INDEX idx_login_history_created_at ON login_history(created_at);
CREATE INDEX idx_login_history_method ON login_history(method);
```

---

## KV Key Patterns

### Password Reset Token

| Key | Value | TTL | Description |
|-----|-------|-----|-------------|
| `reset:<random_token>` | `{ "userId": "<uuid>" }` | 1800s (30 min) | 一次性密碼重設 token |

### OAuth State

| Key | Value | TTL | Description |
|-----|-------|-----|-------------|
| `oauth_state:<random_state>` | `{ "provider": "google\|github", "returnUrl": "..." }` | 600s (10 min) | OAuth CSRF 防護 state |

---

## R2 Object Key Pattern

```
avatars/{user_id}/{uuid}.{ext}
```

- `user_id`: 使用者的 UUID
- `uuid`: 隨機生成的檔名，避免覆蓋
- `ext`: 原始檔案副檔名（jpg, png, webp）
- Content-Type: 保留原始上傳的 MIME type
- Object Access: public bucket 直接提供讀取，`avatar_url` 儲存最終公開 URL

---

## Frontend Derived View Model

### AccountCenterSection

會員中心前端的衍生 view model，用來支撐 section-based account center。

| Section ID | Title | Data Source |
|------------|-------|-------------|
| `profile` | 基本資料 | `GET /api/users/me` |
| `security` | 安全 | `PUT /api/users/me/password` |
| `oauthConnections` | OAuth 連結 | `GET /api/users/me/oauth-accounts` |
| `loginHistory` | 登入歷史 | `GET /api/users/me/login-history` |
| `accountActions` | 帳號操作 | AuthContext logout / future settings expansion |

---

## JWT Token Structure

### Access Token (15 min)

```json
{
  "sub": "<user_id>",
  "email": "<email>",
  "role": "user|admin",
  "type": "access",
  "iat": 1234567890,
  "exp": 1234568790
}
```

### Refresh Token (7 days)

```json
{
  "sub": "<user_id>",
  "type": "refresh",
  "iat": 1234567890,
  "exp": 1235172690
}
```

---

## API Response Types

### Success Response

```typescript
// Single entity
{ data: T }

// List with pagination
{
  data: T[],
  pagination: {
    page: number,
    pageSize: number,
    total: number,
    totalPages: number
  }
}
```

### Error Response

```typescript
{
  error: {
    code: string,   // e.g. "INVALID_CREDENTIALS", "FORBIDDEN"
    message: string  // Human-readable description
  }
}
```

### Error Codes

| Code | HTTP Status | Description |
|------|------------|-------------|
| VALIDATION_ERROR | 400 | 請求參數驗證失敗 |
| INVALID_CREDENTIALS | 401 | 帳密錯誤 |
| UNAUTHORIZED | 401 | 未登入或 token 無效 |
| ACCOUNT_DISABLED | 401 | 帳號已停用 |
| FORBIDDEN | 403 | 無 admin 權限 |
| NOT_FOUND | 404 | 資源不存在 |
| CONFLICT | 409 | Email 已註冊 |
| INVALID_FILE_TYPE | 400 | 不允許的檔案類型 |
| FILE_TOO_LARGE | 400 | 檔案超過 5MB |
| INVALID_TOKEN | 400 | Reset/refresh token 無效或過期 |
| LAST_LOGIN_METHOD | 400 | 不可移除唯一登入方式 |
| INTERNAL_ERROR | 500 | 伺服器內部錯誤 |

---

## Invariants

1. 每個 user 的 email 必須唯一。
2. User 至少保留一種登入方式（password 或至少一個 OAuth 連結）。
3. 密碼必須以 PBKDF2 雜湊後儲存，永不以明文存在。
4. is_active = false 的使用者，即使持有有效 JWT 也無法存取受保護 API。
5. Reset token 只能使用一次，使用後立即從 KV 刪除。
6. OAuth state token 在驗證後立即從 KV 刪除，防止重放攻擊。
7. staging 和 production 使用完全獨立的 D1/R2/KV 資源。
8. JWT secret 不可出現在程式碼或 git history 中。

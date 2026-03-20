# Quick Start: Monster7 Member — Cloudflare 全端會員系統

**Feature**: 007-cloudflare-member-system
**Date**: 2026-03-20

## Prerequisites

1. **Node.js 18+**（LTS）
2. **npm 9+**
3. **Wrangler CLI**：`npm install -g wrangler`
4. **Cloudflare 帳號**：已登入 `wrangler login`
5. **Git**：已安裝

## Setup

### Step 1: 建立 Mono Repo 骨架

```bash
mkdir monster7-member && cd monster7-member
git init
```

### Step 2: 初始化前端 (web-app)

```bash
npm create vite@latest web-app -- --template react-ts
cd web-app
npm install
npm install -D tailwindcss @tailwindcss/vite
npm install react-router-dom
cd ..
```

### Step 3: 初始化後端 (api)

```bash
mkdir api && cd api
npm init -y
npm install hono jose arctic
npm install -D wrangler typescript @cloudflare/workers-types
cd ..
```

### Step 4: 建立 Cloudflare 資源（wrangler CLI）

```bash
# D1 Databases
wrangler d1 create monster7-db-staging
wrangler d1 create monster7-db-production

# R2 Buckets
wrangler r2 bucket create monster7-bucket-staging
wrangler r2 bucket create monster7-bucket-production

# KV Namespaces
wrangler kv namespace create monster7-kv-staging
wrangler kv namespace create monster7-kv-production
```

### Step 5: 設定 wrangler.toml

在 `api/wrangler.toml` 中填入 Step 4 取得的 ID：

```toml
name = "monster7-api"
main = "src/index.ts"
compatibility_date = "2024-01-01"

[env.staging]
name = "monster7-api-staging"

[[env.staging.d1_databases]]
binding = "DB"
database_name = "monster7-db-staging"
database_id = "<staging-db-id>"
migrations_dir = "migrations"

[[env.staging.r2_buckets]]
binding = "BUCKET"
bucket_name = "monster7-bucket-staging"

[[env.staging.kv_namespaces]]
binding = "KV"
id = "<staging-kv-id>"

# Production
[env.production]
name = "monster7-api-production"

[[env.production.d1_databases]]
binding = "DB"
database_name = "monster7-db-production"
database_id = "<production-db-id>"
migrations_dir = "migrations"

[[env.production.r2_buckets]]
binding = "BUCKET"
bucket_name = "monster7-bucket-production"

[[env.production.kv_namespaces]]
binding = "KV"
id = "<production-kv-id>"
```

### Step 6: 設定 Secrets

```bash
# 本地開發（.dev.vars）
cd api
cat > .dev.vars << 'EOF'
JWT_SECRET=local-dev-jwt-secret-change-in-production
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
GITHUB_CLIENT_ID=your-github-client-id
GITHUB_CLIENT_SECRET=your-github-client-secret
EOF

# 遠端 Staging
wrangler secret put JWT_SECRET --env staging
wrangler secret put GOOGLE_CLIENT_ID --env staging
wrangler secret put GOOGLE_CLIENT_SECRET --env staging
wrangler secret put GITHUB_CLIENT_ID --env staging
wrangler secret put GITHUB_CLIENT_SECRET --env staging

# 遠端 Production
wrangler secret put JWT_SECRET --env production
wrangler secret put GOOGLE_CLIENT_ID --env production
wrangler secret put GOOGLE_CLIENT_SECRET --env production
wrangler secret put GITHUB_CLIENT_ID --env production
wrangler secret put GITHUB_CLIENT_SECRET --env production
cd ..
```

### Step 7: 執行 D1 Migration

```bash
cd api
wrangler d1 migrations apply monster7-db-staging
wrangler d1 migrations apply monster7-db-production --env production
cd ..
```

### Step 8: 設定 .gitignore

```bash
cat > .gitignore << 'EOF'
node_modules/
dist/
.dev.vars
.env.local
.wrangler/
*.local
EOF
```

---

## Local Development

### 前端

```bash
cd web-app
npm run dev
# → http://localhost:5173
```

### 後端

```bash
cd api
wrangler dev
# → http://localhost:8787
```

### 驗證 Health Check

```bash
curl http://localhost:8787/health
# → { "status": "ok", "database": "connected" }
```

---

## Implementation Order

### Phase 1: 專案初始化與基礎架構
1. 建立 Mono Repo 骨架（web-app + api）
2. 建立 Cloudflare 資源（D1 × 2, R2 × 2, KV × 2）
3. 配置 wrangler.toml 雙環境 binding
4. 連結 GitHub → Cloudflare Pages

### Phase 2: D1 Schema + 基礎 API
1. 建立 D1 migration SQL（users table）
2. 實作 Hono app 骨架（entry point）
3. 實作 CORS middleware（環境感知）
4. 實作統一錯誤處理
5. 實作 `GET /health`（含 DB 連線檢查）

### Phase 3: 環境驗證
1. 部署 staging，驗證資源隔離
2. 前端加入 STAGING banner
3. 驗證 secret 不在程式碼中

### Phase 4: 認證系統
1. 實作 PBKDF2 password hashing（utils/password.ts）
2. 實作 JWT sign/verify（utils/jwt.ts）
3. 實作 `POST /api/auth/register`
4. 實作 `POST /api/auth/login`
5. 實作 `POST /api/auth/refresh`
6. 實作 auth middleware
7. 實作 `GET /api/users/me`
8. 前端：登入/註冊頁面 + AuthContext

### Phase 5: 會員功能
1. 實作 `PUT /api/users/me`（Profile 更新）
2. 實作 `POST /api/users/me/avatar`（R2 上傳）
3. 實作 `PUT /api/users/me/password`（修改密碼）
4. 實作忘記/重設密碼（KV token）
5. 建立 login_history table + migration
6. 實作登入歷史記錄與查詢
7. 前端：section-based 會員中心、修改密碼、忘記密碼頁面
8. 前端：Token 自動 refresh 機制

### Phase 6: OAuth 登入
1. 建立 oauth_accounts table + migration
2. 實作 OAuth redirect + callback（Google + GitHub）
3. 實作帳號連結/解除邏輯
4. KV 儲存 OAuth state
5. 前端：OAuth 登入按鈕 + `/auth/callback` 處理

### Phase 7: Admin 管理後台
1. 實作 requireRole middleware
2. 實作使用者管理 API（CRUD）
3. 實作 Dashboard 統計 API
4. 實作全站活動日誌 API
5. 建立 seed script
6. 前端：Admin Layout + Dashboard + Users + Activity

---

## Key Patterns Reference

### Hono Route Module

```typescript
// routes/auth.ts
import { Hono } from 'hono'
import type { Env } from '../types'

const auth = new Hono<Env>()

auth.post('/register', async (c) => {
  const { email, password } = await c.req.json()
  // validate, hash, insert into D1
  const db = c.env.DB
  return c.json({ data: { accessToken, refreshToken } })
})

export default auth
```

### Auth Middleware

```typescript
// middleware/auth.ts
import { createMiddleware } from 'hono/factory'
import { verifyToken } from '../utils/jwt'

export const requireAuth = createMiddleware(async (c, next) => {
  const authHeader = c.req.header('Authorization')
  if (!authHeader?.startsWith('Bearer ')) {
    return c.json({ error: { code: 'UNAUTHORIZED', message: 'Missing token' } }, 401)
  }
  const token = authHeader.slice(7)
  const payload = await verifyToken(token, c.env.JWT_SECRET)
  // Check is_active in DB
  c.set('userId', payload.sub)
  c.set('userRole', payload.role)
  await next()
})
```

### D1 Query

```typescript
const result = await c.env.DB.prepare(
  'SELECT * FROM users WHERE email = ?'
).bind(email).first()
```

### R2 Upload

```typescript
const file = await c.req.blob()
const key = `avatars/${userId}/${crypto.randomUUID()}.${ext}`
await c.env.BUCKET.put(key, file, {
  httpMetadata: { contentType: file.type }
})
```

### KV Read/Write

```typescript
// Write with TTL
await c.env.KV.put(`reset:${token}`, JSON.stringify({ userId }), { expirationTtl: 1800 })
// Read + Delete
const data = await c.env.KV.get(`reset:${token}`)
await c.env.KV.delete(`reset:${token}`)
```

### Frontend API Client with Auto-Refresh

```typescript
async function apiClient(path: string, options: RequestInit = {}) {
  let accessToken = localStorage.getItem('accessToken')
  let res = await fetch(`${API_URL}${path}`, {
    ...options,
    headers: { ...options.headers, Authorization: `Bearer ${accessToken}` }
  })
  if (res.status === 401) {
    const refreshToken = localStorage.getItem('refreshToken')
    const refreshRes = await fetch(`${API_URL}/api/auth/refresh`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refreshToken })
    })
    if (refreshRes.ok) {
      const { data } = await refreshRes.json()
      localStorage.setItem('accessToken', data.accessToken)
      // Retry original request
      res = await fetch(`${API_URL}${path}`, {
        ...options,
        headers: { ...options.headers, Authorization: `Bearer ${data.accessToken}` }
      })
    } else {
      // Redirect to login
      window.location.href = '/login'
    }
  }
  return res
}
```

---

## Deployment

### Staging (自動)

```bash
git push origin main
# → Cloudflare Pages 自動部署 web-app
# → 手動部署 API:
cd api && wrangler deploy
```

### Production (手動)

```bash
git push origin production
# → Cloudflare Pages 自動部署 web-app (production)
# → 手動部署 API:
cd api && wrangler deploy --env production
```

---

## Seed Admin Account

```bash
cd api
npx tsx seed/seed.ts
# → Creates admin@monster7.dev / Admin123! in staging D1
```

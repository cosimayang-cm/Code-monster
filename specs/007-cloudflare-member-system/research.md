# Research: Monster7 Member — Cloudflare 全端會員系統

**Feature**: 007-cloudflare-member-system
**Date**: 2026-03-20

## Decision 1: Backend Framework — Hono

**Decision**: 使用 Hono 作為 Cloudflare Workers 的路由框架。

**Rationale**: Hono 是專為 Edge Runtime 設計的輕量 Web 框架，原生支援 Cloudflare Workers，提供路由、middleware、TypeScript 型別安全，且 bundle size 極小（~14KB）。

**Alternatives Considered**:

| Method | Pros | Cons | Status |
|--------|------|------|--------|
| Raw Workers fetch() | 零依賴、最小 bundle | 大量 boilerplate、手動解析路由/CORS/body | ❌ Rejected |
| Hono | 輕量（14KB）、原生 CF 支援、middleware、型別安全 | 額外依賴 | ✅ Chosen |
| itty-router | 極輕量、API 簡單 | middleware 生態不如 Hono 豐富 | ❌ Rejected |

**Implementation Pattern**:
```typescript
import { Hono } from 'hono'
import { cors } from 'hono/cors'

type Env = {
  Bindings: {
    DB: D1Database
    BUCKET: R2Bucket
    KV: KVNamespace
    JWT_SECRET: string
  }
}

const app = new Hono<Env>()
app.use('/api/*', cors({ origin: getAllowedOrigin }))
app.route('/api/auth', authRoutes)
app.route('/api/users', userRoutes)
app.route('/api/admin', adminRoutes)
export default app
```

---

## Decision 2: Password Hashing — PBKDF2 via Web Crypto API

**Decision**: 使用 PBKDF2 演算法（透過 Web Crypto API）進行密碼雜湊。

**Rationale**: Cloudflare Workers 不支援 Node.js `crypto` 模組，只支援 Web Crypto API。PBKDF2 是 Web Crypto API 原生支援的密碼雜湊演算法，不需額外 library。

**Alternatives Considered**:

| Method | Pros | Cons | Status |
|--------|------|------|--------|
| bcrypt | 業界標準、抗 GPU 攻擊 | Workers 不支援 Node.js native module | ❌ Rejected |
| PBKDF2 (Web Crypto) | Workers 原生支援、零額外依賴 | 較 bcrypt/scrypt 慢（迭代次數需調整） | ✅ Chosen |
| argon2 | 最強密碼雜湊 | 需 WASM，Workers CPU 限制可能不夠 | ❌ Rejected |

**Implementation Pattern**:
```typescript
async function hashPassword(password: string): Promise<string> {
  const salt = crypto.getRandomValues(new Uint8Array(16))
  const encoder = new TextEncoder()
  const keyMaterial = await crypto.subtle.importKey(
    'raw', encoder.encode(password), 'PBKDF2', false, ['deriveBits']
  )
  const hash = await crypto.subtle.deriveBits(
    { name: 'PBKDF2', salt, iterations: 100000, hash: 'SHA-256' },
    keyMaterial, 256
  )
  // Store as: iterations:salt_base64:hash_base64
  return `100000:${btoa(String.fromCharCode(...salt))}:${btoa(String.fromCharCode(...new Uint8Array(hash)))}`
}
```

---

## Decision 3: JWT Library — jose

**Decision**: 使用 `jose` library 處理 JWT sign/verify。

**Rationale**: `jose` 是純 JavaScript 實作，完全相容 Web Crypto API / Edge Runtime，是 Cloudflare Workers 上最常用的 JWT library。不依賴 Node.js 特有 API。

**Alternatives Considered**:

| Method | Pros | Cons | Status |
|--------|------|------|--------|
| jsonwebtoken | 最常用 Node.js JWT lib | 依賴 Node.js crypto，Workers 不支援 | ❌ Rejected |
| jose | 純 JS、Web Crypto 相容、Edge Runtime 支援 | API 稍比 jsonwebtoken 繁瑣 | ✅ Chosen |
| 手動 JWT | 零依賴 | 容易有安全漏洞，不應手刻 | ❌ Rejected |

**Implementation Pattern**:
```typescript
import { SignJWT, jwtVerify } from 'jose'

async function signToken(payload: JWTPayload, secret: string, expiresIn: string) {
  const key = new TextEncoder().encode(secret)
  return new SignJWT(payload)
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt()
    .setExpirationTime(expiresIn)
    .sign(key)
}

async function verifyToken(token: string, secret: string) {
  const key = new TextEncoder().encode(secret)
  return jwtVerify(token, key)
}
```

---

## Decision 4: OAuth Library — arctic

**Decision**: 使用 `arctic` library 處理 OAuth 授權流程。

**Rationale**: `arctic` 是輕量的 OAuth 2.0 library，原生支援 Google 和 GitHub provider，API 簡潔，不依賴 Node.js 特有 API。

**Alternatives Considered**:

| Method | Pros | Cons | Status |
|--------|------|------|--------|
| arctic | 輕量、支援多 provider、Edge 相容 | 相對較新 | ✅ Chosen |
| 手動 OAuth flow | 完全掌控、零依賴 | 容易出錯、需處理各 provider 差異 | ❌ Rejected |
| Auth.js (NextAuth) | 功能最全、生態最大 | 偏向 Next.js，與 Workers 整合不直接 | ❌ Rejected |

**Implementation Pattern**:
```typescript
import { Google, GitHub } from 'arctic'

const google = new Google(clientId, clientSecret, redirectURI)
const github = new GitHub(clientId, clientSecret, redirectURI)

// Initiate OAuth
const [url, state] = google.createAuthorizationURL(scopes)
// Store state in KV for CSRF protection
await kv.put(`oauth_state:${state}`, JSON.stringify({ provider: 'google' }), { expirationTtl: 600 })

// Callback
const tokens = await google.validateAuthorizationCode(code)
```

---

## Decision 5: Frontend State Management — React Context + Custom Hooks

**Decision**: 使用 React Context + useReducer + custom hooks 管理全域狀態（auth state）。

**Rationale**: 此專案狀態管理需求相對單純（主要是 auth state），React 內建的 Context + useReducer 已足夠。避免引入額外狀態管理 library（Zustand、Redux）增加學習負擔。

**Alternatives Considered**:

| Method | Pros | Cons | Status |
|--------|------|------|--------|
| React Context + hooks | 零額外依賴、React 內建、夠用 | 大型應用不適合（re-render 問題） | ✅ Chosen |
| Zustand | 輕量、API 簡潔、效能好 | 額外依賴，此專案規模不需要 | ❌ Rejected |
| Redux Toolkit | 最成熟、開發者工具好 | 過重，此專案不需要 | ❌ Rejected |

**Implementation Pattern**:
```typescript
// AuthContext.tsx
const AuthContext = createContext<AuthState | null>(null)

function AuthProvider({ children }: { children: React.ReactNode }) {
  const [state, dispatch] = useReducer(authReducer, initialState)
  // Auto-refresh token logic
  return <AuthContext.Provider value={{ ...state, dispatch }}>{children}</AuthContext.Provider>
}

// useAuth.ts
function useAuth() {
  const context = useContext(AuthContext)
  if (!context) throw new Error('useAuth must be used within AuthProvider')
  return context
}
```

---

## Decision 6: Frontend Build Tool — Vite

**Decision**: 使用 Vite 作為前端 build tool。

**Rationale**: Vite 是 React + TypeScript 專案的現代標準，HMR 快速、Cloudflare Pages 原生支援 Vite build output。

**Alternatives Considered**:

| Method | Pros | Cons | Status |
|--------|------|------|--------|
| Vite | 快速 HMR、TypeScript 原生支援、React plugin | 無 | ✅ Chosen |
| Create React App | 過去標準 | 已停止維護、不推薦新專案 | ❌ Rejected |
| Next.js | SSR/SSG、最全面 | 偏向 Vercel，Cloudflare Pages 支援有限 | ❌ Rejected |

---

## Decision 7: R2 Avatar Access — Public Bucket

**Decision**: 頭像使用 R2 public bucket，`avatar_url` 直接儲存公開物件 URL。

**Rationale**: 這是學習型 Cloudflare 全端專案，需求沒有要求私有媒體授權控管。直接使用 R2 public bucket 能降低實作複雜度、減少 Worker 額外流量與圖片代理邏輯，也更符合目前 PRD v1.2 的定案。

**Alternatives Considered**:

| Method | Pros | Cons | Status |
|--------|------|------|--------|
| R2 public bucket | 架構最簡單、直接存取、學習成本低 | 無法細緻控管權限 | ✅ Chosen |
| Worker proxy | 可加 cache/auth、可隱藏 bucket 細節 | 每次請求經過 Worker、實作較複雜 | ❌ Rejected |

---

## Decision 8: Routing — React Router v6

**Decision**: 前端路由使用 React Router v6。

**Rationale**: React Router 是 React SPA 的標準路由方案，v6 支援 nested routes、lazy loading、data loading 等現代功能。

---

## Decision 9: Member Center Information Architecture — Section-Based Account Center

**Decision**: 會員中心採用 section-based account center，而非單一長表單。至少分為基本資料、安全、OAuth 連結、登入歷史與帳號操作五個區塊。

**Rationale**: 參考 `masterRider` 會員系統，帳號相關操作被拆分成 Account Info、Settings、刪帳與外部個資編輯入口，對於後續擴充與敏感操作隔離更友善。本專案維持較小後端 scope，但前端資訊架構借鏡其分區思路，讓使用者更容易找到功能，也讓未來加入通知偏好或刪帳不必重做 IA。

**Alternatives Considered**:

| Method | Pros | Cons | Status |
|--------|------|------|--------|
| Single long profile page | 實作最直接 | 功能集中後可讀性差、未來擴充成本高 | ❌ Rejected |
| Section-based account center | 可讀性高、擴充性佳、便於分組安全功能 | 需要多一層前端資訊架構設計 | ✅ Chosen |
| 完全拆成多頁 settings flow | 可高度模組化 | 對目前專案規模偏重 | ❌ Rejected |

**Implementation Pattern**:
```tsx
<AccountCenterPage>
  <ProfileSection />
  <SecuritySection />
  <ConnectedAccountsSection />
  <LoginHistorySection />
  <AccountActionsSection />
</AccountCenterPage>
```

---

## Decision 10: Sensitive Identifier Changes — Excluded from v1

**Decision**: email / phone 等高風險帳號識別資料變更不納入 v1；若未來加入，必須要求二次驗證或重新驗證身分。

**Rationale**: 參考 `masterRider` 的 `AccountInfoChangePhoneVerify*` 流程，敏感識別資料變更應與一般暱稱 / 自介編輯分開處理，避免低風險表單直接改動高風險身份資訊。現階段先限制可修改欄位為 `name`、`bio`、`avatar`、`password`，維持系統單純。

---

## Summary

| Area | Decision | Status |
|------|----------|--------|
| Backend Framework | Hono | ✅ Confirmed |
| Password Hashing | PBKDF2 (Web Crypto API) | ✅ Confirmed |
| JWT Library | jose | ✅ Confirmed |
| OAuth Library | arctic | ✅ Confirmed |
| Frontend State | React Context + hooks | ✅ Confirmed |
| Build Tool | Vite | ✅ Confirmed |
| R2 Access | R2 Public Bucket | ✅ Confirmed |
| Frontend Router | React Router v6 | ✅ Confirmed |
| Member Center IA | Section-Based Account Center | ✅ Confirmed |
| Sensitive Identifier Changes | Excluded from v1 | ✅ Confirmed |

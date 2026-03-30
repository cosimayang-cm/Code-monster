# Tasks: Monster7 Member — Cloudflare 全端會員系統

**Input**: Design documents from `specs/007-cloudflare-member-system/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Tests**: Included — Vitest unit tests for API services and middleware.

**Organization**: Tasks grouped by Phase (matching PRD). Each Phase independently verifiable after completion.

## Format: `[ID] [P?] [Phase] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Phase]**: Which phase this task belongs to (Ph1–Ph7)
- All paths relative to project root: `monster7-member/`

---

## Phase 1: 專案初始化與基礎架構

**Purpose**: Mono Repo 骨架、Cloudflare 資源建立、雙環境配置

- [x] T001 [Ph1] 建立 `monster7-member/` 根目錄，初始化 git repo，建立 `.gitignore`（含 node_modules/, dist/, .dev.vars, .env.local, .wrangler/）
- [x] T002 [Ph1] 建立 `web-app/` — 使用 Vite + React 18 + TypeScript template 初始化，安裝 Tailwind CSS + React Router v6
- [x] T003 [Ph1] 建立 `api/` — 初始化 package.json，安裝 hono, jose, wrangler, typescript, @cloudflare/workers-types
- [ ] T004 [Ph1] 使用 wrangler CLI 建立 D1 databases：`monster7-db-staging` + `monster7-db-production`
- [ ] T005 [Ph1] 使用 wrangler CLI 建立 R2 buckets：`monster7-bucket-staging` + `monster7-bucket-production`
- [ ] T006 [Ph1] 使用 wrangler CLI 建立 KV namespaces：`monster7-kv-staging` + `monster7-kv-production`
- [x] T007 [Ph1] 建立 `api/wrangler.toml` — 配置雙環境 D1/R2/KV bindings
- [x] T008 [Ph1] 建立 `api/src/index.ts` — Hono app 骨架，`GET /health` 回傳 `{ status: "ok" }`
- [x] T009 [Ph1] 建立 `api/src/types.ts` — 定義 Env Bindings type（DB, BUCKET, KV, JWT_SECRET 等）
- [ ] T010 [Ph1] 連結 GitHub repo → Cloudflare Pages，設定 `main` 分支觸發 staging 部署、`staging` 分支觸發 production 部署
- [x] T011 [Ph1] 建立 `README.md` — 專案說明、本地開發指令、部署流程

**Checkpoint**: `npm run dev` 可啟動前端，`wrangler dev` 可啟動後端且 `/health` 回傳正常。

---

## Phase 2: D1 Schema + 基礎 API

**Purpose**: 建立 DB schema、API routing、CORS、統一錯誤處理

- [x] T012 [Ph2] 建立 `api/migrations/0001_create_users.sql` — users table schema（含所有欄位與索引）
- [ ] T013 [Ph2] 執行 `wrangler d1 migrations apply` — 在 staging D1 建立 users table
- [x] T014 [Ph2] 建立 `api/src/middleware/cors.ts` — 環境感知 CORS middleware（staging 只允許 staging domain，production 同理，localhost 允許開發）
- [x] T015 [Ph2] 建立統一錯誤處理 — 所有 API 錯誤回傳 `{ error: { code, message } }` 格式，Hono onError handler
- [x] T016 [Ph2] 重構 `api/src/index.ts` — 加入 CORS middleware、錯誤處理、模組化路由掛載（auth, users, admin）
- [x] T017 [Ph2] 建立 `api/src/routes/auth.ts` — auth 路由空骨架
- [x] T018 [Ph2] 建立 `api/src/routes/users.ts` — users 路由空骨架
- [x] T019 [Ph2] 建立 `api/src/routes/admin.ts` — admin 路由空骨架
- [x] T020 [Ph2] 更新 `GET /health` — 加入 DB 連線狀態檢查（`SELECT 1` from D1）

**Checkpoint**: API 路由架構完成，CORS 只允許指定 domain，錯誤回傳格式統一。

---

## Phase 3: 環境驗證與 Secret 管理

**Purpose**: 驗證 staging/production 隔離、設定 secrets、前端環境標示

- [x] T021 [Ph3] 建立 `api/.dev.vars` — 本地開發 secrets（JWT_SECRET 等），確認不進 git
- [ ] T022 [Ph3] 使用 `wrangler secret put` — 在 staging 設定 JWT_SECRET
- [x] T023 [Ph3] 建立 `web-app/.env.staging`、`web-app/.env.production`、`web-app/.env.local` — 非機密環境變數與本機覆寫
- [x] T024 [Ph3] 實作 `web-app/src/components/StagingBanner.tsx` — staging 環境顯示「STAGING」banner，production 不顯示
- [ ] T025 [Ph3] 部署 staging 環境 — 驗證 Pages + Worker 可正常存取
- [ ] T026 [Ph3] 驗證環境隔離 — staging 寫入資料，確認 production 查不到

**Checkpoint**: staging 已部署可存取，STAGING banner 正確顯示，secrets 不在程式碼中。

---

## Phase 4: 認證系統

**Purpose**: 帳密認證、JWT token、auth middleware

### Utilities

- [x] T027 [P] [Ph4] 建立 `api/src/utils/password.ts` — PBKDF2 hashPassword() + verifyPassword()（Web Crypto API）
- [x] T028 [P] [Ph4] 建立 `api/src/utils/jwt.ts` — signAccessToken(), signRefreshToken(), verifyToken()（jose library）
- [x] T029 [P] [Ph4] 建立 `api/src/utils/validation.ts` — validateEmail(), validatePassword()（≥8 字元、含大小寫、含數字）
- [x] T030 [P] [Ph4] 建立 `api/src/utils/uuid.ts` — generateUUID() wrapper

### Middleware

- [x] T031 [Ph4] 建立 `api/src/middleware/auth.ts` — requireAuth middleware：驗證 JWT、檢查 is_active、設定 userId/userRole 到 context

### Auth API

- [x] T032 [Ph4] 實作 `POST /api/auth/register` — 驗證輸入、密碼雜湊、D1 insert、回傳 JWT tokens
- [x] T033 [Ph4] 實作 `POST /api/auth/login` — 驗證帳密、記錄 login_history（if table exists）、回傳 JWT tokens
- [x] T034 [Ph4] 實作 `POST /api/auth/refresh` — 驗證 refresh token、回傳新 access token
- [x] T035 [Ph4] 實作 `GET /api/users/me` — requireAuth + 查詢當前使用者 Profile

### Frontend Auth

- [x] T036 [Ph4] 建立 `web-app/src/types/index.ts` — 共用 TypeScript types（User, AuthResponse, ApiError 等）
- [x] T037 [Ph4] 建立 `web-app/src/api/client.ts` — API client（fetch wrapper + base URL）
- [x] T038 [Ph4] 建立 `web-app/src/contexts/AuthContext.tsx` — Auth state provider（token 管理、login/logout/register dispatch）
- [x] T039 [Ph4] 建立 `web-app/src/hooks/useAuth.ts` — useAuth hook
- [x] T040 [Ph4] 建立 `web-app/src/components/ProtectedRoute.tsx` — 路由守衛（未登入導向 /login）
- [x] T041 [Ph4] 建立 `web-app/src/pages/RegisterPage.tsx` — 註冊頁面（email + password 表單）
- [x] T042 [Ph4] 建立 `web-app/src/pages/LoginPage.tsx` — 登入頁面（email + password 表單）
- [x] T043 [Ph4] 更新 `web-app/src/App.tsx` — React Router 設定（/, /login, /register, /profile, /auth/callback）

**Checkpoint**: 可完整註冊 → 登入 → 取得 Profile → refresh token。AC-12 ~ AC-17 通過。

---

## Phase 5: 會員功能

**Purpose**: Profile 編輯、頭像上傳、修改密碼、忘記密碼、登入歷史

### Database

- [x] T044 [Ph5] 建立 `api/migrations/0002_create_login_history.sql`（若尚未在 Phase 2 建立）
- [ ] T045 [Ph5] 執行 migration — 在 staging D1 建立 login_history table

### User API

- [x] T046 [Ph5] 實作 `PUT /api/users/me` — 更新 name、bio
- [x] T047 [Ph5] 實作 `POST /api/users/me/avatar` — 驗證檔案類型/大小 → 上傳 R2 public bucket → 更新 avatar_url
- [x] T048 [Ph5] 實作 `PUT /api/users/me/password` — 驗證舊密碼 → 雜湊新密碼 → 更新 D1
- [x] T049 [Ph5] 實作 `POST /api/auth/forgot-password` — 產生 reset token → 存 KV（TTL 30 分）→ response body 回傳 link
- [x] T050 [Ph5] 實作 `POST /api/auth/reset-password` — 驗證 KV token → 雜湊新密碼 → 更新 D1 → 刪除 KV token
- [x] T051 [Ph5] 實作 `GET /api/users/me/login-history` — 查詢當前使用者登入歷史
- [x] T052 [Ph5] 更新 login 路由 — 每次登入時寫入 login_history（method, ip, user_agent）

### Frontend Pages

- [x] T053 [Ph5] 建立 `web-app/src/pages/ProfilePage.tsx` — section-based 會員中心，顯示/編輯 name、bio、上傳頭像，並整合安全、OAuth、登入歷史與登出操作區塊
- [x] T054 [Ph5] 建立 `web-app/src/pages/ChangePasswordPage.tsx` — 舊密碼 + 新密碼表單
- [x] T055 [Ph5] 建立 `web-app/src/pages/ForgotPasswordPage.tsx` — 輸入 email，顯示 reset link
- [x] T056 [Ph5] 建立 `web-app/src/pages/ResetPasswordPage.tsx` — 輸入新密碼（從 URL 取 token）

### Token Auto-Refresh

- [x] T057 [Ph5] 更新 `web-app/src/api/client.ts` — 加入 401 自動 refresh token 邏輯 + refresh 失敗導向 /login

**Checkpoint**: 完整會員功能可用。AC-18 ~ AC-24 通過。

---

## Phase 6: OAuth 登入

**Purpose**: Google + GitHub OAuth、帳號連結/解除

### Database

- [x] T058 [Ph6] 建立 `api/migrations/0003_create_oauth_accounts.sql`
- [ ] T059 [Ph6] 執行 migration — 在 staging D1 建立 oauth_accounts table

### OAuth Backend

- [x] T060 [Ph6] 安裝 `arctic` — `cd api && npm install arctic`
- [x] T061 [Ph6] 建立 `api/src/services/oauth.ts` — OAuth provider 初始化（Google + GitHub）、帳號連結邏輯
- [x] T062 [Ph6] 實作 `GET /api/auth/oauth/:provider` — 產生 authorization URL + state → 存 KV → redirect
- [x] T063 [Ph6] 實作 `GET /api/auth/oauth/:provider/callback` — 驗證 state（KV）→ 取得 user info → 登入/註冊/連結 → redirect 前端帶 token
- [x] T064 [Ph6] 實作 `GET /api/users/me/oauth-accounts` — 列出已連結 OAuth 帳號
- [x] T065 [Ph6] 實作 `DELETE /api/users/me/oauth-accounts/:provider` — 解除連結（保護最後一種登入方式）
- [x] T066 [Ph6] 更新 login_history — OAuth 登入也記錄（method = 'google' | 'github'）

### OAuth Secrets

- [ ] T067 [Ph6] 使用 `wrangler secret put` — 設定 GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET（staging + production）

### Frontend

- [x] T068 [Ph6] 更新登入頁面 — 加入 Google / GitHub OAuth 按鈕
- [x] T069 [Ph6] 建立 `web-app/src/pages/AuthCallbackPage.tsx` — `/auth/callback` 從 URL 取得 token，存入 AuthContext
- [x] T070 [Ph6] 更新 Profile 頁面 — 顯示已連結 OAuth、提供連結/解除按鈕

**Checkpoint**: OAuth 登入/連結/解除完整可用。AC-25 ~ AC-29 通過。

---

## Phase 7: Admin 管理後台

**Purpose**: Admin 權限、使用者管理、Dashboard、活動日誌、seed script

### Middleware

- [x] T071 [Ph7] 建立 `api/src/middleware/admin.ts` — requireRole('admin') middleware，非 admin 回傳 403

### Admin API

- [x] T072 [P] [Ph7] 實作 `GET /api/admin/users` — 使用者列表（分頁，page + pageSize 參數）
- [x] T073 [P] [Ph7] 實作 `GET /api/admin/users/:id` — 使用者詳情（含 OAuth 連結 + 登入歷史）
- [x] T074 [Ph7] 實作 `PUT /api/admin/users/:id/role` — 變更角色（user ↔ admin）
- [x] T075 [Ph7] 實作 `PUT /api/admin/users/:id/status` — 啟用/停用帳號
- [x] T076 [Ph7] 實作 `GET /api/admin/dashboard/stats` — 統計數據（總用戶、今日註冊、7日活躍、停用數、OAuth 比例、24h 登入）
- [x] T077 [Ph7] 實作 `GET /api/admin/dashboard/activity` — 全站活動日誌（分頁 + method 篩選 + 時間範圍篩選）

### Seed Script

- [x] T078 [Ph7] 建立 `api/seed/seed.ts` — 建立初始 admin 帳號（admin@monster7.dev / Admin123!），可透過 wrangler d1 execute 執行

### Admin Frontend

- [x] T079 [Ph7] 建立 `web-app/src/pages/admin/AdminLayout.tsx` — Admin 側邊欄 layout（Dashboard、Users、Activity 導航）
- [x] T080 [Ph7] 建立 `web-app/src/pages/admin/DashboardPage.tsx` — 統計數據卡片展示
- [x] T081 [Ph7] 建立 `web-app/src/pages/admin/UsersPage.tsx` — 使用者列表（分頁 table）
- [x] T082 [Ph7] 建立 `web-app/src/pages/admin/UserDetailPage.tsx` — 使用者詳情（OAuth、登入歷史、角色/狀態操作）
- [x] T083 [Ph7] 建立 `web-app/src/pages/admin/ActivityPage.tsx` — 全站活動日誌（分頁 + 篩選）
- [x] T084 [Ph7] 更新 `web-app/src/App.tsx` — 加入 `/admin/*` 路由 + AdminRoute 守衛（驗證 admin role）
- [x] T085 [Ph7] 更新 `web-app/src/components/ProtectedRoute.tsx` — 新增 AdminRoute variant（403 if non-admin）

**Checkpoint**: Admin 後台完整可用，seed script 可建立初始帳號。AC-30 ~ AC-37 通過。

---

## Task Summary

| Phase | Task Count | Dependencies |
|-------|-----------|--------------|
| Phase 1: 專案初始化 | 11 (T001-T011) | None |
| Phase 2: Schema + API | 9 (T012-T020) | Phase 1 |
| Phase 3: 環境驗證 | 6 (T021-T026) | Phase 2 |
| Phase 4: 認證系統 | 17 (T027-T043) | Phase 3 |
| Phase 5: 會員功能 | 14 (T044-T057) | Phase 4 |
| Phase 6: OAuth | 13 (T058-T070) | Phase 4 |
| Phase 7: Admin | 15 (T071-T085) | Phase 5 + Phase 6 |
| **Total** | **85 tasks** | |

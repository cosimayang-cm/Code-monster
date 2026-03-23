# Implementation Plan: Monster7 Member — Cloudflare 全端會員系統

**Branch**: `007-cloudflare-member-system` | **Date**: 2026-03-20 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `specs/007-cloudflare-member-system/spec.md`

## Summary

建立一套完整的 Cloudflare 全端會員管理系統。前端使用 **React 18+ / TypeScript / Tailwind CSS** 部署於 **Cloudflare Pages**；後端使用 **Cloudflare Workers**（搭配 **Hono** 輕量框架）綁定 **D1**（SQLite 資料庫）、**R2**（物件儲存）、**KV**（Key-Value）。

系統涵蓋完整的認證流程（JWT access/refresh token）、會員 Profile 管理、頭像上傳、忘記密碼、OAuth 登入（Google + GitHub）、以及 Admin 管理後台。前端會員中心採用 section-based account center，將個人資料、安全、OAuth 連結、登入歷史與帳號操作分區呈現。全程只使用 Cloudflare 原生服務，不引入第三方 SaaS。

**Key architectural decisions**:
- **Hono** 作為 Workers 路由框架：輕量、原生 Cloudflare Workers 支援、middleware 系統完善
- **Mono Repo** 架構：`web-app/`（React SPA）+ `api/`（Worker），各自獨立 package
- **JWT** access/refresh token：access 15 分鐘、refresh 7 天
- **PBKDF2** 密碼雜湊：Workers 環境相容（Web Crypto API）
- **Section-based account center**：參考既有會員專案，將會員中心拆成清楚區塊而非單一長表單
- **staging / production** 雙環境完全隔離

## Technical Context

**Language/Version**: TypeScript 5.x
**Primary Dependencies**: React 18+, Hono, Tailwind CSS, jose (JWT), arctic (OAuth)
**Database**: Cloudflare D1 (SQLite)
**Storage**: Cloudflare R2 (object storage), Cloudflare KV (key-value)
**Testing**: Vitest (unit tests for API)
**Target Platform**: Web (Cloudflare Pages + Workers)
**Performance Goals**: Workers cold start < 50ms, API response < 200ms
**Constraints**: Workers 只支援 Web Crypto API，不支援 Node.js crypto；CPU 時間限制
**Scale/Scope**: 20 API endpoints, 2 frontend layouts (user + admin), 7 phases

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Constitution Applicability Assessment**:

This is a **Cloudflare 全端 Web 專案**，NOT an iOS/Swift project. PAGEs Framework 架構規範不適用。

| Constitution Principle | Applicability | Status |
|----------------------|---------------|--------|
| PAGEs Architecture layers | NOT applicable — Web/Cloudflare stack | N/A |
| Swift/UIKit patterns | NOT applicable — React/TypeScript | N/A |
| Security (OWASP Top 10) | APPLICABLE — Web 應用安全 | PASS |
| Secret management | APPLICABLE — wrangler secret, .dev.vars | PASS |
| CORS isolation | APPLICABLE — 環境隔離 | PASS |
| Password hashing | APPLICABLE — PBKDF2 via Web Crypto | PASS |
| JWT security | APPLICABLE — token 管理 | PASS |

## Project Structure

### Documentation (this feature)

```text
specs/007-cloudflare-member-system/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── tasks.md
├── contracts/
│   ├── auth-api.md
│   ├── users-api.md
│   └── admin-api.md
└── checklists/
    └── requirements.md
```

### Source Code

```text
monster7-member/
├── web-app/                          # React SPA (Cloudflare Pages)
│   ├── package.json
│   ├── tsconfig.json
│   ├── tailwind.config.js
│   ├── vite.config.ts
│   ├── .env.staging                  # Staging non-secret env vars
│   ├── .env.production               # Production non-secret env vars
│   ├── .env.local                    # Local override (不進 git)
│   ├── public/
│   └── src/
│       ├── main.tsx                  # Entry point
│       ├── App.tsx                   # Router setup
│       ├── api/
│       │   └── client.ts            # API client with auto-refresh
│       ├── components/account/
│       │   └── AccountSectionCard.tsx # 會員中心分區卡片
│       ├── contexts/
│       │   └── AuthContext.tsx       # Auth state management
│       ├── hooks/
│       │   └── useAuth.ts           # Auth hook
│       ├── components/
│       │   ├── StagingBanner.tsx     # Staging 環境標示
│       │   └── ProtectedRoute.tsx   # 路由守衛
│       ├── pages/
│       │   ├── LoginPage.tsx
│       │   ├── RegisterPage.tsx
│       │   ├── AuthCallbackPage.tsx  # /auth/callback
│       │   ├── ProfilePage.tsx       # 會員中心（basic info / security / OAuth / history / actions）
│       │   ├── ChangePasswordPage.tsx
│       │   ├── ForgotPasswordPage.tsx
│       │   ├── ResetPasswordPage.tsx
│       │   └── admin/
│       │       ├── AdminLayout.tsx   # 側邊欄 layout
│       │       ├── DashboardPage.tsx
│       │       ├── UsersPage.tsx
│       │       ├── UserDetailPage.tsx
│       │       └── ActivityPage.tsx
│       └── types/
│           └── index.ts             # Shared TypeScript types
│
├── api/                              # Cloudflare Worker
│   ├── package.json
│   ├── tsconfig.json
│   ├── wrangler.toml                # D1/R2/KV bindings + dual env
│   ├── .dev.vars                    # Local secrets (不進 git)
│   ├── migrations/
│   │   ├── 0001_create_users.sql
│   │   ├── 0002_create_login_history.sql
│   │   └── 0003_create_oauth_accounts.sql
│   ├── src/
│   │   ├── index.ts                 # Hono app entry
│   │   ├── types.ts                 # Env bindings type
│   │   ├── middleware/
│   │   │   ├── auth.ts              # JWT verification + is_active check
│   │   │   ├── cors.ts              # Environment-aware CORS
│   │   │   └── admin.ts             # requireRole('admin')
│   │   ├── routes/
│   │   │   ├── auth.ts              # register, login, refresh, forgot/reset password, OAuth
│   │   │   ├── users.ts             # profile, avatar, password, login-history, OAuth accounts
│   │   │   └── admin.ts             # users management, dashboard, activity
│   │   ├── services/
│   │   │   ├── auth.ts              # Password hashing, JWT sign/verify
│   │   │   ├── user.ts              # User CRUD operations
│   │   │   └── oauth.ts             # OAuth flow logic
│   │   └── utils/
│   │       ├── password.ts          # PBKDF2 wrapper
│   │       ├── jwt.ts               # JWT helpers (jose)
│   │       ├── uuid.ts              # UUID generation
│   │       └── validation.ts        # Input validation helpers
│   └── seed/
│       └── seed.ts                  # Admin seed script
│
├── .gitignore
└── README.md
```

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected |
|-----------|-----------|------------------------------|
| Mono Repo (web-app + api) | Cloudflare Pages 和 Workers 是獨立部署單元，各需獨立 package.json | Single package — 會混淆 Pages 和 Workers 的 build pipeline |
| Dual environment (staging + production) | PRD 要求環境隔離，確保安全性 | Single env — 不符合學習目標 |
| OAuth + KV state | CSRF 防護是 OAuth 安全的標準做法 | 無 state 驗證 — 安全漏洞 |
| Hono framework | 替代手動解析 Request，提供路由/middleware 支援 | Raw Workers fetch handler — 大量 boilerplate |

## Dependencies & Execution Order

```text
Phase 1: 專案初始化 ──────────────────────────┐
    │                                          │
    ▼                                          │
Phase 2: D1 Schema + 基礎 API ────────────────┤
    │                                          │
    ▼                                          │
Phase 3: 環境驗證 + Secret 管理 ───────────────┤
    │                                          │
    ▼                                          │
Phase 4: 認證系統 (JWT + 密碼) ────────────────┤  (所有後續需要 auth)
    │                                          │
    ├──────────────┐                           │
    ▼              ▼                           │
Phase 5:       Phase 6:                        │
會員功能       OAuth 登入                      │
    │              │                           │
    └──────┬───────┘                           │
           ▼                                   │
       Phase 7: Admin 管理後台 ────────────────┘
```

- Phase 1-3 是序列依賴，必須依序完成
- Phase 4 是 Phase 5-7 的前提
- Phase 5 和 Phase 6 可並行開發
- Phase 7 依賴 Phase 5（login_history table）和 Phase 6（oauth_accounts table）

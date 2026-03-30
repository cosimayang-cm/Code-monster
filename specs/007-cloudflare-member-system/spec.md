# Feature Specification: Monster7 Member — Cloudflare 全端會員系統

**Feature Branch**: `007-cloudflare-member-system`
**Created**: 2026-03-20
**Status**: Draft
**Input**: PRD — Cloudflare 全端會員系統 v1.2

## Clarifications

### Session 2026-03-20

- Q: 前端是否採用 SPA 架構？ → A: 採用 React SPA，部署於 Cloudflare Pages。
- Q: 後端是否使用 Hono framework？ → A: 可選用，PRD 建議 Hono 作為輕量路由框架。
- Q: R2 頭像的 public access 方式？ → A: 採用 R2 public bucket，`avatar_url` 直接儲存公開 URL。
- Q: 頭像上傳檔案大小限制？ → A: 5MB 以內。
- Q: OAuth callback URL 格式？ → A: provider callback 固定為 Worker API domain 的 `/api/auth/oauth/:provider/callback`，前端完成頁固定 `/auth/callback`。
- Q: 是否需要 email 驗證註冊流程？ → A: 不需要，註冊即啟用。
- Q: 分頁預設 page size？ → A: 20 筆。
- Q: 前端狀態管理方案？ → A: React Context + custom hooks（內部可使用 useReducer）。
- Q: 忘記密碼 reset link 格式？ → A: 直接回傳在 API response body 中（測試模式，不寄 email）。
- Q: 會員中心前端資訊架構？ → A: 採用 section-based account center，將基本資料、安全、OAuth 連結、登入歷史與帳號操作分區呈現，保留後續設定擴充空間。

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 帳號註冊與登入 (Priority: P1)

使用者開啟網站後看到登入頁面。可以切換到註冊頁面，輸入 email 和密碼完成註冊。註冊成功後自動登入並取得 JWT token。已註冊的使用者可以直接用 email + 密碼登入。登入後進入個人 Profile 頁面。

**Why this priority**: 認證是所有功能的前提，沒有登入就無法使用任何受保護的功能。

**Independent Test**: 在註冊/登入頁面輸入帳密，驗證 token 回傳、頁面導向、錯誤處理。

**Acceptance Scenarios**:

1. **Given** 使用者在註冊頁面，**When** 輸入有效 email 和符合強度要求的密碼（≥8 字元、含大小寫字母與數字），**Then** 帳號建立成功，密碼以 PBKDF2 雜湊儲存，回傳 access token（15 分鐘）+ refresh token（7 天）。
2. **Given** 使用者在註冊頁面，**When** 輸入不符合要求的密碼（如少於 8 字元），**Then** 回傳明確的錯誤訊息，說明密碼要求。
3. **Given** 使用者已有帳號，**When** 在登入頁面輸入正確帳密，**Then** 回傳 access token + refresh token，導向 Profile 頁面。
4. **Given** 使用者輸入錯誤帳密，**When** 嘗試登入，**Then** 回傳 401 錯誤與明確錯誤訊息。
5. **Given** 使用者的 access token 已過期，**When** 前端發送 API 請求，**Then** 自動用 refresh token 換發新 access token，請求不中斷。
6. **Given** refresh token 也已過期，**When** 前端嘗試 refresh，**Then** 導向登入頁。

---

### User Story 2 - 個人 Profile 管理 (Priority: P2)

登入後的使用者進入會員中心，可在分區式介面中查看與編輯 Profile（name、bio）、上傳頭像（存入 R2 public bucket）、修改密碼，並看到 OAuth 連結、登入歷史與帳號操作入口。所有變更即時反映在頁面上。

**Why this priority**: Profile 是會員系統的核心使用者功能，代表使用者身份。

**Independent Test**: 登入後在會員中心執行所有個人資料操作，驗證 R2 上傳、DB 更新與分區式資訊架構是否正確呈現。

**Acceptance Scenarios**:

1. **Given** 使用者已登入，**When** 呼叫 `GET /api/users/me`，**Then** 回傳 name、bio、avatar_url 等完整 Profile 資料。
2. **Given** 使用者已登入，**When** 更新 name 和 bio，**Then** 再次取得 Profile 可見更新後的資料。
3. **Given** 使用者已登入，**When** 上傳頭像（5MB 以內、image/jpeg|png|webp），**Then** 圖片存入 R2 public bucket，avatar_url 回傳可公開存取的 URL。
4. **Given** 使用者上傳超過 5MB 或不允許的檔案類型，**When** 呼叫上傳 API，**Then** 回傳明確錯誤訊息。
5. **Given** 使用者已登入，**When** 輸入正確舊密碼 + 新密碼修改密碼，**Then** 密碼更新成功，舊密碼無法再登入。
6. **Given** 使用者已登入，**When** 輸入錯誤舊密碼嘗試修改，**Then** 回傳 400 錯誤。
7. **Given** 使用者已登入，**When** 進入會員中心，**Then** 頁面清楚分出基本資料、安全、OAuth 連結、登入歷史與帳號操作區塊，避免所有功能堆在單一長表單中。

---

### User Story 3 - 忘記密碼流程 (Priority: P2)

使用者忘記密碼時，可在忘記密碼頁面輸入 email，系統回傳 reset link（測試模式，直接在 response body）。使用 reset link 可重設密碼。Token 一次性使用，30 分鐘過期。

**Why this priority**: 密碼重設是會員系統不可或缺的安全功能。

**Independent Test**: 呼叫忘記密碼 API 取得 reset link，驗證 token 存入 KV、重設後失效。

**Acceptance Scenarios**:

1. **Given** 使用者忘記密碼，**When** 呼叫 `POST /api/auth/forgot-password` 帶有效 email，**Then** response body 回傳 reset link，KV 存入 token（TTL 30 分鐘）。
2. **Given** 使用者取得 reset link，**When** 呼叫 `POST /api/auth/reset-password` 帶有效 token + 新密碼，**Then** 密碼重設成功，token 從 KV 刪除。
3. **Given** reset token 已使用過，**When** 再次使用同一 token，**Then** 回傳錯誤（token 無效）。
4. **Given** reset token 超過 30 分鐘，**When** 嘗試使用，**Then** KV 中 token 已過期，回傳錯誤。
5. **Given** 使用者輸入不存在的 email，**When** 呼叫 forgot-password，**Then** 回傳相同格式的成功 response（防止 email 枚舉攻擊）。

---

### User Story 4 - 登入歷史 (Priority: P3)

使用者可查看自己的登入歷史，包括每次登入的方式（email/google/github）、IP 位址、User Agent 和時間。

**Why this priority**: 登入歷史提供安全透明度，讓使用者可監控自己的帳號活動。

**Independent Test**: 多次用不同方式登入後，查詢登入歷史 API 驗證紀錄完整性。

**Acceptance Scenarios**:

1. **Given** 使用者已多次登入，**When** 呼叫 `GET /api/users/me/login-history`，**Then** 回傳每次登入的 method、ip_address、user_agent、created_at。
2. **Given** 使用者透過 email 登入，**When** 查詢歷史，**Then** method 顯示 "email"。
3. **Given** 使用者透過 OAuth 登入，**When** 查詢歷史，**Then** method 顯示對應 provider（"google" 或 "github"）。

---

### User Story 5 - OAuth 登入與帳號連結 (Priority: P3)

使用者可以用 Google 或 GitHub 進行 OAuth 登入。已有帳號的使用者可以連結/解除 OAuth。未登入時用 OAuth 可自動建立帳號。解除連結時系統保護至少保留一種登入方式。

**Why this priority**: OAuth 提供便利的第三方登入體驗，降低註冊門檻。

**Independent Test**: 透過 OAuth redirect → callback flow 驗證登入/註冊/連結/解除連結。

**Acceptance Scenarios**:

1. **Given** Google OAuth 已設定，**When** 使用者點擊 Google 登入，**Then** redirect → Google 授權 → callback → 取得 token，登入成功。
2. **Given** GitHub OAuth 已設定，**When** 使用者點擊 GitHub 登入，**Then** redirect → GitHub 授權 → callback → 取得 token，登入成功。
3. **Given** OAuth 登入流程開始，**When** callback 回傳時，**Then** 驗證 KV 中的 state 參數（CSRF 防護），state 不符拒絕登入。
4. **Given** 使用者已登入（email 方式），**When** 連結 Google OAuth，**Then** oauth_accounts 新增記錄，下次可用 Google 直接登入。
5. **Given** 使用者只有一種登入方式（僅 Google OAuth，無密碼），**When** 嘗試解除 Google OAuth 連結，**Then** 回傳錯誤，至少保留一種登入方式。
6. **Given** 未登入使用者用 OAuth 登入，provider_id 不存在，**When** callback 完成，**Then** 自動建立新帳號並登入。
7. **Given** OAuth callback 完成，**When** Worker 完成授權交換，**Then** 前端固定導向 `/auth/callback` 完成登入狀態同步。

---

### User Story 6 - Admin 使用者管理 (Priority: P3)

Admin 登入後可瀏覽使用者列表（分頁）、查看使用者詳情（含 OAuth 連結、登入歷史）、變更角色（user ↔ admin）、啟用/停用帳號。帳號停用後該使用者即時無法存取受保護 API。

**Why this priority**: Admin 管理功能是系統治理的必要組件。

**Independent Test**: 用 admin 帳號執行所有管理操作，驗證權限控制和狀態變更。

**Acceptance Scenarios**:

1. **Given** 使用者角色為 user（非 admin），**When** 呼叫 `/api/admin/*` 任一端點，**Then** 回傳 403 Forbidden。
2. **Given** Admin 已登入，**When** 呼叫 `GET /api/admin/users`，**Then** 回傳分頁使用者清單（預設 page size 20）。
3. **Given** Admin 已登入，**When** 查看使用者詳情，**Then** 回傳完整資料含 OAuth 連結與登入歷史。
4. **Given** Admin 變更某使用者角色為 admin，**When** 該使用者重新登入，**Then** 具備 admin 權限。
5. **Given** Admin 停用某帳號（is_active = false），**When** 該帳號嘗試呼叫受保護 API，**Then** 回傳 401，即使持有有效 token。

---

### User Story 7 - Admin Dashboard 與活動日誌 (Priority: P4)

Admin 可在 Dashboard 查看統計數據（總用戶數、今日註冊、活躍用戶、停用帳號、OAuth 比例、24 小時登入次數），並瀏覽全站活動日誌（支援分頁、登入方式篩選、時間範圍篩選）。

**Why this priority**: Dashboard 提供系統營運可視性，是管理功能的輔助工具。

**Independent Test**: 建立測試資料後，驗證 Dashboard 統計數字正確性與活動日誌篩選功能。

**Acceptance Scenarios**:

1. **Given** Admin 已登入，**When** 存取 Dashboard，**Then** 顯示正確的總用戶數、今日註冊數、活躍用戶（7 天）、停用帳號數、OAuth 連結比例、24 小時登入次數。
2. **Given** Admin 已登入，**When** 存取活動日誌，**Then** 顯示跨用戶登入紀錄，支援分頁。
3. **Given** Admin 篩選活動日誌，**When** 依登入方式篩選（email/google/github），**Then** 僅顯示對應方式的紀錄。
4. **Given** Admin 篩選活動日誌，**When** 依時間範圍篩選，**Then** 僅顯示該時段的紀錄。

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 系統 MUST 支援 email + 密碼的帳號註冊與登入。
- **FR-002**: 系統 MUST 使用 JWT access token（15 分鐘過期）+ refresh token（7 天過期）機制。
- **FR-003**: 系統 MUST 使用 PBKDF2 演算法（via Web Crypto API library）進行密碼雜湊。
- **FR-004**: 系統 MUST 驗證密碼強度：≥8 字元、包含大小寫字母與數字。
- **FR-005**: Auth middleware MUST 驗證 JWT 並檢查 `is_active` 狀態。
- **FR-006**: 系統 MUST 支援 Profile 編輯（name、bio）和頭像上傳（R2 儲存）。
- **FR-007**: 系統 MUST 支援修改密碼（驗證舊密碼）。
- **FR-008**: 系統 MUST 支援忘記密碼流程（reset token 存 KV，TTL 30 分鐘，一次性使用）。
- **FR-009**: 系統 MUST 記錄每次登入歷史（method、IP、user agent、時間）。
- **FR-010**: 系統 MUST 支援 Google + GitHub OAuth 登入，含 CSRF 防護（state 存 KV）。
- **FR-011**: 系統 MUST 支援 OAuth 帳號連結與解除，解除時至少保留一種登入方式。
- **FR-012**: Admin MUST 可管理使用者（列表、詳情、角色變更、啟停用）。
- **FR-013**: Admin Dashboard MUST 顯示統計數據與全站活動日誌。
- **FR-014**: CORS MUST 依環境限制（staging API 只允許 staging Pages domain，production 同理）。
- **FR-015**: 所有 API 錯誤 MUST 回傳統一格式 `{ error: { code, message } }`。
- **FR-016**: 前端 MUST 自動處理 token refresh，refresh 失敗導向登入頁。
- **FR-017**: staging 環境 MUST 顯示明顯的「STAGING」banner。
- **FR-018**: 頭像上傳 MUST 限制檔案大小（5MB）和類型（image/jpeg, image/png, image/webp）。
- **FR-019**: 前端會員中心 MUST 以 section-based account center 呈現，至少區分基本資料、安全、OAuth 連結、登入歷史與帳號操作。
- **FR-020**: OAuth callback 完成後，前端 MUST 透過固定 `/auth/callback` 路由接收登入結果。

### Key Entities

- **User**: 會員帳號（email、password_hash、name、bio、avatar_url、role、is_active）
- **OAuthAccount**: OAuth 連結帳號（user_id、provider、provider_id、provider_email）
- **LoginHistory**: 登入歷史紀錄（user_id、method、ip_address、user_agent、created_at）

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 完整的帳號註冊 → 登入 → Profile 編輯 → 頭像上傳 → 修改密碼 → OAuth 連結 → Admin 管理 → 登出 端對端流程可順利完成。
- **SC-002**: staging 和 production 環境完全隔離，各自使用獨立的 D1、R2、KV 資源。
- **SC-003**: 所有 secret（JWT_SECRET、OAuth credentials）不存在於任何程式碼或 git history 中。
- **SC-004**: CORS 正確隔離，staging API 只接受 staging 前端 domain 的請求。
- **SC-005**: Admin 操作（停用帳號）即時生效，被停用帳號立即無法存取受保護 API。
- **SC-006**: 前端 token 自動 refresh 機制運作正常，使用者無感知 token 過期。
- **SC-007**: 忘記密碼的 reset token 為一次性且 30 分鐘過期。
- **SC-008**: OAuth 帳號解除連結時正確保護，不允許移除唯一登入方式。
- **SC-009**: 已登入使用者可在同一個會員中心中找到個資編輯、密碼變更、OAuth 連結、登入歷史與登出操作，無需超過 2 次頁面導覽跳轉。

---

## Assumptions

- 全程只使用 Cloudflare 原生服務（Pages、Workers、D1、R2、KV），不引入第三方 SaaS。
- 所有 Cloudflare 資源使用 `wrangler` CLI 建立與管理。
- 忘記密碼為測試模式，不寄送 email，reset link 回傳在 response body。
- Workers 環境使用 Web Crypto API，不使用 Node.js `crypto` 模組。
- 本地開發 CORS 允許 `localhost`。
- 分頁預設 page size 為 20。
- 第一個 admin 帳號透過 seed script 建立。
- OAuth App 需在 Google Cloud Console 和 GitHub Developer Settings 手動申請。
- 會員中心採 section-based account center，前端先以單一路由整合主要會員操作。

---

## Out of Scope

- Email 通知服務（未整合 email provider）。
- Email 驗證註冊流程。
- Token blacklist（登出僅由前端清除 token）。
- Rate limiting / brute force 防護（可未來擴展）。
- 國際化（i18n）。
- 帳號刪除流程。
- 通知偏好 / 語系偏好設定。
- email / phone 等高風險帳號識別資料變更流程。
- 行動端 responsive 設計（以桌面瀏覽器為主）。
- SSR（Server-Side Rendering）。
- 自動化測試（E2E / integration test）。
- GitHub Actions 自動部署 Worker API（手動 `wrangler deploy` 即可）。

---

## Edge Cases

- 使用者以相同 email 重複註冊：回傳 409 Conflict。
- OAuth 的 provider email 與現有帳號 email 相同但未連結：建立新帳號（不自動合併）。
- 同時發送多個 refresh token 請求：第一個成功，後續可能因 token 已換發而失敗。
- R2 上傳中斷：回傳 500 錯誤，不留下部分上傳的檔案。
- D1 concurrent write：SQLite 層級的 WAL 處理，Cloudflare 保證單一 Worker 實例的序列化。
- Admin 停用自己的帳號：應被允許（自我停用），但立即失去存取權。
- 密碼重設 token race condition：KV 保證原子性讀寫，第二次使用回傳錯誤。
- 若未來新增 email / phone 變更功能：必須要求二次驗證或重新驗證身分，不能直接沿用一般 Profile 編輯流程。

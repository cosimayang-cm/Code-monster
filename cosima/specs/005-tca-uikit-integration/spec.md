# Feature Specification: TCA + UIKit 整合實戰

**Feature Branch**: `005-tca-uikit-integration`  
**Created**: 2026-02-17  
**Status**: Draft  
**Input**: Code Monster #5 - TCA + UIKit 整合實戰

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 登入頁面 UI 與狀態管理 (Priority: P1)

使用者開啟 App 後看到登入頁面，可以輸入帳號與密碼，點擊登入按鈕。輸入的每個字元都即時反映在 TCA State 中。

**Why this priority**: 登入是 App 的入口，所有後續功能都依賴登入成功。

**Independent Test**: 可透過在帳號欄位輸入文字後，驗證 TCA State 中的帳號值是否同步更新。

**Acceptance Scenarios**:

1. **Given** 登入頁面已載入, **When** 使用者在帳號欄位輸入 "emilys", **Then** State 中的帳號值為 "emilys"
2. **Given** 登入頁面已載入, **When** 使用者在密碼欄位輸入 "emilyspass", **Then** State 中的密碼值為 "emilyspass"
3. **Given** 帳號或密碼欄位為空, **When** 檢查登入按鈕, **Then** 登入按鈕視覺上可見但仍可點擊（驗證在 API 端）
4. **Given** 登入頁面已載入, **When** 觀察 UI, **Then** 包含帳號 UITextField、密碼 UITextField、登入 UIButton、UIActivityIndicatorView

---

### User Story 2 - 登入 API 請求與 Loading 狀態 (Priority: P1)

使用者點擊登入按鈕後，系統發送 API 請求。在請求期間，顯示 loading indicator 且登入按鈕 disabled，阻止重複提交。

**Why this priority**: 登入流程的核心邏輯，處理非同步 API 請求與 UI 反饋。

**Independent Test**: 可透過點擊登入按鈕後，驗證 loading indicator 出現且按鈕變為 disabled。

**Acceptance Scenarios**:

1. **Given** 已輸入帳號密碼, **When** 點擊登入按鈕, **Then** isLoading 變為 true，loading indicator 顯示
2. **Given** 正在載入中, **When** 觀察登入按鈕, **Then** 按鈕為 disabled 狀態
3. **Given** API 請求完成（成功或失敗）, **When** 收到回應, **Then** isLoading 變為 false，loading indicator 隱藏
4. **Given** 正在載入中, **When** 使用者嘗試再次點擊登入, **Then** 不會發送重複請求

---

### User Story 3 - 登入成功與畫面轉場 (Priority: P1)

使用者登入成功後，系統保存用戶資訊並自動轉場到文章列表頁面。

**Why this priority**: 成功登入是進入主要功能的必要路徑。

**Independent Test**: 可透過使用測試帳號 emilys/emilyspass 登入，驗證是否成功轉場到 Posts 列表頁。

**Acceptance Scenarios**:

1. **Given** 輸入正確帳密 (emilys/emilyspass), **When** 點擊登入, **Then** API 回傳用戶資訊，State 中 user 不為 nil
2. **Given** 登入成功, **When** 收到用戶資訊, **Then** 自動使用 UINavigationController push 到 Posts 列表頁
3. **Given** 登入成功後的用戶資訊, **When** 檢查資料, **Then** 包含 id、username、email、firstName、lastName、accessToken

---

### User Story 4 - 登入失敗與錯誤處理 (Priority: P1)

使用者輸入錯誤的帳號密碼時，系統顯示錯誤訊息 Toast，3 秒後自動消失。

**Why this priority**: 錯誤處理是基本的使用者體驗要求。

**Independent Test**: 可透過輸入錯誤帳密後，驗證 error toast 是否出現並於 3 秒後消失。

**Acceptance Scenarios**:

1. **Given** 輸入錯誤帳密 (wronguser/wrongpass), **When** 點擊登入, **Then** State 中 errorMessage 不為 nil
2. **Given** 收到錯誤回應, **When** 顯示 error toast, **Then** toast 顯示 API 回傳的錯誤訊息
3. **Given** error toast 已顯示, **When** 經過 3 秒, **Then** toast 自動消失，State 中 errorMessage 回復為 nil
4. **Given** error toast 已顯示, **When** 使用者手動關閉, **Then** toast 立即消失

---

### User Story 5 - Posts 列表載入與顯示 (Priority: P1)

登入成功後進入 Posts 列表頁，系統自動發送 API 請求載入文章列表，並以 UITableView 顯示。

**Why this priority**: 文章列表是登入後的主要功能頁面。

**Independent Test**: 可透過進入列表頁後，驗證 UITableView 是否正確顯示 100 筆文章資料。

**Acceptance Scenarios**:

1. **Given** 進入 Posts 列表頁, **When** 頁面 viewDidAppear, **Then** 自動發送 GET 請求載入文章列表
2. **Given** API 回傳 100 篇文章, **When** 資料載入完成, **Then** UITableView 顯示 100 個 Cell
3. **Given** 每篇文章, **When** 顯示在 Cell 中, **Then** Cell 包含標題（title）、內容預覽（body 截斷）、按讚數、留言數、分享按鈕
4. **Given** 載入中, **When** 資料尚未回傳, **Then** 顯示 loading indicator
5. **Given** 載入失敗, **When** 網路異常, **Then** 顯示錯誤提示

---

### User Story 6 - Post Detail 頁面 (Priority: P1)

使用者點擊文章 Cell 後，使用 UINavigationController push 進入 Post Detail 頁面，顯示完整文章內容與互動按鈕。

**Why this priority**: 文章詳情是列表的延伸，提供完整閱讀體驗。

**Independent Test**: 可透過點擊列表第一篇文章，驗證 Detail 頁面是否正確顯示完整內容。

**Acceptance Scenarios**:

1. **Given** 文章列表已載入, **When** 點擊某篇文章 Cell, **Then** Navigation Controller push 到 Post Detail 頁面
2. **Given** 進入 Detail 頁面, **When** 頁面載入, **Then** 顯示完整文章標題（title）和內容（body）
3. **Given** Detail 頁面, **When** 觀察互動區域, **Then** 顯示按讚按鈕（含按讚數）、留言區域（含留言數）、分享按鈕
4. **Given** Detail 頁面, **When** 點擊返回, **Then** Navigation Controller pop 回列表頁

---

### User Story 7 - 按讚功能與狀態同步 (Priority: P1)

使用者可以在 Post Detail 頁面進行按讚操作，按讚狀態需在返回列表頁時同步更新對應的 Cell。

**Why this priority**: 狀態同步是 TCA 架構的核心學習重點，展示父子狀態如何保持一致。

**Independent Test**: 可透過在 Detail 頁面按讚後返回列表頁，驗證對應 Cell 的按讚數是否更新。

**Acceptance Scenarios**:

1. **Given** 某文章尚未按讚, **When** 在 Detail 頁面點擊按讚, **Then** 按讚數 +1，按讚按鈕變為已按讚樣式
2. **Given** 某文章已按讚, **When** 在 Detail 頁面再次點擊按讚, **Then** 按讚數 -1，按讚按鈕回復未按讚樣式（取消按讚）
3. **Given** 在 Detail 頁面按讚後, **When** 返回列表頁, **Then** 對應的 Cell 按讚數與按讚狀態同步更新
4. **Given** 按讚操作完成, **When** 檢查 Local Storage, **Then** 按讚狀態已持久化儲存

---

### User Story 8 - 留言功能 (Priority: P2)

使用者可以在 Post Detail 頁面進行留言操作，留言數同步回列表頁。

**Why this priority**: 留言是進階互動功能，增強體驗但非核心流程。

**Independent Test**: 可透過在 Detail 頁面新增留言後，驗證留言數是否更新。

**Acceptance Scenarios**:

1. **Given** Detail 頁面的留言區, **When** 輸入留言文字並送出, **Then** 留言數 +1，留言顯示在列表中
2. **Given** 在 Detail 頁面新增留言後, **When** 返回列表頁, **Then** 對應 Cell 的留言數同步更新
3. **Given** 留言操作完成, **When** 檢查 Local Storage, **Then** 留言資料已持久化儲存

---

### User Story 9 - 互動數據持久化 (Priority: P2)

所有互動數據（按讚、留言）使用 Local Storage（UserDefaults）持久化儲存，App 重啟後仍保留。

**Why this priority**: 資料持久化確保使用者操作不會因 App 關閉而遺失。

**Independent Test**: 可透過按讚後重啟 App，驗證按讚狀態是否仍存在。

**Acceptance Scenarios**:

1. **Given** 使用者對文章 ID=1 按讚, **When** App 重新啟動並載入文章列表, **Then** 文章 ID=1 仍顯示已按讚狀態
2. **Given** 使用者在文章 ID=1 留言 "Great post", **When** App 重新啟動並進入 Detail, **Then** 留言 "Great post" 仍存在
3. **Given** 互動數據存在, **When** 讀取 Local Storage, **Then** 資料結構完整可解析

---

### User Story 10 - TCA observe 模式與 UIKit 整合 (Priority: P1)

所有 UIKit ViewController 使用 TCA 的 `observe { }` 模式觀察 State 變化，透過 `store.send()` 發送 Action。

**Why this priority**: 這是本題的核心學習目標，確保 TCA 與 UIKit 的正確整合方式。

**Independent Test**: 可透過 State 變更後驗證 UI 是否自動更新，無需手動刷新。

**Acceptance Scenarios**:

1. **Given** LoginViewController, **When** 在 viewDidLoad 中設定 observe, **Then** State 變更時 UI 自動更新
2. **Given** PostsViewController, **When** store.send(.loadPosts), **Then** 觸發 API 請求並更新列表
3. **Given** PostDetailViewController, **When** store.send(.toggleLike), **Then** 按讚狀態即時反映在 UI 上
4. **Given** 任何 ViewController, **When** State 中的值變更, **Then** 對應的 UIKit 元件自動更新，無需手動呼叫

---

### Edge Cases

- 登入請求超時時的處理（應顯示網路錯誤 toast）
- 登入成功但 token 為空時的處理（應視為登入失敗）
- Posts API 回傳空陣列時的處理（應顯示空狀態提示）
- 連續快速點擊按讚時的處理（應防止重複操作或使用 debounce）
- Local Storage 資料損毀時的處理（應提供 fallback 預設值）
- 網路斷線時嘗試載入文章的處理（應顯示離線提示）
- Navigation stack 中的記憶體管理（ViewController 釋放時應取消觀察）

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 系統 MUST 提供帳號密碼登入功能，使用 POST https://dummyjson.com/auth/login API
- **FR-002**: 系統 MUST 在登入載入期間禁用登入按鈕並顯示 loading indicator
- **FR-003**: 系統 MUST 在登入成功後自動轉場到 Posts 列表頁面
- **FR-004**: 系統 MUST 在登入失敗時顯示 error toast，3 秒後自動消失
- **FR-005**: 系統 MUST 使用 GET https://jsonplaceholder.typicode.com/posts 載入文章列表
- **FR-006**: 系統 MUST 在 UITableView Cell 中顯示文章標題、內容預覽、按讚數、留言數、分享按鈕
- **FR-007**: 系統 MUST 支援點擊 Cell 使用 UINavigationController push 到 Post Detail 頁面
- **FR-008**: 系統 MUST 在 Post Detail 頁面顯示完整文章內容與互動按鈕
- **FR-009**: 系統 MUST 支援按讚/取消按讚操作
- **FR-010**: 系統 MUST 確保 Detail 頁面的按讚狀態與列表頁 Cell 同步
- **FR-011**: 系統 MUST 使用 Local Storage（UserDefaults）持久化互動數據
- **FR-012**: 系統 MUST 使用 TCA 的 `observe { }` 模式與 UIKit 整合
- **FR-013**: 系統 MUST 使用 TCA 管理所有畫面轉場（Navigation）
- **FR-014**: 系統 MUST 使用 `@Dependency` 注入 AuthClient、PostsClient、StorageClient
- **FR-015**: 系統 MUST 支援留言操作且留言數同步回列表頁

### Key Entities

- **User**: 登入用戶資訊（id, username, email, firstName, lastName, gender, image, accessToken, refreshToken）
- **Post**: 文章資料（userId, id, title, body）
- **PostInteraction**: 文章互動數據（postId, likeCount, isLiked, comments, shareCount）
- **Comment**: 留言（id, postId, content, createdAt）
- **LoginFeature.State**: 登入頁面 TCA State
- **LoginFeature.Action**: 登入頁面 TCA Action
- **PostsFeature.State**: 文章列表 TCA State
- **PostsFeature.Action**: 文章列表 TCA Action
- **PostDetailFeature.State**: 文章詳情 TCA State
- **PostDetailFeature.Action**: 文章詳情 TCA Action
- **AppFeature.State**: App 層級 TCA State（管理導航）
- **AppFeature.Action**: App 層級 TCA Action（管理導航）

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 使用測試帳號 emilys/emilyspass 可成功登入並轉場到列表頁
- **SC-002**: 使用錯誤帳密登入時，error toast 3 秒後自動消失
- **SC-003**: Posts 列表正確顯示 100 篇文章
- **SC-004**: 點擊 Cell 成功 push 到 Detail 頁面，顯示完整內容
- **SC-005**: 在 Detail 按讚後返回列表，對應 Cell 按讚數同步更新
- **SC-006**: App 重啟後互動數據（按讚、留言）仍然保留
- **SC-007**: 所有 ViewController 使用 TCA observe 模式，無直接 state mutation
- **SC-008**: 所有 API 請求透過 TCA Dependency 注入，支援測試替換
- **SC-009**: 導航由 TCA State 驅動，非直接 UIKit 操作
- **SC-010**: Loading 狀態期間按鈕 disabled，不可重複提交

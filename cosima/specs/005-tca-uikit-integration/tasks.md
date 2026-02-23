# Tasks: TCA + UIKit 整合實戰

**Feature**: feature/monster5-tca-uikit-integration
**Date**: 2026-02-17

## Task Overview

| Phase | Tasks | Priority | Estimated LOC |
|-------|-------|----------|---------------|
| Phase 1 | 5 | P1 | ~100 |
| Phase 2 | 4 | P1 | ~180 |
| Phase 3 | 4 | P1 | ~260 |
| Phase 4 | 3 | P1 | ~160 |
| Phase 5 | 4 | P1 | ~230 |
| Phase 6 | 4 | P1 | ~340 |
| Phase 7 | 4 | P1-P2 | ~220 |
| Phase 8 | 3 | P2 | ~160 |
| **Total** | **31** | - | **~1650** |

---

## Phase 1: Data Models (P1)

### TASK-001: 建立 User 模型
**Story**: US-003
**File**: `Monster5/Models/User.swift`
**LOC**: ~20

- [ ] 定義 User struct（id, username, email, firstName, lastName, gender, image, accessToken, refreshToken）
- [ ] 實作 Codable, Equatable 協定
- [ ] 新增 static mock 測試用資料
- [ ] 撰寫單元測試

**Acceptance Criteria**:
- 可從 DummyJSON login response JSON 正確解碼
- mock 資料可用於 TestStore

---

### TASK-002: 建立 Post 模型
**Story**: US-005
**File**: `Monster5/Models/Post.swift`
**LOC**: ~15

- [ ] 定義 Post struct（userId, id, title, body）
- [ ] 實作 Codable, Equatable, Identifiable 協定
- [ ] 新增 static mock 與 mockList 測試用資料
- [ ] 撰寫單元測試

**Acceptance Criteria**:
- 可從 JSONPlaceholder posts response JSON 正確解碼
- Identifiable 的 id 為 post 的 id 欄位

---

### TASK-003: 建立 PostInteraction 模型
**Story**: US-007, US-009
**File**: `Monster5/Models/PostInteraction.swift`
**LOC**: ~25

- [ ] 定義 PostInteraction struct（postId, likeCount, isLiked, comments, shareCount）
- [ ] 實作 Codable, Equatable 協定
- [ ] 新增 `static func empty(for postId: Int)` 工廠方法
- [ ] 撰寫單元測試

**Acceptance Criteria**:
- empty 工廠方法回傳全部預設值（likeCount=0, isLiked=false 等）
- 可正確 JSON 序列化/反序列化

---

### TASK-004: 建立 Comment 模型
**Story**: US-008
**File**: `Monster5/Models/Comment.swift`
**LOC**: ~15

- [ ] 定義 Comment struct（id: UUID, postId, content, createdAt）
- [ ] 實作 Codable, Equatable, Identifiable 協定
- [ ] 撰寫單元測試

---

### TASK-005: 建立 APIError 模型
**Story**: US-004
**File**: `Monster5/Models/APIError.swift`
**LOC**: ~10

- [ ] 定義 APIError struct（message: String）
- [ ] 實作 Codable, Equatable, Error 協定
- [ ] 撰寫單元測試

**Acceptance Criteria**:
- 可從 DummyJSON 錯誤回應 JSON 正確解碼

---

## Phase 2: Dependencies (P1)

### TASK-006: 實作 AuthClient
**Story**: US-002, US-003, US-004
**File**: `Monster5/Dependencies/AuthClient.swift`
**LOC**: ~60

- [ ] 定義 AuthClient struct（login closure）
- [ ] 實作 DependencyKey（liveValue: 真實 API 呼叫）
- [ ] 實作 testValue（回傳 mock User）
- [ ] 註冊到 DependencyValues
- [ ] 處理 HTTP 200 成功 / 非 200 失敗邏輯
- [ ] 撰寫單元測試

**Acceptance Criteria**:
- liveValue 可成功呼叫 POST https://dummyjson.com/auth/login
- 帳密錯誤時 throw APIError
- testValue 不發送網路請求

---

### TASK-007: 實作 PostsClient
**Story**: US-005
**File**: `Monster5/Dependencies/PostsClient.swift`
**LOC**: ~40

- [ ] 定義 PostsClient struct（fetchPosts closure）
- [ ] 實作 DependencyKey（liveValue: 真實 API 呼叫）
- [ ] 實作 testValue（回傳 mock posts）
- [ ] 註冊到 DependencyValues
- [ ] 撰寫單元測試

**Acceptance Criteria**:
- liveValue 可成功呼叫 GET https://jsonplaceholder.typicode.com/posts
- 正確解碼 100 筆 Post

---

### TASK-008: 實作 StorageClient
**Story**: US-009
**File**: `Monster5/Dependencies/StorageClient.swift`
**LOC**: ~80

- [ ] 定義 StorageClient struct（loadInteractions, saveInteractions closures）
- [ ] 實作 DependencyKey（liveValue: UserDefaults 讀寫）
- [ ] 實作 testValue（記憶體內 dictionary）
- [ ] 使用 JSONEncoder/JSONDecoder 序列化
- [ ] 處理解碼失敗時的 fallback（空 dictionary）
- [ ] 註冊到 DependencyValues
- [ ] 撰寫單元測試

**Acceptance Criteria**:
- 可正確儲存/讀取 PostInteraction dictionary
- 資料損毀時返回空 dictionary 而非 crash

---

### TASK-009: 建立 ToastView
**Story**: US-004
**File**: `Monster5/Views/ToastView.swift`
**LOC**: ~60

- [ ] 建立自訂 UIView 子類（背景色 + UILabel）
- [ ] 實作 show(in:message:) 靜態方法
- [ ] 實作淡入動畫（UIView.animate）
- [ ] 實作淡出動畫
- [ ] 支援手動點擊關閉

**Acceptance Criteria**:
- Toast 顯示在畫面頂部或底部
- 有圓角和半透明背景
- 動畫流暢

---

## Phase 3: LoginFeature (P1)

### TASK-010: 實作 LoginFeature Reducer
**Story**: US-001, US-002, US-003, US-004
**File**: `Monster5/Features/Login/LoginFeature.swift`
**LOC**: ~80

- [ ] 定義 @ObservableState State（username, password, isLoading, errorMessage, user）
- [ ] 定義 Action（binding, loginButtonTapped, loginResponse, dismissError）
- [ ] 實作 BindingReducer（雙向綁定 username/password）
- [ ] 實作 loginButtonTapped → Effect.run { } 呼叫 AuthClient
- [ ] 實作 loginResponse 成功/失敗處理
- [ ] 實作 dismissError（3 秒後自動觸發）
- [ ] 撰寫完整 TestStore 測試

**Acceptance Criteria**:
- loginButtonTapped 時 isLoading 變 true
- 成功時 user 有值、isLoading 回 false
- 失敗時 errorMessage 有值、3 秒後清除

---

### TASK-011: 實作 LoginViewController
**Story**: US-001, US-010
**File**: `Monster5/Features/Login/LoginViewController.swift`
**LOC**: ~120

- [ ] 建立 UI 元件（usernameField, passwordField, loginButton, loadingIndicator）
- [ ] 使用 Auto Layout 或 StackView 排版
- [ ] 在 viewDidLoad 中設定 observe { } 觀察 State
- [ ] observe 中更新 UI：text、button enabled、loading indicator、error toast
- [ ] 設定 UITextField editingChanged → store.send(.set(\.username, ...))
- [ ] 設定 loginButton touchUpInside → store.send(.loginButtonTapped)
- [ ] 密碼欄位設定 isSecureTextEntry

**Acceptance Criteria**:
- State 變更時 UI 自動更新
- 不使用 ViewStore（使用 observe 模式）

---

### TASK-012: LoginFeature 單元測試
**Story**: US-001~US-004
**File**: `Monster5Tests/LoginFeatureTests.swift`
**LOC**: ~100

- [ ] 測試帳號輸入更新 State
- [ ] 測試密碼輸入更新 State
- [ ] 測試登入成功流程（isLoading → user 有值）
- [ ] 測試登入失敗流程（isLoading → errorMessage 有值）
- [ ] 測試 error 3 秒後自動消失
- [ ] 測試 loading 期間不可重複送出

---

### TASK-013: 整合 Login Error Toast
**Story**: US-004
**File**: `Monster5/Features/Login/LoginViewController.swift` (修改)
**LOC**: ~20

- [ ] 在 observe 中偵測 errorMessage 變化
- [ ] errorMessage 有值時呼叫 ToastView.show()
- [ ] 確保 toast 不會重複顯示

---

## Phase 4: PostsFeature (P1)

### TASK-014: 實作 PostsFeature Reducer
**Story**: US-005
**File**: `Monster5/Features/Posts/PostsFeature.swift`
**LOC**: ~100

- [ ] 定義 @ObservableState State（posts: IdentifiedArrayOf<PostDetailFeature.State>, isLoading, errorMessage）
- [ ] 定義 Action（onAppear, postsResponse, postTapped, post delegate action）
- [ ] 實作 onAppear → Effect.run { } 呼叫 PostsClient + StorageClient
- [ ] 合併 API 文章資料與 Local Storage 互動數據
- [ ] 使用 Scope 或 forEach 整合 PostDetailFeature
- [ ] 撰寫 TestStore 測試

**Acceptance Criteria**:
- onAppear 觸發載入（isLoading → posts 有值）
- posts 為 IdentifiedArray 以支援 id 查找
- 子 Feature (PostDetail) 的 action 可被父 Feature 接收

---

### TASK-015: 實作 PostsViewController
**Story**: US-005, US-010
**File**: `Monster5/Features/Posts/PostsViewController.swift`
**LOC**: ~150

- [ ] 建立 UITableView，註冊 PostTableViewCell
- [ ] 在 viewDidLoad 中 store.send(.onAppear) 觸發載入
- [ ] 在 observe { } 中更新 UITableView（reloadData）
- [ ] 實作 UITableViewDataSource（numberOfRows, cellForRowAt）
- [ ] 實作 UITableViewDelegate（didSelectRowAt → store.send(.postTapped)）
- [ ] 處理 loading 與 error 狀態
- [ ] Cell 中的按讚/分享按鈕透過 closure 回傳 store.send()

**Acceptance Criteria**:
- 正確顯示 100 筆文章
- 點擊 Cell 觸發 postTapped action
- Cell 中的互動按鈕可觸發對應 action

---

### TASK-016: 實作 PostTableViewCell
**Story**: US-005
**File**: `Monster5/Features/Posts/PostTableViewCell.swift`
**LOC**: ~80

- [ ] 建立 title UILabel（粗體）
- [ ] 建立 body preview UILabel（限制行數，灰色）
- [ ] 建立按讚按鈕 + 按讚數 UILabel
- [ ] 建立留言圖示 + 留言數 UILabel
- [ ] 建立分享按鈕
- [ ] 使用 Auto Layout 排版
- [ ] 提供 configure(post:interaction:) 方法
- [ ] 提供 onLikeTapped / onShareTapped closure

**Acceptance Criteria**:
- Cell 可正確顯示文章標題、預覽、互動數據
- 按讚按鈕依據 isLiked 切換樣式（實心/空心愛心）

---

### TASK-017: PostsFeature 單元測試
**Story**: US-005
**File**: `Monster5Tests/PostsFeatureTests.swift`
**LOC**: ~80

- [ ] 測試 onAppear 載入文章列表
- [ ] 測試載入失敗顯示 errorMessage
- [ ] 測試 postTapped 設定選中文章
- [ ] 測試子 Feature action 傳遞

---

## Phase 5: PostDetailFeature (P1)

### TASK-018: 實作 PostDetailFeature Reducer
**Story**: US-006, US-007, US-008
**File**: `Monster5/Features/PostDetail/PostDetailFeature.swift`
**LOC**: ~80

- [ ] 定義 @ObservableState State（post, interaction, commentText）
- [ ] 定義 Action（toggleLike, addComment, commentTextChanged, shareTapped, saveInteraction）
- [ ] 實作 toggleLike（isLiked toggle, likeCount +1/-1）
- [ ] 實作 addComment（建立 Comment，加入 interaction.comments，likeCount +1）
- [ ] 實作 shareTapped（shareCount +1）
- [ ] 每次互動後觸發 saveInteraction Effect
- [ ] 撰寫 TestStore 測試

**Acceptance Criteria**:
- toggleLike 正確切換按讚狀態
- addComment 將留言加入列表
- 每次操作後觸發儲存

---

### TASK-019: 實作 PostDetailViewController
**Story**: US-006, US-010
**File**: `Monster5/Features/PostDetail/PostDetailViewController.swift`
**LOC**: ~150

- [ ] 建立 ScrollView 包含完整文章內容
- [ ] 建立 title UILabel（大標題）
- [ ] 建立 body UILabel（完整內容）
- [ ] 建立互動區域（按讚按鈕 + 留言區 + 分享按鈕）
- [ ] 建立留言輸入框 + 送出按鈕
- [ ] 建立留言列表（簡單 UIStackView 或 UITableView）
- [ ] 在 viewDidLoad 中設定 observe { } 觀察 State
- [ ] 綁定各按鈕到 store.send()

**Acceptance Criteria**:
- 顯示完整文章標題與內容
- 按讚按鈕即時更新樣式
- 留言送出後清空輸入框並顯示新留言

---

### TASK-020: PostDetailFeature 單元測試
**Story**: US-007, US-008
**File**: `Monster5Tests/PostDetailFeatureTests.swift`
**LOC**: ~80

- [ ] 測試 toggleLike 從未按讚到按讚
- [ ] 測試 toggleLike 從已按讚到取消
- [ ] 測試 addComment 新增留言
- [ ] 測試 shareTapped 增加分享數
- [ ] 測試每次操作觸發 saveInteraction

---

## Phase 6: Navigation & App Integration (P1)

### TASK-021: 實作 AppFeature Reducer
**Story**: US-003, US-06
**File**: `Monster5/App/AppFeature.swift`
**LOC**: ~100

- [ ] 定義 State（login: LoginFeature.State, path: StackState<Path.State>）
- [ ] 定義 Path reducer enum（posts, postDetail）
- [ ] 定義 Action（login: LoginFeature.Action, path: StackActionOf<Path>）
- [ ] 在 login(.loginResponse(.success)) 時 push .posts
- [ ] 在 posts(.postTapped) 時 push .postDetail
- [ ] 使用 Scope + forEach 整合子 Feature
- [ ] 撰寫 TestStore 測試

**Acceptance Criteria**:
- 登入成功自動 push 到 posts
- 點擊文章自動 push 到 postDetail
- Navigation pop 時正確移除 path element

---

### TASK-022: 實作 AppCoordinator
**Story**: US-003, US-06, US-10
**File**: `Monster5/App/AppCoordinator.swift`
**LOC**: ~120

- [ ] 持有 StoreOf<AppFeature>
- [ ] 管理 UINavigationController
- [ ] 在 observe { } 中監聽 path 變化
- [ ] path 新增 .posts → push PostsViewController
- [ ] path 新增 .postDetail → push PostDetailViewController
- [ ] 處理 NavigationController 的 back button pop（同步回 TCA State）

**Acceptance Criteria**:
- TCA State 驅動所有導航
- UIKit back button pop 時 TCA path 同步更新
- 不會出現 State 與 UI 不一致的情況

---

### TASK-023: 實作 SceneDelegate 入口
**Story**: 全部
**File**: `Monster5/App/SceneDelegate.swift`
**LOC**: ~30

- [ ] 建立 AppFeature Store
- [ ] 建立 AppCoordinator
- [ ] 設定 window.rootViewController 為 UINavigationController
- [ ] 顯示 LoginViewController 作為初始畫面

---

### TASK-024: AppFeature 整合測試
**Story**: 全部
**File**: `Monster5Tests/AppFeatureTests.swift`
**LOC**: ~80

- [ ] 測試完整登入 → push posts → push detail 流程
- [ ] 測試 detail 按讚後 pop 回 posts 狀態同步
- [ ] 測試 navigation path 正確性

---

## Phase 7: State Sync & Persistence (P1-P2)

### TASK-025: 實作 Detail → List 狀態同步
**Story**: US-007
**File**: `Monster5/Features/Posts/PostsFeature.swift` (修改)
**LOC**: ~30

- [ ] 確保 PostDetailFeature.State 在 IdentifiedArray 中是引用同一份
- [ ] push detail 時傳入 IdentifiedArray 中的 State
- [ ] pop 回列表時驗證 State 已同步
- [ ] 撰寫狀態同步測試

**Acceptance Criteria**:
- Detail 中按讚 → List 中對應 Cell 立即反映

---

### TASK-026: 實作 App 啟動載入互動數據
**Story**: US-009
**File**: `Monster5/Features/Posts/PostsFeature.swift` (修改)
**LOC**: ~20

- [ ] 在 onAppear 時同時載入 API posts 和 Local Storage interactions
- [ ] 合併兩份資料建立 PostDetailFeature.State 列表

---

### TASK-027: 實作互動操作即時儲存
**Story**: US-009
**File**: `Monster5/Features/PostDetail/PostDetailFeature.swift` (修改)
**LOC**: ~20

- [ ] 每次 toggleLike / addComment / shareTapped 後觸發 saveInteraction
- [ ] saveInteraction Effect 呼叫 StorageClient.saveInteractions

---

### TASK-028: 持久化整合測試
**Story**: US-009
**File**: `Monster5Tests/StorageTests.swift`
**LOC**: ~50

- [ ] 測試儲存後讀取資料一致
- [ ] 測試空資料讀取回傳空 dictionary
- [ ] 測試損毀資料讀取回傳空 dictionary（fallback）

---

## Phase 8: Comments & Polish (P2)

### TASK-029: 實作留言功能 UI
**Story**: US-008
**File**: `Monster5/Features/PostDetail/PostDetailViewController.swift` (修改)
**LOC**: ~60

- [ ] 建立留言輸入區（UITextField + 送出按鈕）
- [ ] 建立留言列表（UIStackView 或內嵌 UITableView）
- [ ] 綁定 commentTextChanged 和 addComment action

---

### TASK-030: 留言數同步回列表頁
**Story**: US-008
**File**: `Monster5/Features/Posts/PostsFeature.swift` (修改)
**LOC**: ~10

- [ ] 確保 comments 數量變更反映在 PostTableViewCell

---

### TASK-031: UI 細節調整
**Story**: 全部
**File**: 多個 ViewController
**LOC**: ~60

- [ ] 登入頁面樣式調整（間距、字型、顏色）
- [ ] 列表頁面 Cell 高度與間距
- [ ] Detail 頁面排版優化
- [ ] 按讚按鈕動畫效果（scale animation）
- [ ] Loading 狀態空白頁處理

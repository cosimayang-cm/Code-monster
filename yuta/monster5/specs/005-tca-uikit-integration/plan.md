# Implementation Plan: TCA + UIKit 整合實戰

**Branch**: `yuta-005-tca-uikit-integration` | **Date**: 2026-02-13 | **Spec**: `CodeMonsters/monster5.md`
**Input**: Feature specification from `CodeMonsters/monster5.md` + `yuta/monster5/PLAN.md`

## Summary

實作一個完整的 TCA + UIKit 整合專案，包含 Login 頁面（真實 API 登入）和 Posts 列表/詳情頁面（本地互動 + 狀態同步）。使用 The Composable Architecture (TCA) 1.7+ 管理狀態、副作用與導航，UIKit 負責 UI 層。專案涵蓋：Dependency Client 設計、Stack-based Navigation、Delegate Action 狀態同步、`observe {}` UIKit 整合模式、UserDefaults 持久化。

## Technical Context

**Language/Version**: Swift 5.9+
**Primary Dependencies**: The Composable Architecture (TCA) 1.7+, UIKit, Combine, Foundation
**Storage**: UserDefaults（`[Int: PostInteraction]` 序列化）
**Testing**: XCTest + TCA `TestStore`
**Target Platform**: iOS 15.0+
**Project Type**: Mobile (single Xcode project)
**Performance Goals**: 流暢載入 100 篇文章列表、即時 UI 更新
**Constraints**: 無網路時保留本地互動數據、Error Toast 3 秒自動消失
**Scale/Scope**: 2 個主要頁面 (Login, Home/PostDetail)、4 個 Feature Reducers、3 個 Dependency Clients

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

> **注意**: 此專案為 CodeMonster 學習作業，使用 TCA 架構（非 PAGEs Framework）。以下 Constitution 原則適用於此專案的檢查：

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Architecture Rules | ADAPTED | 使用 TCA Reducer 架構而非 PAGEs。層級：AppFeature → HomeFeature/LoginFeature → PostDetailFeature |
| II. Dependency Injection | PASS | 使用 TCA `@Dependency` 系統注入 AuthClient, PostsClient, StorageClient |
| III. Naming Conventions | PASS | Feature/State/Action/Delegate 遵循 TCA 命名慣例 |
| IV. Data Flow | PASS | 單向資料流：Action → Reducer → State → observe → UIKit |
| V. Testing Standards | PASS | 使用 TCA TestStore，測試命名遵循 camelCase 規範 |
| VI. Code Quality | PASS | Swift 5.9+ 標準，無 print/NSLog |
| VII. Compliance Verification | N/A | 非 PAGEs 專案，無 XcodeGen/StateManager 需求 |
| VIII. Documentation | PASS | PLAN.md 詳細記錄所有架構決策 |

**Gate Result**: PASS - 所有適用原則已通過或已合理調適。

## Project Intelligence

> 此專案為獨立 CodeMonster 學習作業，不依賴 CMProductionLego 的現有元件。

### Existing Features Summary

**CodeMonster 系列作業**: 此為第 5 個練習，前 4 個練習已涵蓋 popup response chain、undo-redo system 等主題。本專案完全獨立，無需整合既有元件。

### Architecture Patterns Observed

**TCA 架構模式**:
- Feature Reducer: 每個畫面對應一個 `@Reducer` struct，包含 State/Action/body
- Dependency Client: 使用 `@DependencyClient` + `DependencyKey` 註冊依賴
- Navigation: Stack-based (`StackState`/`StackAction`) 用於 Home→Detail push
- State Sync: Delegate Action 模式處理子→父狀態回傳
- UIKit Integration: `observe {}` closure 觀察 Store 狀態變化

### Integration Recommendations

**For TCA + UIKit Integration**:

**獨立實作（無需複用）**:
- 全部元件為新建，專注於 TCA 學習目標
- Xcode SPM 引入 TCA 依賴
- 不使用 CocoaPods/XcodeGen

**參考模式**:
- TCA 官方 UIKit case studies
- `observe {}` 取代傳統 Combine subscribe

## Architecture Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Project Format** | Xcode project (.xcodeproj) | 可直接在 Xcode 開啟、跑模擬器 |
| **TCA Integration** | Xcode SPM dependency | 透過 Swift Package Manager 加入 TCA |
| **Navigation (Home→Detail)** | Stack-based (`StackState`) | 直接對應 UINavigationController |
| **Navigation (Login→Home)** | Root replacement | AppCoordinator 切換 root VC |
| **Navigation Management** | AppCoordinator | 集中管理所有導航邏輯 |
| **State Sync** | Delegate Action | PostDetail 發 `.delegate(.interactionUpdated(...))` → HomeFeature 更新 |
| **Login→App Communication** | Delegate Action | LoginFeature 發 `.delegate(.loginSucceeded(User))` → AppFeature 攔截 |
| **Persistence** | UserDefaults + JSONEncoder | `[Int: PostInteraction]` 序列化到單一 key |
| **Error Auto-dismiss** | `continuousClock` + `cancellable` Effect | 可用 TestClock 測試；CancelID: `errorAutoDismiss` |
| **UIKit Observation** | `observe { }` per ViewController | TCA 1.7+ 原生 UIKit 整合模式 |
| **isAuthenticated** | Computed property (`home != nil`) | 避免冗餘狀態 |
| **UI 職責分工** | 結構性導航 → Coordinator；局部 UI → VC | 導航（push/pop/root switch）由 Coordinator 統一管理；短暫 UI（UIActivityViewController 等）由 VC 直接處理，避免不必要的繞路 |

## Project Structure

### Documentation (this feature)

```text
yuta/monster5/specs/005-tca-uikit-integration/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   ├── auth-api.md
│   └── posts-api.md
└── tasks.md             # Phase 2 output (by /speckit.tasks)
```

### Source Code

```text
yuta/monster5/
├── PLAN.md
├── Monster5.xcodeproj/
├── Monster5/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── Info.plist
│   ├── Models/
│   │   ├── User.swift
│   │   ├── Post.swift
│   │   ├── Comment.swift
│   │   └── PostInteraction.swift
│   ├── Dependencies/
│   │   ├── AuthClient.swift
│   │   ├── PostsClient.swift
│   │   └── StorageClient.swift
│   ├── Features/
│   │   ├── Login/
│   │   │   ├── LoginFeature.swift
│   │   │   └── LoginViewController.swift
│   │   └── Home/
│   │       ├── HomeFeature.swift
│   │       ├── HomeViewController.swift
│   │       ├── HomeTableViewCell.swift
│   │       ├── PostDetailFeature.swift
│   │       ├── PostDetailViewController.swift
│   │       └── CommentCell.swift
│   └── App/
│       ├── AppFeature.swift
│       └── AppCoordinator.swift
└── Monster5Tests/
    ├── LoginFeatureTests.swift
    ├── PostDetailFeatureTests.swift
    ├── HomeFeatureTests.swift
    └── AppFeatureTests.swift
```

**Structure Decision**: Mobile single-project structure。所有程式碼在 `Monster5/` 下依功能分資料夾，測試在 `Monster5Tests/`。

## Implementation Phases

### Phase 0: Xcode 專案骨架

**目標**: 建立可編譯的空專案

- `Monster5.xcodeproj`: iOS 15.0, Swift 5.9, App target + Test target
- SPM dependency: `swift-composable-architecture` 1.7+
- `Info.plist`: UIApplicationSceneManifest 設定
- `AppDelegate.swift`: `@main` 標準 UIKit AppDelegate
- `SceneDelegate.swift`: 建立 UIWindow → `Store<AppFeature>()` → `AppCoordinator(store:, window:)` → `start()`

**驗收**: Xcode Build (Cmd+B) 通過

### Phase 1: Models（無依賴）

**目標**: 定義所有資料模型

- `User.swift`: `Equatable, Codable, Sendable` — id, username, email, firstName, lastName, gender, image, accessToken, refreshToken
- `Post.swift`: `Equatable, Codable, Sendable, Identifiable` — userId, id, title, body
- `Comment.swift`: `Equatable, Codable, Sendable, Identifiable` — id (UUID), text (String), createdAt (Date)
- `PostInteraction.swift`: `Equatable, Codable, Sendable` — isLiked, likeCount, comments, shareCount；`commentCount` 為 computed property

**驗收**: Models 編譯通過，無外部依賴

### Phase 2: Dependencies（依賴 Models）

**目標**: 實作 TCA Dependency Clients

- **AuthClient**: `@DependencyClient`, `login(_ username: String, _ password: String) async throws -> User`
  - liveValue: POST `https://dummyjson.com/auth/login`，body 含 `expiresInMins: 30`
  - `AuthError` enum，解析 `{"message": "..."}` 錯誤格式
- **PostsClient**: `@DependencyClient`, `fetchPosts() async throws -> [Post]`
  - liveValue: GET `https://jsonplaceholder.typicode.com/posts`
- **StorageClient**: `@DependencyClient`, `loadInteractions() -> [Int: PostInteraction]`, `saveInteractions([Int: PostInteraction])`
  - liveValue: UserDefaults + JSONEncoder/Decoder

**驗收**: Dependency 註冊正確，可在 Reducer 中 `@Dependency` 注入

### Phase 3: Feature Reducers

**目標**: 實作所有 TCA Reducers

#### LoginFeature

- **State**: username, password, isLoading, errorMessage?, user?
  - `isFormValid`: computed (`!username.isEmpty && !password.isEmpty`)
- **Action**: usernameChanged, passwordChanged, loginButtonTapped, loginResponse(Result), dismissError, errorAutoDismissTimerFired, delegate(Delegate)
- **Delegate**: `.loginSucceeded(User)`
- **Dependencies**: `authClient`, `continuousClock`
- **CancelID**: `enum CancelID { case errorAutoDismiss }`
- **Logic**:
  - loginButtonTapped: `!isFormValid` → error; else isLoading=true → authClient.login
  - loginResponse(.success) → delegate(.loginSucceeded)
  - loginResponse(.failure) → errorMessage + 3s cancellable auto-dismiss
  - dismissError → nil + cancel timer

#### PostDetailFeature

- **State**: post (Post), interaction (PostInteraction), commentText (""), shouldFocusComment (false)
- **Action**: toggleLike, commentTextChanged, submitComment, shareTapped, delegate(Delegate)
- **Delegate**: `.interactionUpdated(postId:, interaction:)`, `.shareRequested(title:, body:)`
- **Logic**:
  - toggleLike: isLiked toggle + likeCount ±1 → delegate
  - submitComment: 建立 Comment → insert comments[0] → delegate; 清空 commentText
  - shareTapped: shareCount +1 → delegate + .shareRequested

#### HomeFeature

- **State**: posts (IdentifiedArray), interactions ([Int: PostInteraction]), isLoading, errorMessage?, path (StackState), hasLoadedPosts (false)
- **Action**: onAppear, postsResponse(Result), postTapped(Post), commentTapped(Post), path(StackActionOf)
- **Path**: `.postDetail(PostDetailFeature)`
- **Dependencies**: `postsClient`, `storageClient`
- **Logic**:
  - onAppear: 若 hasLoadedPosts → .none; 否則 loadInteractions + fetchPosts
  - postTapped: push PostDetail (shouldFocusComment: false)
  - commentTapped: push PostDetail (shouldFocusComment: true)
  - 攔截 delegate `.interactionUpdated` → 更新 interactions + save

### Phase 4: App Reducer

**目標**: 組合所有 Feature Reducers

- **State**: login (LoginFeature.State), home (HomeFeature.State)?
- **Action**: login(LoginFeature.Action), home(HomeFeature.Action)
- `isAuthenticated`: computed (`home != nil`)
- **Logic**: `.login(.delegate(.loginSucceeded))` → `home = HomeFeature.State()`
- 使用 `Scope` + `ifLet` 組合

### Phase 5: UIKit Views

**目標**: 實作所有 UIKit ViewControllers

- **LoginViewController**: 帳號/密碼 TextFields + 登入 Button + ActivityIndicator + Error Toast
- **HomeViewController**: UITableView + dataSource/delegate, `observe {}` reloadData
- **HomeTableViewCell**: `configure(with:interaction:)` 顯示 title/body/counts
- **PostDetailViewController**: TableView (header + comments) + 底部 input bar + keyboard handling
  - shareTapped 後由 VC 直接 `present UIActivityViewController`（局部 UI，不經 Coordinator）
- **CommentCell**: 顯示留言文字 + 時間

**所有 VC 使用 `observe {}` 觀察 Store 狀態變化**
**UI 職責分工**: Feature Reducer 不 import UIKit；結構性導航由 Coordinator 處理；局部 UI（share sheet 等）由 VC 直接處理

### Phase 6: AppCoordinator

**目標**: 管理結構性導航（push/pop/root switch）

- 持有 `StoreOf<AppFeature>`, `UIWindow`, `UINavigationController?`
- Store scoping: Login/Home/PostDetail 各自 scope
- `start()`: LoginVC as root
- Combine 觀察 `isAuthenticated`: true → 動畫切換 root 到 NavController(HomeVC)
- Combine 觀察 `home.path`: 增加 → push; 減少 → pop
- **不處理局部 UI**（UIActivityViewController 等由 VC 自行 present）

### Phase 7: Tests

**目標**: 完整測試覆蓋所有 Feature Reducers

- **LoginFeatureTests**: 帳密 binding、空欄位驗證、登入成功/失敗、auto-dismiss (TestClock)、手動 dismiss
- **PostDetailFeatureTests**: toggleLike ±1、submitComment、shareTapped + delegate
- **HomeFeatureTests**: onAppear fetch、重複 onAppear 不 refetch、postTapped/commentTapped push、delegate 更新
- **AppFeatureTests**: login delegate → home 初始化

## State Sync Flow

```text
PostDetailVC → store.send(.toggleLike)
  → PostDetailFeature: 更新 interaction → .delegate(.interactionUpdated(postId, interaction))
  → HomeFeature 攔截: .path(.element(id:, action: .postDetail(.delegate(...))))
  → 更新 state.interactions[postId] + Effect { storageClient.saveInteractions }
  → HomeVC observe {} → tableView.reloadData() → Cell 顯示最新狀態
```

## App Launch Flow

```text
@main AppDelegate
  → SceneDelegate.scene(_:willConnectTo:)
  → Store<AppFeature>()
  → AppCoordinator(store:, window:)
  → coordinator.start()
  → LoginVC as root
  → 登入成功 → coordinator 觀察 isAuthenticated → 切換 root 到 NavController(HomeVC)
```

## Verification

1. **Xcode Build** (Cmd+B) 通過
2. **Run on Simulator** (Cmd+R) 完整流程可操作
3. **Tests** (Cmd+U) 全部通過
4. **Manual Verification**:
   - Login 成功（emilys / emilyspass）→ 轉場到 Home
   - Login 失敗 → Toast 3 秒消失
   - 空欄位登入 → 顯示「請輸入帳號密碼」
   - Home 載入 100 篇文章
   - 點擊 Cell → push PostDetail
   - PostDetail 按讚 → 返回列表同步更新
   - PostDetail 留言 → commentCount +1, 返回列表同步
   - PostDetail 分享 → UIActivityViewController, shareCount +1
   - 關閉 App 重開 → 互動數據保留

## Complexity Tracking

> No violations detected. All architectural decisions follow TCA best practices.

| Decision | Justification |
|----------|---------------|
| AppCoordinator 分離 | UIKit 導航邏輯不應在 Reducer 中，Coordinator 集中管理符合 SoC 原則 |
| Delegate Action 模式 | TCA 官方推薦的子→父通訊模式，避免 shared state 問題 |
| StackState navigation | Home→Detail 為典型 push/pop，Stack-based 比 Tree-based 更適合 |

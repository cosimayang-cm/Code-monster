# Tasks: TCA + UIKit Login & Posts App

**Input**: Design documents from `/specs/005-tca-uikit-integration/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Tests**: Included — plan.md specifies TCA TestStore tests for all features.

**Organization**: Tasks grouped by user story. Each story independently testable after its phase completes.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US5)
- All paths relative to repo root: `sonia/CodeMonster/CodeMonster/`

## Component Reuse Analysis

| Component | Tag | Source | Notes |
|-----------|-----|--------|-------|
| UserDefaults persistence pattern | [REUSE] | PopupChain/Repositories/UserDefaultsPopupStateRepository.swift | Adapt pattern for StorageClient |
| Logger protocol | [REUSE] | CarSystem/Protocols/Logger.swift | Optional reference for debug logging |
| UIViewController setup pattern | [REUSE] | PopupChain/UI/ | Adapt observe {} pattern for all VCs |
| XCTest structure | [REUSE] | CodeMonsterTests/PopupChainTests/ | Reference for test file organization |
| All TCA Features | [NEW] | — | LoginFeature, PostsListFeature, PostDetailFeature, AppFeature |
| All Dependencies | [NEW] | — | AuthClient, PostsClient, StorageClient |
| All UIViewControllers | [NEW] | — | LoginVC, PostsListVC, PostDetailVC, AppCoordinator |
| All Models | [NEW] | — | User, LoginResponse, Post, PostInteraction, PostWithInteraction |

**Task Count Optimization**: 4 components reused as pattern references, reducing learning curve. All implementation is [NEW] since TCA is a new architecture for this project. No duplicate creation tasks.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization, TCA dependency, directory structure

- [x] T001 Create Monster5 directory structure under sonia/CodeMonster/CodeMonster/Monster5/ with subdirectories: App/, Features/Login/, Features/PostsList/, Features/PostDetail/, Dependencies/, Models/, UI/
- [x] T002 Create Monster5Tests directory at sonia/CodeMonster/CodeMonsterTests/Monster5Tests/
- [x] T003 Add TCA Swift Package dependency (https://github.com/pointfreeco/swift-composable-architecture, version 1.7.0+) to CodeMonster.xcodeproj and set iOS deployment target to 16.0

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: All shared models and dependencies that multiple user stories require

**CRITICAL**: No user story work can begin until this phase is complete

### Models

- [x] T004 [P] [NEW] Create LoginResponse model (id, username, email, firstName, lastName, gender, image, accessToken, refreshToken) conforming to Codable, Equatable in sonia/CodeMonster/CodeMonster/Monster5/Models/User.swift
- [x] T005 [P] [NEW] Create Post model (userId, id, title, body) conforming to Codable, Equatable, Identifiable in sonia/CodeMonster/CodeMonster/Monster5/Models/Post.swift
- [x] T006 [P] [NEW] Create PostInteraction model (postId, isLiked, likeCount, commentCount, shareCount) conforming to Codable, Equatable in sonia/CodeMonster/CodeMonster/Monster5/Models/PostInteraction.swift
- [x] T007 [NEW] Create PostWithInteraction composite struct (post: Post, interaction: PostInteraction) conforming to Equatable, Identifiable (id delegates to post.id) in sonia/CodeMonster/CodeMonster/Monster5/Models/PostInteraction.swift

### Dependencies

- [x] T008 [P] [NEW] Implement AuthClient @DependencyClient with login(username:password:) async throws -> LoginResponse, including liveValue (POST https://dummyjson.com/auth/login) and testValue in sonia/CodeMonster/CodeMonster/Monster5/Dependencies/AuthClient.swift
- [x] T009 [P] [NEW] Implement PostsClient @DependencyClient with fetchPosts() async throws -> [Post], including liveValue (GET https://jsonplaceholder.typicode.com/posts) and testValue in sonia/CodeMonster/CodeMonster/Monster5/Dependencies/PostsClient.swift
- [x] T010 [P] [NEW] [REUSE] Implement StorageClient @DependencyClient with saveInteraction(_:), loadInteraction(postId:), loadAllInteractions() methods using UserDefaults JSON encoding (adapt pattern from PopupChain UserDefaultsPopupStateRepository), including liveValue and testValue in sonia/CodeMonster/CodeMonster/Monster5/Dependencies/StorageClient.swift

### Shared UI

- [x] T011 [P] [NEW] Create ErrorToastView (UIView overlay, displays error message, auto-layout at top of screen) in sonia/CodeMonster/CodeMonster/Monster5/UI/ErrorToastView.swift

**Checkpoint**: Foundation ready — all models, dependencies, and shared UI available for user stories

---

## Phase 3: User Story 1 — User Login (Priority: P1) MVP

**Goal**: User can enter credentials, see loading state, and either navigate to posts list on success or see error toast (3s auto-dismiss) on failure. Login button disabled when fields empty or loading.

**Independent Test**: Enter valid/invalid credentials on login screen, verify loading indicator, navigation, and error toast behavior.

### Tests for User Story 1

- [x] T012 [P] [US1] Write test: testLoginWhenFieldsEmptyThenButtonDisabled — verify login button disabled when username or password is empty in sonia/CodeMonster/CodeMonsterTests/Monster5Tests/LoginFeatureTests.swift
- [x] T013 [P] [US1] Write test: testLoginWhenValidCredentialsThenNavigatesToPostsList — verify successful login sets isLoading, receives success response, and signals navigation in sonia/CodeMonster/CodeMonsterTests/Monster5Tests/LoginFeatureTests.swift
- [x] T014 [P] [US1] Write test: testLoginWhenInvalidCredentialsThenShowsErrorAndAutoDismisses — verify failed login sets errorMessage and dismissError fires after 3s (use TestClock) in sonia/CodeMonster/CodeMonsterTests/Monster5Tests/LoginFeatureTests.swift
- [x] T015 [P] [US1] Write test: testLoginWhenLoadingThenButtonDisabled — verify isLoading disables login button in sonia/CodeMonster/CodeMonsterTests/Monster5Tests/LoginFeatureTests.swift

### Implementation for User Story 1

- [x] T016 [US1] [NEW] Implement LoginFeature @Reducer with @ObservableState State (username, password, isLoading, errorMessage, loginResponse), Actions (usernameChanged, passwordChanged, loginTapped, loginResponse, dismissError), @Dependency(\.authClient), and Effect.run for login API call + ContinuousClock for 3s error dismiss in sonia/CodeMonster/CodeMonster/Monster5/Features/Login/LoginFeature.swift
- [x] T017 [US1] [NEW] [REUSE] Implement LoginViewController with StoreOf<LoginFeature>, setupUI (UITextField x2, UIButton, UIActivityIndicatorView), observe {} closure binding state to UI (button enabled/disabled, loading indicator, error toast show/hide), and store.send() for user actions (adapt UIViewController setup pattern from existing exercises) in sonia/CodeMonster/CodeMonster/Monster5/Features/Login/LoginViewController.swift
- [x] T018 [US1] [NEW] Implement basic AppFeature @Reducer with @ObservableState State (login: LoginFeature.State, path: StackState<Path.State>), Path enum (postsList, postDetail), and Reduce handling login success → path.append(.postsList) in sonia/CodeMonster/CodeMonster/Monster5/App/AppFeature.swift
- [x] T019 [US1] [NEW] Implement AppCoordinator (UINavigationController subclass) with StoreOf<AppFeature>, initial LoginViewController as root, observe {} for path changes syncing UINavigationController stack in sonia/CodeMonster/CodeMonster/Monster5/App/AppCoordinator.swift

**Checkpoint**: Login screen fully functional — can authenticate and navigate to posts list (empty). Error toast works with 3s auto-dismiss.

---

## Phase 4: User Story 2 — Browse Posts List (Priority: P2)

**Goal**: After login, display scrollable UITableView with 100 posts. Each cell shows title, 2-line body preview, like count, comment count, share button. Loading indicator while fetching. Full-screen error with Retry on failure.

**Independent Test**: Navigate to posts screen, verify all 100 posts load, cells display correct info, loading and error+retry states work.

### Tests for User Story 2

- [x] T020 [P] [US2] Write test: testPostsListWhenOnAppearThenFetchesPosts — verify onAppear sets isLoading and receives posts response in sonia/CodeMonster/CodeMonsterTests/Monster5Tests/PostsListFeatureTests.swift
- [x] T021 [P] [US2] Write test: testPostsListWhenFetchFailsThenShowsError — verify error state with errorMessage set on failure in sonia/CodeMonster/CodeMonsterTests/Monster5Tests/PostsListFeatureTests.swift
- [x] T022 [P] [US2] Write test: testPostsListWhenRetryTappedThenRefetches — verify retry action clears error, sets isLoading, and re-triggers fetch in sonia/CodeMonster/CodeMonsterTests/Monster5Tests/PostsListFeatureTests.swift

### Implementation for User Story 2

- [x] T023 [US2] [NEW] Implement PostsListFeature @Reducer with @ObservableState State (posts: IdentifiedArrayOf<PostWithInteraction>, isLoading, errorMessage), Actions (onAppear, postsResponse, retryTapped, postTapped), @Dependency(\.postsClient) and @Dependency(\.storageClient), Effect.run for fetch + merge with stored interactions in sonia/CodeMonster/CodeMonster/Monster5/Features/PostsList/PostsListFeature.swift
- [x] T024 [US2] [NEW] Implement PostCell (UITableViewCell subclass) with titleLabel, bodyPreviewLabel (numberOfLines=2), likeCountLabel, commentCountLabel, shareButton, and configure(with:) method accepting PostWithInteraction in sonia/CodeMonster/CodeMonster/Monster5/Features/PostsList/PostCell.swift
- [x] T025 [US2] [NEW] Implement PostsListViewController with StoreOf<PostsListFeature>, UITableView (dataSource + delegate), UIActivityIndicatorView, error state view with Retry button, observe {} for state binding, and store.send(.onAppear) in viewDidLoad in sonia/CodeMonster/CodeMonster/Monster5/Features/PostsList/PostsListViewController.swift
- [x] T026 [US2] Update AppFeature to create PostsListViewController when path contains .postsList, scope store for postsList destination in sonia/CodeMonster/CodeMonster/Monster5/App/AppFeature.swift
- [x] T027 [US2] Update AppCoordinator observe {} to push PostsListViewController when postsList is appended to path in sonia/CodeMonster/CodeMonster/Monster5/App/AppCoordinator.swift

**Checkpoint**: Full login → posts list flow works. 100 posts display with title, 2-line preview, interaction counts. Loading and error+retry states functional.

---

## Phase 5: User Story 3 + 4 — Post Detail, Interactions & State Sync (Priority: P3)

**Goal**: Tap post → push detail screen showing full content. Like toggle, comment increment, share action. On return to list, interaction state is synchronized instantly (zero-delay). Covers both US3 (interactions) and US4 (sync) as they are inherently coupled.

**Independent Test**: Navigate to detail, like a post, go back, verify list cell shows updated like count. Unlike, go back, verify list reflects removal.

### Tests for User Story 3 + 4

- [x] T028 [P] [US3] Write test: testPostDetailWhenLikeTappedThenTogglesLikeState — verify like toggles isLiked and increments/decrements likeCount in sonia/CodeMonster/CodeMonsterTests/Monster5Tests/PostDetailFeatureTests.swift
- [x] T029 [P] [US3] Write test: testPostDetailWhenCommentTappedThenIncrementsCount — verify comment action increments commentCount in sonia/CodeMonster/CodeMonsterTests/Monster5Tests/PostDetailFeatureTests.swift
- [x] T030 [P] [US3] Write test: testPostDetailWhenShareTappedThenIncrementsCount — verify share action increments shareCount in sonia/CodeMonster/CodeMonsterTests/Monster5Tests/PostDetailFeatureTests.swift
- [x] T031 [P] [US4] Write test: testPostsListWhenDetailInteractionChangedThenListSyncs — verify parent PostsListFeature updates its IdentifiedArray when child detail interaction changes in sonia/CodeMonster/CodeMonsterTests/Monster5Tests/AppFeatureTests.swift

### Implementation for User Story 3 + 4

- [x] T032 [US3] [NEW] Implement PostDetailFeature @Reducer with @ObservableState State (post: Post, interaction: PostInteraction), Actions (likeTapped, commentTapped, shareTapped), Reduce toggling isLiked/likeCount, incrementing commentCount, incrementing shareCount in sonia/CodeMonster/CodeMonster/Monster5/Features/PostDetail/PostDetailFeature.swift
- [x] T033 [US3] [NEW] Implement PostDetailViewController with StoreOf<PostDetailFeature>, full title + body labels, like button (with liked/unliked visual state), comment button, share button, like/comment/share count labels, observe {} for state binding in sonia/CodeMonster/CodeMonster/Monster5/Features/PostDetail/PostDetailViewController.swift
- [x] T034 [US4] Update PostsListFeature to add postTapped action that stores selectedPostId, and add delegate action handling from PostDetailFeature to sync interaction state back into IdentifiedArrayOf<PostWithInteraction> in sonia/CodeMonster/CodeMonster/Monster5/Features/PostsList/PostsListFeature.swift
- [x] T035 [US4] Update AppFeature Path to include .postDetail(PostDetailFeature.State), handle postsList postTapped → path.append(.postDetail), and intercept postDetail interaction actions to sync back to postsList state in sonia/CodeMonster/CodeMonster/Monster5/App/AppFeature.swift
- [x] T036 [US4] Update AppCoordinator observe {} to push PostDetailViewController when postDetail is appended to path, scoping store for postDetail destination in sonia/CodeMonster/CodeMonster/Monster5/App/AppCoordinator.swift

**Checkpoint**: Full login → list → detail flow with like/comment/share. State syncs back to list on return. All interaction counts consistent across screens.

---

## Phase 6: User Story 5 — Interaction Data Persistence (Priority: P4)

**Goal**: All interaction data persists to UserDefaults. On app restart + login, previous likes/comments/shares are restored and displayed correctly.

**Independent Test**: Like several posts, terminate app, relaunch, login, verify all interaction data intact.

### Tests for User Story 5

- [x] T037 [P] [US5] Write test: testStorageClientWhenSaveAndLoadThenDataPersists — verify StorageClient round-trip (save interaction, load by postId, verify equality) in sonia/CodeMonster/CodeMonsterTests/Monster5Tests/StorageClientTests.swift
- [x] T038 [P] [US5] Write test: testStorageClientWhenLoadAllThenReturnsAllInteractions — verify loadAllInteractions returns complete dictionary in sonia/CodeMonster/CodeMonsterTests/Monster5Tests/StorageClientTests.swift
- [x] T039 [P] [US5] Write test: testPostsListWhenOnAppearThenLoadsStoredInteractions — verify PostsListFeature merges stored interactions with fetched posts on appear in sonia/CodeMonster/CodeMonsterTests/Monster5Tests/PostsListFeatureTests.swift

### Implementation for User Story 5

- [x] T040 [US5] Update PostsListFeature onAppear effect to call storageClient.loadAllInteractions() and merge stored interactions into IdentifiedArrayOf<PostWithInteraction> after fetching posts in sonia/CodeMonster/CodeMonster/Monster5/Features/PostsList/PostsListFeature.swift
- [x] T041 [US5] Update PostDetailFeature to call storageClient.saveInteraction() via Effect after each interaction (like/comment/share) to persist changes immediately in sonia/CodeMonster/CodeMonster/Monster5/Features/PostDetail/PostDetailFeature.swift
- [x] T042 [US5] Add @Dependency(\.storageClient) to PostDetailFeature and wire save effects for likeTapped, commentTapped, shareTapped actions in sonia/CodeMonster/CodeMonster/Monster5/Features/PostDetail/PostDetailFeature.swift

**Checkpoint**: All interaction data persists. Full cycle: login → interact → close app → reopen → login → data intact.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Entry point wiring, edge cases, final validation

- [x] T043 Wire up Monster5 entry point — add a button/menu item in existing sonia/CodeMonster/CodeMonster/ViewController.swift to launch AppCoordinator with Store(initialState: AppFeature.State()) { AppFeature() }
- [x] T044 Handle edge case: empty posts list — show "No posts available" message when API returns empty array in PostsListViewController
- [x] T045 Handle edge case: rapid like taps — ensure PostDetailFeature reducer handles rapid toggles correctly (each tap flips state, no debounce needed since it's synchronous)
- [x] T046 [P] Run all TestStore tests and verify they pass on iPhone 16 Pro simulator
- [x] T047 End-to-end manual validation: login (emilys/emilyspass) → browse 100 posts → tap post → like/comment/share → back → verify sync → close app → reopen → verify persistence

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 (T003 SPM dependency must resolve)
- **US1 Login (Phase 3)**: Depends on Phase 2 (needs models + AuthClient)
- **US2 Posts List (Phase 4)**: Depends on Phase 2 + Phase 3 (needs login to navigate to list)
- **US3+4 Detail & Sync (Phase 5)**: Depends on Phase 4 (needs list to navigate to detail)
- **US5 Persistence (Phase 6)**: Depends on Phase 5 (needs features to integrate storage)
- **Polish (Phase 7)**: Depends on all previous phases

### User Story Dependencies

```
Phase 1 (Setup)
  └── Phase 2 (Foundational)
       └── Phase 3: US1 Login (P1) ← MVP
            └── Phase 4: US2 Posts List (P2)
                 └── Phase 5: US3+4 Detail & Sync (P3)
                      └── Phase 6: US5 Persistence (P4)
                           └── Phase 7: Polish
```

Note: Stories are sequential because each screen depends on the previous screen's navigation. US2 needs Login to navigate to it, US3 needs PostsList to navigate to detail, US5 needs features to integrate persistence.

### Within Each User Story

- Tests written FIRST → verify they fail
- Models/Dependencies before Features
- Features (Reducer) before ViewControllers
- Feature tests before integration

### Parallel Opportunities

**Phase 2 (Foundational)**: T004, T005, T006 (models) can run in parallel. T008, T009, T010 (dependencies) can run in parallel. T011 (UI) can run in parallel with all of them.

**Phase 3 (US1)**: T012-T015 (tests) can all run in parallel.

**Phase 4 (US2)**: T020-T022 (tests) can all run in parallel.

**Phase 5 (US3+4)**: T028-T031 (tests) can all run in parallel.

**Phase 6 (US5)**: T037-T039 (tests) can all run in parallel.

---

## Parallel Example: Phase 2 (Foundational)

```
# Launch all models in parallel:
Task T004: "Create LoginResponse model in Monster5/Models/User.swift"
Task T005: "Create Post model in Monster5/Models/Post.swift"
Task T006: "Create PostInteraction model in Monster5/Models/PostInteraction.swift"

# Then all dependencies in parallel:
Task T008: "Implement AuthClient in Monster5/Dependencies/AuthClient.swift"
Task T009: "Implement PostsClient in Monster5/Dependencies/PostsClient.swift"
Task T010: "Implement StorageClient in Monster5/Dependencies/StorageClient.swift"
Task T011: "Create ErrorToastView in Monster5/UI/ErrorToastView.swift"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T003)
2. Complete Phase 2: Foundational (T004-T011)
3. Complete Phase 3: US1 Login (T012-T019)
4. **STOP and VALIDATE**: Login screen works, navigates to empty posts screen on success, shows error toast on failure
5. Demo-ready MVP

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. US1 Login → **MVP demo** (login works)
3. US2 Posts List → **Demo** (login + 100 posts display)
4. US3+4 Detail & Sync → **Demo** (full navigation + interactions + sync)
5. US5 Persistence → **Demo** (interactions persist across sessions)
6. Polish → **Final delivery**

---

## Notes

- [P] tasks = different files, no dependencies within the same phase
- [US*] labels map to user stories from spec.md (US1=Login, US2=PostsList, US3=Detail, US4=Sync, US5=Persistence)
- TCA TestStore tests use `await store.send()` / `await store.receive()` pattern
- All observe {} closures MUST use `[weak self]` + `guard let self`
- Test method names follow `testMethodWhenConditionThenResult` convention
- Test structure follows Given (setup TestStore) → When (send action) → Then (assert state)
- Commit after each completed phase checkpoint

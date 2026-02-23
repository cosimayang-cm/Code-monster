# Implementation Plan: TCA + UIKit Login & Posts App

**Branch**: `005-tca-uikit-integration` | **Date**: 2026-02-10 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/005-tca-uikit-integration/spec.md`

## Summary

Build a Login + Posts App using **The Composable Architecture (TCA) 1.7+** integrated with **UIKit**. The app authenticates users via a remote API, displays a scrollable posts list in UITableView, supports navigation to post detail, and provides local interaction features (like/comment/share) with cross-screen state synchronization and local persistence via UserDefaults.

**Key architectural decisions**:
- **Stack-based navigation** (StackState + StackAction + forEach) for the Login → Posts → Detail linear flow, mapping naturally to UINavigationController
- **TCA observe {}** pattern for UIKit state binding (modern Observation API, no ViewStore)
- **@DependencyClient** for AuthClient, PostsClient, and StorageClient
- **IdentifiedArrayOf** for posts list state management with UITableView
- **UserDefaults** for local interaction data persistence

## Project Intelligence

### Existing Features Summary

**Monster #1 - Car System**: Builder, Repository, Observer, DI patterns
- Key: Logger protocol, ConsoleLogger, protocol-oriented services

**Monster #2 - Popup Response Chain**: Chain of Responsibility, multi-account, Observer
- Key: UserDefaultsPopupStateRepository (UserDefaults persistence pattern), UIKitPopupPresenter

**Monster #3 - Undo/Redo System**: Command Pattern, CommandHistory
- Key: UIViewController state binding patterns, TextEditorViewController, CanvasEditorViewController

**Monster #4 - RPG Item/Inventory System**: Template-Instance, Factory, Serialization
- Key: Complex state management, JSON serialization, in-memory persistence

### Reusable Components Matrix

| Component Type | Name | Location | Purpose | Can Be Reused For |
|---------------|------|----------|---------|-------------------|
| Protocol | Logger | CarSystem/Protocols/Logger.swift | Logging abstraction | TCA debug logging dependency |
| Repository | UserDefaultsPopupStateRepository | PopupChain/Repositories/ | UserDefaults persistence pattern | PostInteraction storage pattern reference |
| UIKit Pattern | UIKitPopupPresenter | PopupChain/UI/ | UIViewController lifecycle management | UIKit navigation/presentation reference |
| Testing Pattern | PopupChainTests/ | CodeMonsterTests/ | XCTest with mock objects | Test structure reference for TCA TestStore tests |

### Architecture Patterns Observed

**Dependency Injection**: Context struct passing (PopupContext bundles logger + repository + presenter). TCA equivalent: @Dependency macro.

**State Binding**: Manual observer pattern with UIKit updates. TCA equivalent: observe {} closure.

**Persistence**: Protocol + concrete implementations (InMemory + UserDefaults). TCA equivalent: @DependencyClient for StorageClient.

**Naming Conventions**: PascalCase for types, camelCase for methods/properties, descriptive test names.

### Integration Recommendations

**For TCA + UIKit Integration**:

**Reuse Existing Patterns** (adapted to TCA):
- UserDefaults repository pattern → StorageClient dependency
- Logger protocol → optional TCA logging dependency
- UIViewController setup pattern → observe {} in viewDidLoad

**Create New Components**:
- All TCA Features (LoginFeature, PostsListFeature, PostDetailFeature, AppFeature)
- All Dependencies (AuthClient, PostsClient, StorageClient)
- All UIViewControllers (LoginVC, PostsListVC, PostDetailVC)
- Models (User, LoginResponse, Post, PostInteraction)
- Custom UITableViewCell (PostCell)

**No conflicts**: This feature is entirely new and independent from existing Monster exercises.

## Technical Context

**Language/Version**: Swift 5.9+
**Primary Dependencies**: The Composable Architecture (TCA) 1.7+, UIKit, Combine, Foundation
**Storage**: UserDefaults (local interaction data persistence)
**Testing**: XCTest + TCA TestStore
**Target Platform**: iOS 16+ (minimum for TCA 1.7+ Observation support)
**Project Type**: Mobile (iOS) — single Xcode project
**Performance Goals**: Smooth scrolling at 60fps for 100-item UITableView; login flow < 10s
**Constraints**: Local-only interactions (no server sync); offline interaction data persists
**Scale/Scope**: 3 screens (Login, Posts List, Post Detail), 4 TCA features, 3 dependencies

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Constitution Applicability Assessment**:

This is a **CodeMonster learning project** using **TCA (The Composable Architecture)**, NOT the PAGEs Framework production project (CMProductionPAGE). The constitution references PAGEs-specific architecture (ViewModel, UseCase, Manager, Repository, DataSource, StateManager, ViewComponent) which **do not apply** to TCA architecture.

| Constitution Principle | Applicability | Status |
|----------------------|---------------|--------|
| Architecture rules (PAGEs layers) | NOT applicable — TCA uses Reducer/Store/Effect | N/A — Justified |
| Dependency injection (PAGEs DI) | NOT applicable — TCA uses @Dependency macro | N/A — Justified |
| StateManager v2.0 injection | NOT applicable — TCA uses Store with observe {} | N/A — Justified |
| Layer boundary rules (UseCase/Repo/DS) | NOT applicable — TCA uses flat @DependencyClient | N/A — Justified |
| Weak self pattern | APPLICABLE — UIKit closures need [weak self] | PASS |
| Logger.log() usage | NOT applicable — CodeMonster uses print/custom Logger | N/A |
| XcodeGen workflow | NOT applicable — CodeMonster uses standard .xcodeproj | N/A |
| Test naming (camelCase) | APPLICABLE — will follow testMethodWhenConditionThenResult | PASS |
| Given-When-Then test structure | APPLICABLE — TCA TestStore follows arrange-act-assert | PASS |
| Agent execution protocols | APPLICABLE — using ios-developer agent | PASS |

**Gate Result**: PASS — All applicable principles satisfied. Non-applicable principles justified by TCA architecture difference.

### Compliance Verification (Post-Design)

**Architecture Compliance**: TCA architecture follows its own well-defined patterns:
- Reducer for business logic (replaces PAGEs UseCase/Manager)
- Store for state container (replaces PAGEs StateManager/ViewModel)
- @Dependency for dependency injection (replaces PAGEs protocol-based DI)
- Effect for side effects (replaces PAGEs async patterns)

**Code Quality Compliance**:
- `[weak self]` + `guard let self` in all observe {} closures — COMPLIANT
- No PAGEs-specific Logger required; standard debugging approaches used

**Testing Standards Compliance**:
- Test method names: `testMethodWhenConditionThenResult` pattern — COMPLIANT
- Test structure: Given (setup TestStore) → When (send action) → Then (assert state) — COMPLIANT
- TCA TestStore provides exhaustive state assertion by default

## Project Structure

### Documentation (this feature)

```text
specs/005-tca-uikit-integration/
├── plan.md              # This file
├── research.md          # Phase 0: TCA + UIKit research findings
├── data-model.md        # Phase 1: Entity definitions and relationships
├── quickstart.md        # Phase 1: Developer quick-start guide
├── contracts/           # Phase 1: API contracts
│   ├── auth-api.md      # DummyJSON Auth API contract
│   └── posts-api.md     # JSONPlaceholder Posts API contract
└── tasks.md             # Phase 2 output (created by /speckit.tasks)
```

### Source Code (repository root)

```text
sonia/CodeMonster/CodeMonster/Monster5/
├── App/
│   ├── AppFeature.swift              # Root TCA Reducer (StackState navigation)
│   └── AppCoordinator.swift          # UINavigationController + observe {}
├── Features/
│   ├── Login/
│   │   ├── LoginFeature.swift        # Login TCA Reducer (@ObservableState)
│   │   └── LoginViewController.swift # UIKit login screen
│   ├── PostsList/
│   │   ├── PostsListFeature.swift    # Posts list TCA Reducer
│   │   ├── PostsListViewController.swift  # UITableView controller
│   │   └── PostCell.swift            # Custom UITableViewCell
│   └── PostDetail/
│       ├── PostDetailFeature.swift   # Post detail TCA Reducer
│       └── PostDetailViewController.swift # UIKit detail screen
├── Dependencies/
│   ├── AuthClient.swift              # @DependencyClient for login API
│   ├── PostsClient.swift             # @DependencyClient for posts API
│   └── StorageClient.swift           # @DependencyClient for UserDefaults
├── Models/
│   ├── User.swift                    # User + LoginResponse models
│   ├── Post.swift                    # Post model (API)
│   └── PostInteraction.swift         # Local interaction data model
└── UI/
    └── ErrorToastView.swift          # Reusable error toast (3s auto-dismiss)

sonia/CodeMonster/CodeMonsterTests/Monster5Tests/
├── LoginFeatureTests.swift           # TestStore tests for login
├── PostsListFeatureTests.swift       # TestStore tests for posts list
├── PostDetailFeatureTests.swift      # TestStore tests for post detail
├── AppFeatureTests.swift             # Navigation + integration tests
├── AuthClientTests.swift             # Auth dependency tests
├── PostsClientTests.swift            # Posts dependency tests
└── StorageClientTests.swift          # Storage dependency tests
```

**Structure Decision**: Mobile iOS project. New feature module `Monster5/` under existing Xcode project structure at `sonia/CodeMonster/CodeMonster/`. Feature-based organization with TCA Reducers alongside their UIViewControllers. Dependencies and Models in shared folders. Tests mirror feature structure.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| PAGEs architecture not followed | TCA is a fundamentally different architecture (Reducer/Store vs UseCase/Manager/ViewModel) | PAGEs patterns cannot coexist with TCA — they solve the same problems differently |
| No XcodeGen usage | CodeMonster project uses standard .xcodeproj | XcodeGen is only required for CMProductionLego, not CodeMonster |

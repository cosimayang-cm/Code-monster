# Research: TCA + UIKit Integration

**Feature**: 005-tca-uikit-integration
**Date**: 2026-02-10

## Decision 1: Navigation Pattern

**Decision**: Stack-based navigation (StackState + StackAction + forEach)

**Rationale**: The app has a linear flow (Login → Posts List → Post Detail) that maps naturally to UINavigationController's push/pop model. Stack-based navigation manages a single `StackState<Path.State>` array that mirrors the navigation stack.

**Alternatives considered**:
- **Tree-based navigation** (@Presents + PresentationAction + ifLet): Better for branching/modal destinations. Rejected because our flow is sequential, not branching.
- **Manual UIKit navigation** (no TCA navigation): Rejected because it loses TCA's state-driven navigation benefits and makes testing harder.

**Implementation pattern**:
```swift
@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        var login = LoginFeature.State()
    }
    enum Action {
        case path(StackActionOf<Path>)
        case login(LoginFeature.Action)
    }
    @Reducer
    struct Path {
        @ObservableState
        enum State: Equatable {
            case postsList(PostsListFeature.State)
            case postDetail(PostDetailFeature.State)
        }
        enum Action {
            case postsList(PostsListFeature.Action)
            case postDetail(PostDetailFeature.Action)
        }
        var body: some ReducerOf<Self> {
            Scope(state: \.postsList, action: \.postsList) { PostsListFeature() }
            Scope(state: \.postDetail, action: \.postDetail) { PostDetailFeature() }
        }
    }
    var body: some ReducerOf<Self> {
        Scope(state: \.login, action: \.login) { LoginFeature() }
        Reduce { state, action in
            switch action {
            case .login(.loginResponse(.success)):
                state.path.append(.postsList(PostsListFeature.State()))
                return .none
            case .login, .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path) { Path() }
    }
}
```

## Decision 2: UIKit + TCA Binding Pattern

**Decision**: Use TCA 1.7+ `observe {}` closure in UIViewController.viewDidLoad()

**Rationale**: The modern Observation-based API (replacing ViewStore) automatically tracks accessed state properties and re-executes when they change. It's the officially recommended UIKit integration pattern.

**Alternatives considered**:
- **ViewStore (legacy)**: Deprecated in TCA 1.7+. More boilerplate, explicit subscribe calls.
- **Combine publishers**: Lower level, more manual state tracking, not TCA-idiomatic.

**Implementation pattern**:
```swift
class LoginViewController: UIViewController {
    let store: StoreOf<LoginFeature>

    override func viewDidLoad() {
        super.viewDidLoad()
        observe { [weak self] in
            guard let self else { return }
            loginButton.isEnabled = !store.username.isEmpty
                && !store.password.isEmpty
                && !store.isLoading
            activityIndicator.isAnimating ? nil : store.isLoading
                ? activityIndicator.startAnimating()
                : activityIndicator.stopAnimating()
        }
    }
}
```

## Decision 3: Dependency Injection

**Decision**: Use TCA's @DependencyClient macro for all external dependencies

**Rationale**: @DependencyClient provides compile-time safe dependency definitions with automatic test stubs. It integrates with TCA's @Dependency property wrapper for injection into Reducers.

**Alternatives considered**:
- **Protocol-based DI** (used in existing CodeMonster exercises): Familiar but doesn't integrate with TCA's dependency system.
- **Manual singletons**: Anti-pattern, not testable.

**Three clients defined**:
1. **AuthClient**: `login(username:password:) async throws -> LoginResponse`
2. **PostsClient**: `fetchPosts() async throws -> [Post]`
3. **StorageClient**: `saveInteraction(_:) throws`, `loadInteraction(postId:) -> PostInteraction?`, `loadAllInteractions() -> [Int: PostInteraction]`

## Decision 4: State Synchronization (Detail → List)

**Decision**: Shared state via IdentifiedArrayOf in parent (PostsListFeature) with child scope for PostDetail

**Rationale**: When PostDetailFeature modifies interaction state, the change propagates through the parent PostsListFeature's IdentifiedArray. Since PostDetail operates on a scoped slice of the parent state, changes are automatically reflected in the list when the user navigates back.

**Alternatives considered**:
- **Delegate pattern**: Manual callback from child to parent. Rejected — TCA handles this natively through state scoping.
- **Shared state / @Shared**: TCA provides @Shared for cross-feature state, but parent-child scoping is simpler for this use case.
- **Notification/Observer**: Not TCA-idiomatic, breaks unidirectional data flow.

**Implementation approach**: PostsListFeature holds all post interactions in its state. When navigating to detail, it passes the relevant post + interaction as child state. When the detail reducer modifies the interaction, the parent intercepts the action and updates its own state.

## Decision 5: Local Storage

**Decision**: UserDefaults via StorageClient @DependencyClient

**Rationale**: UserDefaults is simple, sufficient for small interaction data (100 posts × small interaction struct), and follows the pattern already proven in CodeMonster (UserDefaultsPopupStateRepository).

**Alternatives considered**:
- **Core Data**: Overkill for simple key-value interaction data.
- **File-based JSON**: More complex serialization, no advantage over UserDefaults for this scale.
- **@AppStorage / SwiftUI**: Not applicable (UIKit project).

**Storage format**: Dictionary `[Int: PostInteraction]` encoded as JSON Data stored under a single UserDefaults key.

## Decision 6: Error Toast Implementation

**Decision**: Custom UIView overlay with 3-second auto-dismiss using TCA Effect

**Rationale**: The spec requires a toast that auto-dismisses after exactly 3 seconds. TCA's Effect system with ContinuousClock makes this testable (using TestClock to control time).

**Implementation approach**:
```swift
case .loginResponse(.failure(let error)):
    state.isLoading = false
    state.errorMessage = error.localizedDescription
    return .run { send in
        try await clock.sleep(for: .seconds(3))
        await send(.dismissError)
    }
case .dismissError:
    state.errorMessage = nil
    return .none
```

## Decision 7: SPM Integration for TCA

**Decision**: Add TCA via Swift Package Manager to the existing CodeMonster Xcode project

**Rationale**: TCA is distributed via SPM. The existing CodeMonster.xcodeproj can add the package dependency directly through Xcode.

**Package URL**: `https://github.com/pointfreeco/swift-composable-architecture`
**Version**: 1.7.0 or later (requires `@ObservableState` macro support)
**Minimum iOS**: 16.0 (for Observation framework support)

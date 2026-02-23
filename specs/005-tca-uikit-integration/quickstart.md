# Quick Start: TCA + UIKit Login & Posts App

**Feature**: 005-tca-uikit-integration
**Date**: 2026-02-10

## Prerequisites

1. **Xcode 15+** (Swift 5.9+ support)
2. **iOS 16+ deployment target** (required for TCA Observation)
3. Existing CodeMonster.xcodeproj open in Xcode

## Setup: Add TCA Dependency

1. Open `sonia/CodeMonster/CodeMonster.xcodeproj` in Xcode
2. File → Add Package Dependencies
3. Enter URL: `https://github.com/pointfreeco/swift-composable-architecture`
4. Version rule: **Up to Next Major** from `1.7.0`
5. Add `ComposableArchitecture` library to the `CodeMonster` target

## Project Structure

Create the following directory structure under `sonia/CodeMonster/CodeMonster/`:

```
Monster5/
├── App/
│   ├── AppFeature.swift
│   └── AppCoordinator.swift
├── Features/
│   ├── Login/
│   │   ├── LoginFeature.swift
│   │   └── LoginViewController.swift
│   ├── PostsList/
│   │   ├── PostsListFeature.swift
│   │   ├── PostsListViewController.swift
│   │   └── PostCell.swift
│   └── PostDetail/
│       ├── PostDetailFeature.swift
│       └── PostDetailViewController.swift
├── Dependencies/
│   ├── AuthClient.swift
│   ├── PostsClient.swift
│   └── StorageClient.swift
├── Models/
│   ├── User.swift
│   ├── Post.swift
│   └── PostInteraction.swift
└── UI/
    └── ErrorToastView.swift
```

## Implementation Order

### Phase 1: Foundation (Models + Dependencies)
1. Create `Post.swift`, `User.swift`, `PostInteraction.swift` models
2. Create `AuthClient.swift` with live + test implementations
3. Create `PostsClient.swift` with live + test implementations
4. Create `StorageClient.swift` with live + test implementations

### Phase 2: Login Feature
1. Implement `LoginFeature.swift` (State, Action, Reducer)
2. Implement `LoginViewController.swift` with observe {}
3. Create `ErrorToastView.swift` for login error display
4. Write `LoginFeatureTests.swift`

### Phase 3: Posts List Feature
1. Implement `PostsListFeature.swift` with IdentifiedArrayOf
2. Implement `PostCell.swift` (custom UITableViewCell)
3. Implement `PostsListViewController.swift` with UITableView
4. Write `PostsListFeatureTests.swift`

### Phase 4: Post Detail Feature
1. Implement `PostDetailFeature.swift` (like/comment/share actions)
2. Implement `PostDetailViewController.swift`
3. Write `PostDetailFeatureTests.swift`

### Phase 5: App Navigation + Integration
1. Implement `AppFeature.swift` (StackState navigation, state sync)
2. Implement `AppCoordinator.swift` (UINavigationController)
3. Wire up in SceneDelegate/ViewController entry point
4. Write `AppFeatureTests.swift`

## Key Patterns Reference

### TCA Feature Structure
```swift
import ComposableArchitecture

@Reducer
struct MyFeature {
    @ObservableState
    struct State: Equatable { /* ... */ }
    enum Action { /* ... */ }
    @Dependency(\.myClient) var myClient
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            // handle actions, return effects
        }
    }
}
```

### UIKit observe {} Pattern
```swift
class MyViewController: UIViewController {
    let store: StoreOf<MyFeature>
    override func viewDidLoad() {
        super.viewDidLoad()
        observe { [weak self] in
            guard let self else { return }
            // read store properties → updates UI automatically
        }
    }
}
```

### Sending Actions
```swift
store.send(.buttonTapped)
store.send(.textChanged("new value"))
```

### TestStore Pattern
```swift
@MainActor
func testSomething() async {
    let store = TestStore(initialState: MyFeature.State()) {
        MyFeature()
    } withDependencies: {
        $0.myClient.someMethod = { /* mock */ }
    }
    await store.send(.someAction) { $0.someProperty = expectedValue }
    await store.receive(\.responseAction) { $0.result = expectedResult }
}
```

## Test Credentials

- **Username**: `emilys`
- **Password**: `emilyspass`
- **API docs**: https://dummyjson.com/docs/auth

## API Endpoints

| Endpoint | Method | URL |
|----------|--------|-----|
| Login | POST | https://dummyjson.com/auth/login |
| Posts | GET | https://jsonplaceholder.typicode.com/posts |

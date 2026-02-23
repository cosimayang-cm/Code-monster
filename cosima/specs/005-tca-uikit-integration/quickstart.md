# Quickstart: TCA + UIKit 整合實戰

**Feature**: feature/monster5-tca-uikit-integration
**Date**: 2026-02-17

## 快速開始

### 1. 添加 TCA 依賴

在 Xcode 中使用 Swift Package Manager 添加 TCA：
```
https://github.com/pointfreeco/swift-composable-architecture
```
版本要求：1.7+

### 2. LoginFeature 基本實作

```swift
import ComposableArchitecture

@Reducer
struct LoginFeature {
    @ObservableState
    struct State: Equatable {
        var username = ""
        var password = ""
        var isLoading = false
        var errorMessage: String?
        var user: User?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case loginButtonTapped
        case loginResponse(Result<User, Error>)
        case dismissError
    }
    
    @Dependency(\.authClient) var authClient
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .loginButtonTapped:
                state.isLoading = true
                state.errorMessage = nil
                return .run { [username = state.username, password = state.password] send in
                    do {
                        let user = try await authClient.login(username, password)
                        await send(.loginResponse(.success(user)))
                    } catch {
                        await send(.loginResponse(.failure(error)))
                    }
                }
                
            case let .loginResponse(.success(user)):
                state.isLoading = false
                state.user = user
                return .none
                
            case let .loginResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = (error as? APIError)?.message ?? "登入失敗"
                return .run { send in
                    try await Task.sleep(for: .seconds(3))
                    await send(.dismissError)
                }
                
            case .dismissError:
                state.errorMessage = nil
                return .none
            }
        }
    }
}
```

### 3. LoginViewController (UIKit + observe)

```swift
import UIKit
import ComposableArchitecture

final class LoginViewController: UIViewController {
    let store: StoreOf<LoginFeature>
    
    private let usernameField = UITextField()
    private let passwordField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    init(store: StoreOf<LoginFeature>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        
        observe { [weak self] in
            guard let self else { return }
            // TCA observe — 自動追蹤讀取的 state 屬性
            usernameField.text = store.username
            passwordField.text = store.password
            loginButton.isEnabled = !store.isLoading
            
            if store.isLoading {
                loadingIndicator.startAnimating()
            } else {
                loadingIndicator.stopAnimating()
            }
            
            // 顯示/隱藏 Error Toast
            if let errorMessage = store.errorMessage {
                showToast(message: errorMessage)
            }
        }
    }
    
    private func setupBindings() {
        usernameField.addAction(UIAction { [weak self] _ in
            self?.store.send(.set(\.username, self?.usernameField.text ?? ""))
        }, for: .editingChanged)
        
        passwordField.addAction(UIAction { [weak self] _ in
            self?.store.send(.set(\.password, self?.passwordField.text ?? ""))
        }, for: .editingChanged)
        
        loginButton.addAction(UIAction { [weak self] _ in
            self?.store.send(.loginButtonTapped)
        }, for: .touchUpInside)
    }
    
    private func setupUI() {
        // ... layout code
    }
    
    private func showToast(message: String) {
        // ... toast implementation
    }
}
```

### 4. AuthClient Dependency

```swift
import ComposableArchitecture

struct AuthClient {
    var login: @Sendable (String, String) async throws -> User
}

extension AuthClient: DependencyKey {
    static let liveValue = AuthClient(
        login: { username, password in
            let url = URL(string: "https://dummyjson.com/auth/login")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body = ["username": username, "password": password, "expiresInMins": "30"]
            request.httpBody = try JSONEncoder().encode(body)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError(message: "Invalid response")
            }
            
            if httpResponse.statusCode == 200 {
                return try JSONDecoder().decode(User.self, from: data)
            } else {
                let apiError = try JSONDecoder().decode(APIError.self, from: data)
                throw apiError
            }
        }
    )
    
    static let testValue = AuthClient(
        login: { _, _ in
            User(id: 1, username: "test", email: "test@test.com",
                 firstName: "Test", lastName: "User", gender: "male",
                 image: "", accessToken: "token", refreshToken: "refresh")
        }
    )
}

extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}
```

---

## 測試案例

### TC-001: 登入成功

**Given**: 輸入正確帳密
**When**: 點擊登入
**Then**: isLoading 先變 true，收到回應後變 false，user 不為 nil

```swift
@Test
func testLoginSuccess() async {
    let store = TestStore(initialState: LoginFeature.State()) {
        LoginFeature()
    } withDependencies: {
        $0.authClient.login = { _, _ in .mock }
    }
    
    store.send(.set(\.username, "emilys")) {
        $0.username = "emilys"
    }
    store.send(.set(\.password, "emilyspass")) {
        $0.password = "emilyspass"
    }
    
    await store.send(.loginButtonTapped) {
        $0.isLoading = true
    }
    await store.receive(\.loginResponse.success) {
        $0.isLoading = false
        $0.user = .mock
    }
}
```

---

### TC-002: 登入失敗顯示 Error Toast

**Given**: 輸入錯誤帳密
**When**: 點擊登入
**Then**: errorMessage 有值，3 秒後自動消失

```swift
@Test
func testLoginFailure() async {
    let clock = TestClock()
    
    let store = TestStore(initialState: LoginFeature.State()) {
        LoginFeature()
    } withDependencies: {
        $0.authClient.login = { _, _ in throw APIError(message: "Invalid credentials") }
        $0.continuousClock = clock
    }
    
    store.send(.set(\.username, "wrong")) {
        $0.username = "wrong"
    }
    store.send(.set(\.password, "wrong")) {
        $0.password = "wrong"
    }
    
    await store.send(.loginButtonTapped) {
        $0.isLoading = true
    }
    await store.receive(\.loginResponse.failure) {
        $0.isLoading = false
        $0.errorMessage = "Invalid credentials"
    }
    
    await clock.advance(by: .seconds(3))
    await store.receive(\.dismissError) {
        $0.errorMessage = nil
    }
}
```

---

### TC-003: Posts 列表載入

**Given**: 進入 Posts 頁面
**When**: 觸發 onAppear
**Then**: 載入 100 篇文章

```swift
@Test
func testLoadPosts() async {
    let store = TestStore(initialState: PostsFeature.State()) {
        PostsFeature()
    } withDependencies: {
        $0.postsClient.fetchPosts = { Post.mockList }
        $0.storageClient.loadInteractions = { [:] }
    }
    
    await store.send(.onAppear) {
        $0.isLoading = true
    }
    await store.receive(\.postsResponse.success) {
        $0.isLoading = false
        $0.posts = // IdentifiedArray of PostDetailFeature.State
    }
}
```

---

### TC-004: 按讚狀態同步

**Given**: 文章尚未按讚
**When**: 在 Detail 頁面按讚
**Then**: Posts List 中對應文章的按讚狀態同步更新

```swift
@Test
func testLikeSyncs() async {
    var postsState = PostsFeature.State()
    postsState.posts = [
        PostDetailFeature.State(
            post: .mock,
            interaction: PostInteraction(postId: 1, likeCount: 0, isLiked: false, comments: [], shareCount: 0)
        )
    ]
    
    let store = TestStore(initialState: postsState) {
        PostsFeature()
    } withDependencies: {
        $0.storageClient.saveInteractions = { _ in }
    }
    
    await store.send(.post(id: 1, action: .toggleLike)) {
        $0.posts[id: 1]?.interaction.isLiked = true
        $0.posts[id: 1]?.interaction.likeCount = 1
    }
}
```

---

### TC-005: 互動數據持久化

**Given**: 按讚操作完成
**When**: 儲存互動數據
**Then**: StorageClient 被呼叫儲存

```swift
@Test
func testInteractionPersistence() async {
    var savedInteractions: [Int: PostInteraction]?
    
    let store = TestStore(initialState: PostDetailFeature.State(
        post: .mock,
        interaction: PostInteraction(postId: 1, likeCount: 0, isLiked: false, comments: [], shareCount: 0)
    )) {
        PostDetailFeature()
    } withDependencies: {
        $0.storageClient.saveInteractions = { savedInteractions = $0 }
    }
    
    await store.send(.toggleLike) {
        $0.interaction.isLiked = true
        $0.interaction.likeCount = 1
    }
    await store.receive(\.saveInteraction)
    
    XCTAssertNotNil(savedInteractions)
    XCTAssertEqual(savedInteractions?[1]?.isLiked, true)
}
```

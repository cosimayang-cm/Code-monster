import XCTest
import ComposableArchitecture
@testable import Monster5

@MainActor
final class LoginFeatureTests: XCTestCase {

    func testUsernameChanged() async {
        let store = TestStore(initialState: LoginFeature.State()) {
            LoginFeature()
        }

        await store.send(.usernameChanged("emilys")) {
            $0.username = "emilys"
        }
    }

    func testPasswordChanged() async {
        let store = TestStore(initialState: LoginFeature.State()) {
            LoginFeature()
        }

        await store.send(.passwordChanged("secret")) {
            $0.password = "secret"
        }
    }

    func testIsFormValidWhenBothFieldsFilled() async {
        var state = LoginFeature.State()
        state.username = "emilys"
        state.password = "emilyspass"
        XCTAssertTrue(state.isFormValid)
    }

    func testIsFormInvalidWhenUsernameEmpty() async {
        var state = LoginFeature.State()
        state.password = "emilyspass"
        XCTAssertFalse(state.isFormValid)
    }

    func testIsFormInvalidWhenPasswordEmpty() async {
        var state = LoginFeature.State()
        state.username = "emilys"
        XCTAssertFalse(state.isFormValid)
    }

    func testLoginButtonTappedWithEmptyFieldsShowsError() async {
        let clock = TestClock()
        let store = TestStore(initialState: LoginFeature.State()) {
            LoginFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }

        await store.send(.loginButtonTapped) {
            $0.errorMessage = "請輸入帳號密碼"
        }

        await clock.advance(by: .seconds(3))
        await store.receive(.errorAutoDismissTimerFired) {
            $0.errorMessage = nil
        }
    }

    func testLoginSuccess() async {
        let testUser = User(
            id: 1,
            username: "emilys",
            email: "emily@test.com",
            firstName: "Emily",
            lastName: "Johnson",
            gender: "female",
            image: "https://example.com/img.png",
            accessToken: "token",
            refreshToken: "refresh"
        )

        let store = TestStore(
            initialState: LoginFeature.State(username: "emilys", password: "emilyspass")
        ) {
            LoginFeature()
        } withDependencies: {
            $0.authClient.login = { _, _ in testUser }
        }

        await store.send(.loginButtonTapped) {
            $0.isLoading = true
        }

        await store.receive(.loginResponse(.success(testUser))) {
            $0.isLoading = false
            $0.user = testUser
        }

        await store.receive(.delegate(.loginSucceeded(testUser)))
    }

    func testLoginFailure() async {
        let clock = TestClock()
        let store = TestStore(
            initialState: LoginFeature.State(username: "wrong", password: "wrong")
        ) {
            LoginFeature()
        } withDependencies: {
            $0.authClient.login = { _, _ in throw AuthError.serverError("Invalid credentials") }
            $0.continuousClock = clock
        }

        await store.send(.loginButtonTapped) {
            $0.isLoading = true
        }

        await store.receive(.loginResponse(.failure(.serverError("Invalid credentials")))) {
            $0.isLoading = false
            $0.errorMessage = "Invalid credentials"
        }

        await clock.advance(by: .seconds(3))
        await store.receive(.errorAutoDismissTimerFired) {
            $0.errorMessage = nil
        }
    }

    func testDismissError() async {
        let clock = TestClock()
        let store = TestStore(
            initialState: LoginFeature.State(username: "wrong", password: "wrong")
        ) {
            LoginFeature()
        } withDependencies: {
            $0.authClient.login = { _, _ in throw AuthError.serverError("Error") }
            $0.continuousClock = clock
        }

        await store.send(.loginButtonTapped) {
            $0.isLoading = true
        }

        await store.receive(.loginResponse(.failure(.serverError("Error")))) {
            $0.isLoading = false
            $0.errorMessage = "Error"
        }

        await store.send(.dismissError) {
            $0.errorMessage = nil
        }
    }
}

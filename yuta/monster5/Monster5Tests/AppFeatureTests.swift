import XCTest
import ComposableArchitecture
@testable import Monster5

@MainActor
final class AppFeatureTests: XCTestCase {

    func testLoginSucceededTransitionsToHome() async {
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

        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }

        await store.send(.login(.delegate(.loginSucceeded(testUser)))) {
            $0.home = HomeFeature.State()
        }
    }

    func testIsAuthenticatedComputedProperty() {
        var state = AppFeature.State()
        XCTAssertFalse(state.isAuthenticated)

        state.home = HomeFeature.State()
        XCTAssertTrue(state.isAuthenticated)
    }
}

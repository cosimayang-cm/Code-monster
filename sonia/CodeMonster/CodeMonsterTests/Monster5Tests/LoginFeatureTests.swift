//
//  LoginFeatureTests.swift
//  CodeMonsterTests - Monster 5: TCA + UIKit Integration
//
//  Created by Claude on 2026-02-10.
//

import ComposableArchitecture
import XCTest

@testable import CodeMonster

@MainActor
final class LoginFeatureTests: XCTestCase {

    // MARK: - T012: Empty Fields Disable Login Button

    func testLoginWhenFieldsEmptyThenButtonDisabled() async {
        let store = TestStore(initialState: LoginFeature.State()) {
            LoginFeature()
        }

        // Given: Initial state with empty fields
        // Then: Login button should be disabled
        XCTAssertFalse(store.state.isLoginButtonEnabled)

        // When: Only username entered
        await store.send(.usernameChanged("emilys")) {
            $0.username = "emilys"
        }
        XCTAssertFalse(store.state.isLoginButtonEnabled)

        // When: Both fields have input
        await store.send(.passwordChanged("emilyspass")) {
            $0.password = "emilyspass"
        }
        XCTAssertTrue(store.state.isLoginButtonEnabled)
    }

    // MARK: - T013: Valid Credentials Success

    func testLoginWhenValidCredentialsThenSuccess() async {
        // Given: Mock successful response
        let mockResponse = LoginResponse(
            id: 1,
            username: "emilys",
            email: "emily@test.com",
            firstName: "Emily",
            lastName: "Johnson",
            gender: "female",
            image: "https://example.com/img.png",
            accessToken: "token123",
            refreshToken: "refresh123"
        )

        let store = TestStore(
            initialState: LoginFeature.State(
                username: "emilys",
                password: "emilyspass"
            )
        ) {
            LoginFeature()
        } withDependencies: {
            $0.authClient.login = { _, _ in mockResponse }
        }

        // When: Login tapped
        await store.send(.loginTapped) {
            $0.isLoading = true
            $0.errorMessage = nil
        }

        // Then: Receive success response
        await store.receive(\.loginResponse.success) {
            $0.isLoading = false
            $0.loginResponse = mockResponse
        }
    }

    // MARK: - T014: Invalid Credentials Show Error with Auto-Dismiss

    func testLoginWhenInvalidCredentialsThenShowsErrorAndAutoDismisses() async {
        // Given: Mock clock for testing timers
        let clock = TestClock()

        let store = TestStore(
            initialState: LoginFeature.State(
                username: "wrong",
                password: "wrong"
            )
        ) {
            LoginFeature()
        } withDependencies: {
            $0.authClient.login = { _, _ in
                throw AuthError.loginFailed("Invalid credentials")
            }
            $0.continuousClock = clock
        }

        // When: Login tapped
        await store.send(.loginTapped) {
            $0.isLoading = true
            $0.errorMessage = nil
        }

        // Then: Receive failure response
        await store.receive(\.loginResponse.failure) {
            $0.isLoading = false
            $0.errorMessage = "Invalid credentials"
        }

        // When: 3 seconds pass
        await clock.advance(by: .seconds(3))

        // Then: Error auto-dismisses
        await store.receive(\.dismissError) {
            $0.errorMessage = nil
        }
    }

    // MARK: - T015: Loading State Disables Button

    func testLoginWhenLoadingThenButtonDisabled() async {
        let store = TestStore(
            initialState: LoginFeature.State(
                username: "emilys",
                password: "emilyspass",
                isLoading: true
            )
        ) {
            LoginFeature()
        }

        // Given: State with loading true
        // Then: Login button should be disabled
        XCTAssertFalse(store.state.isLoginButtonEnabled)
    }
}

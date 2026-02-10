//
//  LoginFeature.swift
//  CodeMonster - Monster 5: TCA + UIKit Integration
//
//  Created by Claude on 2026-02-10.
//

import ComposableArchitecture
import Foundation

/// Login feature managing authentication flow
@Reducer
struct LoginFeature {

    // MARK: - State

    @ObservableState
    struct State: Equatable {
        var username: String = ""
        var password: String = ""
        var isLoading: Bool = false
        var errorMessage: String?
        var loginResponse: LoginResponse?

        /// Login button is enabled when both fields are non-empty and not loading
        var isLoginButtonEnabled: Bool {
            !username.isEmpty && !password.isEmpty && !isLoading
        }
    }

    // MARK: - Action

    enum Action {
        case usernameChanged(String)
        case passwordChanged(String)
        case loginTapped
        case loginResponse(Result<LoginResponse, Error>)
        case dismissError
    }

    // MARK: - Dependencies

    @Dependency(\.authClient) var authClient
    @Dependency(\.continuousClock) var clock

    // MARK: - Reducer

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .usernameChanged(username):
                state.username = username
                return .none

            case let .passwordChanged(password):
                state.password = password
                return .none

            case .loginTapped:
                state.isLoading = true
                state.errorMessage = nil

                let username = state.username
                let password = state.password

                return .run { send in
                    let result = await Result {
                        try await authClient.login(username, password)
                    }
                    await send(.loginResponse(result))
                }

            case let .loginResponse(.success(response)):
                state.isLoading = false
                state.loginResponse = response
                return .none

            case let .loginResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = (error as? AuthError)?.errorDescription ?? error.localizedDescription

                // Auto-dismiss error after 3 seconds
                return .run { send in
                    try await clock.sleep(for: .seconds(3))
                    await send(.dismissError)
                }

            case .dismissError:
                state.errorMessage = nil
                return .none
            }
        }
    }
}

//
//  LoginFeature.swift
//  CarSystem
//
//  Monster5 - TCA + UIKit 整合實戰
//

import ComposableArchitecture
import Foundation

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
    @Dependency(\.continuousClock) var clock

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .loginButtonTapped:
                guard !state.isLoading else { return .none }
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
                state.errorMessage = (error as? Monster5APIError)?.message ?? "登入失敗"
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

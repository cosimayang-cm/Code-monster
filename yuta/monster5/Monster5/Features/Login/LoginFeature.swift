import Foundation
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

        var isFormValid: Bool { !username.isEmpty && !password.isEmpty }
    }

    enum Action: Equatable {
        case usernameChanged(String)
        case passwordChanged(String)
        case loginButtonTapped
        case loginResponse(Result<User, AuthError>)
        case dismissError
        case errorAutoDismissTimerFired
        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case loginSucceeded(User)
        }
    }

    private enum CancelID {
        case errorAutoDismiss
    }

    @Dependency(\.authClient) var authClient
    @Dependency(\.continuousClock) var clock

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .usernameChanged(let value):
                state.username = value
                return .none

            case .passwordChanged(let value):
                state.password = value
                return .none

            case .loginButtonTapped:
                guard state.isFormValid else {
                    state.errorMessage = "請輸入帳號密碼"
                    return .run { send in
                        try await clock.sleep(for: .seconds(3))
                        await send(.errorAutoDismissTimerFired)
                    }
                    .cancellable(id: CancelID.errorAutoDismiss, cancelInFlight: true)
                }
                state.isLoading = true
                state.errorMessage = nil
                let username = state.username
                let password = state.password
                return .run { send in
                    let result: Result<User, AuthError>
                    do {
                        let user = try await authClient.login(username, password)
                        result = .success(user)
                    } catch let error as AuthError {
                        result = .failure(error)
                    } catch {
                        result = .failure(.networkError)
                    }
                    await send(.loginResponse(result))
                }

            case .loginResponse(.success(let user)):
                state.isLoading = false
                state.user = user
                return .send(.delegate(.loginSucceeded(user)))

            case .loginResponse(.failure(let error)):
                state.isLoading = false
                state.errorMessage = error.errorDescription ?? "Unknown error"
                return .run { send in
                    try await clock.sleep(for: .seconds(3))
                    await send(.errorAutoDismissTimerFired)
                }
                .cancellable(id: CancelID.errorAutoDismiss, cancelInFlight: true)

            case .dismissError:
                state.errorMessage = nil
                return .cancel(id: CancelID.errorAutoDismiss)

            case .errorAutoDismissTimerFired:
                state.errorMessage = nil
                return .none

            case .delegate:
                return .none
            }
        }
    }
}

import Foundation
import ComposableArchitecture

enum AuthError: LocalizedError, Equatable {
    case networkError
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network connection failed"
        case .serverError(let message):
            return message
        }
    }
}

struct ErrorResponse: Codable {
    let message: String
}

@DependencyClient
struct AuthClient: Sendable {
    var login: @Sendable (_ username: String, _ password: String) async throws -> User
}

extension AuthClient: DependencyKey {
    static let liveValue: Self = .init(
        login: { username, password in
            var request = URLRequest(url: URL(string: "https://dummyjson.com/auth/login")!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body: [String: Any] = [
                "username": username,
                "password": password,
                "expiresInMins": 30
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.networkError
            }

            if httpResponse.statusCode == 200 {
                return try JSONDecoder().decode(User.self, from: data)
            } else {
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                throw AuthError.serverError(errorResponse.message)
            }
        }
    )
}

extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}

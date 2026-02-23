//
//  AuthClient.swift
//  CodeMonster - Monster 5: TCA + UIKit Integration
//
//  Created by Claude on 2026-02-10.
//

import Foundation
import ComposableArchitecture

/// Authentication client for login API calls
@DependencyClient
struct AuthClient: Sendable {
    var login: @Sendable (_ username: String, _ password: String) async throws -> LoginResponse
}

// MARK: - Live Implementation

extension AuthClient: DependencyKey {
    static let liveValue = AuthClient(
        login: { username, password in
            let url = URL(string: "https://dummyjson.com/auth/login")!
            var request = URLRequest(url: url)
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
                throw AuthError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                return try JSONDecoder().decode(LoginResponse.self, from: data)
            } else {
                let errorResponse = try? JSONDecoder().decode(LoginErrorResponse.self, from: data)
                throw AuthError.loginFailed(errorResponse?.message ?? "Login failed")
            }
        }
    )
}

// MARK: - Test Implementation

extension AuthClient: TestDependencyKey {
    static let testValue = AuthClient()
}

// MARK: - Dependency Registration

extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}

// MARK: - Error Types

enum AuthError: Error, LocalizedError, Equatable {
    case loginFailed(String)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .loginFailed(let message):
            return message
        case .invalidResponse:
            return "Invalid server response"
        }
    }
}

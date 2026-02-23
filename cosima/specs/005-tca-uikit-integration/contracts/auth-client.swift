// MARK: - AuthClient Contract
// Feature: feature/monster5-tca-uikit-integration
// Date: 2026-02-17

import Foundation
import ComposableArchitecture

// MARK: - AuthClient

/// 認證 API 客戶端
/// 負責登入請求，透過 TCA Dependency 注入
struct AuthClient {
    /// 登入
    /// - Parameters:
    ///   - username: 帳號
    ///   - password: 密碼
    /// - Returns: 登入成功的用戶資訊
    /// - Throws: APIError（帳密錯誤）或網路錯誤
    var login: @Sendable (_ username: String, _ password: String) async throws -> User
}

// MARK: - DependencyKey

extension AuthClient: DependencyKey {
    /// 真實 API 實作
    static let liveValue = AuthClient(
        login: { username, password in
            let url = URL(string: "https://dummyjson.com/auth/login")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            struct LoginRequest: Encodable {
                let username: String
                let password: String
                let expiresInMins: Int
            }
            
            let loginRequest = LoginRequest(
                username: username,
                password: password,
                expiresInMins: 30
            )
            request.httpBody = try JSONEncoder().encode(loginRequest)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError(message: "Invalid response")
            }
            
            if httpResponse.statusCode == 200 {
                return try JSONDecoder().decode(User.self, from: data)
            } else {
                let apiError = try? JSONDecoder().decode(APIError.self, from: data)
                throw apiError ?? APIError(message: "Unknown error (HTTP \(httpResponse.statusCode))")
            }
        }
    )
    
    /// 測試用 mock 實作
    static let testValue = AuthClient(
        login: { _, _ in
            User(
                id: 1,
                username: "emilys",
                email: "emily.johnson@x.dummyjson.com",
                firstName: "Emily",
                lastName: "Johnson",
                gender: "female",
                image: "https://dummyjson.com/icon/emilys/128",
                accessToken: "mock-access-token",
                refreshToken: "mock-refresh-token"
            )
        }
    )
}

// MARK: - DependencyValues Extension

extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}

// MARK: - PostsClient Contract
// Feature: feature/monster5-tca-uikit-integration
// Date: 2026-02-17

import Foundation
import ComposableArchitecture

// MARK: - PostsClient

/// 文章列表 API 客戶端
/// 負責取得文章列表，透過 TCA Dependency 注入
struct PostsClient {
    /// 取得所有文章
    /// - Returns: 文章陣列（100 篇）
    /// - Throws: 網路錯誤或解碼錯誤
    var fetchPosts: @Sendable () async throws -> [Post]
}

// MARK: - DependencyKey

extension PostsClient: DependencyKey {
    /// 真實 API 實作
    static let liveValue = PostsClient(
        fetchPosts: {
            let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw APIError(message: "Failed to fetch posts")
            }
            
            return try JSONDecoder().decode([Post].self, from: data)
        }
    )
    
    /// 測試用 mock 實作
    static let testValue = PostsClient(
        fetchPosts: {
            [
                Post(userId: 1, id: 1, title: "Test Post 1", body: "Body 1"),
                Post(userId: 1, id: 2, title: "Test Post 2", body: "Body 2"),
                Post(userId: 2, id: 3, title: "Test Post 3", body: "Body 3"),
            ]
        }
    )
}

// MARK: - DependencyValues Extension

extension DependencyValues {
    var postsClient: PostsClient {
        get { self[PostsClient.self] }
        set { self[PostsClient.self] = newValue }
    }
}

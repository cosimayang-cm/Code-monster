//
//  PostsClient.swift
//  CodeMonster - Monster 5: TCA + UIKit Integration
//
//  Created by Claude on 2026-02-10.
//

import Foundation
import ComposableArchitecture

/// Posts client for fetching posts from API
@DependencyClient
struct PostsClient: Sendable {
    var fetchPosts: @Sendable () async throws -> [Post]
}

// MARK: - Live Implementation

extension PostsClient: DependencyKey {
    static let liveValue = PostsClient(
        fetchPosts: {
            let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw PostsError.fetchFailed
            }

            return try JSONDecoder().decode([Post].self, from: data)
        }
    )
}

// MARK: - Test Implementation

extension PostsClient: TestDependencyKey {
    static let testValue = PostsClient()
}

// MARK: - Dependency Registration

extension DependencyValues {
    var postsClient: PostsClient {
        get { self[PostsClient.self] }
        set { self[PostsClient.self] = newValue }
    }
}

// MARK: - Error Types

enum PostsError: Error, LocalizedError, Equatable {
    case fetchFailed

    var errorDescription: String? {
        switch self {
        case .fetchFailed:
            return "Failed to load posts"
        }
    }
}

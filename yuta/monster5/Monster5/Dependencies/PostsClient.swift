import Foundation
import ComposableArchitecture

@DependencyClient
struct PostsClient: Sendable {
    var fetchPosts: @Sendable () async throws -> [Post]
}

extension PostsClient: DependencyKey {
    static let liveValue: Self = .init(
        fetchPosts: {
            let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode([Post].self, from: data)
        }
    )
}

extension DependencyValues {
    var postsClient: PostsClient {
        get { self[PostsClient.self] }
        set { self[PostsClient.self] = newValue }
    }
}

//
//  PostsFeature.swift
//  CarSystem
//
//  Monster5 - TCA + UIKit 整合實戰
//

import ComposableArchitecture
import Foundation

@Reducer
struct PostsFeature {
    @ObservableState
    struct State: Equatable {
        var posts: IdentifiedArrayOf<PostDetailFeature.State> = []
        var isLoading = false
        var errorMessage: String?
    }

    enum Action {
        case onAppear
        case postsResponse(Result<[Post], Error>)
        case post(IdentifiedActionOf<PostDetailFeature>)
        case dismissError
    }

    @Dependency(\.postsClient) var postsClient
    @Dependency(\.storageClient) var storageClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard state.posts.isEmpty else { return .none }
                state.isLoading = true
                return .run { [storageClient, postsClient] send in
                    do {
                        let posts = try await postsClient.fetchPosts()
                        await send(.postsResponse(.success(posts)))
                    } catch {
                        await send(.postsResponse(.failure(error)))
                    }
                }

            case let .postsResponse(.success(posts)):
                state.isLoading = false
                let interactions = storageClient.loadInteractions()
                state.posts = IdentifiedArray(uniqueElements: posts.map { post in
                    PostDetailFeature.State(
                        post: post,
                        interaction: interactions[post.id] ?? .empty(for: post.id)
                    )
                })
                return .none

            case let .postsResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none

            case .post:
                return .none

            case .dismissError:
                state.errorMessage = nil
                return .none
            }
        }
        .forEach(\.posts, action: \.post) {
            PostDetailFeature()
        }
    }
}

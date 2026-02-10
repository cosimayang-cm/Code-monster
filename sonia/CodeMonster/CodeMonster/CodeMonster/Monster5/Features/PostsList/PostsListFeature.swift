//
//  PostsListFeature.swift
//  CodeMonster - Monster 5: TCA + UIKit Integration
//
//  Created by Claude on 2026-02-10.
//

import ComposableArchitecture

/// Posts list feature managing the feed of posts with interactions
@Reducer
struct PostsListFeature {
    @ObservableState
    struct State: Equatable {
        var posts: IdentifiedArrayOf<PostWithInteraction> = []
        var isLoading: Bool = false
        var errorMessage: String?
    }

    enum Action {
        case onAppear
        case postsResponse(Result<[Post], Error>)
        case retryTapped
        case postTapped(PostWithInteraction)
        case updateInteraction(PostInteraction)
    }

    @Dependency(\.postsClient) var postsClient
    @Dependency(\.storageClient) var storageClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    let result = await Result { try await postsClient.fetchPosts() }
                    await send(.postsResponse(result))
                }

            case let .postsResponse(.success(posts)):
                state.isLoading = false
                let interactions = (try? storageClient.loadAllInteractions()) ?? [:]
                state.posts = IdentifiedArrayOf(uniqueElements: posts.map { post in
                    PostWithInteraction(
                        post: post,
                        interaction: interactions[post.id] ?? PostInteraction(postId: post.id)
                    )
                })
                return .none

            case let .postsResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none

            case .retryTapped:
                state.errorMessage = nil
                state.isLoading = true
                return .run { send in
                    let result = await Result { try await postsClient.fetchPosts() }
                    await send(.postsResponse(result))
                }

            case .postTapped:
                return .none // handled by parent AppFeature

            case let .updateInteraction(interaction):
                if let index = state.posts.index(id: interaction.postId) {
                    state.posts[index].interaction = interaction
                }
                return .none
            }
        }
    }
}

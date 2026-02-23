//
//  PostDetailFeature.swift
//  CodeMonster - Monster 5: TCA + UIKit Integration
//
//  Created by Claude on 2026-02-10.
//

import ComposableArchitecture

/// Post detail feature managing single post view with interactions
@Reducer
struct PostDetailFeature {
    @ObservableState
    struct State: Equatable {
        var post: Post
        var interaction: PostInteraction
    }

    enum Action {
        case likeTapped
        case commentTapped
        case shareTapped
    }

    @Dependency(\.storageClient) var storageClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .likeTapped:
                state.interaction.isLiked.toggle()
                state.interaction.likeCount += state.interaction.isLiked ? 1 : -1
                return .run { [interaction = state.interaction] _ in
                    try storageClient.saveInteraction(interaction)
                }

            case .commentTapped:
                state.interaction.commentCount += 1
                return .run { [interaction = state.interaction] _ in
                    try storageClient.saveInteraction(interaction)
                }

            case .shareTapped:
                state.interaction.shareCount += 1
                return .run { [interaction = state.interaction] _ in
                    try storageClient.saveInteraction(interaction)
                }
            }
        }
    }
}

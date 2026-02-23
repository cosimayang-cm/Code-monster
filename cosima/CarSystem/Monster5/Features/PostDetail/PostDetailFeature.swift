//
//  PostDetailFeature.swift
//  CarSystem
//
//  Monster5 - TCA + UIKit 整合實戰
//

import ComposableArchitecture
import Foundation

@Reducer
struct PostDetailFeature {
    @ObservableState
    struct State: Equatable, Identifiable {
        let post: Post
        var interaction: PostInteraction
        var commentText: String = ""

        var id: Int { post.id }
    }

    enum Action: Equatable {
        case toggleLike
        case addComment
        case commentTextChanged(String)
        case shareTapped
        case saveInteraction
    }

    @Dependency(\.storageClient) var storageClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .toggleLike:
                state.interaction.isLiked.toggle()
                state.interaction.likeCount += state.interaction.isLiked ? 1 : -1
                return .send(.saveInteraction)

            case .addComment:
                guard !state.commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    return .none
                }
                let comment = PostComment(
                    postId: state.post.id,
                    content: state.commentText
                )
                state.interaction.comments.append(comment)
                state.commentText = ""
                return .send(.saveInteraction)

            case let .commentTextChanged(text):
                state.commentText = text
                return .none

            case .shareTapped:
                state.interaction.shareCount += 1
                return .send(.saveInteraction)

            case .saveInteraction:
                return .run { [interaction = state.interaction, storageClient] _ in
                    var interactions = storageClient.loadInteractions()
                    interactions[interaction.postId] = interaction
                    storageClient.saveInteractions(interactions)
                }
            }
        }
    }
}

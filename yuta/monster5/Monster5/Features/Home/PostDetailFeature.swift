import Foundation
import ComposableArchitecture

@Reducer
struct PostDetailFeature {

    @ObservableState
    struct State: Equatable {
        let post: Post
        var interaction: PostInteraction
        var commentText = ""
        var shouldFocusComment = false
    }

    enum Action: Equatable {
        case toggleLike
        case commentTextChanged(String)
        case submitComment
        case shareTapped
        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case interactionUpdated(postId: Int, interaction: PostInteraction)
            case shareRequested(title: String, body: String)
        }
    }

    @Dependency(\.uuid) var uuid
    @Dependency(\.date) var date

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .toggleLike:
                state.interaction.isLiked.toggle()
                state.interaction.likeCount += state.interaction.isLiked ? 1 : -1
                return .send(.delegate(.interactionUpdated(
                    postId: state.post.id,
                    interaction: state.interaction
                )))

            case .commentTextChanged(let text):
                state.commentText = text
                return .none

            case .submitComment:
                let trimmed = state.commentText.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty else { return .none }
                let comment = Comment(
                    id: uuid(),
                    text: trimmed,
                    createdAt: date.now
                )
                state.interaction.comments.insert(comment, at: 0)
                state.commentText = ""
                return .send(.delegate(.interactionUpdated(
                    postId: state.post.id,
                    interaction: state.interaction
                )))

            case .shareTapped:
                state.interaction.shareCount += 1
                return .merge(
                    .send(.delegate(.interactionUpdated(
                        postId: state.post.id,
                        interaction: state.interaction
                    ))),
                    .send(.delegate(.shareRequested(
                        title: state.post.title,
                        body: state.post.body
                    )))
                )

            case .delegate:
                return .none
            }
        }
    }
}

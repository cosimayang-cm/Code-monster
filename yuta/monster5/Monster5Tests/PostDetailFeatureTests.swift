import XCTest
import ComposableArchitecture
@testable import Monster5

@MainActor
final class PostDetailFeatureTests: XCTestCase {

    private let testPost = Post(userId: 1, id: 1, title: "Test Title", body: "Test Body")

    func testToggleLikeOn() async {
        let store = TestStore(
            initialState: PostDetailFeature.State(post: testPost, interaction: PostInteraction())
        ) {
            PostDetailFeature()
        }

        await store.send(.toggleLike) {
            $0.interaction.isLiked = true
            $0.interaction.likeCount = 1
        }

        await store.receive(.delegate(.interactionUpdated(
            postId: 1,
            interaction: PostInteraction(isLiked: true, likeCount: 1)
        )))
    }

    func testToggleLikeOff() async {
        let store = TestStore(
            initialState: PostDetailFeature.State(
                post: testPost,
                interaction: PostInteraction(isLiked: true, likeCount: 1)
            )
        ) {
            PostDetailFeature()
        }

        await store.send(.toggleLike) {
            $0.interaction.isLiked = false
            $0.interaction.likeCount = 0
        }

        await store.receive(.delegate(.interactionUpdated(
            postId: 1,
            interaction: PostInteraction(isLiked: false, likeCount: 0)
        )))
    }

    func testCommentTextChanged() async {
        let store = TestStore(
            initialState: PostDetailFeature.State(post: testPost, interaction: PostInteraction())
        ) {
            PostDetailFeature()
        }

        await store.send(.commentTextChanged("Hello")) {
            $0.commentText = "Hello"
        }
    }

    func testSubmitComment() async {
        let testUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let testDate = Date(timeIntervalSince1970: 1000)

        let store = TestStore(
            initialState: PostDetailFeature.State(
                post: testPost,
                interaction: PostInteraction(),
                commentText: "Nice post!"
            )
        ) {
            PostDetailFeature()
        } withDependencies: {
            $0.uuid = .constant(testUUID)
            $0.date = .constant(testDate)
        }

        let expectedComment = Comment(id: testUUID, text: "Nice post!", createdAt: testDate)

        await store.send(.submitComment) {
            $0.interaction.comments = [expectedComment]
            $0.commentText = ""
        }

        await store.receive(.delegate(.interactionUpdated(
            postId: 1,
            interaction: PostInteraction(comments: [expectedComment])
        )))
    }

    func testSubmitEmptyComment() async {
        let store = TestStore(
            initialState: PostDetailFeature.State(
                post: testPost,
                interaction: PostInteraction(),
                commentText: "   "
            )
        ) {
            PostDetailFeature()
        }

        await store.send(.submitComment)
    }

    func testShareTapped() async {
        let store = TestStore(
            initialState: PostDetailFeature.State(post: testPost, interaction: PostInteraction())
        ) {
            PostDetailFeature()
        }

        await store.send(.shareTapped) {
            $0.interaction.shareCount = 1
        }

        await store.receive(.delegate(.interactionUpdated(
            postId: 1,
            interaction: PostInteraction(shareCount: 1)
        )))

        await store.receive(.delegate(.shareRequested(
            title: "Test Title",
            body: "Test Body"
        )))
    }
}

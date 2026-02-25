import XCTest
import ComposableArchitecture
@testable import Monster5

@MainActor
final class HomeFeatureTests: XCTestCase {

    private let testPosts = [
        Post(userId: 1, id: 1, title: "First", body: "Body 1"),
        Post(userId: 1, id: 2, title: "Second", body: "Body 2"),
    ]

    func testOnAppearFetchesPosts() async {
        let posts = testPosts
        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.postsClient.fetchPosts = { posts }
            $0.storageClient.loadInteractions = { [:] }
        }

        await store.send(.onAppear) {
            $0.hasLoadedPosts = true
            $0.isLoading = true
        }

        await store.receive(\.postsResponse) {
            $0.isLoading = false
            $0.posts = IdentifiedArray(uniqueElements: posts)
        }
    }

    func testOnAppearDoesNotRefetch() async {
        let store = TestStore(
            initialState: HomeFeature.State(hasLoadedPosts: true)
        ) {
            HomeFeature()
        }

        await store.send(.onAppear)
    }

    func testOnAppearLoadsStoredInteractions() async {
        let posts = testPosts
        let storedInteractions: [Int: PostInteraction] = [
            1: PostInteraction(isLiked: true, likeCount: 1)
        ]

        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.postsClient.fetchPosts = { posts }
            $0.storageClient.loadInteractions = { storedInteractions }
        }

        await store.send(.onAppear) {
            $0.hasLoadedPosts = true
            $0.isLoading = true
            $0.interactions = storedInteractions
        }

        await store.receive(\.postsResponse) {
            $0.isLoading = false
            $0.posts = IdentifiedArray(uniqueElements: posts)
        }
    }

    func testPostTappedPushesDetail() async {
        let post = testPosts[0]
        let store = TestStore(
            initialState: HomeFeature.State(
                posts: IdentifiedArray(uniqueElements: testPosts)
            )
        ) {
            HomeFeature()
        }

        await store.send(.postTapped(post)) {
            $0.path.append(.postDetail(PostDetailFeature.State(
                post: post,
                interaction: PostInteraction(),
                shouldFocusComment: false
            )))
        }
    }

    func testCommentTappedPushesDetailWithFocus() async {
        let post = testPosts[0]
        let store = TestStore(
            initialState: HomeFeature.State(
                posts: IdentifiedArray(uniqueElements: testPosts)
            )
        ) {
            HomeFeature()
        }

        await store.send(.commentTapped(post)) {
            $0.path.append(.postDetail(PostDetailFeature.State(
                post: post,
                interaction: PostInteraction(),
                shouldFocusComment: true
            )))
        }
    }

    func testDelegateInteractionUpdatedSyncsAndSaves() async {
        let post = testPosts[0]
        let updatedInteraction = PostInteraction(isLiked: true, likeCount: 1)

        var state = HomeFeature.State(
            posts: IdentifiedArray(uniqueElements: testPosts)
        )
        state.path.append(.postDetail(PostDetailFeature.State(
            post: post,
            interaction: PostInteraction()
        )))

        let store = TestStore(initialState: state) {
            HomeFeature()
        } withDependencies: {
            $0.storageClient.saveInteractions = { _ in }
        }

        let pathID = store.state.path.ids.first!

        await store.send(.path(.element(id: pathID, action: .postDetail(.delegate(.interactionUpdated(
            postId: 1,
            interaction: updatedInteraction
        )))))) {
            $0.interactions[1] = updatedInteraction
        }
    }

    func testPostsResponseFailure() async {
        let error = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Network error"])

        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.postsClient.fetchPosts = { throw error }
            $0.storageClient.loadInteractions = { [:] }
        }

        await store.send(.onAppear) {
            $0.hasLoadedPosts = true
            $0.isLoading = true
        }

        await store.receive(\.postsResponse) {
            $0.isLoading = false
            $0.errorMessage = "Network error"
        }
    }
}

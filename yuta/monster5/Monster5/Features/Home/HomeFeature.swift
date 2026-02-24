import Foundation
import ComposableArchitecture

@Reducer
struct HomeFeature {

    @ObservableState
    struct State: Equatable {
        var posts: IdentifiedArrayOf<Post> = []
        var interactions: [Int: PostInteraction] = [:]
        var isLoading = false
        var errorMessage: String?
        var path = StackState<Path.State>()
        var hasLoadedPosts = false

        static func == (lhs: State, rhs: State) -> Bool {
            lhs.posts == rhs.posts
            && lhs.interactions == rhs.interactions
            && lhs.isLoading == rhs.isLoading
            && lhs.errorMessage == rhs.errorMessage
            && lhs.hasLoadedPosts == rhs.hasLoadedPosts
            && lhs.path.ids == rhs.path.ids
        }
    }

    enum Action {
        case onAppear
        case postsResponse(Result<[Post], NSError>)
        case postTapped(Post)
        case commentTapped(Post)
        case path(StackActionOf<Path>)
    }

    @Reducer
    enum Path {
        case postDetail(PostDetailFeature)
    }

    @Dependency(\.postsClient) var postsClient
    @Dependency(\.storageClient) var storageClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard !state.hasLoadedPosts else { return .none }
                state.hasLoadedPosts = true
                state.isLoading = true
                state.interactions = storageClient.loadInteractions()
                return .run { send in
                    let result: Result<[Post], NSError>
                    do {
                        let posts = try await postsClient.fetchPosts()
                        result = .success(posts)
                    } catch {
                        result = .failure(error as NSError)
                    }
                    await send(.postsResponse(result))
                }

            case .postsResponse(.success(let posts)):
                state.isLoading = false
                state.posts = IdentifiedArray(uniqueElements: posts)
                return .none

            case .postsResponse(.failure(let error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none

            case .postTapped(let post):
                let interaction = state.interactions[post.id] ?? PostInteraction()
                state.path.append(.postDetail(PostDetailFeature.State(
                    post: post,
                    interaction: interaction,
                    shouldFocusComment: false
                )))
                return .none

            case .commentTapped(let post):
                let interaction = state.interactions[post.id] ?? PostInteraction()
                state.path.append(.postDetail(PostDetailFeature.State(
                    post: post,
                    interaction: interaction,
                    shouldFocusComment: true
                )))
                return .none

            case .path(.element(_, action: .postDetail(.delegate(.interactionUpdated(let postId, let interaction))))):
                state.interactions[postId] = interaction
                let interactions = state.interactions
                return .run { _ in
                    storageClient.saveInteractions(interactions)
                }

            case .path(.element(_, action: .postDetail(.delegate(.shareRequested)))):
                return .none

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

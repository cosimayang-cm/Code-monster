//
//  AppFeature.swift
//  CodeMonster - Monster 5: TCA + UIKit Integration
//
//  Created by Claude on 2026-02-10.
//

import ComposableArchitecture
import Foundation

/// Root app feature managing navigation flow
@Reducer
struct AppFeature {

    // MARK: - State

    @ObservableState
    struct State: Equatable {
        var login = LoginFeature.State()
        var path = StackState<Path.State>()
    }

    // MARK: - Action

    enum Action {
        case login(LoginFeature.Action)
        case path(StackActionOf<Path>)
    }

    // MARK: - Body

    var body: some ReducerOf<Self> {
        Scope(state: \.login, action: \.login) {
            LoginFeature()
        }

        Reduce { state, action in
            switch action {
            case .login(.loginResponse(.success)):
                // Navigate to posts list on successful login
                state.path.append(.postsList(PostsListFeature.State()))
                return .none

            case .login:
                return .none

            case let .path(.element(id: postsListId, action: .postsList(.postTapped(postWithInteraction)))):
                // Navigate to post detail when post is tapped
                state.path.append(.postDetail(PostDetailFeature.State(
                    post: postWithInteraction.post,
                    interaction: postWithInteraction.interaction
                )))
                return .none

            case let .path(.element(id: detailId, action: .postDetail(.likeTapped))),
                 let .path(.element(id: detailId, action: .postDetail(.commentTapped))),
                 let .path(.element(id: detailId, action: .postDetail(.shareTapped))):
                // Sync interaction changes from detail back to posts list
                guard let detailState = state.path[id: detailId, case: \.postDetail] else {
                    return .none
                }

                // Find the posts list in the path (should be one level before detail)
                if detailId > 0,
                   let postsListId = state.path.ids.dropLast().last,
                   state.path[id: postsListId, case: \.postsList] != nil {
                    return .send(.path(.element(id: postsListId, action: .postsList(.updateInteraction(detailState.interaction)))))
                }
                return .none

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path) {
            Path()
        }
    }

    // MARK: - Path Reducer

    @Reducer
    enum Path {
        case postsList(PostsListFeature)
        case postDetail(PostDetailFeature)
    }
}

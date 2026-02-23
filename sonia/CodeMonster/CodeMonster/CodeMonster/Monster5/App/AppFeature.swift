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
        var postsList = PostsListFeature.State()
        var postDetail: PostDetailFeature.State?
        var isLoggedIn = false
    }

    // MARK: - Action

    enum Action {
        case login(LoginFeature.Action)
        case postsList(PostsListFeature.Action)
        case postDetail(PostDetailFeature.Action)
        case dismissPostDetail
    }

    // MARK: - Body

    var body: some ReducerOf<Self> {
        Scope(state: \.login, action: \.login) {
            LoginFeature()
        }

        Scope(state: \.postsList, action: \.postsList) {
            PostsListFeature()
        }

        Reduce { state, action in
            switch action {
            case .login(.loginResponse(.success)):
                state.isLoggedIn = true
                return .none

            case .login:
                return .none

            case let .postsList(.postTapped(postWithInteraction)):
                state.postDetail = PostDetailFeature.State(
                    post: postWithInteraction.post,
                    interaction: postWithInteraction.interaction
                )
                return .none

            case .postsList:
                return .none

            case .postDetail(.likeTapped),
                 .postDetail(.commentTapped),
                 .postDetail(.shareTapped):
                // Sync interaction from detail back to posts list
                // PostDetailFeature (ifLet) runs before this Reduce,
                // so state.postDetail already has the updated interaction
                if let interaction = state.postDetail?.interaction {
                    return .send(.postsList(.updateInteraction(interaction)))
                }
                return .none

            case .postDetail:
                return .none

            case .dismissPostDetail:
                // Final sync on back navigation
                if let interaction = state.postDetail?.interaction {
                    state.postDetail = nil
                    return .send(.postsList(.updateInteraction(interaction)))
                }
                state.postDetail = nil
                return .none
            }
        }
        .ifLet(\.postDetail, action: \.postDetail) {
            PostDetailFeature()
        }
    }
}

//
//  AppFeature.swift
//  CarSystem
//
//  Monster5 - TCA + UIKit 整合實戰
//

import ComposableArchitecture
import Foundation

@Reducer
struct Monster5AppFeature {
    @ObservableState
    struct State: Equatable {
        var login = LoginFeature.State()
        var posts: PostsFeature.State?
    }

    enum Action {
        case login(LoginFeature.Action)
        case posts(PostsFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.login, action: \.login) {
            LoginFeature()
        }
        Reduce { state, action in
            switch action {
            case .login(.loginResponse(.success)):
                // 登入成功 → 建立 PostsFeature State
                state.posts = PostsFeature.State()
                return .none

            default:
                return .none
            }
        }
        .ifLet(\.posts, action: \.posts) {
            PostsFeature()
        }
    }
}

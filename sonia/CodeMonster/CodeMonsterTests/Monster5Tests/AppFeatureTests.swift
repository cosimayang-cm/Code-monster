//
//  AppFeatureTests.swift
//  CodeMonster - Monster 5: TCA + UIKit Integration
//
//  Created by Claude on 2026-02-10.
//

import XCTest
import ComposableArchitecture
@testable import CodeMonster

@MainActor
final class AppFeatureTests: XCTestCase {

    // MARK: - T031

    func testPostsListWhenDetailInteractionChangedThenListSyncs() async {
        let samplePost = Post(userId: 1, id: 1, title: "Test Post", body: "Test Body")
        let initialInteraction = PostInteraction(postId: 1, isLiked: false, likeCount: 0, commentCount: 0, shareCount: 0)

        let store = TestStore(
            initialState: AppFeature.State(
                path: StackState([
                    .postsList(PostsListFeature.State(
                        posts: IdentifiedArrayOf(uniqueElements: [
                            PostWithInteraction(post: samplePost, interaction: initialInteraction)
                        ])
                    )),
                    .postDetail(PostDetailFeature.State(
                        post: samplePost,
                        interaction: initialInteraction
                    ))
                ])
            )
        ) {
            AppFeature()
        } withDependencies: {
            $0.storageClient.saveInteraction = { _ in }
        }

        // When detail interaction changes (like tapped)
        await store.send(\.path[id: 1].postDetail.likeTapped) {
            $0.path[id: 1, case: \.postDetail]?.interaction.isLiked = true
            $0.path[id: 1, case: \.postDetail]?.interaction.likeCount = 1
        }

        // Then list should sync
        await store.receive(\.path[id: 0].postsList.updateInteraction) {
            $0.path[id: 0, case: \.postsList]?.posts[id: 1]?.interaction.isLiked = true
            $0.path[id: 0, case: \.postsList]?.posts[id: 1]?.interaction.likeCount = 1
        }
    }
}

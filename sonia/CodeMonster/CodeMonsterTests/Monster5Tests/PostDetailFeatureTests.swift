//
//  PostDetailFeatureTests.swift
//  CodeMonster - Monster 5: TCA + UIKit Integration
//
//  Created by Claude on 2026-02-10.
//

import XCTest
import ComposableArchitecture
@testable import CodeMonster

@MainActor
final class PostDetailFeatureTests: XCTestCase {

    // MARK: - T028

    func testPostDetailWhenLikeTappedThenTogglesLikeState() async {
        // Test Unlike → Like
        let store = TestStore(
            initialState: PostDetailFeature.State(
                post: Post(userId: 1, id: 1, title: "Test", body: "Body"),
                interaction: PostInteraction(postId: 1, isLiked: false, likeCount: 0, commentCount: 0, shareCount: 0)
            )
        ) {
            PostDetailFeature()
        } withDependencies: {
            $0.storageClient.saveInteraction = { _ in }
        }

        await store.send(.likeTapped) {
            $0.interaction.isLiked = true
            $0.interaction.likeCount = 1
        }

        // Test Like → Unlike
        await store.send(.likeTapped) {
            $0.interaction.isLiked = false
            $0.interaction.likeCount = 0
        }
    }

    // MARK: - T029

    func testPostDetailWhenCommentTappedThenIncrementsCount() async {
        let store = TestStore(
            initialState: PostDetailFeature.State(
                post: Post(userId: 1, id: 1, title: "Test", body: "Body"),
                interaction: PostInteraction(postId: 1, isLiked: false, likeCount: 0, commentCount: 0, shareCount: 0)
            )
        ) {
            PostDetailFeature()
        } withDependencies: {
            $0.storageClient.saveInteraction = { _ in }
        }

        await store.send(.commentTapped) {
            $0.interaction.commentCount = 1
        }

        await store.send(.commentTapped) {
            $0.interaction.commentCount = 2
        }
    }

    // MARK: - T030

    func testPostDetailWhenShareTappedThenIncrementsCount() async {
        let store = TestStore(
            initialState: PostDetailFeature.State(
                post: Post(userId: 1, id: 1, title: "Test", body: "Body"),
                interaction: PostInteraction(postId: 1, isLiked: false, likeCount: 0, commentCount: 0, shareCount: 0)
            )
        ) {
            PostDetailFeature()
        } withDependencies: {
            $0.storageClient.saveInteraction = { _ in }
        }

        await store.send(.shareTapped) {
            $0.interaction.shareCount = 1
        }

        await store.send(.shareTapped) {
            $0.interaction.shareCount = 2
        }
    }
}

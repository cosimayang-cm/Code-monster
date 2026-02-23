//
//  PostsListFeatureTests.swift
//  CodeMonster - Monster 5: TCA + UIKit Integration
//
//  Created by Claude on 2026-02-10.
//

import XCTest
import ComposableArchitecture
@testable import CodeMonster

@MainActor
final class PostsListFeatureTests: XCTestCase {

    // MARK: - T020

    func testPostsListWhenOnAppearThenFetchesPosts() async {
        let samplePosts = [
            Post(userId: 1, id: 1, title: "Post 1", body: "Body 1"),
            Post(userId: 1, id: 2, title: "Post 2", body: "Body 2")
        ]

        let store = TestStore(initialState: PostsListFeature.State()) {
            PostsListFeature()
        } withDependencies: {
            $0.postsClient.fetchPosts = { samplePosts }
            $0.storageClient.loadAllInteractions = { [:] }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
            $0.errorMessage = nil
        }

        await store.receive(\.postsResponse.success) {
            $0.isLoading = false
            $0.posts = IdentifiedArrayOf(uniqueElements: samplePosts.map { post in
                PostWithInteraction(
                    post: post,
                    interaction: PostInteraction(postId: post.id)
                )
            })
        }
    }

    // MARK: - T021

    func testPostsListWhenFetchFailsThenShowsError() async {
        let store = TestStore(initialState: PostsListFeature.State()) {
            PostsListFeature()
        } withDependencies: {
            $0.postsClient.fetchPosts = { throw PostsError.fetchFailed }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
            $0.errorMessage = nil
        }

        await store.receive(\.postsResponse.failure) {
            $0.isLoading = false
            $0.errorMessage = "Failed to load posts"
        }
    }

    // MARK: - T022

    func testPostsListWhenRetryTappedThenRefetches() async {
        let samplePosts = [
            Post(userId: 1, id: 1, title: "Post 1", body: "Body 1")
        ]

        let store = TestStore(
            initialState: PostsListFeature.State(
                isLoading: false,
                errorMessage: "Previous error"
            )
        ) {
            PostsListFeature()
        } withDependencies: {
            $0.postsClient.fetchPosts = { samplePosts }
            $0.storageClient.loadAllInteractions = { [:] }
        }

        await store.send(.retryTapped) {
            $0.errorMessage = nil
            $0.isLoading = true
        }

        await store.receive(\.postsResponse.success) {
            $0.isLoading = false
            $0.posts = IdentifiedArrayOf(uniqueElements: samplePosts.map { post in
                PostWithInteraction(
                    post: post,
                    interaction: PostInteraction(postId: post.id)
                )
            })
        }
    }

    // MARK: - T039

    func testPostsListWhenOnAppearThenLoadsStoredInteractions() async {
        let samplePosts = [
            Post(userId: 1, id: 1, title: "Post 1", body: "Body 1"),
            Post(userId: 1, id: 2, title: "Post 2", body: "Body 2")
        ]

        let storedInteractions: [Int: PostInteraction] = [
            1: PostInteraction(postId: 1, isLiked: true, likeCount: 5, commentCount: 2, shareCount: 1),
            2: PostInteraction(postId: 2, isLiked: false, likeCount: 0, commentCount: 0, shareCount: 0)
        ]

        let store = TestStore(initialState: PostsListFeature.State()) {
            PostsListFeature()
        } withDependencies: {
            $0.postsClient.fetchPosts = { samplePosts }
            $0.storageClient.loadAllInteractions = { storedInteractions }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
            $0.errorMessage = nil
        }

        await store.receive(\.postsResponse.success) {
            $0.isLoading = false
            $0.posts = IdentifiedArrayOf(uniqueElements: [
                PostWithInteraction(
                    post: samplePosts[0],
                    interaction: storedInteractions[1]!
                ),
                PostWithInteraction(
                    post: samplePosts[1],
                    interaction: storedInteractions[2]!
                )
            ])
        }
    }
}

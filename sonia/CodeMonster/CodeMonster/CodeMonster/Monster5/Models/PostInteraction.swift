//
//  PostInteraction.swift
//  CodeMonster - Monster 5: TCA + UIKit Integration
//
//  Created by Claude on 2026-02-10.
//

import Foundation

/// User interaction state for a single post (likes, comments, shares)
struct PostInteraction: Codable, Equatable, Sendable {
    let postId: Int
    var isLiked: Bool = false
    var likeCount: Int = 0
    var commentCount: Int = 0
    var shareCount: Int = 0
}

/// Composite model combining post content with interaction state
struct PostWithInteraction: Equatable, Identifiable, Sendable {
    let post: Post
    var interaction: PostInteraction

    var id: Int { post.id }
}

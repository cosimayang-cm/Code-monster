//
//  PostInteraction.swift
//  CarSystem
//
//  Monster5 - TCA + UIKit 整合實戰
//

import Foundation

/// 每篇文章的互動數據，儲存在 Local Storage
struct PostInteraction: Codable, Equatable, Sendable {
    var postId: Int
    var likeCount: Int
    var isLiked: Bool
    var comments: [PostComment]
    var shareCount: Int

    /// 建立空的互動數據
    static func empty(for postId: Int) -> PostInteraction {
        PostInteraction(
            postId: postId,
            likeCount: 0,
            isLiked: false,
            comments: [],
            shareCount: 0
        )
    }
}

/// 互動數據儲存容器，用於 JSON 序列化到 UserDefaults
struct PostInteractionStore: Codable, Equatable, Sendable {
    var interactions: [Int: PostInteraction]
}

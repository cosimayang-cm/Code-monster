//
//  PostComment.swift
//  CarSystem
//
//  Monster5 - TCA + UIKit 整合實戰
//

import Foundation

/// 使用者留言資料
struct PostComment: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    let postId: Int
    let content: String
    let createdAt: Date

    init(postId: Int, content: String) {
        self.id = UUID()
        self.postId = postId
        self.content = content
        self.createdAt = Date()
    }

    init(id: UUID, postId: Int, content: String, createdAt: Date) {
        self.id = id
        self.postId = postId
        self.content = content
        self.createdAt = createdAt
    }
}

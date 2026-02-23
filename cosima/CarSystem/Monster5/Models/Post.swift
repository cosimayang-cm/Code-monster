//
//  Post.swift
//  CarSystem
//
//  Monster5 - TCA + UIKit 整合實戰
//

import Foundation

/// 文章列表 API 回傳的文章資料
struct Post: Codable, Equatable, Identifiable, Sendable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

// MARK: - Mock

extension Post {
    static let mock = Post(
        userId: 1,
        id: 1,
        title: "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
        body: "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"
    )

    static let mockList: [Post] = [
        Post(userId: 1, id: 1, title: "Test Post 1", body: "Body of test post 1"),
        Post(userId: 1, id: 2, title: "Test Post 2", body: "Body of test post 2"),
        Post(userId: 2, id: 3, title: "Test Post 3", body: "Body of test post 3"),
    ]
}

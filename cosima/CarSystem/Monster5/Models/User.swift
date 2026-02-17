//
//  User.swift
//  CarSystem
//
//  Monster5 - TCA + UIKit 整合實戰
//

import Foundation

/// 登入成功後 API 回傳的用戶資訊
struct User: Codable, Equatable, Sendable {
    let id: Int
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let gender: String
    let image: String
    let accessToken: String
    let refreshToken: String
}

// MARK: - Mock

extension User {
    static let mock = User(
        id: 1,
        username: "emilys",
        email: "emily.johnson@x.dummyjson.com",
        firstName: "Emily",
        lastName: "Johnson",
        gender: "female",
        image: "https://dummyjson.com/icon/emilys/128",
        accessToken: "mock-access-token",
        refreshToken: "mock-refresh-token"
    )
}

//
//  User.swift
//  CodeMonster - Monster 5: TCA + UIKit Integration
//
//  Created by Claude on 2026-02-10.
//

import Foundation

/// Response model from successful login API call
struct LoginResponse: Codable, Equatable, Sendable {
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

/// Error response from failed login API call
struct LoginErrorResponse: Codable, Sendable {
    let message: String
}

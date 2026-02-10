//
//  Post.swift
//  CodeMonster - Monster 5: TCA + UIKit Integration
//
//  Created by Claude on 2026-02-10.
//

import Foundation

/// Post model from JSONPlaceholder API
struct Post: Codable, Equatable, Identifiable, Sendable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

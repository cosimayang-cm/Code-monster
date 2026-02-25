import Foundation

struct Post: Equatable, Codable, Sendable, Identifiable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

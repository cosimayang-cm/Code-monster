import Foundation

struct Comment: Equatable, Codable, Sendable, Identifiable {
    let id: UUID
    let text: String
    let createdAt: Date
}

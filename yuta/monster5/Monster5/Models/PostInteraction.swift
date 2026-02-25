import Foundation

struct PostInteraction: Equatable, Codable, Sendable {
    var isLiked: Bool = false
    var likeCount: Int = 0
    var comments: [Comment] = []
    var shareCount: Int = 0

    var commentCount: Int { comments.count }
}

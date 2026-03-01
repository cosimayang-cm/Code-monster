import Foundation

// MARK: - ReversiMove
// 黑白棋走步（row/col 0-indexed）。

struct ReversiMove: Equatable {
    let row: Int  // 0...7
    let col: Int  // 0...7
}

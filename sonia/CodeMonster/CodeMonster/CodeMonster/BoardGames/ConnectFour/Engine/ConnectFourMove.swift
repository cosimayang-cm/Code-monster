import Foundation

// MARK: - ConnectFourMove
// 四子棋走步：選擇一欄投入棋子（0-indexed）。

struct ConnectFourMove: Equatable {
    /// 0-indexed 欄號（0...6）
    let column: Int
}

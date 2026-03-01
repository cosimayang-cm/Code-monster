import Foundation

// MARK: - ReversiRenderer
// 黑白棋 console 渲染：* 標記可下位置，顯示翻轉數量，顯示黑白子數。
// TODO: T4-5 實作

struct ReversiRenderer: BoardRenderer {
    let game: ReversiGame

    func render() -> String {
        // TODO: 輸出 spec 格式，* 標記 validMoves，顯示每格翻轉數量
        return "🎮 Reversi\n(TODO: implement renderer)"
    }
}

import Foundation

// MARK: - TicTacToeRenderer
// Console 渲染，輸出符合 spec 的棋盤字串。
// Example output:
// 🎮 Tic-Tac-Toe
// ──────────────
//   1   2   3
// ┌───┬───┬───┐
// │ ❌ │ ⭕ │   │ A
// ├───┼───┼───┤
// ...
// TODO: T2-5 實作

struct TicTacToeRenderer: BoardRenderer {
    let game: TicTacToeGame

    func render() -> String {
        // TODO: 生成完整棋盤字串
        return "🎮 Tic-Tac-Toe\n(TODO: implement renderer)"
    }
}

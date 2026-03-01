import Foundation

// MARK: - ReversiRenderer
// 黑白棋 console 渲染：* 標記共操位置，顯示黑白子數。

struct ReversiRenderer: BoardRenderer {
    let game: ReversiGame

    func render() -> String {
        let validSet = Set(game.validMoves().map { $0.row * 8 + $0.col })
        var lines: [String] = []
        lines.append("🎮 Reversi")
        lines.append(String(repeating: "─", count: 34))
        lines.append("  A   B   C   D   E   F   G   H")
        lines.append("┌───┬───┬───┬───┬───┬───┬───┬───┐")

        for r in 0..<8 {
            var row = "│"
            for c in 0..<8 {
                let key = r * 8 + c
                let cell: String
                switch game.board[r, c] {
                case .black: cell = "⚫"
                case .white: cell = "⭕"
                case .empty: cell = validSet.contains(key) ? "∗ " : "  "
                }
                row += " \(cell)│"
            }
            row += " \(r + 1)"
            lines.append(row)
            if r < 7 { lines.append("├───┼───┼───┼───┼───┼───┼───┼───┤") }
        }
        lines.append("└───┴───┴───┴───┴───┴───┴───┴───┘")

        let black = game.board.count(for: .human)
        let white = game.board.count(for: .ai)
        lines.append("⚫ \(black)  ⭕ \(white)")

        switch game.state {
        case .playing:
            let symbol = game.currentPlayer == .human ? "⚫" : "⭕"
            lines.append("當前: \(symbol) (\(game.currentPlayer == .human ? "You" : "AI"))")
            if game.isPassRequired() { lines.append("⚠️ No valid moves — Pass!") }
        case .won(let p):
            let symbol = p == .human ? "⚫" : "⭕"
            lines.append("🏆 \(symbol) \(p == .human ? "You win!" : "AI wins!")")
        case .draw:
            lines.append("🤝 Draw!")
        default:
            break
        }
        return lines.joined(separator: "\n")
    }
}

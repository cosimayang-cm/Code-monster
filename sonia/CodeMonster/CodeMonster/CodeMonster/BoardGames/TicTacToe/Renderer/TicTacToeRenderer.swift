import Foundation

// MARK: - TicTacToeRenderer
// Console 渲染，輸出符合 spec 的棋盤字串。

struct TicTacToeRenderer: BoardRenderer {
    let game: TicTacToeGame

    func render() -> String {
        var lines: [String] = []
        lines.append("🎮 Tic-Tac-Toe")
        lines.append(String(repeating: "─", count: 14))
        lines.append("  1   2   3")
        lines.append("┌───┬───┬───┐")

        let rowLabels = ["A", "B", "C"]
        for r in 0..<3 {
            var row = "│"
            for c in 0..<3 {
                let cell: String
                switch game.board[r, c] {
                case .human: cell = "❌"
                case .ai:    cell = "⭕"
                case nil:    cell = " "
                }
                row += " \(cell) │"
            }
            row += " \(rowLabels[r])"
            lines.append(row)
            if r < 2 { lines.append("├───┼───┼───┤") }
        }
        lines.append("└───┴───┴───┘")

        switch game.state {
        case .playing:
            let symbol = game.currentPlayer == .human ? "❌" : "⭕"
            lines.append("當前: \(symbol) (\(game.currentPlayer == .human ? "You" : "AI"))")
        case .won(let p):
            let symbol = p == .human ? "❌" : "⭕"
            lines.append("🏆 \(symbol) \(p == .human ? "You win!" : "AI wins!")")
        case .draw:
            lines.append("🤝 Draw!")
        default:
            break
        }

        return lines.joined(separator: "\n")
    }
}

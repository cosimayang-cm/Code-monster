import Foundation

// MARK: - ConnectFourRenderer
// Console 渲染，Row 0 在底部（渲染時倒序顯示使 row 5 在頂部）。

struct ConnectFourRenderer: BoardRenderer {
    let game: ConnectFourGame

    func render() -> String {
        var lines: [String] = []
        lines.append("🎮 Connect Four")
        lines.append(String(repeating: "─", count: 29))
        lines.append(" 1   2   3   4   5   6   7")
        lines.append("┌───┬───┬───┬───┬───┬───┬───┐")

        // 從頂部往底部顯示（row 5 在槽頂）
        for row in stride(from: ConnectFourBoard.rows - 1, through: 0, by: -1) {
            var line = "│"
            for col in 0..<ConnectFourBoard.cols {
                let cell: String
                switch game.board[row, col] {
                case .human: cell = "🔴"
                case .ai:    cell = "🟡"
                case nil:    cell = " "
                }
                line += " \(cell)│"
            }
            lines.append(line)
            if row > 0 { lines.append("├───┼───┼───┼───┼───┼───┼───┤") }
        }
        lines.append("└───┴───┴───┴───┴───┴───┴───┘")

        switch game.state {
        case .playing:
            let symbol = game.currentPlayer == .human ? "🔴" : "🟡"
            lines.append("當前: \(symbol) (\(game.currentPlayer == .human ? "You" : "AI"))")
        case .won(let p):
            let symbol = p == .human ? "🔴" : "🟡"
            lines.append("🏆 \(symbol) \(p == .human ? "You win!" : "AI wins!")")
        case .draw:
            lines.append("🤝 Draw!")
        default:
            break
        }
        return lines.joined(separator: "\n")
    }
}

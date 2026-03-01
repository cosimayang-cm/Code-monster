import Foundation

// MARK: - TicTacToeRenderer
// Console 渲染，輸出符合 spec 的棋盤字串。

struct TicTacToeRenderer: BoardRenderer {
    let game: TicTacToeGame
    /// 游標位置（僅人類回合顯示）
    var cursor: (row: Int, col: Int)? = nil

    func render() -> String {
        var lines: [String] = []
        lines.append("=== Tic-Tac-Toe ===")
        lines.append(String(repeating: "─", count: 14))
        lines.append("  1   2   3")
        lines.append("┌───┬───┬───┐")

        let rowLabels = ["A", "B", "C"]
        for r in 0..<3 {
            var row = "│"
            for c in 0..<3 {
                let cell: String
                switch game.board[r, c] {
                case .human: cell = "X"
                case .ai:    cell = "O"
                case nil:
                    if let cur = cursor, cur.row == r, cur.col == c {
                        cell = "+"  // 游標位置
                    } else {
                        cell = " "
                    }
                }
                row += " \(cell) │"
            }
            row += " \(rowLabels[r])"
            lines.append(row)
            if r < 2 { lines.append("├───┼───┼───┤") }
        }
        lines.append("└───┴───┴───┘")

        if let cur = cursor, game.state == .playing, game.currentPlayer == .human {
            let colLabel = ["A", "B", "C"][cur.row]
            lines.append("▸ \(colLabel)\(cur.col + 1)")
        }

        switch game.state {
        case .playing:
            let symbol = game.currentPlayer == .human ? "X" : "O"
            lines.append("Turn: [\(symbol)] \(game.currentPlayer == .human ? "You" : "AI")")
        case .won(let p):
            let symbol = p == .human ? "X" : "O"
            lines.append("*** [\(symbol)] \(p == .human ? "You win!" : "AI wins!") ***")
        case .draw:
            lines.append("*** Draw! ***")
        default:
            break
        }

        return lines.joined(separator: "\n")
    }
}

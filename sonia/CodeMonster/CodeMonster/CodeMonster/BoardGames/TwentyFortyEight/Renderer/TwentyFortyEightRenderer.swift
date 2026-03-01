import Foundation

// MARK: - TwentyFortyEightRenderer
// 2048 console 渲染：數字靠右對齊（6 字元寬），顯示分數與最大格子。

struct TwentyFortyEightRenderer: BoardRenderer {
    let game: TwentyFortyEightGame

    private static let cellWidth = 6

    func render() -> String {
        let w = Self.cellWidth
        let sep = String(repeating: "─", count: w)
        let top    = "┌" + [sep, sep, sep, sep].joined(separator: "┬") + "┐"
        let middle = "├" + [sep, sep, sep, sep].joined(separator: "┼") + "┤"
        let bottom = "└" + [sep, sep, sep, sep].joined(separator: "┴") + "┘"

        var lines = ["🎮 2048", top]
        let n = TwentyFortyEightBoard.size
        for r in 0..<n {
            let row = (0..<n).map { c -> String in
                let v = game.board[r, c]
                let s = v == 0 ? "" : "\(v)"
                return "│" + String(repeating: " ", count: w - s.count) + s
            }.joined() + "│"
            lines.append(row)
            if r < n - 1 { lines.append(middle) }
        }
        lines.append(bottom)

        let formatted = NumberFormatter.localizedString(from: NSNumber(value: game.score), number: .decimal)
        lines.append("Score: \(formatted)  Max: \(game.board.maxTile)")

        switch game.state {
        case .wonCanContinue: lines.append("🏆 You reached 2048! Keep going!")
        case .draw:           lines.append("💀 No moves left. Game over!")
        default: break
        }
        return lines.joined(separator: "\n")
    }
}

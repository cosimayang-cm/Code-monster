import Foundation

struct ConnectFourRenderer: RendererProtocol {
    func render(_ board: ConnectFourBoard) -> String {
        var lines: [String] = []
        lines.append("Connect Four")
        lines.append("─────────────────────────")
        lines.append("  1   2   3   4   5   6   7")
        lines.append("┌───┬───┬───┬───┬───┬───┬───┐")

        let rows = ConnectFourBoard.rows
        let cols = ConnectFourBoard.cols

        for r in 0..<rows {
            let rowLabel = rows - r
            let cells = (0..<cols).map { c -> String in
                switch board.cells[r][c] {
                case .playerOne: return " R "
                case .playerTwo: return " Y "
                case .none: return "   "
                }
            }
            lines.append("│\(cells.joined(separator: "│"))│ \(rowLabel)")
            if r < rows - 1 {
                lines.append("├───┼───┼───┼───┼───┼───┼───┤")
            }
        }
        lines.append("└───┴───┴───┴───┴───┴───┴───┘")
        return lines.joined(separator: "\n")
    }
}

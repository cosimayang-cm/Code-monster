import Foundation

struct TicTacToeRenderer: RendererProtocol {
    func render(_ board: TicTacToeBoard) -> String {
        var lines: [String] = []
        lines.append("Tic-Tac-Toe")
        lines.append("──────────────")
        lines.append("  1   2   3  ")
        lines.append("┌───┬───┬───┐")

        let rowLabels = ["A", "B", "C"]
        for (rowIdx, row) in board.cells.enumerated() {
            let cells = row.map { player -> String in
                switch player {
                case .playerOne: return " X "
                case .playerTwo: return " O "
                case .none: return "   "
                }
            }
            lines.append("│\(cells[0])│\(cells[1])│\(cells[2])│ \(rowLabels[rowIdx])")
            if rowIdx < 2 {
                lines.append("├───┼───┼───┤")
            }
        }
        lines.append("└───┴───┴───┘")
        return lines.joined(separator: "\n")
    }
}

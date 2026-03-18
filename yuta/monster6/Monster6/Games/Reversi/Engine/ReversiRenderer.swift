import Foundation

struct ReversiRenderer: RendererProtocol {
    func render(_ board: ReversiBoard, validMoves: [(Int, Int)] = [], flipCounts: [String: Int] = [:]) -> String {
        var lines: [String] = []
        let size = ReversiBoard.size
        let colLabels = (1...size).map { "\($0)" }.joined(separator: "   ")

        lines.append("Reversi")
        lines.append("──────────────────────────────")
        lines.append("    \(colLabels)")
        lines.append("  ┌───\(String(repeating: "┬───", count: size - 1))┐")

        let rowLetters = ["A","B","C","D","E","F","G","H"]
        for r in 0..<size {
            var cells: [String] = []
            for c in 0..<size {
                if validMoves.contains(where: { $0 == r && $1 == c }) {
                    cells.append(" * ")
                } else {
                    switch board.cells[r][c] {
                    case .playerOne: cells.append(" B ")
                    case .playerTwo: cells.append(" W ")
                    case .none: cells.append("   ")
                    }
                }
            }
            lines.append("\(rowLetters[r]) │\(cells.joined(separator: "│"))│")
            if r < size - 1 {
                lines.append("  ├───\(String(repeating: "┼───", count: size - 1))┤")
            }
        }
        lines.append("  └───\(String(repeating: "┴───", count: size - 1))┘")

        let black = board.count(for: .playerOne)
        let white = board.count(for: .playerTwo)
        lines.append("\nBlack: \(black)  |  White: \(white)")

        if !validMoves.isEmpty {
            lines.append("* = valid moves (\(validMoves.count) available)")
        }
        return lines.joined(separator: "\n")
    }

    func render(_ board: ReversiBoard) -> String {
        render(board, validMoves: [], flipCounts: [:])
    }
}

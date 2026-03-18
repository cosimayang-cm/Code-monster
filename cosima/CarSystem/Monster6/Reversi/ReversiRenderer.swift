//
//  ReversiRenderer.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import Foundation

struct ReversiRenderer: GameRenderer {
    typealias Board = ReversiBoard

    func render(board: ReversiBoard, state: GameState) -> String {
        var lines: [String] = []
        let validMoves = board.legalMoves()
        let validPositions = Set(validMoves.map { "\($0.row),\($0.col)" })

        // Title
        lines.append("🎮 Reversi")
        lines.append("──────────────────────────────")

        // Column headers
        lines.append("    1   2   3   4   5   6   7   8")

        // Board grid
        let rowLabels = ["A", "B", "C", "D", "E", "F", "G", "H"]
        lines.append("  ┌───┬───┬───┬───┬───┬───┬───┬───┐")

        for row in 0..<ReversiBoard.size {
            let cells = (0..<ReversiBoard.size).map { col -> String in
                let key = "\(row),\(col)"
                if validPositions.contains(key) {
                    return "*"
                }
                return cellSymbol(board.cells[row][col])
            }
            let rowStr = "\(rowLabels[row]) │ " + cells.joined(separator: " │ ") + " │"
            lines.append(rowStr)

            if row < ReversiBoard.size - 1 {
                lines.append("  ├───┼───┼───┼───┼───┼───┼───┼───┤")
            }
        }

        lines.append("  └───┴───┴───┴───┴───┴───┴───┴───┘")
        lines.append("")

        // Piece counts
        let (black, white) = board.pieceCounts()
        lines.append("⚫ Black: \(black)  |  ⚪ White: \(white)")

        // Valid moves info
        if !validMoves.isEmpty {
            lines.append("* = valid moves (\(validMoves.count) available)")
            let flipInfo = validMoves.map { move -> String in
                let rowLabel = String(UnicodeScalar(65 + move.row)!)
                return "\(rowLabel)\(move.col + 1)→\(move.flips.count)"
            }.joined(separator: ", ")
            lines.append("Flips: \(flipInfo)")
        }

        lines.append("")

        // Status
        switch state {
        case .idle:
            lines.append("Press Start to begin")
        case .playing(let player):
            let symbol = player == .human ? "⚫" : "⚪"
            lines.append("Player \(symbol)'s turn")
        case .gameOver(let result):
            switch result {
            case .win(let player):
                let symbol = player == .human ? "⚫" : "⚪"
                lines.append("Player \(symbol) wins! 🎉")
            case .draw:
                lines.append("It's a Draw! 🤝")
            case .lose:
                lines.append("Game Over!")
            }
        }

        return lines.joined(separator: "")
    }

    private func cellSymbol(_ cell: ReversiCellState) -> String {
        switch cell {
        case .empty: return " "
        case .black: return "⚫"
        case .white: return "⚪"
        }
    }
}

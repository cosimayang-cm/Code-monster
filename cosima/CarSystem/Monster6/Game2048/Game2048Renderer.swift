//
//  Game2048Renderer.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import Foundation

struct Game2048Renderer: GameRenderer {
    typealias Board = Game2048Board

    private let cellWidth = 5 // width for number display

    func render(board: Game2048Board, state: GameState) -> String {
        var lines: [String] = []

        // Title
        lines.append("🎮 2048")
        lines.append("──────────────────────")

        // Board grid
        let separator = "├──────┼──────┼──────┼──────┤"
        lines.append("┌──────┬──────┬──────┬──────┐")

        for row in 0..<Game2048Board.size {
            let cells = (0..<Game2048Board.size).map { col -> String in
                formatCell(board.cells[row][col])
            }
            lines.append("│\(cells.joined(separator: "│"))│")

            if row < Game2048Board.size - 1 {
                lines.append(separator)
            }
        }

        lines.append("└──────┴──────┴──────┴──────┘")
        lines.append("")

        // Score
        lines.append("Score: \(formatScore(board.score))")

        // Status
        switch state {
        case .idle:
            lines.append("Swipe: ⬆ ⬇ ⬅ ➡")
        case .playing:
            lines.append("Swipe: ⬆ ⬇ ⬅ ➡")
        case .gameOver(let result):
            switch result {
            case .win:
                lines.append("🎉 You reached 2048! Congratulations!")
            case .lose:
                lines.append("Game Over! No more moves.")
            case .draw:
                lines.append("Game Over!")
            }
        }

        return lines.joined(separator: "")
    }

    private func formatCell(_ value: Int) -> String {
        if value == 0 {
            return "      " // 6 spaces for empty
        }
        let str = String(value)
        let padding = 6 - str.count
        return String(repeating: " ", count: padding) + str // right-aligned
    }

    private func formatScore(_ score: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: score)) ?? "\(score)"
    }
}

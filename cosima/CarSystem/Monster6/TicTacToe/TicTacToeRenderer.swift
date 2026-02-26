//
//  TicTacToeRenderer.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import Foundation

struct TicTacToeRenderer: GameRenderer {
    typealias Board = TicTacToeBoard

    func render(board: TicTacToeBoard, state: GameState) -> String {
        var lines: [String] = []

        // Title
        lines.append("🎮 Tic-Tac-Toe")
        lines.append("──────────────")

        // Column headers
        lines.append("  1   2   3")

        // Board grid
        let rowLabels = ["A", "B", "C"]
        lines.append("┌───┬───┬───┐")

        for row in 0..<3 {
            let cells = (0..<3).map { col -> String in
                cellSymbol(board.cells[row * 3 + col])
            }
            lines.append("│ \(cells[0]) │ \(cells[1]) │ \(cells[2]) │ \(rowLabels[row])")

            if row < 2 {
                lines.append("├───┼───┼───┤")
            }
        }

        lines.append("└───┴───┴───┘")
        lines.append("")

        // Status message
        switch state {
        case .idle:
            lines.append("Press Start to begin")
        case .playing(let player):
            let symbol = player == .human ? "❌" : "⭕"
            lines.append("Player \(symbol)'s turn")
        case .gameOver(let result):
            switch result {
            case .win(let player):
                let symbol = player == .human ? "❌" : "⭕"
                lines.append("Player \(symbol) wins! 🎉")
            case .draw:
                lines.append("It's a Draw! 🤝")
            case .lose:
                lines.append("Game Over!")
            }
        }

        return lines.joined(separator: "")
    }

    private func cellSymbol(_ cell: TicTacToeCellState) -> String {
        switch cell {
        case .empty: return " "
        case .x:     return "❌"
        case .o:     return "⭕"
        }
    }
}

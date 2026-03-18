//
//  ConnectFourRenderer.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import Foundation

struct ConnectFourRenderer: GameRenderer {
    typealias Board = ConnectFourBoard

    func render(board: ConnectFourBoard, state: GameState) -> String {
        var lines: [String] = []
        let grid = buildGrid(from: board)

        // Title
        lines.append("🎮 Connect Four")
        lines.append("─────────────────────────")

        // Column headers
        lines.append("  1   2   3   4   5   6   7")

        // Board grid — render from top (row 5) to bottom (row 0)
        lines.append("┌───┬───┬───┬───┬───┬───┬───┐")

        for row in stride(from: ConnectFourBoard.rowCount - 1, through: 0, by: -1) {
            let cells = (0..<ConnectFourBoard.columnCount).map { col -> String in
                cellSymbol(grid[row][col])
            }
            let rowStr = cells.map { "│ \($0) " }.joined() + "│ \(row + 1)"
            lines.append(rowStr)

            if row > 0 {
                lines.append("├───┼───┼───┼───┼───┼───┼───┤")
            }
        }

        lines.append("└───┴───┴───┴───┴───┴───┴───┘")
        lines.append("")

        // Status
        switch state {
        case .idle:
            lines.append("Press Start to begin")
        case .playing(let player):
            let symbol = player == .human ? "🔴" : "🟡"
            lines.append("Player \(symbol)'s turn | Select column (1-7):")
        case .gameOver(let result):
            switch result {
            case .win(let player):
                let symbol = player == .human ? "🔴" : "🟡"
                lines.append("Player \(symbol) wins! 🎉")
            case .draw:
                lines.append("It's a Draw! 🤝")
            case .lose:
                lines.append("Game Over!")
            }
        }

        return lines.joined(separator: "")
    }

    private func buildGrid(from board: ConnectFourBoard) -> [[ConnectFourCellState]] {
        var grid = Array(repeating: Array(repeating: ConnectFourCellState.empty,
                                          count: ConnectFourBoard.columnCount),
                         count: ConnectFourBoard.rowCount)
        for col in 0..<ConnectFourBoard.columnCount {
            for (row, cell) in board.columns[col].enumerated() {
                grid[row][col] = cell
            }
        }
        return grid
    }

    private func cellSymbol(_ cell: ConnectFourCellState) -> String {
        switch cell {
        case .empty:  return " "
        case .red:    return "🔴"
        case .yellow: return "🟡"
        }
    }
}

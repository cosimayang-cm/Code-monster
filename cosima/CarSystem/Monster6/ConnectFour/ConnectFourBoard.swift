//
//  ConnectFourBoard.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import Foundation

// MARK: - Cell State

enum ConnectFourCellState: Equatable {
    case empty
    case red    // human
    case yellow // ai
}

// MARK: - ConnectFourBoard

struct ConnectFourBoard: GameBoard {
    typealias Move = ConnectFourMove

    static let columnCount = 7
    static let rowCount = 6

    var columns: [[ConnectFourCellState]]
    var currentPlayer: Player

    init(columns: [[ConnectFourCellState]] = Array(repeating: [], count: 7),
         currentPlayer: Player = .human) {
        self.columns = columns
        self.currentPlayer = currentPlayer
    }

    // MARK: - GameBoard Conformance

    var isTerminal: Bool {
        winner() != nil || legalMoves().isEmpty
    }

    func legalMoves() -> [ConnectFourMove] {
        (0..<Self.columnCount).compactMap { col in
            columns[col].count < Self.rowCount ? ConnectFourMove(column: col) : nil
        }
    }

    func applying(_ move: ConnectFourMove) -> ConnectFourBoard {
        var newColumns = columns
        let piece: ConnectFourCellState = currentPlayer == .human ? .red : .yellow
        newColumns[move.column].append(piece)
        let nextPlayer: Player = currentPlayer == .human ? .ai : .human
        return ConnectFourBoard(columns: newColumns, currentPlayer: nextPlayer)
    }

    func winner() -> Player? {
        // Build a 2D grid for easier scanning
        // grid[row][col], row 0 = bottom
        let grid = buildGrid()

        for row in 0..<Self.rowCount {
            for col in 0..<Self.columnCount {
                let cell = grid[row][col]
                guard cell != .empty else { continue }

                // Check 4 directions: right, up, up-right diagonal, up-left diagonal
                let directions = [(0, 1), (1, 0), (1, 1), (1, -1)]
                for (dr, dc) in directions {
                    if checkFour(grid: grid, row: row, col: col, dr: dr, dc: dc, cell: cell) {
                        return cell == .red ? .human : .ai
                    }
                }
            }
        }
        return nil
    }

    func evaluate(for player: Player) -> Double {
        let playerCell: ConnectFourCellState = player == .human ? .red : .yellow
        let opponentCell: ConnectFourCellState = player == .human ? .yellow : .red
        let grid = buildGrid()
        var score = 0.0

        // Center column bonus
        let centerCol = Self.columnCount / 2
        let centerCount = columns[centerCol].filter { $0 == playerCell }.count
        score += Double(centerCount) * 3

        // Scan all windows of 4
        score += evaluateWindows(grid: grid, playerCell: playerCell, opponentCell: opponentCell)

        return score
    }

    // MARK: - Private Helpers

    private func buildGrid() -> [[ConnectFourCellState]] {
        var grid = Array(repeating: Array(repeating: ConnectFourCellState.empty, count: Self.columnCount),
                         count: Self.rowCount)
        for col in 0..<Self.columnCount {
            for (row, cell) in columns[col].enumerated() {
                grid[row][col] = cell
            }
        }
        return grid
    }

    private func checkFour(grid: [[ConnectFourCellState]], row: Int, col: Int,
                           dr: Int, dc: Int, cell: ConnectFourCellState) -> Bool {
        for i in 0..<4 {
            let r = row + i * dr
            let c = col + i * dc
            guard r >= 0 && r < Self.rowCount && c >= 0 && c < Self.columnCount else { return false }
            if grid[r][c] != cell { return false }
        }
        return true
    }

    private func evaluateWindows(grid: [[ConnectFourCellState]],
                                 playerCell: ConnectFourCellState,
                                 opponentCell: ConnectFourCellState) -> Double {
        var score = 0.0
        let directions = [(0, 1), (1, 0), (1, 1), (1, -1)]

        for row in 0..<Self.rowCount {
            for col in 0..<Self.columnCount {
                for (dr, dc) in directions {
                    let window = getWindow(grid: grid, row: row, col: col, dr: dr, dc: dc)
                    guard window.count == 4 else { continue }
                    score += scoreWindow(window, playerCell: playerCell, opponentCell: opponentCell)
                }
            }
        }
        return score
    }

    private func getWindow(grid: [[ConnectFourCellState]], row: Int, col: Int,
                           dr: Int, dc: Int) -> [ConnectFourCellState] {
        var window: [ConnectFourCellState] = []
        for i in 0..<4 {
            let r = row + i * dr
            let c = col + i * dc
            guard r >= 0 && r < Self.rowCount && c >= 0 && c < Self.columnCount else { return [] }
            window.append(grid[r][c])
        }
        return window
    }

    private func scoreWindow(_ window: [ConnectFourCellState],
                             playerCell: ConnectFourCellState,
                             opponentCell: ConnectFourCellState) -> Double {
        let playerCount = window.filter { $0 == playerCell }.count
        let opponentCount = window.filter { $0 == opponentCell }.count
        let emptyCount = window.filter { $0 == .empty }.count

        if playerCount == 4 { return 100 }
        if playerCount == 3 && emptyCount == 1 { return 5 }
        if playerCount == 2 && emptyCount == 2 { return 2 }
        if opponentCount == 3 && emptyCount == 1 { return -4 }
        return 0
    }
}

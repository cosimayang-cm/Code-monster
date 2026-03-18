//
//  TicTacToeBoard.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import Foundation

// MARK: - Cell State

enum TicTacToeCellState: Equatable {
    case empty
    case x    // human
    case o    // ai
}

// MARK: - TicTacToeBoard

struct TicTacToeBoard: GameBoard {
    typealias Move = TicTacToeMove

    var cells: [TicTacToeCellState]
    var currentPlayer: Player

    init(cells: [TicTacToeCellState] = Array(repeating: .empty, count: 9),
         currentPlayer: Player = .human) {
        self.cells = cells
        self.currentPlayer = currentPlayer
    }

    // MARK: - Win Patterns

    private static let winPatterns: [[Int]] = [
        // Rows
        [0, 1, 2], [3, 4, 5], [6, 7, 8],
        // Columns
        [0, 3, 6], [1, 4, 7], [2, 5, 8],
        // Diagonals
        [0, 4, 8], [2, 4, 6]
    ]

    // MARK: - GameBoard Conformance

    var isTerminal: Bool {
        winner() != nil || legalMoves().isEmpty
    }

    func legalMoves() -> [TicTacToeMove] {
        cells.enumerated().compactMap { index, cell in
            cell == .empty ? TicTacToeMove(position: index) : nil
        }
    }

    func applying(_ move: TicTacToeMove) -> TicTacToeBoard {
        var newCells = cells
        newCells[move.position] = currentPlayer == .human ? .x : .o
        let nextPlayer: Player = currentPlayer == .human ? .ai : .human
        return TicTacToeBoard(cells: newCells, currentPlayer: nextPlayer)
    }

    func winner() -> Player? {
        for pattern in Self.winPatterns {
            let a = cells[pattern[0]]
            let b = cells[pattern[1]]
            let c = cells[pattern[2]]
            if a != .empty && a == b && b == c {
                return a == .x ? .human : .ai
            }
        }
        return nil
    }

    func evaluate(for player: Player) -> Double {
        if let w = winner() {
            return w == player ? 1000 : -1000
        }
        return 0
    }
}

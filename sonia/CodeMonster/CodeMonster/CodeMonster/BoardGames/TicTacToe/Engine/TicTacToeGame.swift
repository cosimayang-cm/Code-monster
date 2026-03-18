//
//  TicTacToeGame.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/3/1.
//

import Foundation

// MARK: - TicTacToeGame
// 井字棋遊戲邏輯，conform to BoardGame。

struct TicTacToeGame: BoardGame {
    typealias Move = TicTacToeMove

    private(set) var board = TicTacToeBoard()
    var state: GameState = .waiting
    var currentPlayer: Player = .human

    // MARK: - BoardGame

    mutating func apply(move: TicTacToeMove) throws {
        guard state == .playing else { throw BoardGameError.gameAlreadyOver }
        guard board[move.row, move.col] == nil else { throw BoardGameError.cellAlreadyOccupied }

        board[move.row, move.col] = currentPlayer

        if let winner = checkWinner() {
            state = .won(winner)
        } else if board.isFull {
            state = .draw
        } else {
            currentPlayer = (currentPlayer == .human) ? .ai : .human
        }
    }

    mutating func restart() {
        board = TicTacToeBoard()
        state = .playing
        currentPlayer = .human
    }

    func validMoves() -> [TicTacToeMove] {
        guard state == .playing else { return [] }
        return board.emptyCells.map { TicTacToeMove(row: $0.row, col: $0.col) }
    }

    // MARK: - Private

    private func checkWinner() -> Player? {
        let lines: [([(Int, Int)])] = [
            // 橫
            [(0,0),(0,1),(0,2)], [(1,0),(1,1),(1,2)], [(2,0),(2,1),(2,2)],
            // 直
            [(0,0),(1,0),(2,0)], [(0,1),(1,1),(2,1)], [(0,2),(1,2),(2,2)],
            // 斜
            [(0,0),(1,1),(2,2)], [(0,2),(1,1),(2,0)]
        ]
        for line in lines {
            let players = line.map { board[$0.0, $0.1] }
            if players[0] != nil && players[0] == players[1] && players[1] == players[2] {
                return players[0]
            }
        }
        return nil
    }
}

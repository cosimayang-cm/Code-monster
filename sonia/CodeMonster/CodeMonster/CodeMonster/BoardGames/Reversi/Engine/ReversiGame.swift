//
//  ReversiGame.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/3/1.
//

import Foundation

// MARK: - ReversiGame
// 黑白棋遊戲邏輯，conform to BoardGame。

struct ReversiGame: BoardGame {
    typealias Move = ReversiMove

    private(set) var board = ReversiBoard()
    var state: GameState = .waiting
    var currentPlayer: Player = .human

    // MARK: - BoardGame

    mutating func apply(move: ReversiMove) throws {
        guard state == .playing else { throw BoardGameError.gameAlreadyOver }
        let flips = board.flips(at: move.row, col: move.col, for: currentPlayer)
        guard !flips.isEmpty else { throw BoardGameError.noFlipsAvailable }

        board.place(at: move.row, col: move.col, player: currentPlayer)

        let opponent: Player = currentPlayer == .human ? .ai : .human

        // 換手：對手有子可下就換，否則看自己，都沒有就結束
        if !validMovesFor(opponent).isEmpty {
            currentPlayer = opponent
        } else if !validMovesFor(currentPlayer).isEmpty {
            // 對手無子，自己繼續（不換手）
        } else {
            // 雙方都無子 → 遊戲結束
            let humanCount = board.count(for: .human)
            let aiCount = board.count(for: .ai)
            if humanCount > aiCount {
                state = .won(.human)
            } else if aiCount > humanCount {
                state = .won(.ai)
            } else {
                state = .draw
            }
        }
    }

    mutating func restart() {
        board = ReversiBoard()
        state = .playing
        currentPlayer = .human
    }

    func validMoves() -> [ReversiMove] {
        validMovesFor(currentPlayer)
    }

    /// 當前玩家是否無子可下（需要 Pass）
    func isPassRequired() -> Bool {
        return validMoves().isEmpty && state == .playing
    }

    /// 當前玩家跳過一手（僅 isPassRequired() == true 時有效）。
    mutating func pass() throws {
        guard state == .playing else { throw BoardGameError.gameAlreadyOver }
        guard validMovesFor(currentPlayer).isEmpty else { throw BoardGameError.noFlipsAvailable }
        let opponent: Player = currentPlayer == .human ? .ai : .human
        if !validMovesFor(opponent).isEmpty {
            currentPlayer = opponent
        } else {
            // 雙方無子 → 結算
            let humanCount = board.count(for: .human)
            let aiCount    = board.count(for: .ai)
            if      humanCount > aiCount { state = .won(.human) }
            else if aiCount > humanCount { state = .won(.ai) }
            else                         { state = .draw }
        }
    }

    // MARK: - Private

    private func validMovesFor(_ player: Player) -> [ReversiMove] {
        var moves: [ReversiMove] = []
        for r in 0..<8 {
            for c in 0..<8 {
                if !board.flips(at: r, col: c, for: player).isEmpty {
                    moves.append(ReversiMove(row: r, col: c))
                }
            }
        }
        return moves
    }
}

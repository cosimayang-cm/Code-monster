//
//  TicTacToeAI.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/3/1.
//

import Foundation

// MARK: - TicTacToeAI
// Minimax 演算法，完美對弈，永不輸。

struct TicTacToeAI: GameAI {
    typealias Game = TicTacToeGame

    func bestMove(for game: TicTacToeGame) -> TicTacToeMove? {
        guard game.state == .playing else { return nil }
        let moves = game.validMoves()
        guard !moves.isEmpty else { return nil }

        var bestScore = Int.min
        var bestMove: TicTacToeMove?

        for move in moves {
            var g = game
            try? g.apply(move: move)
            let score = minimax(game: g, isMaximizing: false)
            if score > bestScore {
                bestScore = score
                bestMove = move
            }
        }
        return bestMove
    }

    // MARK: - Private

    /// Minimax 遞迴
    /// - Returns: 局面分數（+1 AI 勝，-1 Human 勝，0 平手）
    private func minimax(game: TicTacToeGame, isMaximizing: Bool) -> Int {
        switch game.state {
        case .won(let winner): return winner == .ai ? 1 : -1
        case .draw: return 0
        default: break
        }

        if isMaximizing {
            var best = Int.min
            for move in game.validMoves() {
                var g = game
                try? g.apply(move: move)
                best = max(best, minimax(game: g, isMaximizing: false))
            }
            return best
        } else {
            var best = Int.max
            for move in game.validMoves() {
                var g = game
                try? g.apply(move: move)
                best = min(best, minimax(game: g, isMaximizing: true))
            }
            return best
        }
    }
}

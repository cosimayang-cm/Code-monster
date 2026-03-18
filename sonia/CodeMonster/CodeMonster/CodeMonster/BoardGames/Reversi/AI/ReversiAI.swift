//
//  ReversiAI.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/3/1.
//

import Foundation

// MARK: - ReversiAI
// 黑白棋 AI：位置權重矩陣 + Alpha-Beta Pruning（深度 5 層）。

struct ReversiAI: GameAI {
    typealias Game = ReversiGame

    var searchDepth: Int = 5

    /// 8×8 位置權重矩陣
    static let positionWeights: [[Int]] = [
        [100, -25, 10,  5,  5, 10, -25, 100],
        [-25, -50,  1,  1,  1,  1, -50, -25],
        [ 10,   1,  5,  2,  2,  5,   1,  10],
        [  5,   1,  2,  1,  1,  2,   1,   5],
        [  5,   1,  2,  1,  1,  2,   1,   5],
        [ 10,   1,  5,  2,  2,  5,   1,  10],
        [-25, -50,  1,  1,  1,  1, -50, -25],
        [100, -25, 10,  5,  5, 10, -25, 100]
    ]

    func bestMove(for game: ReversiGame) -> ReversiMove? {
        guard game.state == .playing else { return nil }
        let moves = game.validMoves()
        guard !moves.isEmpty else { return nil }

        // 角落優先
        let corners = moves.filter { ($0.row == 0 || $0.row == 7) && ($0.col == 0 || $0.col == 7) }
        if let corner = corners.first { return corner }

        var bestScore = Int.min + 1
        var bestMove = moves[0]
        for move in moves {
            var g = game
            try? g.apply(move: move)
            let score = alphaBeta(game: g, depth: searchDepth - 1, alpha: Int.min + 1, beta: Int.max - 1, isMaximizing: false)
            if score > bestScore {
                bestScore = score
                bestMove = move
            }
        }
        return bestMove
    }

    // MARK: - Private

    private func alphaBeta(game: ReversiGame, depth: Int, alpha: Int, beta: Int, isMaximizing: Bool) -> Int {
        switch game.state {
        case .won(let winner): return winner == .ai ? 10000 : -10000
        case .draw: return 0
        default: break
        }
        if depth == 0 { return evaluate(game: game) }

        var alpha = alpha
        var beta = beta
        let moves = game.validMoves()

        // Pass 情況：無合法走法但遊戲未結束
        if moves.isEmpty {
            return evaluate(game: game)
        }

        if isMaximizing {
            var value = Int.min + 1
            for move in moves {
                var g = game
                try? g.apply(move: move)
                value = max(value, alphaBeta(game: g, depth: depth - 1, alpha: alpha, beta: beta, isMaximizing: false))
                alpha = max(alpha, value)
                if alpha >= beta { break }
            }
            return value
        } else {
            var value = Int.max - 1
            for move in moves {
                var g = game
                try? g.apply(move: move)
                value = min(value, alphaBeta(game: g, depth: depth - 1, alpha: alpha, beta: beta, isMaximizing: true))
                beta = min(beta, value)
                if alpha >= beta { break }
            }
            return value
        }
    }

    private func evaluate(game: ReversiGame) -> Int {
        var score = 0
        for r in 0..<8 {
            for c in 0..<8 {
                switch game.board[r, c] {
                case .black: score -= Self.positionWeights[r][c]  // human
                case .white: score += Self.positionWeights[r][c]  // ai
                case .empty: break
                }
            }
        }
        return score
    }
}

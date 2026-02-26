//
//  MinimaxEngine.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import Foundation

struct MinimaxEngine<Board: GameBoard> {

    /// Find the best move for the given player using Minimax with Alpha-Beta Pruning.
    /// - Parameters:
    ///   - board: Current board state
    ///   - depth: Maximum search depth
    ///   - maximizing: Whether the current player is maximizing
    ///   - for: The player to evaluate for
    /// - Returns: The best move, or nil if no legal moves exist
    func bestMove(board: Board, depth: Int, maximizing: Bool, for player: Player) -> Board.Move? {
        let moves = board.legalMoves()
        guard !moves.isEmpty else { return nil }

        var bestMove: Board.Move?
        var bestScore = maximizing ? -Double.infinity : Double.infinity

        for move in moves {
            let newBoard = board.applying(move)
            let score = minimax(
                board: newBoard,
                depth: depth - 1,
                alpha: -Double.infinity,
                beta: Double.infinity,
                maximizing: !maximizing,
                for: player
            )

            if maximizing {
                if score > bestScore {
                    bestScore = score
                    bestMove = move
                }
            } else {
                if score < bestScore {
                    bestScore = score
                    bestMove = move
                }
            }
        }

        return bestMove
    }

    // MARK: - Private

    private func minimax(
        board: Board,
        depth: Int,
        alpha: Double,
        beta: Double,
        maximizing: Bool,
        for player: Player
    ) -> Double {
        if depth == 0 || board.isTerminal {
            return board.evaluate(for: player)
        }

        let moves = board.legalMoves()
        guard !moves.isEmpty else {
            return board.evaluate(for: player)
        }

        var alpha = alpha
        var beta = beta

        if maximizing {
            var maxEval = -Double.infinity
            for move in moves {
                let newBoard = board.applying(move)
                let eval = minimax(
                    board: newBoard,
                    depth: depth - 1,
                    alpha: alpha,
                    beta: beta,
                    maximizing: false,
                    for: player
                )
                maxEval = max(maxEval, eval)
                alpha = max(alpha, eval)
                if beta <= alpha { break }
            }
            return maxEval
        } else {
            var minEval = Double.infinity
            for move in moves {
                let newBoard = board.applying(move)
                let eval = minimax(
                    board: newBoard,
                    depth: depth - 1,
                    alpha: alpha,
                    beta: beta,
                    maximizing: true,
                    for: player
                )
                minEval = min(minEval, eval)
                beta = min(beta, eval)
                if beta <= alpha { break }
            }
            return minEval
        }
    }
}

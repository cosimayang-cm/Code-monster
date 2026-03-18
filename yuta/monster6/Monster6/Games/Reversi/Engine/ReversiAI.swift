import Foundation

struct ReversiAI: AIProtocol {
    let searchDepth = 4

    // Position weight matrix - corners highest, adjacent to corners lowest
    private let weights: [[Int]] = [
        [100, -20,  10,   5,   5,  10, -20, 100],
        [-20, -50,  -2,  -2,  -2,  -2, -50, -20],
        [ 10,  -2,   0,   1,   1,   0,  -2,  10],
        [  5,  -2,   1,   3,   3,   1,  -2,   5],
        [  5,  -2,   1,   3,   3,   1,  -2,   5],
        [ 10,  -2,   0,   1,   1,   0,  -2,  10],
        [-20, -50,  -2,  -2,  -2,  -2, -50, -20],
        [100, -20,  10,   5,   5,  10, -20, 100]
    ]

    let engine = ReversiEngine()

    func bestMove(for board: ReversiBoard) -> ReversiMove? {
        let moves = engine.validMoves(for: .playerTwo, on: board)
        guard !moves.isEmpty else { return nil }

        var bestScore = Int.min
        var bestMove: ReversiMove?

        for move in moves {
            var nextBoard = board
            applyMoveToBoard(&nextBoard, move: move, player: .playerTwo)
            let score = alphaBeta(board: nextBoard, depth: searchDepth - 1, alpha: Int.min, beta: Int.max, isMaximizing: false)
            if score > bestScore {
                bestScore = score
                bestMove = move
            }
        }
        return bestMove
    }

    private func applyMoveToBoard(_ board: inout ReversiBoard, move: ReversiMove, player: Player) {
        let flips = engine.flippedCells(for: move, player: player, board: board)
        board.cells[move.row][move.col] = player
        for (r, c) in flips {
            board.cells[r][c] = player
        }
    }

    private func evaluate(_ board: ReversiBoard) -> Int {
        var score = 0
        let size = ReversiBoard.size
        for r in 0..<size {
            for c in 0..<size {
                if board.cells[r][c] == .playerTwo { score += weights[r][c] }
                else if board.cells[r][c] == .playerOne { score -= weights[r][c] }
            }
        }
        return score
    }

    private func alphaBeta(board: ReversiBoard, depth: Int, alpha: Int, beta: Int, isMaximizing: Bool) -> Int {
        let currentPlayer: Player = isMaximizing ? .playerTwo : .playerOne
        let moves = engine.validMoves(for: currentPlayer, on: board)

        if depth == 0 || moves.isEmpty { return evaluate(board) }

        var alpha = alpha
        var beta = beta

        if isMaximizing {
            var maxScore = Int.min
            for move in moves {
                var nextBoard = board
                applyMoveToBoard(&nextBoard, move: move, player: .playerTwo)
                let score = alphaBeta(board: nextBoard, depth: depth - 1, alpha: alpha, beta: beta, isMaximizing: false)
                maxScore = max(maxScore, score)
                alpha = max(alpha, score)
                if beta <= alpha { break }
            }
            return maxScore
        } else {
            var minScore = Int.max
            for move in moves {
                var nextBoard = board
                applyMoveToBoard(&nextBoard, move: move, player: .playerOne)
                let score = alphaBeta(board: nextBoard, depth: depth - 1, alpha: alpha, beta: beta, isMaximizing: true)
                minScore = min(minScore, score)
                beta = min(beta, score)
                if beta <= alpha { break }
            }
            return minScore
        }
    }
}

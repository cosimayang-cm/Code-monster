import Foundation

struct ConnectFourAI: AIProtocol {
    let searchDepth = 6

    func bestMove(for board: ConnectFourBoard) -> ConnectFourMove? {
        let cols = ConnectFourBoard.cols
        var bestScore = Int.min
        var bestCol = 0
        let engine = ConnectFourEngine()

        let colOrder = [3, 2, 4, 1, 5, 0, 6]

        for col in colOrder {
            guard col < cols, !board.isColumnFull(col) else { continue }
            var mutableBoard = board
            _ = mutableBoard.dropPiece(col: col, player: .playerTwo)
            let score = alphaBeta(board: mutableBoard, depth: searchDepth - 1, alpha: Int.min, beta: Int.max, isMaximizing: false, engine: engine)
            if score > bestScore || bestScore == Int.min {
                bestScore = score
                bestCol = col
            }
        }
        return ConnectFourMove(col: bestCol)
    }

    private func alphaBeta(board: ConnectFourBoard, depth: Int, alpha: Int, beta: Int, isMaximizing: Bool, engine: ConnectFourEngine) -> Int {
        if engine.checkWinOnBoard(board, for: .playerTwo) { return 1000 + depth }
        if engine.checkWinOnBoard(board, for: .playerOne) { return -1000 - depth }
        if board.isFull || depth == 0 { return evaluate(board: board) }

        var alpha = alpha
        var beta = beta
        let colOrder = [3, 2, 4, 1, 5, 0, 6]

        if isMaximizing {
            var maxScore = Int.min
            for col in colOrder {
                guard col < ConnectFourBoard.cols, !board.isColumnFull(col) else { continue }
                var nextBoard = board
                _ = nextBoard.dropPiece(col: col, player: .playerTwo)
                let score = alphaBeta(board: nextBoard, depth: depth - 1, alpha: alpha, beta: beta, isMaximizing: false, engine: engine)
                maxScore = max(maxScore, score)
                alpha = max(alpha, score)
                if beta <= alpha { break }
            }
            return maxScore
        } else {
            var minScore = Int.max
            for col in colOrder {
                guard col < ConnectFourBoard.cols, !board.isColumnFull(col) else { continue }
                var nextBoard = board
                _ = nextBoard.dropPiece(col: col, player: .playerOne)
                let score = alphaBeta(board: nextBoard, depth: depth - 1, alpha: alpha, beta: beta, isMaximizing: true, engine: engine)
                minScore = min(minScore, score)
                beta = min(beta, score)
                if beta <= alpha { break }
            }
            return minScore
        }
    }

    private func evaluate(board: ConnectFourBoard) -> Int {
        var score = 0
        let rows = ConnectFourBoard.rows
        let cols = ConnectFourBoard.cols
        let b = board.cells

        let centerCol = cols / 2
        for r in 0..<rows {
            if b[r][centerCol] == .playerTwo { score += 3 }
            else if b[r][centerCol] == .playerOne { score -= 3 }
        }

        for r in 0..<rows {
            for c in 0..<(cols - 3) {
                let window = (0..<4).map { b[r][c + $0] }
                score += evaluateWindow(window)
            }
        }
        for r in 0..<(rows - 3) {
            for c in 0..<cols {
                let window = (0..<4).map { b[r + $0][c] }
                score += evaluateWindow(window)
            }
        }
        for r in 0..<(rows - 3) {
            for c in 0..<(cols - 3) {
                let window = (0..<4).map { b[r + $0][c + $0] }
                score += evaluateWindow(window)
            }
        }
        for r in 0..<(rows - 3) {
            for c in 3..<cols {
                let window = (0..<4).map { b[r + $0][c - $0] }
                score += evaluateWindow(window)
            }
        }
        return score
    }

    private func evaluateWindow(_ window: [Player]) -> Int {
        let aiCount = window.filter { $0 == .playerTwo }.count
        let humanCount = window.filter { $0 == .playerOne }.count
        let emptyCount = window.filter { $0 == .none }.count

        if aiCount == 4 { return 100 }
        if aiCount == 3 && emptyCount == 1 { return 5 }
        if aiCount == 2 && emptyCount == 2 { return 2 }
        if humanCount == 3 && emptyCount == 1 { return -4 }
        return 0
    }
}

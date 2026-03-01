import Foundation

// MARK: - ConnectFourAI
// Alpha-Beta Pruning，搜尋深度 7 層。
// 評估函數：連線數量 + 中路優勢（第 3/4 欄）。

struct ConnectFourAI: GameAI {
    typealias Game = ConnectFourGame

    var searchDepth: Int = 7

    func bestMove(for game: ConnectFourGame) -> ConnectFourMove? {
        guard game.state == .playing else { return nil }
        let moves = game.validMoves()
        guard !moves.isEmpty else { return nil }

        let center = ConnectFourBoard.cols / 2
        let sortedMoves = moves.sorted { abs($0.column - center) < abs($1.column - center) }

        var bestScore = Int.min + 1
        var bestMove = sortedMoves[0]

        for move in sortedMoves {
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

    private func alphaBeta(game: ConnectFourGame, depth: Int, alpha: Int, beta: Int, isMaximizing: Bool) -> Int {
        switch game.state {
        case .won(let winner): return winner == .ai ? 1000 + depth : -(1000 + depth)
        case .draw: return 0
        default: break
        }
        if depth == 0 { return evaluate(game: game) }

        var alpha = alpha
        var beta = beta
        let center = ConnectFourBoard.cols / 2
        let moves = game.validMoves().sorted { abs($0.column - center) < abs($1.column - center) }

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

    private func evaluate(game: ConnectFourGame) -> Int {
        var score = 0
        let rows = ConnectFourBoard.rows
        let cols = ConnectFourBoard.cols
        let board = game.board

        let centerCol = cols / 2
        for r in 0..<rows {
            if board[r, centerCol] == .ai { score += 3 }
            else if board[r, centerCol] == .human { score -= 3 }
        }

        let directions: [(dr: Int, dc: Int)] = [(0,1),(1,0),(1,1),(1,-1)]
        for r in 0..<rows {
            for c in 0..<cols {
                for d in directions {
                    var window: [Player?] = []
                    for i in 0..<4 {
                        let nr = r + d.dr * i
                        let nc = c + d.dc * i
                        guard nr >= 0 && nr < rows && nc >= 0 && nc < cols else { break }
                        window.append(board[nr, nc])
                    }
                    guard window.count == 4 else { continue }
                    score += scoreWindow(window)
                }
            }
        }
        return score
    }

    private func scoreWindow(_ window: [Player?]) -> Int {
        let aiCount = window.filter { $0 == .ai }.count
        let humanCount = window.filter { $0 == .human }.count
        let empty = window.filter { $0 == nil }.count
        if humanCount > 0 && aiCount > 0 { return 0 }
        if aiCount == 4 { return 100 }
        if aiCount == 3 && empty == 1 { return 5 }
        if aiCount == 2 && empty == 2 { return 2 }
        if humanCount == 3 && empty == 1 { return -80 }
        if humanCount == 2 && empty == 2 { return -2 }
        return 0
    }
}

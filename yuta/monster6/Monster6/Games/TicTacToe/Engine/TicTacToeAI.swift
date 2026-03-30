import Foundation

struct TicTacToeAI: AIProtocol {
    func bestMove(for board: TicTacToeBoard) -> TicTacToeMove? {
        var bestScore = Int.min
        var bestMove: TicTacToeMove?
        var mutableBoard = board

        for row in 0..<3 {
            for col in 0..<3 {
                if mutableBoard.cell(row: row, col: col) == .none {
                    mutableBoard.setCell(row: row, col: col, player: .playerTwo)
                    let score = minimaxBoard(board: mutableBoard, depth: 0, isMaximizing: false)
                    mutableBoard.setCell(row: row, col: col, player: .none)
                    if score > bestScore {
                        bestScore = score
                        bestMove = TicTacToeMove(row: row, col: col)
                    }
                }
            }
        }
        return bestMove
    }

    private func checkWinOnBoard(_ board: TicTacToeBoard, for player: Player) -> Bool {
        let b = board.cells
        for row in 0..<3 {
            if b[row].allSatisfy({ $0 == player }) { return true }
        }
        for col in 0..<3 {
            if (0..<3).allSatisfy({ b[$0][col] == player }) { return true }
        }
        if (0..<3).allSatisfy({ b[$0][$0] == player }) { return true }
        if (0..<3).allSatisfy({ b[$0][2 - $0] == player }) { return true }
        return false
    }

    private func minimaxBoard(board: TicTacToeBoard, depth: Int, isMaximizing: Bool) -> Int {
        if checkWinOnBoard(board, for: .playerOne) { return -10 + depth }
        if checkWinOnBoard(board, for: .playerTwo) { return 10 - depth }
        if board.isFull { return 0 }

        var mutableBoard = board

        if isMaximizing {
            var bestScore = Int.min
            for row in 0..<3 {
                for col in 0..<3 {
                    if mutableBoard.cell(row: row, col: col) == .none {
                        mutableBoard.setCell(row: row, col: col, player: .playerTwo)
                        let score = minimaxBoard(board: mutableBoard, depth: depth + 1, isMaximizing: false)
                        mutableBoard.setCell(row: row, col: col, player: .none)
                        bestScore = max(bestScore, score)
                    }
                }
            }
            return bestScore
        } else {
            var bestScore = Int.max
            for row in 0..<3 {
                for col in 0..<3 {
                    if mutableBoard.cell(row: row, col: col) == .none {
                        mutableBoard.setCell(row: row, col: col, player: .playerOne)
                        let score = minimaxBoard(board: mutableBoard, depth: depth + 1, isMaximizing: true)
                        mutableBoard.setCell(row: row, col: col, player: .none)
                        bestScore = min(bestScore, score)
                    }
                }
            }
            return bestScore
        }
    }
}

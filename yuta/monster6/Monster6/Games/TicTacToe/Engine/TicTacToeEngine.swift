import Foundation

final class TicTacToeEngine: GameEngineProtocol {
    typealias Board = TicTacToeBoard
    typealias Move = TicTacToeMove

    private(set) var board = TicTacToeBoard()
    private(set) var state: GameState = .playing(currentPlayer: .playerOne)

    var onStateChanged: ((GameState, TicTacToeBoard) -> Void)?

    func applyMove(_ move: TicTacToeMove) -> Bool {
        guard case .playing(let current) = state else { return false }
        guard board.cell(row: move.row, col: move.col) == .none else { return false }

        board.setCell(row: move.row, col: move.col, player: current)
        updateState(lastPlayer: current)
        return true
    }

    func reset() {
        board.reset()
        state = .playing(currentPlayer: .playerOne)
    }

    private func updateState(lastPlayer: Player) {
        if checkWin(for: lastPlayer) {
            state = .finished(result: .win(player: lastPlayer))
        } else if board.isFull {
            state = .finished(result: .draw)
        } else {
            let next: Player = lastPlayer == .playerOne ? .playerTwo : .playerOne
            state = .playing(currentPlayer: next)
        }
        onStateChanged?(state, board)
    }

    func checkWin(for player: Player) -> Bool {
        let b = board.cells
        // rows
        for row in 0..<3 {
            if b[row].allSatisfy({ $0 == player }) { return true }
        }
        // cols
        for col in 0..<3 {
            if (0..<3).allSatisfy({ b[$0][col] == player }) { return true }
        }
        // diagonals
        if (0..<3).allSatisfy({ b[$0][$0] == player }) { return true }
        if (0..<3).allSatisfy({ b[$0][2 - $0] == player }) { return true }
        return false
    }
}

struct TicTacToeMove: MoveProtocol {
    let row: Int
    let col: Int
}

import Foundation

struct ConnectFourMove: MoveProtocol {
    let col: Int
}

final class ConnectFourEngine: GameEngineProtocol {
    typealias Board = ConnectFourBoard
    typealias Move = ConnectFourMove

    var board = ConnectFourBoard()
    private(set) var state: GameState = .playing(currentPlayer: .playerOne)

    var onStateChanged: ((GameState, ConnectFourBoard) -> Void)?

    func applyMove(_ move: ConnectFourMove) -> Bool {
        guard case .playing(let current) = state else { return false }
        guard board.landingRow(col: move.col) != nil else { return false }

        _ = board.dropPiece(col: move.col, player: current)
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
        checkWinOnBoard(board, for: player)
    }

    func checkWinOnBoard(_ board: ConnectFourBoard, for player: Player) -> Bool {
        let rows = ConnectFourBoard.rows
        let cols = ConnectFourBoard.cols
        let b = board.cells

        // horizontal
        for r in 0..<rows {
            for c in 0..<(cols - 3) {
                if (0..<4).allSatisfy({ b[r][c + $0] == player }) { return true }
            }
        }
        // vertical
        for r in 0..<(rows - 3) {
            for c in 0..<cols {
                if (0..<4).allSatisfy({ b[r + $0][c] == player }) { return true }
            }
        }
        // diagonal down-right
        for r in 0..<(rows - 3) {
            for c in 0..<(cols - 3) {
                if (0..<4).allSatisfy({ b[r + $0][c + $0] == player }) { return true }
            }
        }
        // diagonal down-left
        for r in 0..<(rows - 3) {
            for c in 3..<cols {
                if (0..<4).allSatisfy({ b[r + $0][c - $0] == player }) { return true }
            }
        }
        return false
    }
}

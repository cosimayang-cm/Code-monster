import Foundation

// MARK: - ConnectFourGame
// 四子棋遊戲邏輯，conform to BoardGame。

struct ConnectFourGame: BoardGame {
    typealias Move = ConnectFourMove

    private(set) var board = ConnectFourBoard()
    var state: GameState = .waiting
    var currentPlayer: Player = .human

    // MARK: - BoardGame

    mutating func apply(move: ConnectFourMove) throws {
        guard state == .playing else { throw BoardGameError.gameAlreadyOver }
        guard !board.isColumnFull(move.column) else { throw BoardGameError.columnFull }

        board.drop(column: move.column, player: currentPlayer)

        if let winner = checkWinner() {
            state = .won(winner)
        } else if board.isFull {
            state = .draw
        } else {
            currentPlayer = (currentPlayer == .human) ? .ai : .human
        }
    }

    mutating func restart() {
        board = ConnectFourBoard()
        state = .playing
        currentPlayer = .human
    }

    func validMoves() -> [ConnectFourMove] {
        guard state == .playing else { return [] }
        return board.availableColumns.map { ConnectFourMove(column: $0) }
    }

    // MARK: - Private

    private func checkWinner() -> Player? {
        let rows = ConnectFourBoard.rows
        let cols = ConnectFourBoard.cols

        // 檢查四個方向：橫/直/方斜/反斜
        let directions: [(dr: Int, dc: Int)] = [(0,1),(1,0),(1,1),(1,-1)]
        for r in 0..<rows {
            for c in 0..<cols {
                guard let player = board[r, c] else { continue }
                for d in directions {
                    var count = 1
                    var nr = r + d.dr
                    var nc = c + d.dc
                    while nr >= 0 && nr < rows && nc >= 0 && nc < cols && board[nr, nc] == player {
                        count += 1
                        nr += d.dr
                        nc += d.dc
                    }
                    if count >= 4 { return player }
                }
            }
        }
        return nil
    }
}

import Foundation

struct ReversiMove: MoveProtocol {
    let row: Int
    let col: Int
}

final class ReversiEngine: GameEngineProtocol {
    typealias Board = ReversiBoard
    typealias Move = ReversiMove

    private(set) var board = ReversiBoard()
    private(set) var state: GameState = .playing(currentPlayer: .playerOne)

    var onStateChanged: ((GameState, ReversiBoard) -> Void)?

    let directions = [(-1,-1),(-1,0),(-1,1),(0,-1),(0,1),(1,-1),(1,0),(1,1)]

    func applyMove(_ move: ReversiMove) -> Bool {
        guard case .playing(let current) = state else { return false }
        let flips = flippedCells(for: move, player: current, board: board)
        guard !flips.isEmpty else { return false }

        board.cells[move.row][move.col] = current
        for (r, c) in flips {
            board.cells[r][c] = current
        }

        updateState(lastPlayer: current)
        return true
    }

    func reset() {
        board.reset()
        state = .playing(currentPlayer: .playerOne)
    }

    func validMoves(for player: Player, on board: ReversiBoard) -> [ReversiMove] {
        var moves: [ReversiMove] = []
        let size = ReversiBoard.size
        for r in 0..<size {
            for c in 0..<size {
                let move = ReversiMove(row: r, col: c)
                if board.cells[r][c] == .none && !flippedCells(for: move, player: player, board: board).isEmpty {
                    moves.append(move)
                }
            }
        }
        return moves
    }

    func flippedCells(for move: ReversiMove, player: Player, board: ReversiBoard) -> [(Int, Int)] {
        guard board.cells[move.row][move.col] == .none else { return [] }
        let opponent: Player = player == .playerOne ? .playerTwo : .playerOne
        var flipped: [(Int, Int)] = []
        let size = ReversiBoard.size

        for (dr, dc) in directions {
            var r = move.row + dr
            var c = move.col + dc
            var candidates: [(Int, Int)] = []

            while r >= 0 && r < size && c >= 0 && c < size && board.cells[r][c] == opponent {
                candidates.append((r, c))
                r += dr
                c += dc
            }

            if r >= 0 && r < size && c >= 0 && c < size && board.cells[r][c] == player && !candidates.isEmpty {
                flipped += candidates
            }
        }
        return flipped
    }

    private func updateState(lastPlayer: Player) {
        let next: Player = lastPlayer == .playerOne ? .playerTwo : .playerOne

        if !validMoves(for: next, on: board).isEmpty {
            state = .playing(currentPlayer: next)
        } else if !validMoves(for: lastPlayer, on: board).isEmpty {
            // skip next player's turn
            print("Player \(next == .playerOne ? "Black" : "White") has no valid moves. Turn skipped.")
            state = .playing(currentPlayer: lastPlayer)
        } else {
            // Both can't move - game over
            let blackCount = board.count(for: .playerOne)
            let whiteCount = board.count(for: .playerTwo)
            if blackCount > whiteCount {
                state = .finished(result: .win(player: .playerOne))
            } else if whiteCount > blackCount {
                state = .finished(result: .win(player: .playerTwo))
            } else {
                state = .finished(result: .draw)
            }
        }
        onStateChanged?(state, board)
    }
}

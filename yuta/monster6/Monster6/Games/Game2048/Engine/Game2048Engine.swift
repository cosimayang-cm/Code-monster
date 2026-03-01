import Foundation

enum Game2048Direction: MoveProtocol {
    case up, down, left, right
}

final class Game2048Engine: GameEngineProtocol {
    typealias Board = Game2048Board
    typealias Move = Game2048Direction

    var board = Game2048Board()
    private(set) var state: GameState = .playing(currentPlayer: .playerOne)
    private var wonAlreadyAnnounced = false

    var onStateChanged: ((GameState, Game2048Board) -> Void)?

    init() {
        spawnTile()
        spawnTile()
    }

    func applyMove(_ direction: Game2048Direction) -> Bool {
        guard case .playing = state else { return false }

        let previousCells = board.cells
        slide(direction: direction)

        guard board.cells != previousCells else { return false }

        spawnTile()

        if !wonAlreadyAnnounced && board.hasWon {
            wonAlreadyAnnounced = true
            print("\nYou reached 2048! Keep going?")
        }

        if !board.hasValidMove {
            state = .finished(result: .win(player: .none))
        }

        onStateChanged?(state, board)
        return true
    }

    func reset() {
        board.reset()
        wonAlreadyAnnounced = false
        spawnTile()
        spawnTile()
        state = .playing(currentPlayer: .playerOne)
    }

    private func spawnTile() {
        let empties = board.emptyCells
        guard !empties.isEmpty else { return }
        let (r, c) = empties[Int.random(in: 0..<empties.count)]
        board.cells[r][c] = Int.random(in: 0..<10) == 0 ? 4 : 2
    }

    private func slide(direction: Game2048Direction) {
        let size = Game2048Board.size
        switch direction {
        case .left:
            for r in 0..<size {
                board.cells[r] = slideLine(board.cells[r])
            }
        case .right:
            for r in 0..<size {
                board.cells[r] = Array(slideLine(Array(board.cells[r].reversed())).reversed())
            }
        case .up:
            for c in 0..<size {
                let col = (0..<size).map { board.cells[$0][c] }
                let slid = slideLine(col)
                for r in 0..<size { board.cells[r][c] = slid[r] }
            }
        case .down:
            for c in 0..<size {
                let col = (0..<size).map { board.cells[$0][c] }
                let slid = Array(slideLine(Array(col.reversed())).reversed())
                for r in 0..<size { board.cells[r][c] = slid[r] }
            }
        }
    }

    // Slide and merge a single row/column leftward
    private func slideLine(_ line: [Int]) -> [Int] {
        let tiles = line.filter { $0 != 0 }
        var merged: [Int] = []
        var i = 0
        while i < tiles.count {
            if i + 1 < tiles.count && tiles[i] == tiles[i + 1] {
                let val = tiles[i] * 2
                merged.append(val)
                board.score += val
                i += 2
            } else {
                merged.append(tiles[i])
                i += 1
            }
        }
        while merged.count < line.count { merged.append(0) }
        return merged
    }
}

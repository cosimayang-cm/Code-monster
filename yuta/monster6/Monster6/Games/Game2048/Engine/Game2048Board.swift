import Foundation

struct Game2048Board: BoardProtocol {
    var cells: [[Int]]  // 0 = empty
    var score: Int = 0
    static let size = 4

    init() {
        cells = Array(repeating: Array(repeating: 0, count: Game2048Board.size), count: Game2048Board.size)
    }

    mutating func reset() {
        cells = Array(repeating: Array(repeating: 0, count: Game2048Board.size), count: Game2048Board.size)
        score = 0
    }

    var emptyCells: [(Int, Int)] {
        var result: [(Int, Int)] = []
        let size = Game2048Board.size
        for r in 0..<size {
            for c in 0..<size {
                if cells[r][c] == 0 { result.append((r, c)) }
            }
        }
        return result
    }

    var isFull: Bool { emptyCells.isEmpty }

    var hasValidMove: Bool {
        if !isFull { return true }
        let size = Game2048Board.size
        for r in 0..<size {
            for c in 0..<size {
                if c + 1 < size && cells[r][c] == cells[r][c + 1] { return true }
                if r + 1 < size && cells[r][c] == cells[r + 1][c] { return true }
            }
        }
        return false
    }

    var hasWon: Bool {
        cells.flatMap { $0 }.contains(2048)
    }
}

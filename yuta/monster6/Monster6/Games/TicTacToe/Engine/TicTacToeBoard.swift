import Foundation

struct TicTacToeBoard: BoardProtocol {
    var cells: [[Player]]

    init() {
        cells = Array(repeating: Array(repeating: .none, count: 3), count: 3)
    }

    mutating func reset() {
        cells = Array(repeating: Array(repeating: .none, count: 3), count: 3)
    }

    func cell(row: Int, col: Int) -> Player {
        cells[row][col]
    }

    mutating func setCell(row: Int, col: Int, player: Player) {
        cells[row][col] = player
    }

    var isFull: Bool {
        cells.allSatisfy { $0.allSatisfy { $0 != .none } }
    }
}

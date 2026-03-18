import Foundation

struct ReversiBoard: BoardProtocol {
    var cells: [[Player]]
    static let size = 8

    init() {
        cells = Array(repeating: Array(repeating: .none, count: ReversiBoard.size), count: ReversiBoard.size)
        // Initial setup
        cells[3][3] = .playerTwo // White
        cells[3][4] = .playerOne // Black
        cells[4][3] = .playerOne // Black
        cells[4][4] = .playerTwo // White
    }

    mutating func reset() {
        cells = Array(repeating: Array(repeating: .none, count: ReversiBoard.size), count: ReversiBoard.size)
        cells[3][3] = .playerTwo
        cells[3][4] = .playerOne
        cells[4][3] = .playerOne
        cells[4][4] = .playerTwo
    }

    func count(for player: Player) -> Int {
        cells.flatMap { $0 }.filter { $0 == player }.count
    }

    var isFull: Bool {
        cells.allSatisfy { $0.allSatisfy { $0 != .none } }
    }
}

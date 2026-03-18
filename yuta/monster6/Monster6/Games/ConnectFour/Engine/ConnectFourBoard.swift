import Foundation

struct ConnectFourBoard: BoardProtocol {
    // rows 0 = top, rows 5 = bottom (gravity: pieces fall to higher row index)
    var cells: [[Player]]
    static let cols = 7
    static let rows = 6

    init() {
        cells = Array(repeating: Array(repeating: .none, count: ConnectFourBoard.cols), count: ConnectFourBoard.rows)
    }

    mutating func reset() {
        cells = Array(repeating: Array(repeating: .none, count: ConnectFourBoard.cols), count: ConnectFourBoard.rows)
    }

    // Returns the row where the piece lands (bottom-most empty), or nil if column is full
    func landingRow(col: Int) -> Int? {
        for row in stride(from: ConnectFourBoard.rows - 1, through: 0, by: -1) {
            if cells[row][col] == .none { return row }
        }
        return nil
    }

    mutating func dropPiece(col: Int, player: Player) -> Int? {
        guard let row = landingRow(col: col) else { return nil }
        cells[row][col] = player
        return row
    }

    func isColumnFull(_ col: Int) -> Bool {
        landingRow(col: col) == nil
    }

    var isFull: Bool {
        (0..<ConnectFourBoard.cols).allSatisfy { isColumnFull($0) }
    }
}

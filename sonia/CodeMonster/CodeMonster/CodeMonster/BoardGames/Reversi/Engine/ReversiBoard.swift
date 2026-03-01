import Foundation

// MARK: - ReversiBoard
// 8×8 黑白棋棋盤，value type。
// 初始：D4=⭕, E4=⚫, D5=⚫, E5=⭕（row/col 0-indexed: [3][3]=white,[3][4]=black,[4][3]=black,[4][4]=white）。

struct ReversiBoard {
    enum Cell: Equatable {
        case empty
        case black  // .human
        case white  // .ai
    }

    private(set) var cells: [[Cell]]

    init() {
        cells = Array(repeating: Array(repeating: .empty, count: 8), count: 8)
        // 初始四子
        cells[3][3] = .white
        cells[3][4] = .black
        cells[4][3] = .black
        cells[4][4] = .white
    }

    subscript(row: Int, col: Int) -> Cell {
        get { cells[row][col] }
    }

    static let directions: [(dr: Int, dc: Int)] = [
        (-1,-1),(-1,0),(-1,1),
        (0,-1),         (0,1),
        (1,-1), (1,0),  (1,1)
    ]

    /// 返回典第 (row,col) 方向上可被翻轉的棋子座標
    func flips(at row: Int, col: Int, for player: Player) -> [(Int, Int)] {
        let myCell: Cell = player == .human ? .black : .white
        let opCell: Cell = player == .human ? .white : .black
        guard cells[row][col] == .empty else { return [] }

        var allFlips: [(Int, Int)] = []
        for d in Self.directions {
            var path: [(Int, Int)] = []
            var r = row + d.dr
            var c = col + d.dc
            while r >= 0 && r < 8 && c >= 0 && c < 8 && cells[r][c] == opCell {
                path.append((r, c))
                r += d.dr
                c += d.dc
            }
            if !path.isEmpty && r >= 0 && r < 8 && c >= 0 && c < 8 && cells[r][c] == myCell {
                allFlips.append(contentsOf: path)
            }
        }
        return allFlips
    }

    /// 將棋子放在 (row,col) 並翻轉對應棋子
    mutating func place(at row: Int, col: Int, player: Player) {
        let myCell: Cell = player == .human ? .black : .white
        // 必須先算出 flips，再放棋子；否則 flips() 的 guard cells[row][col] == .empty 會提早返回 []
        let toFlip = flips(at: row, col: col, for: player)
        cells[row][col] = myCell
        for (r, c) in toFlip {
            cells[r][c] = myCell
        }
    }

    func count(for player: Player) -> Int {
        let cell: Cell = player == .human ? .black : .white
        return cells.flatMap { $0 }.filter { $0 == cell }.count
    }
}

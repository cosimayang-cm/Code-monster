//
//  ConnectFourBoard.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/3/1.
//

import Foundation

// MARK: - ConnectFourBoard
// 7 欄 × 6 列棋盤，value type。
// cells[row][col]: row 0 = 底部（重力方向），row 5 = 頂部。

struct ConnectFourBoard {
    static let cols = 7
    static let rows = 6

    // cells[row][col], row 0 = bottom
    private(set) var cells: [[Player?]] = Array(
        repeating: Array(repeating: nil, count: 7),
        count: 6
    )

    subscript(row: Int, col: Int) -> Player? {
        get { cells[row][col] }
    }

    /// 將棋子投入指定欄，返回落入的 row（欄満返回 nil）
    @discardableResult
    mutating func drop(column col: Int, player: Player) -> Int? {
        for row in 0..<ConnectFourBoard.rows {
            if cells[row][col] == nil {
                cells[row][col] = player
                return row
            }
        }
        return nil
    }

    func isColumnFull(_ col: Int) -> Bool {
        cells[ConnectFourBoard.rows - 1][col] != nil
    }

    var isFull: Bool {
        (0..<ConnectFourBoard.cols).allSatisfy { isColumnFull($0) }
    }

    var availableColumns: [Int] {
        (0..<ConnectFourBoard.cols).filter { !isColumnFull($0) }
    }
}

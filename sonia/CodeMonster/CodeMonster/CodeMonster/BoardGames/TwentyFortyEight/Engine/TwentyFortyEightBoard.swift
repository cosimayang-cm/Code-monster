//
//  TwentyFortyEightBoard.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/3/1.
//

import Foundation

// MARK: - TwentyFortyEightBoard
// 4×4 滑動棋盤，value type。
// spawn：90% 機率生成 2，10% 機率生成 4。

struct TwentyFortyEightBoard: Equatable {
    static let size = 4

    private(set) var cells: [[Int]]

    init() {
        cells = Array(repeating: Array(repeating: 0, count: Self.size), count: Self.size)
    }

    subscript(row: Int, col: Int) -> Int {
        get { cells[row][col] }
        set { cells[row][col] = newValue }
    }

    var hasEmptyCell: Bool {
        cells.contains(where: { $0.contains(0) })
    }

    var isFull: Bool { !hasEmptyCell }

    var emptyCells: [(row: Int, col: Int)] {
        var result: [(Int, Int)] = []
        for r in 0..<Self.size {
            for c in 0..<Self.size {
                if cells[r][c] == 0 { result.append((r, c)) }
            }
        }
        return result
    }

    /// 在隨機空格生成 2（90%）或 4（10%）。
    @discardableResult
    mutating func randomSpawn() -> Bool {
        let empty = emptyCells
        guard let spot = empty.randomElement() else { return false }
        cells[spot.row][spot.col] = Int.random(in: 1...10) <= 9 ? 2 : 4
        return true
    }

    var maxTile: Int {
        cells.flatMap { $0 }.max() ?? 0
    }
}

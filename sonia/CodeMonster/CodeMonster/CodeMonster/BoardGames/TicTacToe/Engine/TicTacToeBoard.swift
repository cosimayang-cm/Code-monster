//
//  TicTacToeBoard.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/3/1.
//

import Foundation

// MARK: - TicTacToeBoard
// 3×3 棋盤，value type（struct），方便 Minimax 遞迴時複製。

struct TicTacToeBoard {
    // nil = 空格，.human = ❌，.ai = ⭕
    private var cells: [[Player?]] = Array(repeating: Array(repeating: nil, count: 3), count: 3)

    subscript(row: Int, col: Int) -> Player? {
        get { cells[row][col] }
        set { cells[row][col] = newValue }
    }

    var isFull: Bool {
        cells.allSatisfy { $0.allSatisfy { $0 != nil } }
    }

    var emptyCells: [(row: Int, col: Int)] {
        var result: [(Int, Int)] = []
        for r in 0..<3 {
            for c in 0..<3 where cells[r][c] == nil {
                result.append((r, c))
            }
        }
        return result
    }
}

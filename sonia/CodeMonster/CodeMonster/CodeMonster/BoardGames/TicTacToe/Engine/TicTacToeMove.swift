//
//  TicTacToeMove.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/3/1.
//

import Foundation

// MARK: - TicTacToeMove
// 井字棋走步（row: 0-2，col: 0-2）。

struct TicTacToeMove: Equatable {
    let row: Int
    let col: Int

    /// 人類可讀描述，例如 "A1"（row A=0, col 1-indexed）
    var description: String {
        let rowLabel = ["A", "B", "C"][row]
        return "\(rowLabel)\(col + 1)"
    }
}

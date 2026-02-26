//
//  ReversiMove.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import Foundation

struct ReversiMove: GameMove {
    let row: Int    // 0-7
    let col: Int    // 0-7
    let flips: [(Int, Int)] // positions to flip

    var description: String {
        let rowLabel = String(UnicodeScalar(65 + row)!) // A-H
        return "\(rowLabel)\(col + 1)"
    }

    // MARK: - Hashable (ignore flips for identity)

    func hash(into hasher: inout Hasher) {
        hasher.combine(row)
        hasher.combine(col)
    }

    static func == (lhs: ReversiMove, rhs: ReversiMove) -> Bool {
        lhs.row == rhs.row && lhs.col == rhs.col
    }
}

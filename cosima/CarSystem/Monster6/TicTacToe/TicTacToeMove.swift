//
//  TicTacToeMove.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import Foundation

struct TicTacToeMove: GameMove {
    let position: Int // 0-8

    var description: String {
        let row = position / 3
        let col = position % 3
        let rowLabel = ["A", "B", "C"][row]
        let colLabel = col + 1
        return "\(rowLabel)\(colLabel)"
    }
}

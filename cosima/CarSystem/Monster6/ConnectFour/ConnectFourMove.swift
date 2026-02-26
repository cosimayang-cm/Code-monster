//
//  ConnectFourMove.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import Foundation

struct ConnectFourMove: GameMove {
    let column: Int // 0-6

    var description: String {
        "Col \(column + 1)"
    }
}

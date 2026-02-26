//
//  Game2048Move.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import Foundation

enum Direction: CaseIterable {
    case up, down, left, right
}

struct Game2048Move: GameMove {
    let direction: Direction

    var description: String {
        switch direction {
        case .up:    return "⬆"
        case .down:  return "⬇"
        case .left:  return "⬅"
        case .right: return "➡"
        }
    }
}

//
//  GameResult.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import Foundation

enum GameResult: Equatable {
    case win(player: Player)
    case draw
    case lose
}

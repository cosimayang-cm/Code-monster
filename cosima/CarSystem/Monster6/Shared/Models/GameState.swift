//
//  GameState.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import Foundation

enum GameState: Equatable {
    case idle
    case playing(currentPlayer: Player)
    case gameOver(result: GameResult)
}

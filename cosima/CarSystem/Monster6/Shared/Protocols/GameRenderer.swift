//
//  GameRenderer.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import Foundation

protocol GameRenderer {
    associatedtype Board: GameBoard
    func render(board: Board, state: GameState) -> String
}

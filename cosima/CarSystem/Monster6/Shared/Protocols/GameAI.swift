//
//  GameAI.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import Foundation

protocol GameAI {
    associatedtype Board: GameBoard
    func bestMove(for board: Board) -> Board.Move?
}

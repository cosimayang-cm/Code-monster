//
//  GameBoard.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import Foundation

protocol GameBoard {
    associatedtype Move: GameMove
    var currentPlayer: Player { get }
    var isTerminal: Bool { get }
    func legalMoves() -> [Move]
    func applying(_ move: Move) -> Self
    func winner() -> Player?
    func evaluate(for player: Player) -> Double
}

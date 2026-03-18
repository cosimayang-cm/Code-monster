//
//  ReversiAI.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import Foundation

struct ReversiAI: GameAI {
    typealias Board = ReversiBoard

    private let engine = MinimaxEngine<ReversiBoard>()
    private let searchDepth = 4

    func bestMove(for board: ReversiBoard) -> ReversiMove? {
        return engine.bestMove(
            board: board,
            depth: searchDepth,
            maximizing: board.currentPlayer == .human,
            for: board.currentPlayer
        )
    }
}

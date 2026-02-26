//
//  TicTacToeAI.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import Foundation

struct TicTacToeAI: GameAI {
    typealias Board = TicTacToeBoard

    private let engine = MinimaxEngine<TicTacToeBoard>()

    func bestMove(for board: TicTacToeBoard) -> TicTacToeMove? {
        let maximizing = board.currentPlayer == .human
        return engine.bestMove(
            board: board,
            depth: 9, // full search — search space is small
            maximizing: maximizing,
            for: board.currentPlayer
        )
    }
}

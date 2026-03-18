//
//  ConnectFourAI.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import Foundation

struct ConnectFourAI: GameAI {
    typealias Board = ConnectFourBoard

    private let engine = MinimaxEngine<ConnectFourBoard>()
    private let searchDepth = 6

    func bestMove(for board: ConnectFourBoard) -> ConnectFourMove? {
        // Move ordering: search center columns first for better pruning
        let moves = board.legalMoves().sorted { a, b in
            abs(a.column - 3) < abs(b.column - 3)
        }
        guard !moves.isEmpty else { return nil }

        // Use MinimaxEngine with move ordering applied via board evaluation
        return engine.bestMove(
            board: board,
            depth: searchDepth,
            maximizing: board.currentPlayer == .human,
            for: board.currentPlayer
        )
    }
}

//
//  Game2048DummyAI.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import Foundation

/// 2048 is a single-player game. This dummy AI conforms to GameAI
/// but never returns a move, so the engine skips the AI turn.
struct Game2048DummyAI: GameAI {
    typealias Board = Game2048Board

    func bestMove(for board: Game2048Board) -> Game2048Move? {
        nil // single player — no AI opponent
    }
}

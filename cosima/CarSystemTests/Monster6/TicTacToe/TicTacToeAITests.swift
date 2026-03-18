//
//  TicTacToeAITests.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import XCTest
@testable import CarSystem

final class TicTacToeAITests: XCTestCase {

    let ai = TicTacToeAI()

    func testAITakesWinningMove() {
        // AI (O) has positions 3,4 → should pick 5 to win row 1
        let cells: [TicTacToeCellState] = [
            .x, .x, .empty,
            .o, .o, .empty,
            .x, .empty, .empty
        ]
        let board = TicTacToeBoard(cells: cells, currentPlayer: .ai)
        let move = ai.bestMove(for: board)
        XCTAssertNotNil(move)
        XCTAssertEqual(move?.position, 5) // AI should complete row 1
    }

    func testAIBlocksHumanWin() {
        // Human (X) has positions 0,1 → about to win at 2
        // AI must block at position 2
        let cells: [TicTacToeCellState] = [
            .x, .x, .empty,
            .o, .o, .empty,
            .empty, .empty, .empty
        ]
        let board = TicTacToeBoard(cells: cells, currentPlayer: .ai)
        let move = ai.bestMove(for: board)
        XCTAssertNotNil(move)
        // AI should either block at 2 or take the win at 5
        // Since AI can win at 5, it should prefer winning
        XCTAssertEqual(move?.position, 5)
    }

    func testAIBlocksWhenNoWin() {
        // Human (X) has positions 0,1, AI has only 3 → must block at 2
        let cells: [TicTacToeCellState] = [
            .x, .x, .empty,
            .o, .empty, .empty,
            .empty, .empty, .empty
        ]
        let board = TicTacToeBoard(cells: cells, currentPlayer: .ai)
        let move = ai.bestMove(for: board)
        XCTAssertNotNil(move)
        XCTAssertEqual(move?.position, 2) // Must block
    }

    func testAINeverLosesAsSecondPlayer() {
        // Simulate many games where human plays randomly, AI plays optimal
        // AI should never lose when playing second (O)
        var aiLosses = 0

        for _ in 0..<50 {
            var board = TicTacToeBoard()

            while !board.isTerminal {
                if board.currentPlayer == .human {
                    // Human plays random
                    let moves = board.legalMoves()
                    let randomMove = moves[Int.random(in: 0..<moves.count)]
                    board = board.applying(randomMove)
                } else {
                    // AI plays optimal
                    if let move = ai.bestMove(for: board) {
                        board = board.applying(move)
                    }
                }
            }

            if board.winner() == .human {
                aiLosses += 1
            }
        }

        XCTAssertEqual(aiLosses, 0, "AI should never lose as second player")
    }

    func testAINeverLosesAsFirstPlayer() {
        // AI plays first (as human role in board), opponent plays random
        let aiAsFirst = TicTacToeAI()
        var aiLosses = 0

        for _ in 0..<50 {
            var board = TicTacToeBoard()

            while !board.isTerminal {
                if board.currentPlayer == .human {
                    // AI plays as first player (human side)
                    if let move = aiAsFirst.bestMove(for: board) {
                        board = board.applying(move)
                    }
                } else {
                    // Random opponent
                    let moves = board.legalMoves()
                    let randomMove = moves[Int.random(in: 0..<moves.count)]
                    board = board.applying(randomMove)
                }
            }

            // AI playing as human, so if ai (the opponent) wins, AI lost
            if board.winner() == .ai {
                aiLosses += 1
            }
        }

        XCTAssertEqual(aiLosses, 0, "AI should never lose as first player")
    }
}

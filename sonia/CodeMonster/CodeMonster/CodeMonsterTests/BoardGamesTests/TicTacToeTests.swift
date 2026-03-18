//
//  TicTacToeTests.swift
//  CodeMonsterTests
//
//  Created by Sonia Wu on 2026/3/1.
//

import XCTest
@testable import CodeMonster

// MARK: - TicTacToeBoardTests

final class TicTacToeBoardTests: XCTestCase {

    // MARK: - Board Initial State

    func test_board_initiallyAllEmpty() {
        let board = TicTacToeBoard()
        for r in 0..<3 {
            for c in 0..<3 {
                XCTAssertNil(board[r, c], "Cell [\(r)][\(c)] should be nil initially")
            }
        }
    }

    func test_board_isFullFalseInitially() {
        let board = TicTacToeBoard()
        XCTAssertFalse(board.isFull)
    }

    func test_board_isFullTrueWhenAllOccupied() {
        var board = TicTacToeBoard()
        for r in 0..<3 {
            for c in 0..<3 {
                board[r, c] = .human
            }
        }
        XCTAssertTrue(board.isFull)
    }

    func test_board_subscriptSetAndGet() {
        var board = TicTacToeBoard()
        board[1, 2] = .ai
        XCTAssertEqual(board[1, 2], .ai)
        XCTAssertNil(board[0, 0])
    }

    func test_board_emptyCellsCountsCorrectly() {
        var board = TicTacToeBoard()
        XCTAssertEqual(board.emptyCells.count, 9)
        board[0, 0] = .human
        board[1, 1] = .ai
        XCTAssertEqual(board.emptyCells.count, 7)
    }
}

// MARK: - TicTacToeGameTests

final class TicTacToeGameTests: XCTestCase {

    func makeGame() -> TicTacToeGame {
        var g = TicTacToeGame()
        g.restart()
        return g
    }

    // MARK: - Initial State

    func test_game_initialStateIsWaiting() {
        let g = TicTacToeGame()
        XCTAssertEqual(g.state, .waiting)
    }

    func test_game_afterRestartStateIsPlaying() {
        let g = makeGame()
        XCTAssertEqual(g.state, .playing)
    }

    func test_game_firstPlayerIsHuman() {
        let g = makeGame()
        XCTAssertEqual(g.currentPlayer, .human)
    }

    // MARK: - Apply Move

    func test_applyMove_placesPlayerOnBoard() throws {
        var g = makeGame()
        try g.apply(move: TicTacToeMove(row: 0, col: 0))
        XCTAssertEqual(g.board[0, 0], .human)
    }

    func test_applyMove_switchesPlayer() throws {
        var g = makeGame()
        try g.apply(move: TicTacToeMove(row: 0, col: 0))
        XCTAssertEqual(g.currentPlayer, .ai)
    }

    func test_applyMove_throwsOnOccupiedCell() throws {
        var g = makeGame()
        try g.apply(move: TicTacToeMove(row: 0, col: 0))
        XCTAssertThrowsError(try g.apply(move: TicTacToeMove(row: 0, col: 0))) { error in
            XCTAssertEqual(error as? BoardGameError, .cellAlreadyOccupied)
        }
    }

    func test_applyMove_throwsWhenGameOver() throws {
        var g = makeGame()
        // Human wins top row
        try g.apply(move: TicTacToeMove(row: 0, col: 0)) // human
        try g.apply(move: TicTacToeMove(row: 1, col: 0)) // ai
        try g.apply(move: TicTacToeMove(row: 0, col: 1)) // human
        try g.apply(move: TicTacToeMove(row: 1, col: 1)) // ai
        try g.apply(move: TicTacToeMove(row: 0, col: 2)) // human wins
        XCTAssertThrowsError(try g.apply(move: TicTacToeMove(row: 2, col: 2))) { error in
            XCTAssertEqual(error as? BoardGameError, .gameAlreadyOver)
        }
    }

    // MARK: - Win Detection

    func test_humanWins_topRow() throws {
        var g = makeGame()
        try g.apply(move: TicTacToeMove(row: 0, col: 0)) // human
        try g.apply(move: TicTacToeMove(row: 1, col: 0)) // ai
        try g.apply(move: TicTacToeMove(row: 0, col: 1)) // human
        try g.apply(move: TicTacToeMove(row: 1, col: 1)) // ai
        try g.apply(move: TicTacToeMove(row: 0, col: 2)) // human
        XCTAssertEqual(g.state, .won(.human))
    }

    func test_humanWins_leftColumn() throws {
        var g = makeGame()
        try g.apply(move: TicTacToeMove(row: 0, col: 0)) // human
        try g.apply(move: TicTacToeMove(row: 0, col: 1)) // ai
        try g.apply(move: TicTacToeMove(row: 1, col: 0)) // human
        try g.apply(move: TicTacToeMove(row: 1, col: 1)) // ai
        try g.apply(move: TicTacToeMove(row: 2, col: 0)) // human
        XCTAssertEqual(g.state, .won(.human))
    }

    func test_humanWins_diagonal() throws {
        var g = makeGame()
        try g.apply(move: TicTacToeMove(row: 0, col: 0)) // human
        try g.apply(move: TicTacToeMove(row: 0, col: 1)) // ai
        try g.apply(move: TicTacToeMove(row: 1, col: 1)) // human
        try g.apply(move: TicTacToeMove(row: 0, col: 2)) // ai
        try g.apply(move: TicTacToeMove(row: 2, col: 2)) // human
        XCTAssertEqual(g.state, .won(.human))
    }

    func test_draw() throws {
        var g = makeGame()
        // 最終棋盤（H=human ❌, A=ai ⭕）：
        //   ❌ ⭕ ❌
        //   ❌ ⭕ ⭕
        //   ⭕ ❌ ❌  → 無任何三連線，平局
        // 走法順序：H(0,0) A(1,1) H(0,2) A(2,0) H(1,0) A(0,1) H(2,2) A(1,2) H(2,1)
        let moves: [(Int, Int)] = [
            (0,0), (1,1), (0,2),
            (2,0), (1,0), (0,1),
            (2,2), (1,2), (2,1)
        ]
        for (r, c) in moves {
            try g.apply(move: TicTacToeMove(row: r, col: c))
        }
        XCTAssertEqual(g.state, .draw)
    }

    // MARK: - validMoves

    func test_validMoves_nineAtStart() {
        let g = makeGame()
        XCTAssertEqual(g.validMoves().count, 9)
    }

    func test_validMoves_emptyAfterGameOver() throws {
        var g = makeGame()
        try g.apply(move: TicTacToeMove(row: 0, col: 0))
        try g.apply(move: TicTacToeMove(row: 1, col: 0))
        try g.apply(move: TicTacToeMove(row: 0, col: 1))
        try g.apply(move: TicTacToeMove(row: 1, col: 1))
        try g.apply(move: TicTacToeMove(row: 0, col: 2))
        XCTAssertTrue(g.validMoves().isEmpty)
    }

    // MARK: - Restart

    func test_restart_resetsBoard() throws {
        var g = makeGame()
        try g.apply(move: TicTacToeMove(row: 0, col: 0))
        g.restart()
        XCTAssertNil(g.board[0, 0])
        XCTAssertEqual(g.state, .playing)
        XCTAssertEqual(g.currentPlayer, .human)
    }
}

// MARK: - TicTacToeAITests

final class TicTacToeAITests: XCTestCase {

    let ai = TicTacToeAI()

    func makeGame() -> TicTacToeGame {
        var g = TicTacToeGame()
        g.restart()
        return g
    }

    func test_ai_returnsNilWhenGameOver() throws {
        var g = makeGame()
        // Force a win
        try g.apply(move: TicTacToeMove(row: 0, col: 0))
        try g.apply(move: TicTacToeMove(row: 1, col: 0))
        try g.apply(move: TicTacToeMove(row: 0, col: 1))
        try g.apply(move: TicTacToeMove(row: 1, col: 1))
        try g.apply(move: TicTacToeMove(row: 0, col: 2))
        XCTAssertNil(ai.bestMove(for: g))
    }

    func test_ai_blocksHumanWin() throws {
        // Human has 2 in top row, AI must block col 2
        var g = makeGame()
        try g.apply(move: TicTacToeMove(row: 0, col: 0)) // human
        try g.apply(move: TicTacToeMove(row: 2, col: 2)) // ai (any)
        try g.apply(move: TicTacToeMove(row: 0, col: 1)) // human threatens (0,2)

        // It's AI's turn now
        let move = ai.bestMove(for: g)
        XCTAssertNotNil(move)
        XCTAssertEqual(move, TicTacToeMove(row: 0, col: 2), "AI should block human's winning move")
    }

    func test_ai_takesWinningMove() throws {
        // AI has 2 in a row, should take the win
        var g = makeGame()
        try g.apply(move: TicTacToeMove(row: 2, col: 0)) // human
        try g.apply(move: TicTacToeMove(row: 0, col: 0)) // ai
        try g.apply(move: TicTacToeMove(row: 2, col: 1)) // human
        try g.apply(move: TicTacToeMove(row: 0, col: 1)) // ai

        // AI can win at (0,2)
        let move = ai.bestMove(for: g)
        XCTAssertEqual(move, TicTacToeMove(row: 0, col: 2), "AI should take the winning move")
    }

    func test_ai_neverLoses() throws {
        // Sim: AI plays second (ai player) against a fixed human sequence
        // Full game: human plays 0,0 then 0,1 then 0,2 — AI must block
        var g = makeGame()
        try g.apply(move: TicTacToeMove(row: 0, col: 0)) // human
        if let m = ai.bestMove(for: g) { try g.apply(move: m) }
        try g.apply(move: TicTacToeMove(row: 0, col: 1)) // human
        if let m = ai.bestMove(for: g) { try g.apply(move: m) }
        try g.apply(move: TicTacToeMove(row: 1, col: 0)) // human
        if g.state == .playing, let m = ai.bestMove(for: g) { try g.apply(move: m) }

        // AI should not have lost
        if case .won(let winner) = g.state {
            XCTAssertNotEqual(winner, .human, "Minimax AI should never lose")
        }
    }
}

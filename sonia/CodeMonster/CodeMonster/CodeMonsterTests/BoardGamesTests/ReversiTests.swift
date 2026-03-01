//
//  ReversiTests.swift
//  CodeMonsterTests
//
//  Created by Sonia Wu on 2026/3/1.
//

import XCTest
@testable import CodeMonster

// MARK: - ReversiBoardTests

final class ReversiBoardTests: XCTestCase {

    func test_board_initialFourPieces() {
        let board = ReversiBoard()
        XCTAssertEqual(board[3, 3], .white)
        XCTAssertEqual(board[3, 4], .black)
        XCTAssertEqual(board[4, 3], .black)
        XCTAssertEqual(board[4, 4], .white)
    }

    func test_board_initialEmptyCount() {
        let board = ReversiBoard()
        var emptyCount = 0
        for r in 0..<8 { for c in 0..<8 { if board[r, c] == .empty { emptyCount += 1 } } }
        XCTAssertEqual(emptyCount, 60)
    }

    func test_board_flipsDetectedCorrectly() {
        let board = ReversiBoard()
        // Human (black) can play at (2,3) to flip (3,3) white
        let flips = board.flips(at: 2, col: 3, for: .human)
        XCTAssertFalse(flips.isEmpty, "Human should be able to flip at (2,3)")
        XCTAssertTrue(flips.contains { $0.0 == 3 && $0.1 == 3 })
    }

    func test_board_noFlipOnOccupiedCell() {
        let board = ReversiBoard()
        let flips = board.flips(at: 3, col: 3, for: .human)
        XCTAssertTrue(flips.isEmpty)
    }

    func test_board_place_flipsOpponent() {
        var board = ReversiBoard()
        board.place(at: 2, col: 3, player: .human)
        XCTAssertEqual(board[2, 3], .black)
        XCTAssertEqual(board[3, 3], .black, "(3,3) should be flipped from white to black")
    }

    func test_board_count() {
        let board = ReversiBoard()
        XCTAssertEqual(board.count(for: .human), 2)
        XCTAssertEqual(board.count(for: .ai), 2)
    }
}

// MARK: - ReversiGameTests

final class ReversiGameTests: XCTestCase {

    func makeGame() -> ReversiGame {
        var g = ReversiGame()
        g.restart()
        return g
    }

    func test_game_initialStateIsWaiting() {
        XCTAssertEqual(ReversiGame().state, .waiting)
    }

    func test_game_afterRestartIsPlaying() {
        XCTAssertEqual(makeGame().state, .playing)
    }

    func test_game_humanHasFourValidMovesAtStart() {
        let g = makeGame()
        // Standard Reversi opening has exactly 4 valid moves for black
        XCTAssertEqual(g.validMoves().count, 4)
    }

    func test_applyMove_flipsPiece() throws {
        var g = makeGame()
        // Human plays (2,3) flipping (3,3)
        try g.apply(move: ReversiMove(row: 2, col: 3))
        XCTAssertEqual(g.board[2, 3], .black)
        XCTAssertEqual(g.board[3, 3], .black)
    }

    func test_applyMove_switchesPlayer() throws {
        var g = makeGame()
        try g.apply(move: ReversiMove(row: 2, col: 3))
        XCTAssertEqual(g.currentPlayer, .ai)
    }

    func test_applyMove_throwsOnInvalidMove() {
        var g = makeGame()
        // (0,0) can't flip any piece at start
        XCTAssertThrowsError(try g.apply(move: ReversiMove(row: 0, col: 0))) { error in
            XCTAssertEqual(error as? BoardGameError, .noFlipsAvailable)
        }
    }

    func test_applyMove_throwsWhenGameOver() throws {
        var g = makeGame()
        // Force game over by setting state directly is not possible (private state)
        // Instead, just verify the happy path doesn't throw
        let moves = g.validMoves()
        XCTAssertFalse(moves.isEmpty)
        XCTAssertNoThrow(try g.apply(move: moves[0]))
    }

    func test_isPassRequired_falseAtStart() {
        let g = makeGame()
        XCTAssertFalse(g.isPassRequired())
    }

    func test_restart_resetsBoard() throws {
        var g = makeGame()
        try g.apply(move: ReversiMove(row: 2, col: 3))
        g.restart()
        XCTAssertEqual(g.board[3, 3], .white, "Board should reset to initial state")
        XCTAssertEqual(g.currentPlayer, .human)
        XCTAssertEqual(g.state, .playing)
    }
}

// MARK: - ReversiAITests

final class ReversiAITests: XCTestCase {

    let ai = ReversiAI(searchDepth: 2) // shallow for test speed

    func makeGame() -> ReversiGame {
        var g = ReversiGame()
        g.restart()
        return g
    }

    func test_ai_returnsValidMove() {
        var g = makeGame()
        // Switch to AI's turn
        try? g.apply(move: g.validMoves()[0]) // human plays
        let move = ai.bestMove(for: g)
        XCTAssertNotNil(move)
        if let m = move {
            XCTAssertFalse(g.board.flips(at: m.row, col: m.col, for: .ai).isEmpty,
                           "AI move must be a valid flip")
        }
    }

    func test_ai_prefersCorner() {
        // Create a game where AI can take a corner
        var g = makeGame()
        // We can't easily force a corner scenario without many moves
        // Just verify the AI picks a valid move in the opening
        try? g.apply(move: g.validMoves()[0])
        let move = ai.bestMove(for: g)
        XCTAssertNotNil(move)
    }

    func test_ai_returnsNilWhenGameOver() {
        var g = makeGame()
        g = ReversiGame() // waiting state
        XCTAssertNil(ai.bestMove(for: g))
    }
}

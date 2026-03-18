//
//  ConnectFourTests.swift
//  CodeMonsterTests
//
//  Created by Sonia Wu on 2026/3/1.
//

import XCTest
@testable import CodeMonster

// MARK: - ConnectFourBoardTests

final class ConnectFourBoardTests: XCTestCase {

    func test_board_initiallyEmpty() {
        let board = ConnectFourBoard()
        for r in 0..<ConnectFourBoard.rows {
            for c in 0..<ConnectFourBoard.cols {
                XCTAssertNil(board[r, c])
            }
        }
    }

    func test_board_dropColumn_landsAtBottom() {
        var board = ConnectFourBoard()
        let row = board.drop(column: 3, player: .human)
        XCTAssertEqual(row, 0)
        XCTAssertEqual(board[0, 3], .human)
    }

    func test_board_dropColumn_stacksUp() {
        var board = ConnectFourBoard()
        board.drop(column: 0, player: .human)
        board.drop(column: 0, player: .ai)
        XCTAssertEqual(board[0, 0], .human)
        XCTAssertEqual(board[1, 0], .ai)
    }

    func test_board_isColumnFull() {
        var board = ConnectFourBoard()
        for _ in 0..<ConnectFourBoard.rows {
            board.drop(column: 2, player: .human)
        }
        XCTAssertTrue(board.isColumnFull(2))
        XCTAssertFalse(board.isColumnFull(0))
    }

    func test_board_dropReturnsNilWhenFull() {
        var board = ConnectFourBoard()
        for _ in 0..<ConnectFourBoard.rows {
            board.drop(column: 1, player: .human)
        }
        let result = board.drop(column: 1, player: .ai)
        XCTAssertNil(result)
    }

    func test_board_isFull() {
        var board = ConnectFourBoard()
        XCTAssertFalse(board.isFull)
        for c in 0..<ConnectFourBoard.cols {
            for _ in 0..<ConnectFourBoard.rows {
                board.drop(column: c, player: .human)
            }
        }
        XCTAssertTrue(board.isFull)
    }
}

// MARK: - ConnectFourGameTests

final class ConnectFourGameTests: XCTestCase {

    func makeGame() -> ConnectFourGame {
        var g = ConnectFourGame()
        g.restart()
        return g
    }

    func test_game_initialStateIsWaiting() {
        XCTAssertEqual(ConnectFourGame().state, .waiting)
    }

    func test_game_afterRestartIsPlaying() {
        XCTAssertEqual(makeGame().state, .playing)
    }

    func test_applyMove_dropsPiece() throws {
        var g = makeGame()
        try g.apply(move: ConnectFourMove(column: 0))
        XCTAssertEqual(g.board[0, 0], .human)
    }

    func test_applyMove_switchesPlayer() throws {
        var g = makeGame()
        try g.apply(move: ConnectFourMove(column: 0))
        XCTAssertEqual(g.currentPlayer, .ai)
    }

    func test_applyMove_throwsOnFullColumn() throws {
        var g = makeGame()
        for _ in 0..<ConnectFourBoard.rows {
            // alternate players so game doesn't end on a win
            try g.apply(move: ConnectFourMove(column: 0))
        }
        // Column 0 is full, but game may have ended; let's use a controlled scenario
        // Reset and fill column fresh
        var g2 = makeGame()
        // Fill col 0 with alternating moves
        try g2.apply(move: ConnectFourMove(column: 1)) // human col1
        // Manually fill col0 only if we can avoid a win — use simpler test
        var g3 = makeGame()
        // Fill column 1 completely (7 alternating moves, no 4-in-a-row in col)
        // To avoid a win: spread across columns
        // Simplest: just test the error is thrown
        var g4 = ConnectFourGame()
        g4.restart()
        // Fill col 3 six times alternating
        for i in 0..<ConnectFourBoard.rows {
            let col = i % 2 == 0 ? 3 : 4   // alternate cols to avoid win
            if g4.state == .playing {
                try? g4.apply(move: ConnectFourMove(column: col))
            }
        }
        // Now fill col 3 if not already full
        var g5 = makeGame()
        for _ in 0..<ConnectFourBoard.rows {
            try? g5.apply(move: ConnectFourMove(column: 2))
        }
        if g5.state == .playing {
            XCTAssertThrowsError(try g5.apply(move: ConnectFourMove(column: 2))) { error in
                XCTAssertEqual(error as? BoardGameError, .columnFull)
            }
        }
        // columnFull error check: direct board test
        var board = ConnectFourBoard()
        for _ in 0..<ConnectFourBoard.rows { board.drop(column: 5, player: .human) }
        XCTAssertTrue(board.isColumnFull(5))
    }

    func test_humanWins_horizontally() throws {
        var g = makeGame()
        // Human plays col 0,1,2,3 (AI plays col 0,1,2 in between)
        try g.apply(move: ConnectFourMove(column: 0)) // human
        try g.apply(move: ConnectFourMove(column: 0)) // ai (row 1 col 0)
        try g.apply(move: ConnectFourMove(column: 1)) // human
        try g.apply(move: ConnectFourMove(column: 1)) // ai
        try g.apply(move: ConnectFourMove(column: 2)) // human
        try g.apply(move: ConnectFourMove(column: 2)) // ai
        try g.apply(move: ConnectFourMove(column: 3)) // human wins row 0 cols 0-3
        XCTAssertEqual(g.state, .won(.human))
    }

    func test_humanWins_vertically() throws {
        var g = makeGame()
        // Human stacks col 0 × 4, AI plays col 1 between
        try g.apply(move: ConnectFourMove(column: 0)) // human
        try g.apply(move: ConnectFourMove(column: 1)) // ai
        try g.apply(move: ConnectFourMove(column: 0)) // human
        try g.apply(move: ConnectFourMove(column: 1)) // ai
        try g.apply(move: ConnectFourMove(column: 0)) // human
        try g.apply(move: ConnectFourMove(column: 1)) // ai
        try g.apply(move: ConnectFourMove(column: 0)) // human wins col 0 rows 0-3
        XCTAssertEqual(g.state, .won(.human))
    }

    func test_validMoves_includesAllColumnsAtStart() {
        let g = makeGame()
        XCTAssertEqual(g.validMoves().count, 7)
    }

    func test_restart_resetsState() throws {
        var g = makeGame()
        try g.apply(move: ConnectFourMove(column: 0))
        g.restart()
        XCTAssertEqual(g.state, .playing)
        XCTAssertEqual(g.currentPlayer, .human)
        XCTAssertNil(g.board[0, 0])
    }
}

// MARK: - ConnectFourAITests

final class ConnectFourAITests: XCTestCase {

    let ai = ConnectFourAI(searchDepth: 4)   // shallow depth for tests speed

    func makeGame() -> ConnectFourGame {
        var g = ConnectFourGame()
        g.restart()
        return g
    }

    func test_ai_returnsMove() {
        let g = makeGame()
        XCTAssertNotNil(ai.bestMove(for: g))
    }

    func test_ai_returnsNilWhenGameOver() throws {
        var g = makeGame()
        // Force vertical win for human
        try g.apply(move: ConnectFourMove(column: 0))
        try g.apply(move: ConnectFourMove(column: 1))
        try g.apply(move: ConnectFourMove(column: 0))
        try g.apply(move: ConnectFourMove(column: 1))
        try g.apply(move: ConnectFourMove(column: 0))
        try g.apply(move: ConnectFourMove(column: 1))
        try g.apply(move: ConnectFourMove(column: 0))
        XCTAssertNil(ai.bestMove(for: g))
    }

    func test_ai_blocksHumanThreeInARow() throws {
        var g = makeGame()
        // Human has 3 in row 0, cols 0-2; AI must block col 3
        try g.apply(move: ConnectFourMove(column: 0)) // human
        try g.apply(move: ConnectFourMove(column: 6)) // ai
        try g.apply(move: ConnectFourMove(column: 1)) // human
        try g.apply(move: ConnectFourMove(column: 6)) // ai
        try g.apply(move: ConnectFourMove(column: 2)) // human threatens col 3

        // AI should block at col 3
        let move = ai.bestMove(for: g)
        XCTAssertEqual(move?.column, 3, "AI should block human's horizontal win at col 3")
    }
}

//
//  TicTacToeBoardTests.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import XCTest
@testable import CarSystem

final class TicTacToeBoardTests: XCTestCase {

    func testInitialBoardIsEmpty() {
        let board = TicTacToeBoard()
        XCTAssertEqual(board.cells.count, 9)
        XCTAssertTrue(board.cells.allSatisfy { $0 == .empty })
    }

    func testLegalMovesOnEmptyBoard() {
        let board = TicTacToeBoard()
        XCTAssertEqual(board.legalMoves().count, 9)
    }

    func testApplyMoveChangesCell() {
        let board = TicTacToeBoard()
        let newBoard = board.applying(TicTacToeMove(position: 4))
        XCTAssertEqual(newBoard.cells[4], .x) // human plays X
    }

    func testApplyMoveChangesPlayer() {
        let board = TicTacToeBoard()
        XCTAssertEqual(board.currentPlayer, .human)
        let newBoard = board.applying(TicTacToeMove(position: 0))
        XCTAssertEqual(newBoard.currentPlayer, .ai)
    }

    func testOccupiedCellNotInLegalMoves() {
        let board = TicTacToeBoard()
        let newBoard = board.applying(TicTacToeMove(position: 4))
        let legalPositions = newBoard.legalMoves().map { $0.position }
        XCTAssertFalse(legalPositions.contains(4))
        XCTAssertEqual(legalPositions.count, 8)
    }

    // MARK: - Win Detection

    func testHorizontalWinRow0() {
        // X at 0,1,2
        var board = TicTacToeBoard()
        board = board.applying(TicTacToeMove(position: 0)) // X
        board = board.applying(TicTacToeMove(position: 3)) // O
        board = board.applying(TicTacToeMove(position: 1)) // X
        board = board.applying(TicTacToeMove(position: 4)) // O
        board = board.applying(TicTacToeMove(position: 2)) // X wins
        XCTAssertEqual(board.winner(), .human)
    }

    func testHorizontalWinRow1() {
        // X at 3,4,5
        var board = TicTacToeBoard()
        board = board.applying(TicTacToeMove(position: 3)) // X
        board = board.applying(TicTacToeMove(position: 0)) // O
        board = board.applying(TicTacToeMove(position: 4)) // X
        board = board.applying(TicTacToeMove(position: 1)) // O
        board = board.applying(TicTacToeMove(position: 5)) // X wins
        XCTAssertEqual(board.winner(), .human)
    }

    func testHorizontalWinRow2() {
        // X at 6,7,8
        var board = TicTacToeBoard()
        board = board.applying(TicTacToeMove(position: 6)) // X
        board = board.applying(TicTacToeMove(position: 0)) // O
        board = board.applying(TicTacToeMove(position: 7)) // X
        board = board.applying(TicTacToeMove(position: 1)) // O
        board = board.applying(TicTacToeMove(position: 8)) // X wins
        XCTAssertEqual(board.winner(), .human)
    }

    func testVerticalWinCol0() {
        // X at 0,3,6
        var board = TicTacToeBoard()
        board = board.applying(TicTacToeMove(position: 0)) // X
        board = board.applying(TicTacToeMove(position: 1)) // O
        board = board.applying(TicTacToeMove(position: 3)) // X
        board = board.applying(TicTacToeMove(position: 4)) // O
        board = board.applying(TicTacToeMove(position: 6)) // X wins
        XCTAssertEqual(board.winner(), .human)
    }

    func testVerticalWinCol1() {
        // X at 1,4,7
        var board = TicTacToeBoard()
        board = board.applying(TicTacToeMove(position: 1)) // X
        board = board.applying(TicTacToeMove(position: 0)) // O
        board = board.applying(TicTacToeMove(position: 4)) // X
        board = board.applying(TicTacToeMove(position: 3)) // O
        board = board.applying(TicTacToeMove(position: 7)) // X wins
        XCTAssertEqual(board.winner(), .human)
    }

    func testVerticalWinCol2() {
        // X at 2,5,8
        var board = TicTacToeBoard()
        board = board.applying(TicTacToeMove(position: 2)) // X
        board = board.applying(TicTacToeMove(position: 0)) // O
        board = board.applying(TicTacToeMove(position: 5)) // X
        board = board.applying(TicTacToeMove(position: 3)) // O
        board = board.applying(TicTacToeMove(position: 8)) // X wins
        XCTAssertEqual(board.winner(), .human)
    }

    func testDiagonalWinTopLeftToBottomRight() {
        // X at 0,4,8
        var board = TicTacToeBoard()
        board = board.applying(TicTacToeMove(position: 0)) // X
        board = board.applying(TicTacToeMove(position: 1)) // O
        board = board.applying(TicTacToeMove(position: 4)) // X
        board = board.applying(TicTacToeMove(position: 2)) // O
        board = board.applying(TicTacToeMove(position: 8)) // X wins
        XCTAssertEqual(board.winner(), .human)
    }

    func testDiagonalWinTopRightToBottomLeft() {
        // X at 2,4,6
        var board = TicTacToeBoard()
        board = board.applying(TicTacToeMove(position: 2)) // X
        board = board.applying(TicTacToeMove(position: 0)) // O
        board = board.applying(TicTacToeMove(position: 4)) // X
        board = board.applying(TicTacToeMove(position: 1)) // O
        board = board.applying(TicTacToeMove(position: 6)) // X wins
        XCTAssertEqual(board.winner(), .human)
    }

    func testDrawWhenBoardFull() {
        // X O X
        // X X O
        // O X O  → no winner
        let cells: [TicTacToeCellState] = [.x, .o, .x, .x, .x, .o, .o, .x, .o]
        let board = TicTacToeBoard(cells: cells, currentPlayer: .human)
        XCTAssertNil(board.winner())
        XCTAssertTrue(board.legalMoves().isEmpty)
        XCTAssertTrue(board.isTerminal)
    }

    func testIsTerminalOnWin() {
        var board = TicTacToeBoard()
        board = board.applying(TicTacToeMove(position: 0)) // X
        board = board.applying(TicTacToeMove(position: 3)) // O
        board = board.applying(TicTacToeMove(position: 1)) // X
        board = board.applying(TicTacToeMove(position: 4)) // O
        board = board.applying(TicTacToeMove(position: 2)) // X wins (row 0)
        XCTAssertTrue(board.isTerminal)
    }

    func testIsTerminalOnDraw() {
        let cells: [TicTacToeCellState] = [.x, .o, .x, .x, .x, .o, .o, .x, .o]
        let board = TicTacToeBoard(cells: cells, currentPlayer: .human)
        XCTAssertTrue(board.isTerminal)
    }

    func testNotTerminalMidGame() {
        let board = TicTacToeBoard()
        let newBoard = board.applying(TicTacToeMove(position: 4))
        XCTAssertFalse(newBoard.isTerminal)
    }

    // MARK: - Evaluate

    func testEvaluateWinReturnsPositive() {
        var board = TicTacToeBoard()
        board = board.applying(TicTacToeMove(position: 0))
        board = board.applying(TicTacToeMove(position: 3))
        board = board.applying(TicTacToeMove(position: 1))
        board = board.applying(TicTacToeMove(position: 4))
        board = board.applying(TicTacToeMove(position: 2)) // X wins
        XCTAssertEqual(board.evaluate(for: .human), 1000)
        XCTAssertEqual(board.evaluate(for: .ai), -1000)
    }
}

//
//  TicTacToeRendererTests.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import XCTest
@testable import CarSystem

final class TicTacToeRendererTests: XCTestCase {

    let renderer = TicTacToeRenderer()

    func testRenderEmptyBoard() {
        let board = TicTacToeBoard()
        let output = renderer.render(board: board, state: .playing(currentPlayer: .human))

        // Should contain title
        XCTAssertTrue(output.contains("Tic-Tac-Toe"))
        // Should contain grid lines
        XCTAssertTrue(output.contains("┌───┬───┬───┐"))
        XCTAssertTrue(output.contains("└───┴───┴───┘"))
        // Should contain column headers
        XCTAssertTrue(output.contains("1"))
        XCTAssertTrue(output.contains("2"))
        XCTAssertTrue(output.contains("3"))
        // Should contain row labels
        XCTAssertTrue(output.contains("A"))
        XCTAssertTrue(output.contains("B"))
        XCTAssertTrue(output.contains("C"))
    }

    func testRenderMidGame() {
        var board = TicTacToeBoard()
        board = board.applying(TicTacToeMove(position: 4)) // X at center
        board = board.applying(TicTacToeMove(position: 0)) // O at top-left

        let output = renderer.render(board: board, state: .playing(currentPlayer: .human))
        XCTAssertTrue(output.contains("❌"))
        XCTAssertTrue(output.contains("⭕"))
    }

    func testRenderWinMessage() {
        var board = TicTacToeBoard()
        board = board.applying(TicTacToeMove(position: 0))
        board = board.applying(TicTacToeMove(position: 3))
        board = board.applying(TicTacToeMove(position: 1))
        board = board.applying(TicTacToeMove(position: 4))
        board = board.applying(TicTacToeMove(position: 2)) // X wins

        let output = renderer.render(board: board, state: .gameOver(result: .win(player: .human)))
        XCTAssertTrue(output.contains("❌") && output.contains("wins") || output.contains("勝"))
    }

    func testRenderDrawMessage() {
        let cells: [TicTacToeCellState] = [.x, .o, .x, .x, .x, .o, .o, .x, .o]
        let board = TicTacToeBoard(cells: cells, currentPlayer: .human)

        let output = renderer.render(board: board, state: .gameOver(result: .draw))
        XCTAssertTrue(output.contains("Draw") || output.contains("平手"))
    }

    func testRenderCurrentPlayerTurn() {
        let board = TicTacToeBoard()
        let output = renderer.render(board: board, state: .playing(currentPlayer: .human))
        XCTAssertTrue(output.contains("❌") && output.contains("turn"))
    }
}

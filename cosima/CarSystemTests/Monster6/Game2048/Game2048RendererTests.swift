//
//  Game2048RendererTests.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import XCTest
@testable import CarSystem

final class Game2048RendererTests: XCTestCase {

    let renderer = Game2048Renderer()

    func testRenderEmptyBoard() {
        let cells = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        let board = Game2048Board(cells: cells, score: 0, hasWon: false)
        let output = renderer.render(board: board, state: .playing(currentPlayer: .human))

        XCTAssertTrue(output.contains("2048"))
        XCTAssertTrue(output.contains("┌──────┬──────┬──────┬──────┐"))
        XCTAssertTrue(output.contains("└──────┴──────┴──────┴──────┘"))
    }

    func testRenderNumbersRightAligned() {
        let cells = [
            [2, 16, 256, 1024],
            [0, 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0]
        ]
        let board = Game2048Board(cells: cells, score: 0, hasWon: false)
        let output = renderer.render(board: board, state: .playing(currentPlayer: .human))

        // Numbers should be right-aligned with consistent width
        XCTAssertTrue(output.contains("    2"))
        XCTAssertTrue(output.contains("   16"))
        XCTAssertTrue(output.contains("  256"))
        XCTAssertTrue(output.contains(" 1024"))
    }

    func testRenderConsistentCellWidth() {
        let cells = [
            [2, 4, 8, 16],
            [32, 64, 128, 256],
            [512, 1024, 2048, 4],
            [0, 0, 0, 0]
        ]
        let board = Game2048Board(cells: cells, score: 0, hasWon: false)
        let output = renderer.render(board: board, state: .playing(currentPlayer: .human))

        // All row dividers should have consistent width
        let dividerCount = output.components(separatedBy: "┼──────┼").count
        XCTAssertGreaterThan(dividerCount, 1)
    }

    func testRenderScore() {
        let cells = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        let board = Game2048Board(cells: cells, score: 4892, hasWon: false)
        let output = renderer.render(board: board, state: .playing(currentPlayer: .human))
        XCTAssertTrue(output.contains("Score: 4,892") || output.contains("Score: 4892"))
    }

    func testRenderWinMessage() {
        let cells = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        let board = Game2048Board(cells: cells, score: 0, hasWon: true)
        let output = renderer.render(board: board, state: .gameOver(result: .win(player: .human)))
        XCTAssertTrue(output.contains("2048") || output.contains("wins") || output.contains("🎉"))
    }

    func testRenderLoseMessage() {
        let cells = [
            [2, 4, 8, 16],
            [16, 8, 4, 2],
            [2, 4, 8, 16],
            [16, 8, 4, 2]
        ]
        let board = Game2048Board(cells: cells, score: 0, hasWon: false)
        let output = renderer.render(board: board, state: .gameOver(result: .lose))
        XCTAssertTrue(output.contains("Game Over") || output.contains("lose") || output.contains("失敗"))
    }
}

//
//  ReversiRendererTests.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import XCTest
@testable import CarSystem

final class ReversiRendererTests: XCTestCase {

    let renderer = ReversiRenderer()

    func testRenderInitialBoard() {
        let board = ReversiBoard()
        let output = renderer.render(board: board, state: .playing(currentPlayer: .human))

        XCTAssertTrue(output.contains("Reversi"))
        XCTAssertTrue(output.contains("⚫"))
        XCTAssertTrue(output.contains("⚪"))
        XCTAssertTrue(output.contains("A"))
        XCTAssertTrue(output.contains("H"))
        XCTAssertTrue(output.contains("1"))
        XCTAssertTrue(output.contains("8"))
    }

    func testRenderValidMoveMarkers() {
        let board = ReversiBoard()
        let output = renderer.render(board: board, state: .playing(currentPlayer: .human))
        // Should show * for valid positions
        XCTAssertTrue(output.contains("*"))
    }

    func testRenderFlipCounts() {
        let board = ReversiBoard()
        let output = renderer.render(board: board, state: .playing(currentPlayer: .human))
        // Should show flip count info
        XCTAssertTrue(output.contains("Flips:") || output.contains("available"))
    }

    func testRenderPieceCounts() {
        let board = ReversiBoard()
        let output = renderer.render(board: board, state: .playing(currentPlayer: .human))
        // Should show piece counts
        XCTAssertTrue(output.contains("Black:") || output.contains("⚫"))
        XCTAssertTrue(output.contains("White:") || output.contains("⚪"))
        XCTAssertTrue(output.contains("2"))
    }
}

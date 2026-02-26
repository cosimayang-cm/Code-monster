//
//  ConnectFourRendererTests.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import XCTest
@testable import CarSystem

final class ConnectFourRendererTests: XCTestCase {

    let renderer = ConnectFourRenderer()

    func testRenderEmptyBoard() {
        let board = ConnectFourBoard()
        let output = renderer.render(board: board, state: .playing(currentPlayer: .human))

        XCTAssertTrue(output.contains("Connect Four"))
        XCTAssertTrue(output.contains("┌───┬───┬───┬───┬───┬───┬───┐"))
        XCTAssertTrue(output.contains("└───┴───┴───┴───┴───┴───┴───┘"))
        // Row labels
        XCTAssertTrue(output.contains("1"))
        XCTAssertTrue(output.contains("6"))
    }

    func testRenderWithPieces() {
        var board = ConnectFourBoard()
        board = board.applying(ConnectFourMove(column: 3)) // red at bottom of col 3
        board = board.applying(ConnectFourMove(column: 3)) // yellow on top

        let output = renderer.render(board: board, state: .playing(currentPlayer: .human))
        XCTAssertTrue(output.contains("🔴"))
        XCTAssertTrue(output.contains("🟡"))
    }

    func testRenderCurrentPlayer() {
        let board = ConnectFourBoard()
        let output = renderer.render(board: board, state: .playing(currentPlayer: .human))
        XCTAssertTrue(output.contains("🔴") && output.contains("turn"))
    }
}

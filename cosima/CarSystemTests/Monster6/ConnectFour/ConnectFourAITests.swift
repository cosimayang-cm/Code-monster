//
//  ConnectFourAITests.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import XCTest
@testable import CarSystem

final class ConnectFourAITests: XCTestCase {

    let ai = ConnectFourAI()

    func testAIBlocksHorizontalThreat() {
        // Human has 3 in a row at bottom: cols 0,1,2 → AI must block col 3
        var columns: [[ConnectFourCellState]] = Array(repeating: [], count: 7)
        columns[0] = [.red]
        columns[1] = [.red]
        columns[2] = [.red]
        let board = ConnectFourBoard(columns: columns, currentPlayer: .ai)
        let move = ai.bestMove(for: board)
        XCTAssertNotNil(move)
        // AI should block at column 3 (or column -1 which doesn't exist, so must be 3)
        XCTAssertEqual(move?.column, 3)
    }

    func testAIBlocksVerticalThreat() {
        // Human has 3 stacked in column 0 → AI must block by placing on top
        var columns: [[ConnectFourCellState]] = Array(repeating: [], count: 7)
        columns[0] = [.red, .red, .red]
        columns[1] = [.yellow, .yellow]
        let board = ConnectFourBoard(columns: columns, currentPlayer: .ai)
        let move = ai.bestMove(for: board)
        XCTAssertNotNil(move)
        XCTAssertEqual(move?.column, 0) // must cap column 0
    }

    func testAITakesWinningMove() {
        // AI has 3 in a row at bottom: cols 0,1,2 → should complete at col 3
        var columns: [[ConnectFourCellState]] = Array(repeating: [], count: 7)
        columns[0] = [.yellow]
        columns[1] = [.yellow]
        columns[2] = [.yellow]
        columns[4] = [.red, .red, .red] // human pieces elsewhere
        let board = ConnectFourBoard(columns: columns, currentPlayer: .ai)
        let move = ai.bestMove(for: board)
        XCTAssertNotNil(move)
        XCTAssertEqual(move?.column, 3)
    }

    func testAIPrefersCenter() {
        // On empty board, AI should prefer center column (3)
        let board = ConnectFourBoard(currentPlayer: .ai)
        let move = ai.bestMove(for: board)
        XCTAssertNotNil(move)
        XCTAssertEqual(move?.column, 3) // center column preferred
    }
}

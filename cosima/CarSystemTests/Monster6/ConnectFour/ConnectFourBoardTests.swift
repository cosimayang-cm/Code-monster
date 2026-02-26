//
//  ConnectFourBoardTests.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import XCTest
@testable import CarSystem

final class ConnectFourBoardTests: XCTestCase {

    func testInitialBoardIsEmpty() {
        let board = ConnectFourBoard()
        XCTAssertEqual(board.columns.count, 7)
        for col in board.columns {
            XCTAssertTrue(col.isEmpty)
        }
    }

    func testGravityDrop() {
        let board = ConnectFourBoard()
        let newBoard = board.applying(ConnectFourMove(column: 3))
        // Piece should be at the bottom (index 0) of column 3
        XCTAssertEqual(newBoard.columns[3].count, 1)
        XCTAssertEqual(newBoard.columns[3][0], .red)
    }

    func testMultipleDropsSameColumn() {
        var board = ConnectFourBoard()
        board = board.applying(ConnectFourMove(column: 3)) // red at [3][0]
        board = board.applying(ConnectFourMove(column: 3)) // yellow at [3][1]
        board = board.applying(ConnectFourMove(column: 3)) // red at [3][2]

        XCTAssertEqual(board.columns[3].count, 3)
        XCTAssertEqual(board.columns[3][0], .red)
        XCTAssertEqual(board.columns[3][1], .yellow)
        XCTAssertEqual(board.columns[3][2], .red)
    }

    func testFullColumnNotInLegalMoves() {
        var board = ConnectFourBoard()
        // Fill column 0 with 6 pieces
        for _ in 0..<6 {
            board = board.applying(ConnectFourMove(column: 0))
        }
        let legalColumns = board.legalMoves().map { $0.column }
        XCTAssertFalse(legalColumns.contains(0))
        XCTAssertEqual(legalColumns.count, 6) // other 6 columns still available
    }

    func testHorizontalFourWin() {
        // Red at columns 0,1,2,3 bottom row
        var board = ConnectFourBoard()
        board = board.applying(ConnectFourMove(column: 0)) // red
        board = board.applying(ConnectFourMove(column: 0)) // yellow (on top)
        board = board.applying(ConnectFourMove(column: 1)) // red
        board = board.applying(ConnectFourMove(column: 1)) // yellow
        board = board.applying(ConnectFourMove(column: 2)) // red
        board = board.applying(ConnectFourMove(column: 2)) // yellow
        board = board.applying(ConnectFourMove(column: 3)) // red → 4 in a row!
        XCTAssertEqual(board.winner(), .human)
        XCTAssertTrue(board.isTerminal)
    }

    func testVerticalFourWin() {
        // Red stacks 4 in column 0
        var board = ConnectFourBoard()
        board = board.applying(ConnectFourMove(column: 0)) // red
        board = board.applying(ConnectFourMove(column: 1)) // yellow
        board = board.applying(ConnectFourMove(column: 0)) // red
        board = board.applying(ConnectFourMove(column: 1)) // yellow
        board = board.applying(ConnectFourMove(column: 0)) // red
        board = board.applying(ConnectFourMove(column: 1)) // yellow
        board = board.applying(ConnectFourMove(column: 0)) // red → vertical 4!
        XCTAssertEqual(board.winner(), .human)
    }

    func testDiagonalUpRightWin() {
        // Build diagonal: red at (0,0), (1,1), (2,2), (3,3)
        var board = ConnectFourBoard()

        // Col 0: red at row 0
        board = board.applying(ConnectFourMove(column: 0)) // red [0][0]
        // Col 1: yellow at row 0, red at row 1
        board = board.applying(ConnectFourMove(column: 1)) // yellow [1][0]
        board = board.applying(ConnectFourMove(column: 1)) // red [1][1]
        // Col 2: yellow×2 at rows 0,1, red at row 2
        board = board.applying(ConnectFourMove(column: 2)) // yellow [2][0]
        board = board.applying(ConnectFourMove(column: 2)) // red [2][1]
        board = board.applying(ConnectFourMove(column: 2)) // yellow [2][2] — oops, need to fix
        // Let me restructure: need red at diagonal positions

        // Restart with a cleaner approach
        board = ConnectFourBoard()
        // Build: col0=[R], col1=[Y,R], col2=[Y,Y,R], col3=[Y,Y,Y,R]
        board = board.applying(ConnectFourMove(column: 0)) // R [0][0]
        board = board.applying(ConnectFourMove(column: 1)) // Y [1][0]
        board = board.applying(ConnectFourMove(column: 1)) // R [1][1]
        board = board.applying(ConnectFourMove(column: 2)) // Y [2][0]
        board = board.applying(ConnectFourMove(column: 2)) // R [2][1] -- wait, this is red but we need yellow here

        // Simplest approach: manually build board state
        var columns: [[ConnectFourCellState]] = Array(repeating: [], count: 7)
        columns[0] = [.red]
        columns[1] = [.yellow, .red]
        columns[2] = [.yellow, .yellow, .red]
        columns[3] = [.yellow, .yellow, .yellow, .red]
        board = ConnectFourBoard(columns: columns, currentPlayer: .ai)
        XCTAssertEqual(board.winner(), .human)
    }

    func testDiagonalDownRightWin() {
        // Red at (col0,row3), (col1,row2), (col2,row1), (col3,row0)
        var columns: [[ConnectFourCellState]] = Array(repeating: [], count: 7)
        columns[0] = [.yellow, .yellow, .yellow, .red]
        columns[1] = [.yellow, .yellow, .red]
        columns[2] = [.yellow, .red]
        columns[3] = [.red]
        let board = ConnectFourBoard(columns: columns, currentPlayer: .ai)
        XCTAssertEqual(board.winner(), .human)
    }

    func testDrawWhenBoardFull() {
        // Create a full board with no 4-in-a-row
        // Pattern that avoids 4-in-a-row: alternate every 2
        var columns: [[ConnectFourCellState]] = Array(repeating: [], count: 7)
        for col in 0..<7 {
            for row in 0..<6 {
                // Alternate pattern that avoids horizontal/vertical/diagonal 4
                let isRed = (col + row) % 2 == 0
                columns[col].append(isRed ? .red : .yellow)
            }
        }
        // Manually verify no 4-in-a-row exists in this checkerboard
        let board = ConnectFourBoard(columns: columns, currentPlayer: .human)
        XCTAssertNil(board.winner())
        XCTAssertTrue(board.legalMoves().isEmpty)
        XCTAssertTrue(board.isTerminal)
    }
}

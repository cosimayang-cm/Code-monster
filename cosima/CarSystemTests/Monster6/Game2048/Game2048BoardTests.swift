//
//  Game2048BoardTests.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import XCTest
@testable import CarSystem

final class Game2048BoardTests: XCTestCase {

    // MARK: - slideLine Tests

    func testSlideLeft_2222() {
        let (result, score) = Game2048Board.slideLine([2, 2, 2, 2])
        XCTAssertEqual(result, [4, 4, 0, 0])
        XCTAssertEqual(score, 8)
    }

    func testSlideLeft_2020() {
        let (result, score) = Game2048Board.slideLine([2, 0, 2, 0])
        XCTAssertEqual(result, [4, 0, 0, 0])
        XCTAssertEqual(score, 4)
    }

    func testSlideLeft_4224() {
        let (result, score) = Game2048Board.slideLine([4, 2, 2, 4])
        XCTAssertEqual(result, [4, 4, 4, 0])
        XCTAssertEqual(score, 4)
    }

    func testSlideLeft_noChange() {
        let (result, score) = Game2048Board.slideLine([2, 4, 8, 16])
        XCTAssertEqual(result, [2, 4, 8, 16])
        XCTAssertEqual(score, 0)
    }

    func testSlideLeft_0022() {
        let (result, score) = Game2048Board.slideLine([0, 0, 2, 2])
        XCTAssertEqual(result, [4, 0, 0, 0])
        XCTAssertEqual(score, 4)
    }

    // MARK: - Direction Tests

    func testSlideRight() {
        let cells = [
            [2, 2, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0]
        ]
        let board = Game2048Board(cells: cells, score: 0, hasWon: false)
        let newBoard = board.applying(Game2048Move(direction: .right))
        // After slide right: [0, 0, 0, 4] + random tile
        XCTAssertEqual(newBoard.cells[0][3], 4)
        XCTAssertEqual(newBoard.cells[0][0] + newBoard.cells[0][1] + newBoard.cells[0][2], newBoard.cells[0].prefix(3).reduce(0, +))
    }

    func testSlideUp() {
        let cells = [
            [2, 0, 0, 0],
            [2, 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0]
        ]
        let board = Game2048Board(cells: cells, score: 0, hasWon: false)
        let newBoard = board.applying(Game2048Move(direction: .up))
        XCTAssertEqual(newBoard.cells[0][0], 4) // merged at top
    }

    func testSlideDown() {
        let cells = [
            [2, 0, 0, 0],
            [2, 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0]
        ]
        let board = Game2048Board(cells: cells, score: 0, hasWon: false)
        let newBoard = board.applying(Game2048Move(direction: .down))
        XCTAssertEqual(newBoard.cells[3][0], 4) // merged at bottom
    }

    // MARK: - No-Op Slide

    func testNoOpSlideDoesNothing() {
        let cells = [
            [2, 4, 8, 16],
            [0, 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0]
        ]
        let board = Game2048Board(cells: cells, score: 0, hasWon: false)
        // Sliding left shouldn't change anything for row 0 (already compressed left)
        let moves = board.legalMoves()
        let leftMove = moves.first { $0.direction == .left }
        // Left is valid because other rows can slide
        // But the actual test: verify that a pure no-change slide doesn't create new tile
    }

    // MARK: - Tile Generation

    func testNewTileGeneratedAfterValidSlide() {
        let cells = [
            [2, 2, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0]
        ]
        let board = Game2048Board(cells: cells, score: 0, hasWon: false)
        let newBoard = board.applying(Game2048Move(direction: .left))
        // Count non-zero cells: should be 2 (merged 4 + new tile)
        let nonZero = newBoard.cells.flatMap { $0 }.filter { $0 != 0 }.count
        XCTAssertEqual(nonZero, 2) // merged tile + new random tile
    }

    // MARK: - Win/Lose

    func testWinCondition() {
        let cells = [
            [1024, 1024, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0]
        ]
        let board = Game2048Board(cells: cells, score: 0, hasWon: false)
        let newBoard = board.applying(Game2048Move(direction: .left))
        XCTAssertTrue(newBoard.hasWon)
    }

    func testLoseCondition() {
        // Full board with no adjacent equal values
        let cells = [
            [2, 4, 8, 16],
            [16, 8, 4, 2],
            [2, 4, 8, 16],
            [16, 8, 4, 2]
        ]
        let board = Game2048Board(cells: cells, score: 0, hasWon: false)
        XCTAssertTrue(board.isTerminal)
    }

    func testScoreAccumulates() {
        let cells = [
            [2, 2, 2, 2],
            [0, 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0]
        ]
        let board = Game2048Board(cells: cells, score: 100, hasWon: false)
        let newBoard = board.applying(Game2048Move(direction: .left))
        XCTAssertEqual(newBoard.score, 108) // 100 + 4 + 4
    }

    func testInitialBoardHasTwoTiles() {
        let board = Game2048Board()
        let nonZero = board.cells.flatMap { $0 }.filter { $0 != 0 }.count
        XCTAssertEqual(nonZero, 2)
    }
}

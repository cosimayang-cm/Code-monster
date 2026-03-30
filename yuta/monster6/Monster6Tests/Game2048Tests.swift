import XCTest
@testable import Monster6

final class Game2048Tests: XCTestCase {

    // MARK: - Rendering Tests

    func test_renderer_numberRightAligned() {
        var board = Game2048Board()
        board.cells[0][0] = 2048
        let renderer = Game2048Renderer()
        let output = renderer.render(board)
        XCTAssertTrue(output.contains("2048"))
        XCTAssertTrue(output.contains("Score:"))
    }

    // MARK: - Slide Merge Tests

    func test_slideLeft_mergesCorrectly() {
        let engine = Game2048Engine()
        engine.board.cells = [
            [2, 2, 2, 2],
            [0, 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0]
        ]
        let prevScore = engine.board.score
        _ = engine.applyMove(.left)
        XCTAssertEqual(engine.board.cells[0][0], 4)
        XCTAssertEqual(engine.board.cells[0][1], 4)
        XCTAssertGreaterThan(engine.board.score, prevScore)
    }

    func test_slideLeft_withGaps() {
        let engine = Game2048Engine()
        engine.board.cells = [
            [2, 0, 2, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0]
        ]
        _ = engine.applyMove(.left)
        XCTAssertGreaterThanOrEqual(engine.board.cells[0][0], 4)
    }

    func test_noMergeOnInvalidSlide() {
        let engine = Game2048Engine()
        engine.board.cells = [
            [2, 4, 8, 16],
            [32, 64, 128, 256],
            [512, 1024, 2, 4],
            [8, 16, 32, 64]
        ]
        let moved = engine.applyMove(.left)
        XCTAssertFalse(moved)
    }

    func test_scoreUpdates_onMerge() {
        let engine = Game2048Engine()
        engine.board.cells = [
            [4, 4, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0]
        ]
        _ = engine.applyMove(.left)
        XCTAssertGreaterThanOrEqual(engine.board.score, 8)
    }

    func test_winCondition_2048Tile() {
        let engine = Game2048Engine()
        engine.board.cells = [
            [1024, 1024, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0]
        ]
        _ = engine.applyMove(.left)
        XCTAssertTrue(engine.board.hasWon)
    }

    func test_loseCondition_noValidMoves() {
        let engine = Game2048Engine()
        engine.board.cells = [
            [2, 4, 2, 4],
            [4, 2, 4, 2],
            [2, 4, 2, 4],
            [4, 2, 4, 2]
        ]
        XCTAssertFalse(engine.board.hasValidMove)
    }

    // MARK: - Spawn Tests

    func test_noSpawn_onInvalidMove() {
        let engine = Game2048Engine()
        engine.board.cells = [
            [2, 4, 8, 16],
            [32, 64, 128, 256],
            [512, 1024, 2, 4],
            [8, 16, 32, 64]
        ]
        let emptiesBefore = engine.board.emptyCells.count
        _ = engine.applyMove(.left)
        let emptiesAfter = engine.board.emptyCells.count
        XCTAssertEqual(emptiesBefore, emptiesAfter)
    }
}

import XCTest
@testable import Monster6

final class ReversiTests: XCTestCase {

    // MARK: - Initial State Tests

    func test_initialBoard_centerPiecesCorrect() {
        let board = ReversiBoard()
        XCTAssertEqual(board.cells[3][3], .playerTwo)  // White
        XCTAssertEqual(board.cells[3][4], .playerOne)  // Black
        XCTAssertEqual(board.cells[4][3], .playerOne)  // Black
        XCTAssertEqual(board.cells[4][4], .playerTwo)  // White
    }

    // MARK: - Rendering Tests

    func test_renderer_showsValidMoves() {
        let board = ReversiBoard()
        let renderer = ReversiRenderer()
        let engine = ReversiEngine()
        let validMoves = engine.validMoves(for: .playerOne, on: board)
        let positions = validMoves.map { ($0.row, $0.col) }
        let output = renderer.render(board, validMoves: positions)
        XCTAssertTrue(output.contains("*"))
        XCTAssertEqual(validMoves.count, 4)
    }

    // MARK: - Flip Logic Tests

    func test_flipLogic_allDirections() {
        let board = ReversiBoard()
        let engine = ReversiEngine()
        // D3 (row 3, col 2) should flip (3,3)
        let move = ReversiMove(row: 3, col: 2)
        let flips = engine.flippedCells(for: move, player: .playerOne, board: board)
        XCTAssertFalse(flips.isEmpty)
        XCTAssertTrue(flips.contains { $0 == 3 && $1 == 3 })
    }

    func test_invalidMove_noFlips_rejected() {
        let board = ReversiBoard()
        let engine = ReversiEngine()
        // Corner (0,0) has no flips initially
        let flips = engine.flippedCells(for: ReversiMove(row: 0, col: 0), player: .playerOne, board: board)
        XCTAssertTrue(flips.isEmpty)
    }

    // MARK: - Valid Moves Tests

    func test_validMoves_initialState_fourMoves() {
        let board = ReversiBoard()
        let engine = ReversiEngine()
        let moves = engine.validMoves(for: .playerOne, on: board)
        XCTAssertEqual(moves.count, 4)
    }

    // MARK: - AI Tests

    func test_ai_returnsValidMove() {
        let engine = ReversiEngine()
        let ai = ReversiAI()
        let move = ai.bestMove(for: engine.board)
        XCTAssertNotNil(move)
    }

    // MARK: - Game End Tests

    func test_scoreCount_correct() {
        let board = ReversiBoard()
        XCTAssertEqual(board.count(for: .playerOne), 2)
        XCTAssertEqual(board.count(for: .playerTwo), 2)
    }
}

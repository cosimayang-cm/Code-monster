import XCTest
@testable import Monster6

final class ConnectFourTests: XCTestCase {

    // MARK: - Board Rendering Tests

    func test_renderer_emptyBoard() {
        let board = ConnectFourBoard()
        let renderer = ConnectFourRenderer()
        let output = renderer.render(board)
        XCTAssertTrue(output.contains("Connect Four"))
        XCTAssertTrue(output.contains("1   2   3   4   5   6   7"))
    }

    // MARK: - Gravity Tests

    func test_dropPiece_landAtBottom() {
        var board = ConnectFourBoard()
        let row = board.dropPiece(col: 0, player: .playerOne)
        XCTAssertEqual(row, ConnectFourBoard.rows - 1)
        XCTAssertEqual(board.cells[ConnectFourBoard.rows - 1][0], .playerOne)
    }

    func test_dropPiece_stacksCorrectly() {
        var board = ConnectFourBoard()
        _ = board.dropPiece(col: 0, player: .playerOne)
        let row = board.dropPiece(col: 0, player: .playerTwo)
        XCTAssertEqual(row, ConnectFourBoard.rows - 2)
    }

    func test_fullColumn_rejectsMove() {
        let engine = ConnectFourEngine()
        for i in 0..<ConnectFourBoard.rows {
            let player: Player = i % 2 == 0 ? .playerOne : .playerTwo
            engine.board.cells[i][0] = player
        }
        XCTAssertTrue(engine.board.isColumnFull(0))
    }

    // MARK: - Win Detection Tests

    func test_winDetection_horizontal() {
        let engine = ConnectFourEngine()
        for col in 0..<4 {
            engine.board.cells[ConnectFourBoard.rows - 1][col] = .playerOne
        }
        XCTAssertTrue(engine.checkWin(for: .playerOne))
    }

    func test_winDetection_vertical() {
        let engine = ConnectFourEngine()
        for row in (ConnectFourBoard.rows - 4)..<ConnectFourBoard.rows {
            engine.board.cells[row][0] = .playerOne
        }
        XCTAssertTrue(engine.checkWin(for: .playerOne))
    }

    func test_winDetection_diagonal() {
        let engine = ConnectFourEngine()
        for i in 0..<4 {
            engine.board.cells[i][i] = .playerOne
        }
        XCTAssertTrue(engine.checkWin(for: .playerOne))
    }

    // MARK: - AI Tests

    func test_ai_blocksObviousWin() {
        let engine = ConnectFourEngine()
        for col in 0..<3 {
            engine.board.cells[ConnectFourBoard.rows - 1][col] = .playerOne
        }
        let ai = ConnectFourAI()
        let move = ai.bestMove(for: engine.board)
        XCTAssertEqual(move?.col, 3)
    }
}

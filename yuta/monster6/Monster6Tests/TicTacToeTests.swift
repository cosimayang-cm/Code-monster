import XCTest
@testable import Monster6

final class TicTacToeTests: XCTestCase {

    // MARK: - Board Rendering Tests

    func test_renderer_emptyBoard_containsCorrectSymbols() {
        let board = TicTacToeBoard()
        let renderer = TicTacToeRenderer()
        let output = renderer.render(board)
        XCTAssertTrue(output.contains("Tic-Tac-Toe"))
        XCTAssertTrue(output.contains("┌"))
        XCTAssertTrue(output.contains("└"))
    }

    // MARK: - Move Validation Tests

    func test_applyMove_emptyCell_succeeds() {
        let engine = TicTacToeEngine()
        let result = engine.applyMove(TicTacToeMove(row: 0, col: 0))
        XCTAssertTrue(result)
        XCTAssertEqual(engine.board.cell(row: 0, col: 0), .playerOne)
    }

    func test_applyMove_occupiedCell_fails() {
        let engine = TicTacToeEngine()
        _ = engine.applyMove(TicTacToeMove(row: 0, col: 0))
        let result = engine.applyMove(TicTacToeMove(row: 0, col: 0))
        XCTAssertFalse(result)
    }

    // MARK: - Win Detection Tests

    func test_winDetection_horizontalRow0() {
        let engine = TicTacToeEngine()
        _ = engine.applyMove(TicTacToeMove(row: 0, col: 0)) // P1
        _ = engine.applyMove(TicTacToeMove(row: 1, col: 0)) // P2
        _ = engine.applyMove(TicTacToeMove(row: 0, col: 1)) // P1
        _ = engine.applyMove(TicTacToeMove(row: 1, col: 1)) // P2
        _ = engine.applyMove(TicTacToeMove(row: 0, col: 2)) // P1 wins

        if case .finished(let result) = engine.state {
            XCTAssertEqual(result, .win(player: .playerOne))
        } else {
            XCTFail("Expected finished state")
        }
    }

    func test_winDetection_vertical() {
        let engine = TicTacToeEngine()
        _ = engine.applyMove(TicTacToeMove(row: 0, col: 0)) // P1
        _ = engine.applyMove(TicTacToeMove(row: 0, col: 1)) // P2
        _ = engine.applyMove(TicTacToeMove(row: 1, col: 0)) // P1
        _ = engine.applyMove(TicTacToeMove(row: 1, col: 1)) // P2
        _ = engine.applyMove(TicTacToeMove(row: 2, col: 0)) // P1 wins col 0

        if case .finished(let result) = engine.state {
            XCTAssertEqual(result, .win(player: .playerOne))
        } else {
            XCTFail("Expected finished state")
        }
    }

    func test_winDetection_diagonal() {
        let engine = TicTacToeEngine()
        _ = engine.applyMove(TicTacToeMove(row: 0, col: 0)) // P1
        _ = engine.applyMove(TicTacToeMove(row: 0, col: 1)) // P2
        _ = engine.applyMove(TicTacToeMove(row: 1, col: 1)) // P1
        _ = engine.applyMove(TicTacToeMove(row: 0, col: 2)) // P2
        _ = engine.applyMove(TicTacToeMove(row: 2, col: 2)) // P1 wins diagonal

        if case .finished(let result) = engine.state {
            XCTAssertEqual(result, .win(player: .playerOne))
        } else {
            XCTFail("Expected finished state")
        }
    }

    func test_winDetection_draw() {
        let engine = TicTacToeEngine()
        // Fill board to draw: X O X / O X O / O X O
        let moves = [
            (0,0),(0,1),(0,2),
            (1,1),(1,0),(1,2),
            (2,1),(2,0),(2,2)
        ]
        for (r, c) in moves {
            _ = engine.applyMove(TicTacToeMove(row: r, col: c))
        }
        if case .finished(let result) = engine.state {
            XCTAssertEqual(result, .draw)
        } else {
            XCTFail("Expected draw")
        }
    }

    // MARK: - AI Tests

    func test_hardAI_neverLoses_asSecondPlayer() {
        for _ in 0..<10 {
            let engine = TicTacToeEngine()
            let ai = TicTacToeAI()

            while case .playing(let current) = engine.state {
                if current == .playerOne {
                    let empties = (0..<3).flatMap { r in (0..<3).map { c in (r, c) } }
                        .filter { engine.board.cell(row: $0.0, col: $0.1) == .none }
                    if let (r, c) = empties.randomElement() {
                        _ = engine.applyMove(TicTacToeMove(row: r, col: c))
                    }
                } else {
                    if let move = ai.bestMove(for: engine.board) {
                        _ = engine.applyMove(move)
                    }
                }
            }

            if case .finished(let result) = engine.state {
                XCTAssertNotEqual(result, .win(player: .playerOne), "AI lost!")
            }
        }
    }
}

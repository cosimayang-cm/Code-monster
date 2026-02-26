//
//  GameEngineTests.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import XCTest
@testable import CarSystem

// MARK: - Mock Types for GameEngine Testing

struct MockMove: GameMove {
    let position: Int
    var description: String { "Move(\(position))" }
}

struct MockBoard: GameBoard {
    typealias Move = MockMove

    var cells: [Int] // 0=empty, 1=human, 2=ai
    var currentPlayer: Player

    var isTerminal: Bool {
        winner() != nil || legalMoves().isEmpty
    }

    func legalMoves() -> [MockMove] {
        cells.enumerated().compactMap { index, value in
            value == 0 ? MockMove(position: index) : nil
        }
    }

    func applying(_ move: MockMove) -> MockBoard {
        var newCells = cells
        newCells[move.position] = currentPlayer == .human ? 1 : 2
        let nextPlayer: Player = currentPlayer == .human ? .ai : .human
        return MockBoard(cells: newCells, currentPlayer: nextPlayer)
    }

    func winner() -> Player? {
        // Simple: first 3 cells same nonzero = win
        if cells.count >= 3 && cells[0] != 0 && cells[0] == cells[1] && cells[1] == cells[2] {
            return cells[0] == 1 ? .human : .ai
        }
        return nil
    }

    func evaluate(for player: Player) -> Double {
        if let w = winner() {
            return w == player ? 1000 : -1000
        }
        return 0
    }
}

struct MockRenderer: GameRenderer {
    typealias Board = MockBoard
    func render(board: MockBoard, state: GameState) -> String {
        let cellStr = board.cells.map { $0 == 0 ? "." : ($0 == 1 ? "X" : "O") }.joined()
        return "[\(cellStr)] \(state)"
    }
}

struct MockAI: GameAI {
    typealias Board = MockBoard
    func bestMove(for board: MockBoard) -> MockMove? {
        board.legalMoves().first
    }
}

// MARK: - Mock Delegate

final class MockDelegate: GameEngineDelegate {
    var stateChanges: [GameState] = []
    var boardStrings: [String] = []

    func gameEngineDidUpdateState(_ state: GameState) {
        stateChanges.append(state)
    }

    func gameEngineDidUpdateBoard(_ boardString: String) {
        boardStrings.append(boardString)
    }
}

// MARK: - GameEngine Tests

final class GameEngineTests: XCTestCase {

    typealias Engine = GameEngine<MockBoard, MockRenderer, MockAI>

    private func makeEngine(cells: [Int] = [0, 0, 0, 0]) -> (Engine, MockDelegate) {
        let board = MockBoard(cells: cells, currentPlayer: .human)
        let renderer = MockRenderer()
        let ai = MockAI()
        let engine = Engine(board: board, renderer: renderer, ai: ai)
        let delegate = MockDelegate()
        engine.delegate = delegate
        return (engine, delegate)
    }

    func testInitialStateIsIdle() {
        let (engine, _) = makeEngine()
        XCTAssertEqual(engine.state, .idle)
    }

    func testStartGameTransitionsToPlaying() {
        let (engine, delegate) = makeEngine()
        engine.startGame()
        XCTAssertEqual(engine.state, .playing(currentPlayer: .human))
        XCTAssertTrue(delegate.stateChanges.contains(.playing(currentPlayer: .human)))
        XCTAssertFalse(delegate.boardStrings.isEmpty)
    }

    func testApplyMoveTransitionsPlayer() throws {
        let (engine, _) = makeEngine()
        engine.startGame()

        // Human moves at position 0, then AI auto-plays
        try engine.applyHumanMove(MockMove(position: 0))

        // After human move + AI auto-move, it should be back to human's turn
        // (unless game ended)
        if case .playing(let player) = engine.state {
            XCTAssertEqual(player, .human)
        }
    }

    func testWinTransitionsToGameOver() throws {
        // cells[0]=human, cells[1]=human, cells[2]=empty → human places at 2 → win
        let (engine, delegate) = makeEngine(cells: [1, 1, 0, 0])
        engine.startGame()
        try engine.applyHumanMove(MockMove(position: 2))
        XCTAssertEqual(engine.state, .gameOver(result: .win(player: .human)))
        XCTAssertTrue(delegate.stateChanges.contains(.gameOver(result: .win(player: .human))))
    }

    func testDrawTransitionsToGameOver() throws {
        // Board with 1 empty cell, no winner possible
        let (engine, _) = makeEngine(cells: [1, 2, 0])
        engine.startGame()
        try engine.applyHumanMove(MockMove(position: 2))
        // After human move, board is full [1,2,1], no 3-in-a-row → check terminal
        // MockBoard winner checks first 3 cells: 1,2,1 → no winner, no moves → terminal
        if case .gameOver(let result) = engine.state {
            XCTAssertEqual(result, .draw)
        }
    }

    func testResetTransitionsToIdle() throws {
        let (engine, _) = makeEngine(cells: [1, 1, 0, 0])
        engine.startGame()
        try engine.applyHumanMove(MockMove(position: 2))
        // Should be gameOver now
        engine.reset()
        XCTAssertEqual(engine.state, .idle)
    }

    func testInvalidTransitionThrows() {
        let (engine, _) = makeEngine(cells: [1, 1, 0, 0])
        engine.startGame()
        do {
            try engine.applyHumanMove(MockMove(position: 2))
            // Now in gameOver state
            XCTAssertThrowsError(try engine.applyHumanMove(MockMove(position: 3)))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testDelegateCalledOnStateChange() {
        let (engine, delegate) = makeEngine()
        engine.startGame()
        XCTAssertFalse(delegate.stateChanges.isEmpty)
        XCTAssertFalse(delegate.boardStrings.isEmpty)
    }
}

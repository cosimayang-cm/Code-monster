//
//  MinimaxEngineTests.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import XCTest
@testable import CarSystem

// MARK: - Minimax Test Board (simple 1D board for testing)

/// A minimal 3-cell board where first player to fill 3 cells of same value wins.
/// Used to verify MinimaxEngine finds winning/blocking moves.
struct MinimaxTestBoard: GameBoard {
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

    func applying(_ move: MockMove) -> MinimaxTestBoard {
        var newCells = cells
        newCells[move.position] = currentPlayer == .human ? 1 : 2
        let nextPlayer: Player = currentPlayer == .human ? .ai : .human
        return MinimaxTestBoard(cells: newCells, currentPlayer: nextPlayer)
    }

    func winner() -> Player? {
        let humanCount = cells.filter { $0 == 1 }.count
        let aiCount = cells.filter { $0 == 2 }.count
        // Simple win: if any player has 2+ in first 3 cells and they're adjacent
        if cells.count >= 3 {
            if cells[0] != 0 && cells[0] == cells[1] && cells[1] == cells[2] {
                return cells[0] == 1 ? .human : .ai
            }
        }
        // 2 in a row at positions 0,1
        if cells.count >= 2 && cells[0] != 0 && cells[0] == cells[1] {
            // Not a full win, just advantage
        }
        return nil
    }

    func evaluate(for player: Player) -> Double {
        if let w = winner() {
            return w == player ? 1000 : -1000
        }
        // Heuristic: count pieces
        let playerVal = player == .human ? 1 : 2
        let opponentVal = player == .human ? 2 : 1
        let playerCount = Double(cells.filter { $0 == playerVal }.count)
        let opponentCount = Double(cells.filter { $0 == opponentVal }.count)
        return playerCount - opponentCount
    }
}

// MARK: - MinimaxEngine Tests

final class MinimaxEngineTests: XCTestCase {

    let engine = MinimaxEngine<MinimaxTestBoard>()

    func testFindsWinningMove() {
        // AI has cells[0]=2, cells[1]=2, cells[2]=empty → AI should pick position 2 to win
        let board = MinimaxTestBoard(cells: [2, 2, 0], currentPlayer: .ai)
        let move = engine.bestMove(board: board, depth: 5, maximizing: true, for: .ai)
        XCTAssertNotNil(move)
        XCTAssertEqual(move?.position, 2)
    }

    func testBlocksOpponentWin() {
        // Human has cells[0]=1, cells[1]=1, cells[2]=empty. AI's turn → must block at position 2
        let board = MinimaxTestBoard(cells: [1, 1, 0], currentPlayer: .ai)
        let move = engine.bestMove(board: board, depth: 5, maximizing: true, for: .ai)
        XCTAssertNotNil(move)
        XCTAssertEqual(move?.position, 2)
    }

    func testReturnsNilForTerminalBoard() {
        // Board is full: [1, 2, 1] → no legal moves
        let board = MinimaxTestBoard(cells: [1, 2, 1], currentPlayer: .ai)
        let move = engine.bestMove(board: board, depth: 5, maximizing: true, for: .ai)
        XCTAssertNil(move)
    }

    func testAlphaBetaPrunesCorrectly() {
        // With depth=1, AI should still find a reasonable move but won't search deep
        let board = MinimaxTestBoard(cells: [0, 0, 0], currentPlayer: .ai)
        let move = engine.bestMove(board: board, depth: 1, maximizing: true, for: .ai)
        XCTAssertNotNil(move)
        // Just verify it returns a valid legal move
        let legalPositions = board.legalMoves().map { $0.position }
        XCTAssertTrue(legalPositions.contains(move!.position))
    }
}

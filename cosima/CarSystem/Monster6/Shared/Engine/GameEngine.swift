//
//  GameEngine.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import Foundation

// MARK: - GameEngine Error

enum GameEngineError: Error {
    case invalidTransition(from: GameState, action: String)
    case illegalMove
}

// MARK: - GameEngine Delegate

protocol GameEngineDelegate: AnyObject {
    func gameEngineDidUpdateState(_ state: GameState)
    func gameEngineDidUpdateBoard(_ boardString: String)
}

// MARK: - GameEngine

final class GameEngine<Board: GameBoard, Renderer: GameRenderer, AI: GameAI>
    where Renderer.Board == Board, AI.Board == Board {

    private(set) var state: GameState = .idle
    private(set) var board: Board
    private let initialBoard: Board
    private let renderer: Renderer
    private let ai: AI

    weak var delegate: GameEngineDelegate?

    init(board: Board, renderer: Renderer, ai: AI) {
        self.board = board
        self.initialBoard = board
        self.renderer = renderer
        self.ai = ai
    }

    // MARK: - Public API

    func startGame() {
        board = initialBoard
        transition(to: .playing(currentPlayer: board.currentPlayer))
        notifyBoardUpdate()
    }

    func applyHumanMove(_ move: Board.Move) throws {
        guard case .playing(let player) = state, player == .human else {
            throw GameEngineError.invalidTransition(from: state, action: "applyHumanMove")
        }

        guard board.legalMoves().contains(where: { $0 == move }) else {
            throw GameEngineError.illegalMove
        }

        board = board.applying(move)
        notifyBoardUpdate()

        if board.isTerminal {
            handleTerminal()
            return
        }

        // Switch to AI turn
        transition(to: .playing(currentPlayer: .ai))
        performAIMove()
    }

    func reset() {
        board = initialBoard
        transition(to: .idle)
    }

    // MARK: - Private

    private func performAIMove() {
        guard let aiMove = ai.bestMove(for: board) else {
            // AI has no moves — could be single-player game or game over
            if board.isTerminal {
                handleTerminal()
            } else {
                // Single-player: return control to human
                transition(to: .playing(currentPlayer: .human))
            }
            return
        }

        board = board.applying(aiMove)
        notifyBoardUpdate()

        if board.isTerminal {
            handleTerminal()
            return
        }

        transition(to: .playing(currentPlayer: .human))
    }

    private func handleTerminal() {
        if let winner = board.winner() {
            transition(to: .gameOver(result: .win(player: winner)))
        } else {
            transition(to: .gameOver(result: .draw))
        }
    }

    private func transition(to newState: GameState) {
        state = newState
        delegate?.gameEngineDidUpdateState(newState)
    }

    private func notifyBoardUpdate() {
        let boardString = renderer.render(board: board, state: state)
        delegate?.gameEngineDidUpdateBoard(boardString)
    }
}

//
//  ReversiBoard.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import Foundation

// MARK: - Cell State

enum ReversiCellState: Equatable {
    case empty
    case black  // human
    case white  // ai
}

// MARK: - ReversiBoard

struct ReversiBoard: GameBoard {
    typealias Move = ReversiMove

    static let size = 8

    private static let directions = [
        (-1, -1), (-1, 0), (-1, 1),
        ( 0, -1),          ( 0, 1),
        ( 1, -1), ( 1, 0), ( 1, 1)
    ]

    var cells: [[ReversiCellState]]
    var currentPlayer: Player

    init() {
        cells = Array(repeating: Array(repeating: ReversiCellState.empty, count: Self.size), count: Self.size)
        // Initial 4 pieces in center
        cells[3][3] = .white
        cells[3][4] = .black
        cells[4][3] = .black
        cells[4][4] = .white
        currentPlayer = .human
    }

    init(cells: [[ReversiCellState]], currentPlayer: Player) {
        self.cells = cells
        self.currentPlayer = currentPlayer
    }

    // MARK: - GameBoard Conformance

    var isTerminal: Bool {
        // Game over when neither player can move
        let currentMoves = legalMoves()
        if !currentMoves.isEmpty { return false }

        // Check if opponent can move
        let opponent = switchedBoard()
        return opponent.legalMoves().isEmpty
    }

    func legalMoves() -> [ReversiMove] {
        let piece = currentPlayer == .human ? ReversiCellState.black : .white
        var moves: [ReversiMove] = []

        for row in 0..<Self.size {
            for col in 0..<Self.size {
                guard cells[row][col] == .empty else { continue }
                let flips = findFlips(row: row, col: col, piece: piece)
                if !flips.isEmpty {
                    moves.append(ReversiMove(row: row, col: col, flips: flips))
                }
            }
        }
        return moves
    }

    func applying(_ move: ReversiMove) -> ReversiBoard {
        var newCells = cells
        let piece = currentPlayer == .human ? ReversiCellState.black : .white
        newCells[move.row][move.col] = piece

        // Flip captured pieces
        for (r, c) in move.flips {
            newCells[r][c] = piece
        }

        // Determine next player
        let nextPlayer: Player = currentPlayer == .human ? .ai : .human
        var nextBoard = ReversiBoard(cells: newCells, currentPlayer: nextPlayer)

        // If next player has no moves, skip back to current player
        if nextBoard.legalMoves().isEmpty {
            nextBoard.currentPlayer = currentPlayer == .human ? .human : .ai
            // Check again — if still no moves, game is over (handled by isTerminal)
            // Just switch back to allow isTerminal to detect properly
            let switchedPlayer: Player = currentPlayer == .human ? .ai : .human
            nextBoard.currentPlayer = switchedPlayer
            if nextBoard.legalMoves().isEmpty {
                nextBoard.currentPlayer = currentPlayer
            }
        }

        return nextBoard
    }

    func winner() -> Player? {
        guard isTerminal else { return nil }
        let (black, white) = pieceCounts()
        if black > white { return .human }
        if white > black { return .ai }
        return nil // draw
    }

    func evaluate(for player: Player) -> Double {
        let playerPiece = player == .human ? ReversiCellState.black : .white
        let opponentPiece = player == .human ? ReversiCellState.white : .black

        var score = 0.0

        // Position weight matrix
        for row in 0..<Self.size {
            for col in 0..<Self.size {
                let weight = Self.positionWeights[row][col]
                if cells[row][col] == playerPiece {
                    score += weight
                } else if cells[row][col] == opponentPiece {
                    score -= weight
                }
            }
        }

        // Piece count difference
        let (black, white) = pieceCounts()
        let playerCount = player == .human ? black : white
        let opponentCount = player == .human ? white : black
        score += Double(playerCount - opponentCount)

        // Mobility (number of available moves)
        let myMoves = legalMoves().count
        let oppBoard = switchedBoard()
        let oppMoves = oppBoard.legalMoves().count
        if myMoves + oppMoves > 0 {
            score += Double(myMoves - oppMoves) * 2
        }

        return score
    }

    // MARK: - Public Helpers

    func pieceCounts() -> (black: Int, white: Int) {
        var black = 0, white = 0
        for row in cells {
            for cell in row {
                if cell == .black { black += 1 }
                else if cell == .white { white += 1 }
            }
        }
        return (black, white)
    }

    // MARK: - Private

    private static let positionWeights: [[Double]] = [
        [ 100, -20,  10,   5,   5,  10, -20,  100],
        [ -20, -50,  -2,  -2,  -2,  -2, -50,  -20],
        [  10,  -2,   1,   1,   1,   1,  -2,   10],
        [   5,  -2,   1,   0,   0,   1,  -2,    5],
        [   5,  -2,   1,   0,   0,   1,  -2,    5],
        [  10,  -2,   1,   1,   1,   1,  -2,   10],
        [ -20, -50,  -2,  -2,  -2,  -2, -50,  -20],
        [ 100, -20,  10,   5,   5,  10, -20,  100]
    ]

    private func findFlips(row: Int, col: Int, piece: ReversiCellState) -> [(Int, Int)] {
        let opponent: ReversiCellState = piece == .black ? .white : .black
        var allFlips: [(Int, Int)] = []

        for (dr, dc) in Self.directions {
            var flips: [(Int, Int)] = []
            var r = row + dr
            var c = col + dc

            while r >= 0 && r < Self.size && c >= 0 && c < Self.size {
                if cells[r][c] == opponent {
                    flips.append((r, c))
                } else if cells[r][c] == piece {
                    allFlips.append(contentsOf: flips)
                    break
                } else {
                    break // empty cell
                }
                r += dr
                c += dc
            }
        }

        return allFlips
    }

    private func switchedBoard() -> ReversiBoard {
        let nextPlayer: Player = currentPlayer == .human ? .ai : .human
        return ReversiBoard(cells: cells, currentPlayer: nextPlayer)
    }
}

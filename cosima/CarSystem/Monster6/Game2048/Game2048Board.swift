//
//  Game2048Board.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import Foundation

struct Game2048Board: GameBoard {
    typealias Move = Game2048Move

    static let size = 4

    var cells: [[Int]]  // 4x4, 0 = empty
    var score: Int
    var hasWon: Bool
    var currentPlayer: Player

    init() {
        cells = Array(repeating: Array(repeating: 0, count: Self.size), count: Self.size)
        score = 0
        hasWon = false
        currentPlayer = .human

        // Place 2 initial tiles
        addRandomTile()
        addRandomTile()
    }

    init(cells: [[Int]], score: Int, hasWon: Bool, currentPlayer: Player = .human) {
        self.cells = cells
        self.score = score
        self.hasWon = hasWon
        self.currentPlayer = currentPlayer
    }

    // MARK: - GameBoard Conformance

    var isTerminal: Bool {
        // Game over when no moves produce change
        legalMoves().isEmpty
    }

    func legalMoves() -> [Game2048Move] {
        Direction.allCases.compactMap { dir in
            let move = Game2048Move(direction: dir)
            let newBoard = applySlide(direction: dir)
            return newBoard.cells != cells ? move : nil
        }
    }

    func applying(_ move: Game2048Move) -> Game2048Board {
        var newBoard = applySlide(direction: move.direction)

        // Only add random tile if the board actually changed
        if newBoard.cells != cells {
            newBoard.addRandomTile()
        }

        // Check for 2048
        if !newBoard.hasWon {
            for row in newBoard.cells {
                if row.contains(2048) {
                    newBoard.hasWon = true
                    break
                }
            }
        }

        return newBoard
    }

    func winner() -> Player? {
        nil // single player game
    }

    func evaluate(for player: Player) -> Double {
        Double(score)
    }

    // MARK: - Core Slide Algorithm

    /// Slide and merge a single line toward index 0 (left).
    /// Returns (new line, merge score)
    static func slideLine(_ line: [Int]) -> ([Int], Int) {
        // Step 1: Remove zeros (compress)
        var compressed = line.filter { $0 != 0 }

        // Step 2: Merge adjacent equal values
        var mergeScore = 0
        var merged: [Int] = []
        var i = 0
        while i < compressed.count {
            if i + 1 < compressed.count && compressed[i] == compressed[i + 1] {
                let value = compressed[i] * 2
                merged.append(value)
                mergeScore += value
                i += 2
            } else {
                merged.append(compressed[i])
                i += 1
            }
        }

        // Step 3: Pad with zeros
        while merged.count < Self.size {
            merged.append(0)
        }

        return (merged, mergeScore)
    }

    // MARK: - Private

    private func applySlide(direction: Direction) -> Game2048Board {
        var newCells = cells
        var addedScore = 0

        switch direction {
        case .left:
            for row in 0..<Self.size {
                let (newLine, lineScore) = Self.slideLine(newCells[row])
                newCells[row] = newLine
                addedScore += lineScore
            }

        case .right:
            for row in 0..<Self.size {
                let reversed = Array(newCells[row].reversed())
                let (newLine, lineScore) = Self.slideLine(reversed)
                newCells[row] = Array(newLine.reversed())
                addedScore += lineScore
            }

        case .up:
            for col in 0..<Self.size {
                let column = (0..<Self.size).map { newCells[$0][col] }
                let (newLine, lineScore) = Self.slideLine(column)
                for row in 0..<Self.size {
                    newCells[row][col] = newLine[row]
                }
                addedScore += lineScore
            }

        case .down:
            for col in 0..<Self.size {
                let column = (0..<Self.size).map { newCells[$0][col] }.reversed()
                let (newLine, lineScore) = Self.slideLine(Array(column))
                let reversedLine = Array(newLine.reversed())
                for row in 0..<Self.size {
                    newCells[row][col] = reversedLine[row]
                }
                addedScore += lineScore
            }
        }

        return Game2048Board(cells: newCells, score: score + addedScore, hasWon: hasWon)
    }

    private mutating func addRandomTile() {
        var emptyCells: [(Int, Int)] = []
        for row in 0..<Self.size {
            for col in 0..<Self.size {
                if cells[row][col] == 0 {
                    emptyCells.append((row, col))
                }
            }
        }
        guard let (row, col) = emptyCells.randomElement() else { return }
        cells[row][col] = Double.random(in: 0..<1) < 0.9 ? 2 : 4
    }
}

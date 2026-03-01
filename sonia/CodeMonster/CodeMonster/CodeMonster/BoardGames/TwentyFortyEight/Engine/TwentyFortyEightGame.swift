import Foundation

// MARK: - TwentyFortyEightGame
// 2048 遊戲邏輯，conform to BoardGame。
// 核心：slideRow 演算法（每格每次只合併一次）。

struct TwentyFortyEightGame: BoardGame {
    typealias Move = Direction

    private(set) var board = TwentyFortyEightBoard()
    var state: GameState = .waiting
    var currentPlayer: Player = .human
    private(set) var score: Int = 0

    // MARK: - BoardGame

    mutating func apply(move: Direction) throws {
        guard state == .playing || state == .wonCanContinue else {
            throw BoardGameError.gameAlreadyOver
        }
        let before = board
        let gained = slide(direction: move)
        guard board != before else { return }  // 無效滑動，不消耗次數
        score += gained
        board.randomSpawn()

        if board.maxTile >= 2048 && state != .wonCanContinue {
            state = .wonCanContinue   // 達成 2048，可繼續玩
        } else if board.isFull && validMoves().isEmpty {
            state = .draw             // 棋盤全滿且無合併 → 遊戲結束
        }
    }

    mutating func restart() {
        board = TwentyFortyEightBoard()
        score = 0
        board.randomSpawn()
        board.randomSpawn()
        state = .playing
        currentPlayer = .human
    }

    func validMoves() -> [Direction] {
        Direction.allCases.filter { canSlide(direction: $0) }
    }

    // MARK: - Core Algorithm

    /// 單列/行的滑動合併（方向無關，統一介面）。
    /// 規則：移除空格 → 相鄰相同合併（每格每次只合併一次）→ 補空格到尾端。
    /// - Returns: (合併後陣列, 本次獲得分數)
    func slideRow(_ row: [Int]) -> (result: [Int], score: Int) {
        var nonZero = row.filter { $0 != 0 }
        var gained = 0
        var i = 0
        while i < nonZero.count - 1 {
            if nonZero[i] == nonZero[i + 1] {
                let merged = nonZero[i] * 2
                gained += merged
                nonZero[i] = merged
                nonZero.remove(at: i + 1)
            }
            i += 1
        }
        let padding = Array(repeating: 0, count: row.count - nonZero.count)
        return (nonZero + padding, gained)
    }

    // MARK: - Slide Helpers

    /// 執行滑動，返回得分。
    @discardableResult
    private mutating func slide(direction: Direction) -> Int {
        var totalScore = 0
        let n = TwentyFortyEightBoard.size
        switch direction {
        case .left:
            for r in 0..<n {
                let (res, s) = slideRow(board.cells[r])
                for c in 0..<n { board[r, c] = res[c] }
                totalScore += s
            }
        case .right:
            for r in 0..<n {
                let (res, s) = slideRow(board.cells[r].reversed())
                let reversed = Array(res.reversed())
                for c in 0..<n { board[r, c] = reversed[c] }
                totalScore += s
            }
        case .up:
            for c in 0..<n {
                let col = (0..<n).map { board[$0, c] }
                let (res, s) = slideRow(col)
                for r in 0..<n { board[r, c] = res[r] }
                totalScore += s
            }
        case .down:
            for c in 0..<n {
                let col = (0..<n).map { board[$0, c] }.reversed()
                let (res, s) = slideRow(Array(col))
                let reversed = Array(res.reversed())
                for r in 0..<n { board[r, c] = reversed[r] }
                totalScore += s
            }
        }
        return totalScore
    }

    private func canSlide(direction: Direction) -> Bool {
        var copy = self
        let before = copy.board
        copy.slide(direction: direction)
        return copy.board != before
    }
}

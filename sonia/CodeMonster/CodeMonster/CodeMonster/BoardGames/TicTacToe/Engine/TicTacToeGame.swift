import Foundation

// MARK: - TicTacToeGame
// 井字棋遊戲邏輯，conform to BoardGame。
// TODO: T2-3 實作

struct TicTacToeGame: BoardGame {
    typealias Move = TicTacToeMove

    // TODO: state, currentPlayer, board
    var state: GameState = .waiting
    var currentPlayer: Player = .human

    mutating func apply(move: TicTacToeMove) throws {
        // TODO: 驗證空格、下子、換手、checkWinner
    }

    mutating func restart() {
        // TODO: 重置棋盤與狀態
    }

    func validMoves() -> [TicTacToeMove] {
        // TODO: 返回所有空格座標
        return []
    }

    // MARK: - Private

    private func checkWinner() -> Player? {
        // TODO: 橫 3 種、直 3 種、斜 2 種
        return nil
    }
}

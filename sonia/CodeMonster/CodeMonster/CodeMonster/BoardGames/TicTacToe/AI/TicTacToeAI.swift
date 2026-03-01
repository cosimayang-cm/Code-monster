import Foundation

// MARK: - TicTacToeAI
// Minimax 演算法，完美對弈，永不輸。
// 搜尋空間小（最多 9 格），不需 Alpha-Beta Pruning。
// TODO: T2-4 實作

struct TicTacToeAI: GameAI {
    typealias Game = TicTacToeGame

    func bestMove(for game: TicTacToeGame) -> TicTacToeMove? {
        // TODO: Minimax 搜尋，返回 AI 最佳走步
        return nil
    }

    // MARK: - Private

    /// Minimax 遞迴
    /// - Returns: 局面分數（+1 AI 勝，-1 Human 勝，0 平手）
    private func minimax(game: TicTacToeGame, isMaximizing: Bool) -> Int {
        // TODO
        return 0
    }
}

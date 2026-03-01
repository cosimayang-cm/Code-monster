import Foundation

// MARK: - ConnectFourAI
// Alpha-Beta Pruning，搜尋深度 6-8 層。
// 評估函數：連線數量、中路優勢（第 4 欄）、潛在威脅。
// TODO: T3-4 實作

struct ConnectFourAI: GameAI {
    typealias Game = ConnectFourGame

    var searchDepth: Int = 7

    func bestMove(for game: ConnectFourGame) -> ConnectFourMove? {
        // TODO: Alpha-Beta Pruning
        return nil
    }

    private func alphaBeta(game: ConnectFourGame, depth: Int, alpha: Int, beta: Int, isMaximizing: Bool) -> Int {
        // TODO
        return 0
    }

    private func evaluate(game: ConnectFourGame) -> Int {
        // TODO: 連線數量 + 中路優勢 + 潛在威脅
        return 0
    }
}

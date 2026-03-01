import Foundation

// MARK: - ReversiAI
// 黑白棋 AI：位置權重矩陣 + Alpha-Beta Pruning（深度 4-6 層）。
// 角落策略：有角落可下時必選角落。
// TODO: T4-4 實作

struct ReversiAI: GameAI {
    typealias Game = ReversiGame

    var searchDepth: Int = 5

    /// 8×8 位置權重矩陣
    /// 角落（0,0）, (0,7), (7,0), (7,7）= 最高分 100
    /// 角落相鄰位置 = 最低分 -25
    static let positionWeights: [[Int]] = [
        [100, -25, 10,  5,  5, 10, -25, 100],
        [-25, -50,  1,  1,  1,  1, -50, -25],
        [ 10,   1,  5,  2,  2,  5,   1,  10],
        [  5,   1,  2,  1,  1,  2,   1,   5],
        [  5,   1,  2,  1,  1,  2,   1,   5],
        [ 10,   1,  5,  2,  2,  5,   1,  10],
        [-25, -50,  1,  1,  1,  1, -50, -25],
        [100, -25, 10,  5,  5, 10, -25, 100]
    ]

    func bestMove(for game: ReversiGame) -> ReversiMove? {
        // TODO: 角落策略優先 → Alpha-Beta Pruning
        return nil
    }

    private func alphaBeta(game: ReversiGame, depth: Int, alpha: Int, beta: Int, isMaximizing: Bool) -> Int {
        // TODO
        return 0
    }

    private func evaluate(game: ReversiGame) -> Int {
        // TODO: 根據 positionWeights 和棋子位置計算分數
        return 0
    }
}

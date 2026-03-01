import Foundation

// MARK: - ReversiGame
// 黑白棋遊戲邏輯，conform to BoardGame。
// 特殊機制：8 方向翻轉、跳過回合（Pass）、雙方都不能下時結束。
// TODO: T4-3 實作

struct ReversiGame: BoardGame {
    typealias Move = ReversiMove

    var state: GameState = .waiting
    var currentPlayer: Player = .human

    mutating func apply(move: ReversiMove) throws {
        // TODO: 驗證至少能翻轉 1 顆、flipPieces、換手、checkGameOver
    }

    mutating func restart() {
        // TODO: 重置為初始盤面
    }

    func validMoves() -> [ReversiMove] {
        // TODO: 當前玩家所有合法位置（至少能翻轉 1 顆）
        return []
    }

    /// 當前玩家是否無子可下（需要 Pass）
    func isPassRequired() -> Bool {
        return validMoves().isEmpty && state == .playing
    }

    /// 雙方都無子可下 → 遊戲結束
    func isGameOver() -> Bool {
        // TODO: 雙方 validMoves 都為空
        return false
    }

    /// 計算勝者（子數多者勝）
    private func countWinner() -> Player? {
        // TODO: 計算黑子數與白子數
        return nil
    }
}

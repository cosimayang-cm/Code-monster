import Foundation

// MARK: - GameAI Protocol
// AI 協議（Foundation only，不依賴 UIKit）。
// 接受一個 BoardGame snapshot（值語義），回傳最佳走步。

protocol GameAI {
    associatedtype Game: BoardGame

    /// 根據傳入的局面，計算並返回最佳走步。
    /// - Returns: 最佳走法。若無合法走步（遊戲結束或需 Pass），返回 nil。
    func bestMove(for game: Game) -> Game.Move?
}

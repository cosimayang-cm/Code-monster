import Foundation

// MARK: - BoardGame Protocol
// 四個遊戲共用的主協議（Foundation only，不依賴 UIKit）。
// Move 由各遊戲自行定義，透過 associatedtype 提供型別安全。

protocol BoardGame {
    associatedtype Move

    // MARK: State

    /// 當前遊戲狀態
    var state: GameState { get }

    /// 當前輪到的玩家
    var currentPlayer: Player { get }

    // MARK: Actions

    /// 執行一步走法。
    /// - Throws: 若走法不合法（格子已佔用、欄已滿、無法翻轉等），throw error。
    mutating func apply(move: Move) throws

    /// 重開遊戲，回到初始狀態。
    mutating func restart()

    // MARK: Queries

    /// 返回當前玩家所有合法走法。空陣列代表目前無子可下（需 Pass 或遊戲結束判定）。
    func validMoves() -> [Move]
}

// MARK: - BoardGameError
// 共用的走法非法錯誤。各遊戲可依需求擴充或定義自己的 error。

enum BoardGameError: Error, Equatable {
    /// 嘗試在已有棋子的位置下子
    case cellAlreadyOccupied
    /// 欄位已滿（Connect Four）
    case columnFull
    /// 無法翻轉任何棋子（Reversi）
    case noFlipsAvailable
    /// 無效的走法座標（超出棋盤範圍）
    case invalidPosition
    /// 遊戲已結束，無法繼續
    case gameAlreadyOver
}

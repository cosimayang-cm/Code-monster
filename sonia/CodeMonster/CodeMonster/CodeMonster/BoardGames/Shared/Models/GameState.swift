import Foundation

// MARK: - GameState
// 所有遊戲共用的狀態機，明確定義遊戲在任何時刻的狀態。

enum GameState: Equatable {
    /// 尚未開始（初始狀態）
    case waiting
    /// 遊戲進行中
    case playing
    /// 勝利（含勝者）
    case won(Player)
    /// 平手（棋盤滿無人獲勝）
    case draw
    /// 2048 專用：達成 2048 可選擇繼續遊玩
    case wonCanContinue
}

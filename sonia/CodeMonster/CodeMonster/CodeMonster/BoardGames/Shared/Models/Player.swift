import Foundation

// MARK: - Player
// 統一的玩家模型，支援雙人對弈與單人（2048）模式。
// 具體語意由各遊戲使用端自行詮釋：
//   - TicTacToe / ConnectFour / Reversi：.human（❌/🔴/⚫）vs .ai（⭕/🟡/⚪）
//   - 2048：僅 .human（單人模式）

enum Player: Equatable {
    /// 使用者（Human）
    case human
    /// AI 對手
    case ai
}

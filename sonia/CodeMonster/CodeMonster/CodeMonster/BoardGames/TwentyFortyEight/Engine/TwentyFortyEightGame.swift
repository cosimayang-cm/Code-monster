import Foundation

// MARK: - TwentyFortyEightGame
// 2048 遊戲邏輯，conform to BoardGame。
// 核心：slideRow 演算法（每格每次只合併一次）。
// TODO: T5-3 實作

struct TwentyFortyEightGame: BoardGame {
    typealias Move = Direction

    var state: GameState = .waiting
    var currentPlayer: Player = .human
    private(set) var score: Int = 0

    mutating func apply(move: Direction) throws {
        // TODO: slide(direction:)，若棋盤有變化才 spawn，否則不動作
        // 達成 2048 → state = .wonCanContinue（繼續可玩）
        // 棋盤全滿且無法合併 → state = .won(.human)（失敗）
    }

    mutating func restart() {
        // TODO: 重置 board、score，randomSpawn 兩次，state = .playing
    }

    func validMoves() -> [Direction] {
        // TODO: 返回能讓棋盤產生變化的方向
        return Direction.allCases
    }

    // MARK: - Core Algorithm

    /// 單列/行的滑動合併（方向無關，統一介面）。
    /// 規則：移除空格 → 相鄰相同合併（每格每次只合併一次）→ 補空格到尾端。
    /// - Returns: (合併後陣列, 本次獲得分數)
    func slideRow(_ row: [Int]) -> (result: [Int], score: Int) {
        // TODO: 實作核心合併演算法
        // 範例：[2,2,2,2] → ([4,4,0,0], 8)
        //       [2,0,2,0] → ([4,0,0,0], 4)
        //       [4,4,4,4] → ([8,8,0,0], 16)
        return (row, 0)
    }
}

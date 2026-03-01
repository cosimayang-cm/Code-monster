import Foundation

// MARK: - ConnectFourGame
// 四子棋遊戲邏輯，conform to BoardGame。
// 特殊機制：重力掉落（棋子落到欄的最底空位）。
// TODO: T3-3 實作

struct ConnectFourGame: BoardGame {
    typealias Move = ConnectFourMove

    var state: GameState = .waiting
    var currentPlayer: Player = .human

    mutating func apply(move: ConnectFourMove) throws {
        // TODO: dropColumn, checkWinner, 換手
    }

    mutating func restart() {
        // TODO
    }

    func validMoves() -> [ConnectFourMove] {
        // TODO: 返回未滿的欄
        return []
    }

    private func checkWinner() -> Player? {
        // TODO: 橫、直、斜（兩方向）四連線
        return nil
    }
}

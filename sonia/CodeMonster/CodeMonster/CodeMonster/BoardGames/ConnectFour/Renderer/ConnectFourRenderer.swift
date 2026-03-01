//
//  ConnectFourRenderer.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/3/1.
//

import Foundation

// MARK: - ConnectFourRenderer
// Console 渲染，Row 0 在底部（渲染時倒序顯示使 row 5 在頂部）。

struct ConnectFourRenderer: BoardRenderer {
    let game: ConnectFourGame
    /// 游標欄位（0-indexed，僅人類回合顯示）
    var cursor: Int? = nil

    func render() -> String {
        var lines: [String] = []
        lines.append("=== Connect Four ===")
        lines.append(String(repeating: "─", count: 29))
        // 動態欄位標題：游標欄顯示 [N]，其餘顯示  N
        var colLine = ""
        for c in 0..<ConnectFourBoard.cols {
            let n = c + 1
            colLine += (cursor == c) ? "[\(n)] " : " \(n)  "
        }
        lines.append(colLine)
        lines.append("┌───┬───┬───┬───┬───┬───┬───┐")

        // 從頂部往底部顯示（row 5 在槽頂）
        for row in stride(from: ConnectFourBoard.rows - 1, through: 0, by: -1) {
            var line = "│"
            for col in 0..<ConnectFourBoard.cols {
                let cell: String
                switch game.board[row, col] {
                case .human: cell = "R"
                case .ai:    cell = "Y"
                case nil:    cell = " "
                }
                line += " \(cell)│"
            }
            lines.append(line)
            if row > 0 { lines.append("├───┼───┼───┼───┼───┼───┼───┤") }
        }
        lines.append("└───┴───┴───┴───┴───┴───┴───┘")

        switch game.state {
        case .playing:
            let symbol = game.currentPlayer == .human ? "R" : "Y"
            lines.append("Turn: [\(symbol)] \(game.currentPlayer == .human ? "You" : "AI")")
        case .won(let p):
            let symbol = p == .human ? "R" : "Y"
            lines.append("*** [\(symbol)] \(p == .human ? "You win!" : "AI wins!") ***")
        case .draw:
            lines.append("*** Draw! ***")
        default:
            break
        }
        return lines.joined(separator: "\n")
    }
}

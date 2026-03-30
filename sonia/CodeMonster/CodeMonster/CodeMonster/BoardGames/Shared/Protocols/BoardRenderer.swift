//
//  BoardRenderer.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/3/1.
//

import Foundation

// MARK: - BoardRenderer Protocol
// Console 渲染協議（Foundation only，不依賴 UIKit）。
// ViewController 負責呼叫 print(renderer.render())，
// Renderer 只負責生成字串，不做任何 I/O。

protocol BoardRenderer {
    /// 返回完整棋盤的 console 顯示字串。
    /// ViewController 收到後負責執行 print()。
    func render() -> String
}

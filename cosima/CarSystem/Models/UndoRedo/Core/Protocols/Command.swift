//
//  Command.swift
//  CarSystem
//
//  Code Monster #3: Undo/Redo 系統
//  Command Pattern - 命令協議
//

import Foundation

/// 命令協議 - 定義可執行、可撤銷的命令介面
///
/// Command Pattern 的核心介面，所有可撤銷的操作都必須實作此協議。
///
/// ## 使用範例
/// ```swift
/// class InsertTextCommand: Command {
///     var description: String { "插入文字" }
///
///     func execute() {
///         document.insert(text, at: position)
///     }
///
///     func undo() {
///         document.delete(range: position..<position + text.count)
///     }
/// }
/// ```
///
/// ## 重要事項
/// - `execute()` 和 `undo()` 必須是互逆操作
/// - 命令需保存足夠資訊以支援 undo（如被刪除的文字）
/// - 此協議只能 import Foundation，確保可獨立測試
///
protocol Command: AnyObject {
    
    /// 命令描述，用於顯示在 UI 上
    ///
    /// 範例：「插入文字」、「刪除圖形」、「移動圖形」
    var description: String { get }
    
    /// 執行命令
    ///
    /// 執行此命令的主要操作。呼叫後，命令應該保存足夠資訊以支援 `undo()`。
    func execute()
    
    /// 撤銷命令
    ///
    /// 還原 `execute()` 造成的變更。呼叫後，系統狀態應與執行前相同。
    func undo()
}

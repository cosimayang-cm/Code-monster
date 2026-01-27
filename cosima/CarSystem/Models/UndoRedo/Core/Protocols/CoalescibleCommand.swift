//
//  CoalescibleCommand.swift
//  CarSystem
//
//  Code Monster #3: Undo/Redo 系統
//  可合併命令協議
//

import Foundation

/// 可合併命令協議 - 支援連續同類型操作合併
///
/// 繼承自 `Command`，新增合併功能。當使用者連續執行同類型操作時
/// （如連續輸入字元、連續小幅移動），可將多個命令合併為一個，
/// 讓 Undo 時一次撤銷整組操作。
///
/// ## 使用範例
/// ```swift
/// class InsertTextCommand: CoalescibleCommand {
///     func coalesce(with command: Command) -> Bool {
///         guard let other = command as? InsertTextCommand,
///               other.position == self.position + self.text.count else {
///             return false
///         }
///         self.text += other.text
///         return true
///     }
/// }
/// ```
///
/// ## 合併條件（由各 Command 自行決定）
/// - 時間間隔：兩個操作間隔小於某閾值（如 500ms）
/// - 位置連續：如連續輸入的字元位置相鄰
/// - 同一目標：操作同一個物件
///
protocol CoalescibleCommand: Command {
    
    /// 命令建立的時間戳記，用於判斷是否在合併時間窗口內
    var timestamp: Date { get }
    
    /// 嘗試將另一個命令合併到自己
    ///
    /// - Parameter command: 要合併的命令
    /// - Returns: 是否成功合併。若成功，`command` 的操作將併入 `self`
    ///
    /// ## 實作注意
    /// - 合併後，`self` 應包含兩個命令的完整效果
    /// - 合併後的 `undo()` 應能還原所有合併的操作
    /// - 若無法合併，回傳 `false`，`CommandHistory` 會將 `command` 作為新命令加入
    ///
    func coalesce(with command: Command) -> Bool
}

// MARK: - 預設實作

extension CoalescibleCommand {
    
    /// 預設合併時間窗口：500 毫秒
    static var coalescingTimeInterval: TimeInterval { 0.5 }
    
    /// 判斷兩個命令是否在合併時間窗口內
    func isWithinCoalescingWindow(of command: CoalescibleCommand) -> Bool {
        return abs(timestamp.timeIntervalSince(command.timestamp)) < Self.coalescingTimeInterval
    }
}

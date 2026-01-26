import Foundation

/// Command protocol - 代表一個可執行、可撤銷的操作
/// FR-001: Command protocol with execute(), undo(), description
protocol Command {
    /// 執行命令
    func execute()

    /// 撤銷命令
    func undo()

    /// 命令描述，用於 UI 顯示
    var description: String { get }
}

// MARK: - CoalescibleCommand

/// CoalescibleCommand - 可合併的命令協議
/// FR-019: Support command coalescing for consecutive operations
protocol CoalescibleCommand: Command {
    /// 嘗試與另一個命令合併
    /// - Parameter other: 要合併的命令
    /// - Returns: 是否成功合併
    func coalesce(with other: Command) -> Bool

    /// 合併的超時時間（秒）
    var coalescingTimeout: TimeInterval { get }

    /// 最後執行的時間戳
    var lastExecutionTime: Date { get set }
}

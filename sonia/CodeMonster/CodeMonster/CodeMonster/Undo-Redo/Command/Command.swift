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

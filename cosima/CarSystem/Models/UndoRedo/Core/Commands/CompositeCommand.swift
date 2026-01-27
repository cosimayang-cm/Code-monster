//
//  CompositeCommand.swift
//  CarSystem
//
//  Code Monster #3: Undo/Redo 系統
//  組合命令 - 將多個命令組成原子操作
//

import Foundation

/// 組合命令 - 將多個命令組合成一個原子操作
///
/// Composite Pattern 應用於 Command Pattern，讓多個命令可以被視為單一命令。
/// 執行時依序執行所有子命令，撤銷時反序撤銷所有子命令。
///
/// ## 使用場景
/// - 複雜操作需要多個步驟，但使用者視為單一操作
/// - 例如：「貼上格式」同時改變文字內容和樣式
/// - 例如：「群組移動」同時移動多個圖形
///
/// ## 使用範例
/// ```swift
/// let composite = CompositeCommand(description: "貼上格式化文字")
/// composite.add(InsertTextCommand(document: doc, text: "Hello", position: 0))
/// composite.add(ApplyStyleCommand(document: doc, style: .bold, range: 0..<5))
///
/// history.execute(composite)  // 一次執行兩個操作
/// history.undo()              // 一次撤銷兩個操作
/// ```
///
final class CompositeCommand: Command {
    
    // MARK: - Properties
    
    /// 命令描述
    let description: String
    
    /// 子命令陣列
    private var commands: [Command] = []
    
    /// 子命令數量
    var count: Int { commands.count }
    
    /// 是否為空（沒有子命令）
    var isEmpty: Bool { commands.isEmpty }
    
    // MARK: - Initialization
    
    /// 初始化組合命令
    ///
    /// - Parameter description: 命令描述，用於顯示在 UI 上
    init(description: String) {
        self.description = description
    }
    
    /// 使用子命令陣列初始化
    ///
    /// - Parameters:
    ///   - description: 命令描述
    ///   - commands: 子命令陣列
    convenience init(description: String, commands: [Command]) {
        self.init(description: description)
        self.commands = commands
    }
    
    // MARK: - Public Methods
    
    /// 加入子命令
    ///
    /// - Parameter command: 要加入的命令
    ///
    /// 注意：加入的命令不會立即執行，需等到 `execute()` 被呼叫時才會執行。
    func add(_ command: Command) {
        commands.append(command)
    }
    
    /// 加入多個子命令
    ///
    /// - Parameter commands: 要加入的命令陣列
    func add(contentsOf commands: [Command]) {
        self.commands.append(contentsOf: commands)
    }
    
    // MARK: - Command Protocol
    
    /// 依序執行所有子命令
    func execute() {
        for command in commands {
            command.execute()
        }
    }
    
    /// 反序撤銷所有子命令
    ///
    /// 以相反順序撤銷，確保狀態正確還原。
    /// 例如：執行順序是 A → B → C，撤銷順序應該是 C → B → A
    func undo() {
        for command in commands.reversed() {
            command.undo()
        }
    }
}

import Foundation

/// CommandHistory - 管理命令歷史的協調者
/// FR-002: CommandHistory class with undoStack, redoStack
/// FR-003: execute(), undo(), redo() methods
/// FR-004: canUndo, canRedo properties
/// FR-005: undoDescription, redoDescription properties
/// FR-006: Execute clears redoStack
final class CommandHistory {

    // MARK: - Private Properties

    private var undoStack: [Command] = []
    private var redoStack: [Command] = []

    // MARK: - Configuration

    /// 是否啟用命令合併功能（預設關閉）
    var coalescingEnabled: Bool = false

    // MARK: - Public Properties (FR-004)

    /// 是否可以執行 Undo
    var canUndo: Bool {
        return !undoStack.isEmpty
    }

    /// 是否可以執行 Redo
    var canRedo: Bool {
        return !redoStack.isEmpty
    }

    // MARK: - Description Properties (FR-005)

    /// 下一個撤銷命令的描述
    var undoDescription: String? {
        return undoStack.last?.description
    }

    /// 下一個重做命令的描述
    var redoDescription: String? {
        return redoStack.last?.description
    }

    // MARK: - Initialization

    init() {}

    // MARK: - Public Methods (FR-003)

    /// 執行命令並加入 undo stack
    /// FR-006: 執行新命令時清空 redo stack
    /// FR-019: 支援命令合併
    func execute(_ command: Command) {
        command.execute()

        // 嘗試合併命令 (FR-019) - 只有在啟用合併功能時才嘗試
        if coalescingEnabled,
           let coalescibleCommand = command as? CoalescibleCommand,
           let lastCommand = undoStack.last as? CoalescibleCommand {
            // 檢查是否在超時時間內
            let timeSinceLastExecution = Date().timeIntervalSince(lastCommand.lastExecutionTime)
            if timeSinceLastExecution <= lastCommand.coalescingTimeout {
                // 嘗試合併
                if lastCommand.coalesce(with: command) {
                    // 合併成功，更新時間戳
                    var mutableLastCommand = lastCommand
                    mutableLastCommand.lastExecutionTime = Date()
                    redoStack.removeAll()
                    return
                }
            }
        }

        undoStack.append(command)
        redoStack.removeAll() // FR-006
    }

    /// 撤銷最後一個命令
    func undo() {
        guard let command = undoStack.popLast() else { return }
        command.undo()
        redoStack.append(command)
    }

    /// 重做最後一個撤銷的命令
    func redo() {
        guard let command = redoStack.popLast() else { return }
        command.execute()
        undoStack.append(command)
    }
}

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
    func execute(_ command: Command) {
        command.execute()
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

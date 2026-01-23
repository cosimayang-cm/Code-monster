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

    // MARK: - Observer Properties (FR-025 ~ FR-027)

    /// 觀察者列表，使用弱引用避免循環引用
    private var observers: [WeakCommandHistoryObserver] = []

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
                    notifyObservers()
                    return
                }
            }
        }

        undoStack.append(command)
        redoStack.removeAll() // FR-006
        notifyObservers()
    }

    /// 撤銷最後一個命令
    func undo() {
        guard let command = undoStack.popLast() else { return }
        command.undo()
        redoStack.append(command)
        notifyObservers()
    }

    /// 重做最後一個撤銷的命令
    func redo() {
        guard let command = redoStack.popLast() else { return }
        command.execute()
        undoStack.append(command)
        notifyObservers()
    }

    // MARK: - Observer Methods (FR-025 ~ FR-027)

    /// 註冊觀察者
    /// - Parameter observer: 要註冊的觀察者，會以弱引用方式持有
    func addObserver(_ observer: CommandHistoryObserver) {
        // 檢查是否已經存在（避免重複註冊）
        let alreadyExists = observers.contains { $0.observer === observer }
        if !alreadyExists {
            observers.append(WeakCommandHistoryObserver(observer))
        }
    }

    /// 移除觀察者
    /// - Parameter observer: 要移除的觀察者
    func removeObserver(_ observer: CommandHistoryObserver) {
        observers.removeAll { $0.observer === observer }
    }

    /// 通知所有觀察者狀態已變化（私有方法）
    /// 同時清理已被釋放的弱引用
    private func notifyObservers() {
        // 清理 nil 的 weak references
        observers.removeAll { $0.observer == nil }

        // 通知所有存活的觀察者
        for weakObserver in observers {
            weakObserver.observer?.commandHistoryDidChange(self)
        }
    }
}

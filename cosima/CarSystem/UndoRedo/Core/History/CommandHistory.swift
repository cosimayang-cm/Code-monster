//
//  CommandHistory.swift
//  CarSystem
//
//  Code Monster #3: Undo/Redo 系統
//  命令歷史管理器
//

import Foundation
import Combine

/// 命令歷史管理器 - 管理 Undo/Redo 堆疊
///
/// Command Pattern 中的 Invoker 角色，負責：
/// - 執行命令並加入歷史
/// - 管理 Undo/Redo 堆疊
/// - 支援命令合併（Coalescing）
/// - 限制歷史數量防止記憶體無限增長
///
/// ## 使用範例
/// ```swift
/// let history = CommandHistory()
///
/// // 執行命令
/// let command = InsertTextCommand(document: doc, text: "Hello", position: 0)
/// history.execute(command)
///
/// // Undo/Redo
/// history.undo()
/// history.redo()
///
/// // UI 綁定
/// history.$canUndo.sink { print("Can undo: \($0)") }
/// ```
///
final class CommandHistory: ObservableObject {
    
    // MARK: - Published Properties（供 UI 綁定）
    
    /// 是否可以 Undo
    @Published private(set) var canUndo: Bool = false
    
    /// 是否可以 Redo
    @Published private(set) var canRedo: Bool = false
    
    /// 下一個要 Undo 的命令描述
    @Published private(set) var undoDescription: String?
    
    /// 下一個要 Redo 的命令描述
    @Published private(set) var redoDescription: String?
    
    // MARK: - Private Properties
    
    /// Undo 堆疊
    private var undoStack: [Command] = []
    
    /// Redo 堆疊
    private var redoStack: [Command] = []
    
    /// 最大歷史數量（0 表示無限制）
    private let maxHistoryCount: Int
    
    // MARK: - Initialization
    
    /// 初始化命令歷史管理器
    ///
    /// - Parameter maxHistoryCount: 最大歷史數量，預設 100。設為 0 表示無限制。
    init(maxHistoryCount: Int = 100) {
        self.maxHistoryCount = maxHistoryCount
    }
    
    // MARK: - Public Methods
    
    /// 執行命令並加入歷史
    ///
    /// 執行命令後：
    /// 1. 嘗試與最後一個命令合併（若為 CoalescibleCommand）
    /// 2. 若無法合併，將命令加入 undo 堆疊
    /// 3. 清空 redo 堆疊（執行新命令後無法 redo 之前撤銷的操作）
    /// 4. 若超過最大歷史數量，移除最舊的命令
    ///
    /// - Parameter command: 要執行的命令
    func execute(_ command: Command) {
        // 執行命令
        command.execute()
        
        // 嘗試合併
        if let coalescible = command as? CoalescibleCommand,
           let lastCommand = undoStack.last as? CoalescibleCommand,
           lastCommand.coalesce(with: coalescible) {
            // 合併成功，不需加入新命令
            updateState()
            return
        }
        
        // 加入 undo 堆疊
        undoStack.append(command)
        
        // 清空 redo 堆疊
        redoStack.removeAll()
        
        // 限制歷史數量
        trimHistoryIfNeeded()
        
        // 更新狀態
        updateState()
    }
    
    /// 撤銷最近一次命令
    ///
    /// 將最後一個命令從 undo 堆疊移到 redo 堆疊，並執行其 `undo()` 方法。
    func undo() {
        guard let command = undoStack.popLast() else { return }
        
        command.undo()
        redoStack.append(command)
        
        updateState()
    }
    
    /// 重做最近撤銷的命令
    ///
    /// 將最後一個命令從 redo 堆疊移到 undo 堆疊，並執行其 `execute()` 方法。
    func redo() {
        guard let command = redoStack.popLast() else { return }
        
        command.execute()
        undoStack.append(command)
        
        updateState()
    }
    
    /// 清除所有歷史紀錄
    func clear() {
        undoStack.removeAll()
        redoStack.removeAll()
        updateState()
    }
    
    // MARK: - Read-only Access
    
    /// 目前 undo 堆疊的命令數量
    var undoCount: Int { undoStack.count }
    
    /// 目前 redo 堆疊的命令數量
    var redoCount: Int { redoStack.count }
    
    // MARK: - Private Methods
    
    /// 更新 Published 屬性
    private func updateState() {
        canUndo = !undoStack.isEmpty
        canRedo = !redoStack.isEmpty
        undoDescription = undoStack.last?.description
        redoDescription = redoStack.last?.description
    }
    
    /// 若超過最大歷史數量，移除最舊的命令
    private func trimHistoryIfNeeded() {
        guard maxHistoryCount > 0, undoStack.count > maxHistoryCount else { return }
        
        let removeCount = undoStack.count - maxHistoryCount
        undoStack.removeFirst(removeCount)
    }
}

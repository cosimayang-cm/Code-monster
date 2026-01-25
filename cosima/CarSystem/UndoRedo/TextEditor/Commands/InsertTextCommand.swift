//
//  InsertTextCommand.swift
//  CarSystem
//
//  Code Monster #3: Undo/Redo 系統
//  插入文字命令
//

import Foundation

/// 插入文字命令
///
/// 在指定位置插入文字，支援 Undo/Redo。
///
/// ## 使用範例
/// ```swift
/// let command = InsertTextCommand(document: doc, text: "Hello", position: 0)
/// history.execute(command)  // doc.content == "Hello"
/// history.undo()            // doc.content == ""
/// history.redo()            // doc.content == "Hello"
/// ```
///
final class InsertTextCommand: Command {
    
    // MARK: - Properties
    
    /// 命令描述
    var description: String { "插入文字" }
    
    /// 目標文件
    private let document: TextDocument
    
    /// 要插入的文字
    private var text: String
    
    /// 插入位置
    private let position: Int
    
    // MARK: - Initialization
    
    /// 初始化插入文字命令
    ///
    /// - Parameters:
    ///   - document: 目標文件
    ///   - text: 要插入的文字
    ///   - position: 插入位置（字元索引，0-based）
    init(document: TextDocument, text: String, position: Int) {
        self.document = document
        self.text = text
        self.position = position
    }
    
    // MARK: - Command Protocol
    
    func execute() {
        document.insert(text, at: position)
    }
    
    func undo() {
        let range = position..<(position + text.count)
        document.delete(range: range)
    }
}

// MARK: - CoalescibleCommand

extension InsertTextCommand: CoalescibleCommand {
    
    /// 命令建立時間
    var timestamp: Date { _timestamp }
    private let _timestamp = Date()
    
    /// 嘗試合併連續輸入的文字
    ///
    /// 合併條件：
    /// 1. 另一個命令也是 InsertTextCommand
    /// 2. 操作同一個 document
    /// 3. 插入位置緊接在目前文字之後
    /// 4. 在時間窗口內
    func coalesce(with command: Command) -> Bool {
        guard let other = command as? InsertTextCommand,
              other.document === self.document,
              other.position == self.position + self.text.count,
              isWithinCoalescingWindow(of: other) else {
            return false
        }
        
        // 合併文字
        self.text += other.text
        return true
    }
}

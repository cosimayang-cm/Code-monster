//
//  DeleteTextCommand.swift
//  CarSystem
//
//  Code Monster #3: Undo/Redo 系統
//  刪除文字命令
//

import Foundation

/// 刪除文字命令
///
/// 刪除指定範圍的文字，支援 Undo/Redo。
/// 執行時會保存被刪除的文字，以便 Undo 時還原。
///
/// ## 使用範例
/// ```swift
/// // doc.content == "Hello World"
/// let command = DeleteTextCommand(document: doc, range: 5..<11)
/// history.execute(command)  // doc.content == "Hello"
/// history.undo()            // doc.content == "Hello World"
/// ```
///
final class DeleteTextCommand: Command {
    
    // MARK: - Properties
    
    /// 命令描述
    var description: String { "刪除文字" }
    
    /// 目標文件
    private let document: TextDocument
    
    /// 刪除範圍
    private let range: Range<Int>
    
    /// 被刪除的文字（execute 後設定，供 undo 使用）
    private var deletedText: String?
    
    /// 被刪除範圍的樣式（execute 後設定，供 undo 使用）
    private var deletedStyleRanges: [StyleRange]?
    
    // MARK: - Initialization
    
    /// 初始化刪除文字命令
    ///
    /// - Parameters:
    ///   - document: 目標文件
    ///   - range: 要刪除的範圍
    init(document: TextDocument, range: Range<Int>) {
        self.document = document
        self.range = range
    }
    
    // MARK: - Command Protocol
    
    func execute() {
        // 保存被刪除的內容（供 undo 使用）
        deletedStyleRanges = document.getStyleRanges(in: range)
        deletedText = document.delete(range: range)
    }
    
    func undo() {
        guard let text = deletedText else { return }
        
        // 還原文字
        document.insert(text, at: range.lowerBound)
        
        // 還原樣式
        if let styles = deletedStyleRanges {
            for styleRange in styles {
                document.applyStyle(styleRange.style, to: styleRange.range)
            }
        }
    }
}

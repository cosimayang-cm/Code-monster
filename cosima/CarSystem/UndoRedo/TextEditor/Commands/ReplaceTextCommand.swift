//
//  ReplaceTextCommand.swift
//  CarSystem
//
//  Code Monster #3: Undo/Redo 系統
//  取代文字命令
//

import Foundation

/// 取代文字命令
///
/// 將指定範圍的文字替換成新文字，支援 Undo/Redo。
/// 本質上是「刪除 + 插入」的組合，但作為單一命令處理。
///
/// ## 使用範例
/// ```swift
/// // doc.content == "Hello World"
/// let command = ReplaceTextCommand(document: doc, range: 6..<11, newText: "Swift")
/// history.execute(command)  // doc.content == "Hello Swift"
/// history.undo()            // doc.content == "Hello World"
/// ```
///
final class ReplaceTextCommand: Command {
    
    // MARK: - Properties
    
    /// 命令描述
    var description: String { "取代文字" }
    
    /// 目標文件
    private let document: TextDocument
    
    /// 取代範圍
    private let range: Range<Int>
    
    /// 新文字
    private let newText: String
    
    /// 被取代的文字（execute 後設定，供 undo 使用）
    private var oldText: String?
    
    /// 被取代範圍的樣式（execute 後設定，供 undo 使用）
    private var oldStyleRanges: [StyleRange]?
    
    // MARK: - Initialization
    
    /// 初始化取代文字命令
    ///
    /// - Parameters:
    ///   - document: 目標文件
    ///   - range: 要取代的範圍
    ///   - newText: 新的文字
    init(document: TextDocument, range: Range<Int>, newText: String) {
        self.document = document
        self.range = range
        self.newText = newText
    }
    
    // MARK: - Command Protocol
    
    func execute() {
        // 保存被取代的內容（供 undo 使用）
        oldStyleRanges = document.getStyleRanges(in: range)
        oldText = document.replace(range: range, with: newText)
    }
    
    func undo() {
        guard let text = oldText else { return }
        
        // 還原文字
        let newRange = range.lowerBound..<(range.lowerBound + newText.count)
        document.replace(range: newRange, with: text)
        
        // 還原樣式
        if let styles = oldStyleRanges {
            for styleRange in styles {
                document.applyStyle(styleRange.style, to: styleRange.range)
            }
        }
    }
}

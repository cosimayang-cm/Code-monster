//
//  ApplyStyleCommand.swift
//  CarSystem
//
//  Code Monster #3: Undo/Redo 系統
//  套用樣式命令
//

import Foundation

/// 套用樣式命令
///
/// 對指定範圍的文字套用樣式（粗體/斜體/底線），支援 Undo/Redo。
///
/// ## 使用範例
/// ```swift
/// // doc.content == "Hello World"
/// let command = ApplyStyleCommand(document: doc, style: .bold, range: 0..<5)
/// history.execute(command)  // "Hello" 變成粗體
/// history.undo()            // "Hello" 回復原樣式
/// ```
///
final class ApplyStyleCommand: Command {
    
    // MARK: - Properties
    
    /// 命令描述
    var description: String { "套用\(style.description)" }
    
    /// 目標文件
    private let document: TextDocument
    
    /// 要套用的樣式
    private let style: TextStyle
    
    /// 套用範圍
    private let range: Range<Int>
    
    /// 套用前的樣式狀態（供 undo 使用）
    private var previousStyleRanges: [StyleRange]?
    
    // MARK: - Initialization
    
    /// 初始化套用樣式命令
    ///
    /// - Parameters:
    ///   - document: 目標文件
    ///   - style: 要套用的樣式
    ///   - range: 套用範圍
    init(document: TextDocument, style: TextStyle, range: Range<Int>) {
        self.document = document
        self.style = style
        self.range = range
    }
    
    // MARK: - Command Protocol
    
    func execute() {
        // 保存目前的樣式狀態（供 undo 使用）
        previousStyleRanges = document.getStyleRanges(in: range)
        
        // 套用新樣式
        document.applyStyle(style, to: range)
    }
    
    func undo() {
        // 移除套用的樣式
        document.removeStyle(style, from: range)
        
        // 還原之前的樣式
        if let previousRanges = previousStyleRanges {
            for styleRange in previousRanges {
                document.applyStyle(styleRange.style, to: styleRange.range)
            }
        }
    }
}

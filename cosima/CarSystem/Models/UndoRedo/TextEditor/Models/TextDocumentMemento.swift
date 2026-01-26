//
//  TextDocumentMemento.swift
//  CarSystem
//
//  Code Monster #3: Undo/Redo 系統
//  文件快照 (Memento)
//

import Foundation

/// 文件快照 - Memento Pattern
///
/// 保存 `TextDocument` 的完整狀態，可用於：
/// - 複雜批次操作的撤銷（直接還原快照比逐一反向操作簡單）
/// - 跳轉到特定歷史版本
/// - 自動儲存功能
///
/// ## 使用範例
/// ```swift
/// // 建立快照
/// let memento = document.createMemento()
///
/// // 執行一些操作...
/// document.insert("Hello", at: 0)
/// document.applyStyle(.bold, to: 0..<5)
///
/// // 還原快照
/// document.restore(from: memento)
/// ```
///
struct TextDocumentMemento: Equatable, Codable {
    
    /// 文件內容
    let content: String
    
    /// 樣式範圍
    let styleRanges: [StyleRange]
    
    /// 快照建立時間
    let timestamp: Date
    
    // MARK: - Computed Properties
    
    /// 文件長度
    var length: Int { content.count }
    
    /// 是否為空文件
    var isEmpty: Bool { content.isEmpty }
}

// MARK: - CustomStringConvertible

extension TextDocumentMemento: CustomStringConvertible {
    var description: String {
        let preview = content.prefix(20)
        let suffix = content.count > 20 ? "..." : ""
        return "Memento(\"\(preview)\(suffix)\", styles: \(styleRanges.count))"
    }
}

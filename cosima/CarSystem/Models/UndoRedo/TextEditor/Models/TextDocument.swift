//
//  TextDocument.swift
//  CarSystem
//
//  Code Monster #3: Undo/Redo 系統
//  文件模型 (Receiver)
//

import Foundation
import Combine

/// 文件模型 - Command Pattern 的 Receiver
///
/// 負責實際執行文字操作，提供基本的 CRUD 方法供 Command 呼叫。
/// 使用 `@Published` 讓 UI 可以即時反映變更。
///
/// ## 使用範例
/// ```swift
/// let document = TextDocument()
/// document.insert("Hello", at: 0)
/// document.insert(" World", at: 5)
/// print(document.content)  // "Hello World"
///
/// let deleted = document.delete(range: 5..<11)
/// print(deleted)  // " World"
/// print(document.content)  // "Hello"
/// ```
///
final class TextDocument: ObservableObject {
    
    // MARK: - Published Properties
    
    /// 文件內容
    @Published private(set) var content: String = ""
    
    /// 各區段的樣式對應
    /// Key: 文字範圍（以字元索引表示）
    /// Value: 該範圍的樣式
    @Published private(set) var styleRanges: [StyleRange] = []
    
    // MARK: - Initialization
    
    /// 初始化空文件
    init() {}
    
    /// 使用初始內容初始化
    init(content: String) {
        self.content = content
    }
    
    // MARK: - Text Operations
    
    /// 在指定位置插入文字
    ///
    /// - Parameters:
    ///   - text: 要插入的文字
    ///   - position: 插入位置（字元索引，0-based）
    func insert(_ text: String, at position: Int) {
        let index = content.index(content.startIndex, offsetBy: min(position, content.count))
        content.insert(contentsOf: text, at: index)
        
        // 調整樣式範圍
        adjustStyleRanges(afterInsertAt: position, length: text.count)
    }
    
    /// 刪除指定範圍的文字
    ///
    /// - Parameter range: 要刪除的範圍
    /// - Returns: 被刪除的文字（供 Undo 使用）
    @discardableResult
    func delete(range: Range<Int>) -> String {
        let startIndex = content.index(content.startIndex, offsetBy: range.lowerBound)
        let endIndex = content.index(content.startIndex, offsetBy: min(range.upperBound, content.count))
        let deletedText = String(content[startIndex..<endIndex])
        
        content.removeSubrange(startIndex..<endIndex)
        
        // 調整樣式範圍
        adjustStyleRanges(afterDeleteAt: range)
        
        return deletedText
    }
    
    /// 取代指定範圍的文字
    ///
    /// - Parameters:
    ///   - range: 要取代的範圍
    ///   - text: 新的文字
    /// - Returns: 被取代的文字（供 Undo 使用）
    @discardableResult
    func replace(range: Range<Int>, with text: String) -> String {
        let oldText = delete(range: range)
        insert(text, at: range.lowerBound)
        return oldText
    }
    
    // MARK: - Style Operations
    
    /// 對指定範圍套用樣式
    ///
    /// - Parameters:
    ///   - style: 要套用的樣式
    ///   - range: 套用範圍
    func applyStyle(_ style: TextStyle, to range: Range<Int>) {
        // 尋找是否有重疊的樣式範圍
        var newRanges: [StyleRange] = []
        var handled = false
        
        for existingRange in styleRanges {
            if existingRange.range.overlaps(range) {
                // 有重疊，合併樣式
                let mergedStyle = existingRange.style.union(style)
                
                // 處理部分重疊的情況（簡化處理：直接更新整個重疊區域）
                let newStart = min(existingRange.range.lowerBound, range.lowerBound)
                let newEnd = max(existingRange.range.upperBound, range.upperBound)
                newRanges.append(StyleRange(range: newStart..<newEnd, style: mergedStyle))
                handled = true
            } else {
                newRanges.append(existingRange)
            }
        }
        
        if !handled {
            newRanges.append(StyleRange(range: range, style: style))
        }
        
        styleRanges = newRanges
    }
    
    /// 從指定範圍移除樣式
    ///
    /// - Parameters:
    ///   - style: 要移除的樣式
    ///   - range: 移除範圍
    func removeStyle(_ style: TextStyle, from range: Range<Int>) {
        styleRanges = styleRanges.compactMap { existingRange in
            if existingRange.range.overlaps(range) {
                let newStyle = existingRange.style.subtracting(style)
                if newStyle.isEmpty {
                    return nil
                }
                return StyleRange(range: existingRange.range, style: newStyle)
            }
            return existingRange
        }
    }
    
    /// 取得指定範圍的樣式
    ///
    /// - Parameter range: 查詢範圍
    /// - Returns: 該範圍的樣式（若無則回傳 .none）
    func style(at range: Range<Int>) -> TextStyle {
        for styleRange in styleRanges {
            if styleRange.range.overlaps(range) {
                return styleRange.style
            }
        }
        return .none
    }
    
    /// 取得指定範圍的所有樣式資訊（供 Undo 使用）
    func getStyleRanges(in range: Range<Int>) -> [StyleRange] {
        return styleRanges.filter { $0.range.overlaps(range) }
    }
    
    /// 設定樣式範圍（用於 Undo 還原）
    func setStyleRanges(_ ranges: [StyleRange]) {
        self.styleRanges = ranges
    }
    
    // MARK: - Memento
    
    /// 建立文件快照
    func createMemento() -> TextDocumentMemento {
        return TextDocumentMemento(
            content: content,
            styleRanges: styleRanges,
            timestamp: Date()
        )
    }
    
    /// 從快照還原
    func restore(from memento: TextDocumentMemento) {
        content = memento.content
        styleRanges = memento.styleRanges
    }
    
    // MARK: - Private Methods
    
    /// 插入文字後調整樣式範圍
    private func adjustStyleRanges(afterInsertAt position: Int, length: Int) {
        styleRanges = styleRanges.map { range in
            if range.range.lowerBound >= position {
                // 整個範圍在插入點之後，往後移
                return StyleRange(
                    range: (range.range.lowerBound + length)..<(range.range.upperBound + length),
                    style: range.style
                )
            } else if range.range.upperBound > position {
                // 插入點在範圍中間，擴展範圍
                return StyleRange(
                    range: range.range.lowerBound..<(range.range.upperBound + length),
                    style: range.style
                )
            }
            return range
        }
    }
    
    /// 刪除文字後調整樣式範圍
    private func adjustStyleRanges(afterDeleteAt deletedRange: Range<Int>) {
        let length = deletedRange.upperBound - deletedRange.lowerBound
        
        styleRanges = styleRanges.compactMap { range in
            if range.range.upperBound <= deletedRange.lowerBound {
                // 整個範圍在刪除範圍之前，不變
                return range
            } else if range.range.lowerBound >= deletedRange.upperBound {
                // 整個範圍在刪除範圍之後，往前移
                return StyleRange(
                    range: (range.range.lowerBound - length)..<(range.range.upperBound - length),
                    style: range.style
                )
            } else {
                // 有重疊，縮減或移除
                let newStart = min(range.range.lowerBound, deletedRange.lowerBound)
                let newEnd = max(range.range.lowerBound, range.range.upperBound - length)
                if newStart >= newEnd {
                    return nil
                }
                return StyleRange(range: newStart..<newEnd, style: range.style)
            }
        }
    }
}

// MARK: - StyleRange

/// 樣式範圍 - 記錄某段文字的樣式
struct StyleRange: Equatable, Codable {
    /// 文字範圍（字元索引）
    let range: Range<Int>
    
    /// 該範圍的樣式
    let style: TextStyle
}

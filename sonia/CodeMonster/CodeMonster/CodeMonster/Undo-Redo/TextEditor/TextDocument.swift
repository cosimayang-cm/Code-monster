import Foundation

/// TextDocument - 文字編輯器的接收者 (Receiver)
/// FR-011: TextDocument as Receiver, manages text content and styles
final class TextDocument {

    // MARK: - Properties

    /// 文件的文字內容
    private(set) var content: String = ""

    /// 文件的樣式列表
    private(set) var styles: [TextStyleRange] = []

    // MARK: - Initialization

    init(content: String = "") {
        self.content = content
    }

    // MARK: - Text Operations

    /// 在指定位置插入文字
    /// - Parameters:
    ///   - text: 要插入的文字
    ///   - index: 插入位置
    func insert(_ text: String, at index: String.Index) {
        content.insert(contentsOf: text, at: index)
    }

    /// 刪除指定範圍的文字
    /// - Parameter range: 要刪除的範圍
    /// - Returns: 被刪除的文字
    @discardableResult
    func delete(range: Range<String.Index>) -> String {
        let deletedText = String(content[range])
        content.removeSubrange(range)
        return deletedText
    }

    /// 取代指定範圍的文字
    /// - Parameters:
    ///   - range: 要取代的範圍
    ///   - newText: 新的文字
    /// - Returns: 被取代的舊文字
    @discardableResult
    func replace(range: Range<String.Index>, with newText: String) -> String {
        let oldText = String(content[range])
        content.replaceSubrange(range, with: newText)
        return oldText
    }

    // MARK: - Style Operations

    /// 對指定範圍套用樣式
    /// - Parameters:
    ///   - style: 要套用的樣式
    ///   - range: 套用範圍
    func applyStyle(_ style: TextStyle, to range: Range<String.Index>) {
        // 移除該範圍現有的相同樣式（避免重複）
        styles.removeAll { $0.range == range && $0.style == style }
        // 新增樣式
        styles.append(TextStyleRange(range: range, style: style))
    }

    /// 從指定範圍移除樣式
    /// - Parameters:
    ///   - style: 要移除的樣式
    ///   - range: 移除範圍
    func removeStyle(_ style: TextStyle, from range: Range<String.Index>) {
        styles.removeAll { $0.range == range && $0.style == style }
    }

    /// 取得指定範圍的樣式
    /// - Parameter range: 查詢範圍
    /// - Returns: 該範圍的所有樣式
    func stylesIn(range: Range<String.Index>) -> [TextStyleRange] {
        return styles.filter { $0.range.overlaps(range) }
    }
}

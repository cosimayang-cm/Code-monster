import Foundation

/// TextDocument - 文字編輯器的接收者 (Receiver)
/// FR-011: TextDocument as Receiver, manages text content and styles
final class TextDocument {

    // MARK: - Properties

    /// 文件的文字內容
    private(set) var content: String = ""

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
}

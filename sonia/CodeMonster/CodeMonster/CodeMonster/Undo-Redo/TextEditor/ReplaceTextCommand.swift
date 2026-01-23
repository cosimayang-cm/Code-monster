import Foundation

/// ReplaceTextCommand - 取代文字的命令
/// FR-009: ReplaceTextCommand supports replacing text in specified range
final class ReplaceTextCommand: Command {

    // MARK: - Properties

    private let document: TextDocument
    private let replaceRange: Range<String.Index>
    private let newText: String
    private var oldText: String = ""

    // MARK: - Command Protocol

    var description: String {
        return "取代文字"
    }

    // MARK: - Initialization

    /// 建立取代文字命令
    /// - Parameters:
    ///   - document: 目標文件
    ///   - range: 要取代的範圍
    ///   - newText: 新的文字
    init(document: TextDocument, range: Range<String.Index>, newText: String) {
        self.document = document
        self.replaceRange = range
        self.newText = newText
        // 先記錄舊文字，以便 undo
        self.oldText = String(document.content[range])
    }

    // MARK: - Execute & Undo

    func execute() {
        oldText = document.replace(range: replaceRange, with: newText)
    }

    func undo() {
        // 計算新文字的範圍
        let newEndIndex = document.content.index(replaceRange.lowerBound, offsetBy: newText.count)
        let newRange = replaceRange.lowerBound..<newEndIndex
        // 用舊文字取代回去
        document.replace(range: newRange, with: oldText)
    }
}

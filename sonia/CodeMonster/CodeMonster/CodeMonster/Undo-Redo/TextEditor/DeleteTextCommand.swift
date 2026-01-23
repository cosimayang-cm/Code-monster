import Foundation

/// DeleteTextCommand - 刪除文字的命令
/// FR-008: DeleteTextCommand supports deleting text in specified range
final class DeleteTextCommand: Command {

    // MARK: - Properties

    private let document: TextDocument
    private let deleteRange: Range<String.Index>
    private var deletedText: String = ""

    // MARK: - Command Protocol

    var description: String {
        return "刪除文字"
    }

    // MARK: - Initialization

    /// 建立刪除文字命令
    /// - Parameters:
    ///   - document: 目標文件
    ///   - range: 要刪除的範圍
    init(document: TextDocument, range: Range<String.Index>) {
        self.document = document
        self.deleteRange = range
        // 先記錄要刪除的文字，以便 undo
        self.deletedText = String(document.content[range])
    }

    // MARK: - Execute & Undo

    func execute() {
        deletedText = document.delete(range: deleteRange)
    }

    func undo() {
        // 在原位置插入被刪除的文字
        document.insert(deletedText, at: deleteRange.lowerBound)
    }
}

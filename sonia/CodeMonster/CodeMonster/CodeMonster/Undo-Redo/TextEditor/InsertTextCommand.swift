import Foundation

/// InsertTextCommand - 插入文字的命令
/// FR-007: InsertTextCommand supports inserting text at specified position
final class InsertTextCommand: Command {

    // MARK: - Properties

    private let document: TextDocument
    private let text: String
    private let insertIndex: String.Index

    // MARK: - Command Protocol

    var description: String {
        return "插入文字"
    }

    // MARK: - Initialization

    /// 建立插入文字命令
    /// - Parameters:
    ///   - document: 目標文件
    ///   - text: 要插入的文字
    ///   - at: 插入位置
    init(document: TextDocument, text: String, at index: String.Index) {
        self.document = document
        self.text = text
        self.insertIndex = index
    }

    // MARK: - Execute & Undo

    func execute() {
        document.insert(text, at: insertIndex)
    }

    func undo() {
        // 計算插入後的結束位置
        let endIndex = document.content.index(insertIndex, offsetBy: text.count)
        document.delete(range: insertIndex..<endIndex)
    }
}

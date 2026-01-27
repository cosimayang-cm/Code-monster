import Foundation

/// Command for replacing text in a TextDocument.
///
/// Implements the Command pattern for text replacement with undo/redo support.
/// Uses the Memento pattern to capture document state before modification.
///
/// Design notes:
/// - Holds weak reference to document to avoid retain cycles
/// - Captures state before first execute() for undo
/// - Replacement is equivalent to delete + insert in a single operation
/// - Generic over TextDocumentProtocol to support any conforming document type
///
/// Usage:
/// ```swift
/// let command = ReplaceTextCommand(
///     document: doc,
///     range: NSRange(location: 0, length: 5),
///     replacementText: "Hi"
/// )
/// command.execute() // Replaces first 5 characters with "Hi"
/// command.undo()    // Restores original text
/// ```
public final class ReplaceTextCommand<Document: TextDocumentProtocol>: Command {
    // MARK: - Properties

    /// Weak reference to the text document (receiver)
    private weak var document: Document?

    /// The range of text to replace
    private let range: NSRange

    /// The replacement text
    private let replacementText: String

    /// Memento captured before first execute (for undo)
    private var beforeMemento: Document.MementoType?

    // MARK: - Initialization

    /// Creates a new replace text command.
    ///
    /// - Parameters:
    ///   - document: The text document to modify
    ///   - range: The range of text to replace (NSRange)
    ///   - replacementText: The text to replace with
    public init(document: Document, range: NSRange, replacementText: String) {
        self.document = document
        self.range = range
        self.replacementText = replacementText
    }

    // MARK: - Command

    public func execute() {
        guard let document = document else { return }

        // Capture state before first execute
        if beforeMemento == nil {
            beforeMemento = document.createMemento()
        }

        // Execute replacement
        document.replace(in: range, with: replacementText)
    }

    public func undo() {
        guard let document = document,
              let memento = beforeMemento else {
            return
        }

        // Restore to state before execute
        document.restore(from: memento)
    }

    public var description: String {
        let truncatedText = replacementText.count > 20
            ? String(replacementText.prefix(20)) + "..."
            : replacementText
        return "Replace range (location: \(range.location), length: \(range.length)) with '\(truncatedText)'"
    }
}

import Foundation

/// Command for inserting text into a TextDocument.
///
/// Implements the Command pattern for text insertion with undo/redo support.
/// Uses the Memento pattern to capture document state before modification.
///
/// Design notes:
/// - Holds weak reference to document to avoid retain cycles
/// - Captures state before first execute() for undo
/// - Not idempotent: multiple execute() calls insert text multiple times
/// - Generic over TextDocumentProtocol to support any conforming document type
///
/// Usage:
/// ```swift
/// let command = InsertTextCommand(document: doc, text: "Hello", position: 0)
/// command.execute() // Inserts "Hello"
/// command.undo()    // Removes "Hello"
/// ```
public final class InsertTextCommand<Document: TextDocumentProtocol>: Command {
    // MARK: - Properties

    /// Weak reference to the text document (receiver)
    private weak var document: Document?

    /// The text to insert
    private let text: String

    /// The position where text should be inserted
    private let position: Int

    /// Memento captured before first execute (for undo)
    private var beforeMemento: Document.MementoType?

    // MARK: - Initialization

    /// Creates a new insert text command.
    ///
    /// - Parameters:
    ///   - document: The text document to modify
    ///   - text: The text to insert
    ///   - position: The character position for insertion (0-based)
    public init(document: Document, text: String, position: Int) {
        self.document = document
        self.text = text
        self.position = position
    }

    // MARK: - Command

    public func execute() {
        guard let document = document else { return }

        // Capture state before first execute
        if beforeMemento == nil {
            beforeMemento = document.createMemento()
        }

        // Execute insertion
        document.insert(text, at: position)
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
        let truncatedText = text.count > 20
            ? String(text.prefix(20)) + "..."
            : text
        return "Insert '\(truncatedText)' at position \(position)"
    }
}

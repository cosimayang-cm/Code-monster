import Foundation

/// Command for deleting text from a TextDocument.
///
/// Implements the Command pattern for text deletion with undo/redo support.
/// Uses the Memento pattern to capture document state before modification.
///
/// Design notes:
/// - Holds weak reference to document to avoid retain cycles
/// - Captures state before first execute() for undo
/// - Subsequent execute() calls delete from current state
/// - Generic over TextDocumentProtocol to support any conforming document type
///
/// Usage:
/// ```swift
/// let command = DeleteTextCommand(document: doc, range: NSRange(location: 0, length: 5))
/// command.execute() // Deletes first 5 characters
/// command.undo()    // Restores deleted text
/// ```
public final class DeleteTextCommand<Document: TextDocumentProtocol>: Command {
    // MARK: - Properties

    /// Weak reference to the text document (receiver)
    private weak var document: Document?

    /// The range of text to delete
    private let range: NSRange

    /// Memento captured before first execute (for undo)
    private var beforeMemento: Document.MementoType?

    // MARK: - Initialization

    /// Creates a new delete text command.
    ///
    /// - Parameters:
    ///   - document: The text document to modify
    ///   - range: The range of text to delete (NSRange)
    public init(document: Document, range: NSRange) {
        self.document = document
        self.range = range
    }

    // MARK: - Command

    public func execute() {
        guard let document = document else { return }

        // Capture state before first execute
        if beforeMemento == nil {
            beforeMemento = document.createMemento()
        }

        // Execute deletion
        document.delete(in: range)
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
        return "Delete range (location: \(range.location), length: \(range.length))"
    }
}

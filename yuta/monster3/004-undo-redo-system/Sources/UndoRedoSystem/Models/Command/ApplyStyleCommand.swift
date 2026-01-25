import Foundation

/// Command to apply text style to a range in a TextDocument.
///
/// Implements FR-004 (bold), FR-005 (italic), FR-006 (underline),
/// FR-009 (undo), FR-010 (redo).
///
/// This command captures the previous style (if any) to enable proper undo/redo.
/// Generic over TextDocumentProtocol to support any conforming document type.
///
/// Usage:
/// ```swift
/// let document = TextDocument(text: "Hello World")
/// let command = ApplyStyleCommand(document: document, style: .bold, range: NSRange(location: 0, length: 5))
/// command.execute() // "Hello" becomes bold
/// command.undo()    // "Hello" returns to previous style (or no style)
/// ```
public final class ApplyStyleCommand<Document: TextDocumentProtocol>: Command {
    // MARK: - Properties

    /// Weak reference to the target document (avoids retain cycle)
    private weak var document: Document?

    /// The style to apply
    private let style: TextStyle

    /// The range to apply the style to
    private let range: NSRange

    /// The previous style in this range (captured on first execute, used for undo)
    private var previousStyle: TextStyle?

    /// Flag to track if this is the first execution (to capture previous style)
    private var isFirstExecution: Bool = true

    // MARK: - Initialization

    /// Creates a command to apply a text style to a specific range.
    ///
    /// - Parameters:
    ///   - document: The text document to modify (weak reference)
    ///   - style: The text style to apply
    ///   - range: The range of text to style (NSRange)
    public init(
        document: Document,
        style: TextStyle,
        range: NSRange
    ) {
        self.document = document
        self.style = style
        self.range = range
    }

    // MARK: - Command Protocol

    public func execute() {
        guard let document = document else { return }

        // Capture previous style on first execution (for undo)
        if isFirstExecution {
            previousStyle = document.getStyle(in: range)
            isFirstExecution = false
        }

        // Apply the new style
        document.applyStyle(style, in: range)
    }

    public func undo() {
        guard let document = document else { return }

        // Restore previous style (or remove style if there was none)
        if let previousStyle = previousStyle {
            document.applyStyle(previousStyle, in: range)
        } else {
            document.removeStyle(in: range)
        }
    }

    public var description: String {
        let styleDescription: String
        if style.isBold {
            styleDescription = "粗體"
        } else if style.isItalic {
            styleDescription = "斜體"
        } else if style.isUnderlined {
            styleDescription = "底線"
        } else {
            styleDescription = "樣式"
        }

        return "套用\(styleDescription) (位置: \(range.location), 長度: \(range.length))"
    }
}

import Foundation

/// Concrete implementation of TextDocumentProtocol.
///
/// TextDocument manages mutable text content and supports undo/redo
/// through the Memento pattern.
///
/// Thread safety: Not thread-safe. Use on main thread only.
///
/// Usage:
/// ```swift
/// let document = TextDocument()
/// document.insert("Hello", at: 0)
/// let memento = document.createMemento()
/// document.insert(" World", at: 5)
/// document.restore(from: memento) // Back to "Hello"
/// ```
public final class TextDocument: TextDocumentProtocol {
    // MARK: - Nested Types

    /// Memento capturing TextDocument state.
    ///
    /// Immutable snapshot of text content and styles at a specific point in time.
    public struct TextDocumentMemento: Memento {
        public let text: String
        public let styleMap: [NSRange: TextStyle]
        public let timestamp: Date

        public init(text: String, styleMap: [NSRange: TextStyle] = [:], timestamp: Date = Date()) {
            self.text = text
            self.styleMap = styleMap
            self.timestamp = timestamp
        }
    }

    // MARK: - Properties

    /// The mutable text content
    private var text: String

    /// Style mappings for text ranges
    /// Key: NSRange representing the styled text range
    /// Value: TextStyle applied to that range
    private var styleMap: [NSRange: TextStyle] = [:]

    // MARK: - Initialization

    /// Creates a new text document with optional initial text.
    ///
    /// - Parameter text: Initial text content (default: empty string)
    public init(text: String = "") {
        self.text = text
    }

    // MARK: - TextDocumentProtocol

    public func getText() -> String {
        return text
    }

    public func insert(_ newText: String, at position: Int) {
        // Validate non-empty insertion
        guard !newText.isEmpty else { return }

        // Adjust position to valid bounds
        let safePosition = max(0, min(position, text.count))

        // Insert text at position
        let index = text.index(text.startIndex, offsetBy: safePosition)
        text.insert(contentsOf: newText, at: index)
    }

    public func delete(in range: NSRange) {
        // Validate range
        guard range.location >= 0,
              range.length > 0,
              range.location < text.count else {
            return
        }

        // Adjust range to valid bounds
        let safeLocation = range.location
        let safeLength = min(range.length, text.count - range.location)

        // Convert to String.Index range
        let startIndex = text.index(text.startIndex, offsetBy: safeLocation)
        let endIndex = text.index(startIndex, offsetBy: safeLength)

        // Remove text
        text.removeSubrange(startIndex..<endIndex)
    }

    public func replace(in range: NSRange, with newText: String) {
        // Delete existing text in range
        delete(in: range)

        // Insert new text at the same location
        insert(newText, at: range.location)
    }

    // MARK: - Style Operations

    public func applyStyle(_ style: TextStyle, in range: NSRange) {
        // Validate range
        guard range.location >= 0,
              range.length > 0,
              range.location < text.count else {
            return
        }

        // Adjust range to valid bounds
        let safeLength = min(range.length, text.count - range.location)
        let safeRange = NSRange(location: range.location, length: safeLength)

        // Apply style to range
        styleMap[safeRange] = style
    }

    @discardableResult
    public func removeStyle(in range: NSRange) -> TextStyle? {
        // Remove and return the style for this range
        return styleMap.removeValue(forKey: range)
    }

    public func getStyle(in range: NSRange) -> TextStyle? {
        // Return the style for this range, or nil if not styled
        return styleMap[range]
    }

    // MARK: - MementoOriginator

    public func createMemento() -> TextDocumentMemento {
        return TextDocumentMemento(text: text, styleMap: styleMap)
    }

    public func restore(from memento: TextDocumentMemento) {
        self.text = memento.text
        self.styleMap = memento.styleMap
    }
}

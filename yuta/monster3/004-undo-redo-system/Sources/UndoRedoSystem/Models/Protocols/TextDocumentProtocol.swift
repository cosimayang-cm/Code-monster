import Foundation

/// Protocol defining the interface for a text document.
///
/// TextDocument is the "Receiver" in the Command Pattern for text editing operations.
/// It manages text content and supports operations like insert, delete, and replace.
///
/// Key responsibilities:
/// - Manage text content
/// - Provide text editing operations
/// - Support memento-based state capture/restoration
///
/// Design notes:
/// - Implementations should be thread-safe if used from multiple threads
/// - Range validation is implementation responsibility
/// - Invalid operations should fail gracefully (no-op or bounds adjustment)
/// - AnyObject constraint enables weak references in Commands
public protocol TextDocumentProtocol: AnyObject, MementoOriginator {
    /// The current text content of the document.
    ///
    /// - Returns: The complete text content as a String
    func getText() -> String

    /// Inserts text at the specified position.
    ///
    /// If position is beyond text length, text is appended to the end.
    ///
    /// - Parameters:
    ///   - text: The text to insert
    ///   - position: The character position where text should be inserted (0-based)
    func insert(_ text: String, at position: Int)

    /// Deletes text in the specified range.
    ///
    /// If range is invalid or out of bounds, the operation is adjusted to valid bounds
    /// or becomes a no-op.
    ///
    /// - Parameter range: The range of characters to delete (NSRange)
    func delete(in range: NSRange)

    /// Replaces text in the specified range with new text.
    ///
    /// Equivalent to delete(in:) followed by insert(_:at:).
    /// If range is invalid, the operation is adjusted to valid bounds or becomes a no-op.
    ///
    /// - Parameters:
    ///   - range: The range of characters to replace (NSRange)
    ///   - text: The replacement text
    func replace(in range: NSRange, with text: String)

    // MARK: - Style Operations

    /// Applies a text style to the specified range.
    ///
    /// If range is invalid or out of bounds, the operation is adjusted to valid bounds
    /// or becomes a no-op. Applying a style to the same range replaces the previous style.
    ///
    /// - Parameters:
    ///   - style: The text style to apply
    ///   - range: The range of characters to style (NSRange)
    func applyStyle(_ style: TextStyle, in range: NSRange)

    /// Removes the text style from the specified range.
    ///
    /// If no style exists in the range, this is a no-op.
    /// Returns the style that was removed, or nil if no style existed.
    ///
    /// - Parameter range: The range of characters to remove style from (NSRange)
    /// - Returns: The removed style, or nil if no style was present
    @discardableResult
    func removeStyle(in range: NSRange) -> TextStyle?

    /// Gets the text style applied to the specified range.
    ///
    /// If no style exists in the range, returns nil.
    ///
    /// - Parameter range: The range to query for style (NSRange)
    /// - Returns: The style applied to the range, or nil if no style exists
    func getStyle(in range: NSRange) -> TextStyle?
}

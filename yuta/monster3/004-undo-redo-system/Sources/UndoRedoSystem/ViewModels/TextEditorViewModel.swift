import Foundation
import Combine

/// ViewModel for a text editor with undo/redo support.
///
/// Provides a reactive interface for text editing operations using Combine publishers.
/// Manages a TextDocument and CommandHistory to support undo/redo functionality.
///
/// Architecture:
/// - ViewModel layer in MVVM/Clean Architecture
/// - Uses @Published for reactive UI updates
/// - Commands encapsulate operations for undo/redo
/// - Document holds actual text state
///
/// Usage:
/// ```swift
/// let viewModel = TextEditorViewModel()
/// viewModel.insert("Hello", at: 0)
/// print(viewModel.text) // "Hello"
/// viewModel.undo()
/// print(viewModel.text) // ""
/// ```
///
/// Thread safety: Use on main thread only.
public final class TextEditorViewModel: ObservableObject {
    // MARK: - Published Properties

    /// The current text content.
    ///
    /// This property publishes changes whenever text is modified through
    /// insert, delete, replace, undo, or redo operations.
    @Published public private(set) var text: String = ""

    /// Whether undo operation is available.
    ///
    /// True when there are operations in the undo stack.
    @Published public private(set) var canUndo: Bool = false

    /// Whether redo operation is available.
    ///
    /// True when there are operations in the redo stack.
    @Published public private(set) var canRedo: Bool = false

    // MARK: - Private Properties

    /// The document managing text content
    private let document: TextDocument

    /// The command history managing undo/redo
    private let commandHistory: CommandHistory

    /// Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    /// Creates a new text editor view model.
    ///
    /// - Parameter initialText: Optional initial text content (default: empty)
    public init(initialText: String = "") {
        self.document = TextDocument(text: initialText)
        self.commandHistory = CommandHistory()
        self.text = initialText

        setupBindings()
    }

    // MARK: - Public Methods

    /// Inserts text at the specified position.
    ///
    /// Creates and executes an InsertTextCommand, adding it to undo history.
    ///
    /// - Parameters:
    ///   - text: The text to insert
    ///   - position: The character position where text should be inserted (0-based)
    public func insert(_ text: String, at position: Int) {
        let command = InsertTextCommand(document: document, text: text, position: position)
        commandHistory.execute(command)
        updateText()
    }

    /// Deletes text in the specified range.
    ///
    /// Creates and executes a DeleteTextCommand, adding it to undo history.
    ///
    /// - Parameter range: The range of characters to delete (NSRange)
    public func delete(in range: NSRange) {
        let command = DeleteTextCommand(document: document, range: range)
        commandHistory.execute(command)
        updateText()
    }

    /// Replaces text in the specified range with new text.
    ///
    /// Creates and executes a ReplaceTextCommand, adding it to undo history.
    ///
    /// - Parameters:
    ///   - range: The range of characters to replace (NSRange)
    ///   - text: The replacement text
    public func replace(in range: NSRange, with text: String) {
        let command = ReplaceTextCommand(document: document, range: range, replacementText: text)
        commandHistory.execute(command)
        updateText()
    }

    /// Undoes the last operation.
    ///
    /// Reverts the most recent change and updates the text.
    /// Does nothing if undo stack is empty.
    public func undo() {
        commandHistory.undo()
        updateText()
    }

    /// Redoes the last undone operation.
    ///
    /// Re-applies the most recently undone change and updates the text.
    /// Does nothing if redo stack is empty.
    public func redo() {
        commandHistory.redo()
        updateText()
    }

    // MARK: - Style Operations

    /// Applies bold style to the specified range.
    ///
    /// Creates and executes an ApplyStyleCommand with bold style.
    /// Implements FR-004: Bold style application.
    ///
    /// - Parameter range: The range of text to make bold (NSRange)
    public func applyBold(in range: NSRange) {
        let command = ApplyStyleCommand(document: document, style: .bold, range: range)
        commandHistory.execute(command)
        updateText()
    }

    /// Applies italic style to the specified range.
    ///
    /// Creates and executes an ApplyStyleCommand with italic style.
    /// Implements FR-005: Italic style application.
    ///
    /// - Parameter range: The range of text to make italic (NSRange)
    public func applyItalic(in range: NSRange) {
        let command = ApplyStyleCommand(document: document, style: .italic, range: range)
        commandHistory.execute(command)
        updateText()
    }

    /// Applies underline style to the specified range.
    ///
    /// Creates and executes an ApplyStyleCommand with underline style.
    /// Implements FR-006: Underline style application.
    ///
    /// - Parameter range: The range of text to underline (NSRange)
    public func applyUnderline(in range: NSRange) {
        let command = ApplyStyleCommand(document: document, style: .underline, range: range)
        commandHistory.execute(command)
        updateText()
    }

    /// Gets the style applied to the specified range.
    ///
    /// - Parameter range: The range to query (NSRange)
    /// - Returns: The TextStyle if one exists, nil otherwise
    public func getStyle(in range: NSRange) -> TextStyle? {
        return document.getStyle(in: range)
    }

    // MARK: - Private Methods

    /// Sets up Combine bindings for reactive updates.
    ///
    /// Subscribes to commandHistory publishers and updates @Published properties.
    private func setupBindings() {
        // Bind canUndo
        commandHistory.canUndoPublisher
            .assign(to: &$canUndo)

        // Bind canRedo
        commandHistory.canRedoPublisher
            .assign(to: &$canRedo)
    }

    /// Updates the text property from document state.
    ///
    /// Called after every operation to sync ViewModel state with Document.
    private func updateText() {
        text = document.getText()
    }
}

import Foundation
import Combine

/// Protocol defining the Command History interface for undo/redo functionality.
///
/// This protocol abstracts the command history management, allowing for
/// dependency injection and testability (via mocks).
///
/// Key responsibilities:
/// - Execute commands and add them to history
/// - Support undo/redo operations
/// - Track current state (canUndo, canRedo)
/// - Notify observers of state changes via Combine publishers
///
/// Design notes:
/// - Uses Combine for reactive state updates
/// - Maintains linear undo/redo history (no branching)
/// - Executing a new command clears redo stack
public protocol CommandHistoryProtocol {
    /// Executes a command and adds it to the history.
    ///
    /// - Parameter command: The command to execute
    ///
    /// This method:
    /// 1. Executes the command immediately
    /// 2. Adds it to the undo stack
    /// 3. Clears the redo stack (new action invalidates redo history)
    func execute(_ command: Command)

    /// Undoes the most recent command.
    ///
    /// If there are no commands to undo, this method does nothing.
    /// The undone command is moved to the redo stack.
    func undo()

    /// Redoes the most recently undone command.
    ///
    /// If there are no commands to redo, this method does nothing.
    /// The redone command is moved back to the undo stack.
    func redo()

    /// Indicates whether undo is currently available.
    var canUndo: Bool { get }

    /// Indicates whether redo is currently available.
    var canRedo: Bool { get }

    /// Publisher that emits when undo availability changes.
    ///
    /// ViewModels can subscribe to this to update UI state reactively.
    var canUndoPublisher: AnyPublisher<Bool, Never> { get }

    /// Publisher that emits when redo availability changes.
    ///
    /// ViewModels can subscribe to this to update UI state reactively.
    var canRedoPublisher: AnyPublisher<Bool, Never> { get }

    /// Description of the next command to undo (nil if no undo available).
    ///
    /// Used for UI display: "Undo: Insert Text"
    var undoDescription: String? { get }

    /// Description of the next command to redo (nil if no redo available).
    ///
    /// Used for UI display: "Redo: Delete Shape"
    var redoDescription: String? { get }

    /// Clears all command history (undo and redo stacks).
    ///
    /// Use this when starting a new document or resetting state.
    func clear()
}

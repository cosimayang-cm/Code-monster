import Foundation
import Combine

/// Concrete implementation of CommandHistoryProtocol.
///
/// Manages a linear undo/redo history using two stacks:
/// - undoStack: Commands that can be undone
/// - redoStack: Commands that can be redone
///
/// Thread safety: Not thread-safe. Use on main thread only.
public final class CommandHistory: CommandHistoryProtocol {
    // MARK: - Private Properties

    /// Stack of commands that can be undone (most recent at end)
    private var undoStack: [Command] = []

    /// Stack of commands that can be redone (most recent at end)
    private var redoStack: [Command] = []

    /// Subject for publishing canUndo state changes
    private let canUndoSubject = CurrentValueSubject<Bool, Never>(false)

    /// Subject for publishing canRedo state changes
    private let canRedoSubject = CurrentValueSubject<Bool, Never>(false)

    // MARK: - Initialization

    public init() {}

    // MARK: - CommandHistoryProtocol

    public func execute(_ command: Command) {
        // Execute the command immediately
        command.execute()

        // Add to undo stack
        undoStack.append(command)

        // Clear redo stack (new action invalidates redo history)
        redoStack.removeAll()

        // Update state publishers
        updatePublishers()
    }

    public func undo() {
        guard let command = undoStack.popLast() else {
            return
        }

        // Undo the command
        command.undo()

        // Move to redo stack
        redoStack.append(command)

        // Update state publishers
        updatePublishers()
    }

    public func redo() {
        guard let command = redoStack.popLast() else {
            return
        }

        // Re-execute the command
        command.execute()

        // Move back to undo stack
        undoStack.append(command)

        // Update state publishers
        updatePublishers()
    }

    public var canUndo: Bool {
        !undoStack.isEmpty
    }

    public var canRedo: Bool {
        !redoStack.isEmpty
    }

    public var canUndoPublisher: AnyPublisher<Bool, Never> {
        canUndoSubject.eraseToAnyPublisher()
    }

    public var canRedoPublisher: AnyPublisher<Bool, Never> {
        canRedoSubject.eraseToAnyPublisher()
    }

    public var undoDescription: String? {
        undoStack.last?.description
    }

    public var redoDescription: String? {
        redoStack.last?.description
    }

    public func clear() {
        undoStack.removeAll()
        redoStack.removeAll()
        updatePublishers()
    }

    // MARK: - Private Methods

    /// Updates all publishers with current state
    private func updatePublishers() {
        canUndoSubject.send(canUndo)
        canRedoSubject.send(canRedo)
    }
}

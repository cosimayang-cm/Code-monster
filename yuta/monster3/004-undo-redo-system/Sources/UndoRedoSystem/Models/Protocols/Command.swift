import Foundation

/// Protocol defining the Command Pattern interface.
///
/// All commands in the Undo/Redo system must conform to this protocol.
/// Commands encapsulate actions that can be executed, undone, and redone.
///
/// Key responsibilities:
/// - Execute the command's action
/// - Undo the command's effect
/// - Provide a description for debugging/UI
///
/// Design notes:
/// - Commands should hold weak references to receivers to avoid retain cycles
/// - Commands should be stateless or capture minimal state
/// - Use Memento pattern for complex state restoration
public protocol Command {
    /// Executes the command's action.
    ///
    /// This method performs the command's primary operation on its receiver.
    /// It should be idempotent when possible.
    func execute()

    /// Undoes the command's effect.
    ///
    /// This method reverses the command's action, restoring the receiver
    /// to its previous state. Must be the inverse of execute().
    func undo()

    /// A human-readable description of the command.
    ///
    /// Used for debugging, logging, and potentially UI display.
    /// Should describe the action in past tense (e.g., "Inserted text at position 5").
    var description: String { get }
}

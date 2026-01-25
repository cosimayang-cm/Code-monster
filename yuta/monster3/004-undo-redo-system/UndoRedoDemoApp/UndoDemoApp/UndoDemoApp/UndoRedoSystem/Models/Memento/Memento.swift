import Foundation

/// Protocol defining the Memento Pattern interface.
///
/// Mementos capture and externalize an object's internal state without
/// violating encapsulation, allowing the object to be restored to this
/// state later.
///
/// Key responsibilities:
/// - Capture state immutably
/// - Provide opaque state storage
/// - Enable state restoration
///
/// Design notes:
/// - Mementos should be immutable (use 'let' properties)
/// - Mementos should be lightweight snapshots
/// - Only the originator should interpret memento contents
///
/// Usage pattern:
/// ```swift
/// // Save state
/// let memento = document.createMemento()
///
/// // ... modify document ...
///
/// // Restore state
/// document.restore(from: memento)
/// ```
public protocol Memento {
    /// The timestamp when this memento was created.
    ///
    /// Useful for debugging and potentially showing revision history.
    var timestamp: Date { get }
}

/// Protocol for objects that can create and restore from mementos.
///
/// This is the "Originator" in the Memento Pattern.
public protocol MementoOriginator {
    associatedtype MementoType: Memento

    /// Creates a memento capturing the current state.
    ///
    /// - Returns: A new memento containing the current state
    func createMemento() -> MementoType

    /// Restores state from a memento.
    ///
    /// - Parameter memento: The memento to restore from
    func restore(from memento: MementoType)
}

import Foundation

/// Manages persistence of popup states per user.
/// Implementations must ensure thread-safety for concurrent access.
public protocol PopupStateRepository {
    /// Retrieves the state for a specific popup type and user.
    /// - Parameters:
    ///   - type: The popup type to query.
    ///   - memberId: The user's unique identifier.
    /// - Returns: The popup state or an error.
    func getState(for type: PopupType, memberId: String) -> Result<PopupState, PopupError>

    /// Updates the state for a specific popup type and user.
    /// - Parameters:
    ///   - state: The new state to persist.
    ///   - memberId: The user's unique identifier.
    /// - Returns: Success or an error.
    func updateState(_ state: PopupState, memberId: String) -> Result<Void, PopupError>

    /// Convenience method to mark a popup as shown.
    /// - Parameters:
    ///   - type: The popup type that was shown.
    ///   - memberId: The user's unique identifier.
    /// - Returns: Success or an error.
    func markAsShown(type: PopupType, memberId: String) -> Result<Void, PopupError>

    /// Resets all popup states for a specific user.
    /// - Parameter memberId: The user's unique identifier.
    func resetUser(memberId: String)

    /// Resets all popup states for all users. Used primarily for testing.
    func resetAll()
}

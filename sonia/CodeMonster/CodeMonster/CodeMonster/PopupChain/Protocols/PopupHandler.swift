import Foundation

/// Defines a handler in the popup chain of responsibility.
/// Each handler checks one popup type and decides whether to show, skip, or terminate.
public protocol PopupHandler: AnyObject {
    /// The next handler in the chain. Set to nil for the last handler.
    var next: PopupHandler? { get set }

    /// The popup type this handler is responsible for
    var popupType: PopupType { get }

    /// Handles the popup check for this handler's popup type.
    /// - Parameter context: The execution context containing user info and dependencies.
    /// - Returns: Result indicating the action taken (shown, skipped, or terminated).
    func handle(context: PopupContext) -> Result<PopupHandleResult, PopupError>

    /// Called when the popup presented by this handler is dismissed.
    /// Default implementation continues to next handler.
    func onPopupDismissed(context: PopupContext)
}

// MARK: - Default Implementation

public extension PopupHandler {
    func onPopupDismissed(context: PopupContext) {
        // Default: continue to next handler
        if let next = next {
            _ = next.handle(context: context)
        }
    }
}

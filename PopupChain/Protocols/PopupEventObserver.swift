import Foundation

/// Observes popup chain lifecycle events.
/// Implementations receive notifications for UI updates, analytics, etc.
protocol PopupEventObserver: AnyObject {
    /// Called when a popup event is published.
    /// - Parameter event: The event that occurred.
    func popupChain(didPublish event: PopupEvent)
}

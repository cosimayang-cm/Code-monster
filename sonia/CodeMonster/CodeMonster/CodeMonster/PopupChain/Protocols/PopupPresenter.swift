import UIKit

/// Presents popup UI to the user.
/// Implementations handle the actual UI display mechanics.
public protocol PopupPresenter: AnyObject {
    /// Presents a popup of the specified type.
    /// - Parameters:
    ///   - type: The type of popup to present.
    ///   - viewController: The view controller to present from.
    ///   - completion: Called when the user dismisses the popup (button tap only).
    func present(
        type: PopupType,
        from viewController: UIViewController,
        completion: @escaping () -> Void
    )

    /// Dismisses the currently presented popup programmatically.
    /// - Parameter type: The type of popup to dismiss.
    func dismiss(type: PopupType)

    /// Returns true if a popup is currently being presented.
    var isPresenting: Bool { get }

    /// The currently presented popup type, or nil if none.
    var currentPopupType: PopupType? { get }
}

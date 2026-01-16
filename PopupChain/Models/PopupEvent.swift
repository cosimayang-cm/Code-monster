import Foundation

/// Popup lifecycle events
enum PopupEvent: Equatable {
    case popupWillShow(PopupType)
    case popupDidShow(PopupType)
    case popupWillDismiss(PopupType)
    case popupDidDismiss(PopupType)
    case chainCompleted
}

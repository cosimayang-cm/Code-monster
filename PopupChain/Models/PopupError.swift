import Foundation

/// Popup operation errors
enum PopupError: Error, Equatable {
    case repositoryReadFailed(PopupType)
    case repositoryWriteFailed(PopupType)
    case presenterCreationFailed
    case invalidState(String)

    var localizedDescription: String {
        switch self {
        case .repositoryReadFailed(let type):
            return "Failed to read state for \(type.rawValue)"
        case .repositoryWriteFailed(let type):
            return "Failed to write state for \(type.rawValue)"
        case .presenterCreationFailed:
            return "Failed to create popup presenter"
        case .invalidState(let message):
            return "Invalid state: \(message)"
        }
    }
}

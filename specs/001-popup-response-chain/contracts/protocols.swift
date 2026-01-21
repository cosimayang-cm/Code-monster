// MARK: - Popup Response Chain Contracts
// Feature: 001-popup-response-chain
// Date: 2026-01-16
//
// This file defines the protocol contracts for the Popup Response Chain system.
// Implementation files should conform to these protocols.

import UIKit

// MARK: - PopupHandler Protocol

/// Defines a handler in the popup chain of responsibility.
/// Each handler checks one popup type and decides whether to show, skip, or terminate.
protocol PopupHandler: AnyObject {
    /// The next handler in the chain. Set to nil for the last handler.
    var next: PopupHandler? { get set }

    /// Handles the popup check for this handler's popup type.
    /// - Parameter context: The execution context containing user info and dependencies.
    /// - Returns: Result indicating the action taken (shown, skipped, or terminated).
    func handle(context: PopupContext) -> Result<PopupHandleResult, PopupError>

    /// Called when the popup presented by this handler is dismissed.
    /// Default implementation continues to next handler.
    func onPopupDismissed(context: PopupContext)
}

// MARK: - PopupStateRepository Protocol

/// Manages persistence of popup states per user.
/// Implementations must ensure thread-safety for concurrent access.
protocol PopupStateRepository {
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

// MARK: - PopupPresenter Protocol

/// Presents popup UI to the user.
/// Implementations handle the actual UI display mechanics.
protocol PopupPresenter: AnyObject {
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

// MARK: - PopupEventObserver Protocol

/// Observes popup chain lifecycle events.
/// Implementations receive notifications for UI updates, analytics, etc.
protocol PopupEventObserver: AnyObject {
    /// Called when a popup event is published.
    /// - Parameter event: The event that occurred.
    func popupChain(didPublish event: PopupEvent)
}

// MARK: - PopupEventPublishing Protocol

/// Publishes popup events to registered observers.
protocol PopupEventPublishing {
    /// Adds an observer to receive events. Uses weak reference.
    /// - Parameter observer: The observer to add.
    func addObserver(_ observer: PopupEventObserver)

    /// Removes an observer from receiving events.
    /// - Parameter observer: The observer to remove.
    func removeObserver(_ observer: PopupEventObserver)

    /// Publishes an event to all registered observers.
    /// - Parameter event: The event to publish.
    func publish(_ event: PopupEvent)
}

// MARK: - Logger Protocol

/// Logs messages for debugging and error tracking.
protocol Logger {
    /// Logs a message at the specified level.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - level: The severity level.
    func log(_ message: String, level: LogLevel)
}

// MARK: - PopupChainManaging Protocol

/// Manages the popup chain execution lifecycle.
protocol PopupChainManaging {
    /// Starts the popup chain from the first handler.
    /// Should only be called once per app launch.
    func startPopupChain()

    /// Returns true if the chain has been triggered this session.
    var hasTriggeredThisSession: Bool { get }

    /// Resets the session flag. Used primarily for testing.
    func resetSession()
}

// MARK: - Supporting Types

/// Result of a handler's decision.
enum PopupHandleResult: Equatable {
    /// Popup was shown; wait for user to dismiss.
    case shown(PopupType)
    /// Popup was skipped; proceed to next handler immediately.
    case skipped
    /// Chain was terminated; stop processing. (Tutorial only)
    case chainTerminated
}

/// Popup types in priority order.
enum PopupType: String, CaseIterable {
    case tutorial = "tutorial"
    case interstitialAd = "interstitialAd"
    case newFeature = "newFeature"
    case dailyCheckIn = "dailyCheckIn"
    case predictionResult = "predictionResult"

    /// Priority order (1 = highest)
    var priority: Int {
        switch self {
        case .tutorial: return 1
        case .interstitialAd: return 2
        case .newFeature: return 3
        case .dailyCheckIn: return 4
        case .predictionResult: return 5
        }
    }

    /// Human-readable display name
    var displayName: String {
        switch self {
        case .tutorial: return "新手教學"
        case .interstitialAd: return "插頁式廣告"
        case .newFeature: return "新功能公告"
        case .dailyCheckIn: return "每日簽到"
        case .predictionResult: return "猜多空結果"
        }
    }

    /// Whether this popup terminates the chain after display
    var terminatesChain: Bool {
        self == .tutorial
    }

    /// Reset policy for this popup type
    var resetPolicy: ResetPolicy {
        switch self {
        case .tutorial, .interstitialAd, .newFeature:
            return .permanent
        case .dailyCheckIn:
            return .daily
        case .predictionResult:
            return .onNewResult
        }
    }
}

/// Reset policies for popup states
enum ResetPolicy {
    /// Never resets (shown only once per user)
    case permanent
    /// Resets daily (can show once per calendar day)
    case daily
    /// Resets when new result is available
    case onNewResult
}

/// Popup state persistence model
struct PopupState: Codable, Equatable {
    let type: PopupType
    let hasShown: Bool
    let lastShownDate: Date?
    let showCount: Int

    init(
        type: PopupType,
        hasShown: Bool = false,
        lastShownDate: Date? = nil,
        showCount: Int = 0
    ) {
        self.type = type
        self.hasShown = hasShown
        self.lastShownDate = lastShownDate
        self.showCount = showCount
    }
}

/// User information passed to the popup chain
struct UserInfo {
    let memberId: String
    let hasSeenTutorial: Bool
    let hasSeenAd: Bool
    let hasSeenNewFeature: Bool
    let lastCheckInDate: Date?
    let hasPredictionResult: Bool

    // MARK: - Test Profiles

    static let newUser = UserInfo(
        memberId: "1",
        hasSeenTutorial: false,
        hasSeenAd: false,
        hasSeenNewFeature: false,
        lastCheckInDate: nil,
        hasPredictionResult: false
    )

    static let returningUser = UserInfo(
        memberId: "2",
        hasSeenTutorial: true,
        hasSeenAd: false,
        hasSeenNewFeature: false,
        lastCheckInDate: Date().addingTimeInterval(-86400 * 7),
        hasPredictionResult: false
    )

    static let experiencedUser = UserInfo(
        memberId: "3",
        hasSeenTutorial: true,
        hasSeenAd: true,
        hasSeenNewFeature: false,
        lastCheckInDate: Date().addingTimeInterval(-86400),
        hasPredictionResult: false
    )

    static let checkedInUser = UserInfo(
        memberId: "4",
        hasSeenTutorial: true,
        hasSeenAd: true,
        hasSeenNewFeature: true,
        lastCheckInDate: Date(),
        hasPredictionResult: false
    )

    static let allCompletedUser = UserInfo(
        memberId: "5",
        hasSeenTutorial: true,
        hasSeenAd: true,
        hasSeenNewFeature: true,
        lastCheckInDate: Date(),
        hasPredictionResult: true
    )
}

/// Execution context for the popup chain
struct PopupContext {
    let userInfo: UserInfo
    let stateRepository: PopupStateRepository
    let presenter: PopupPresenter?
    let logger: Logger
}

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

/// Popup lifecycle events
enum PopupEvent: Equatable {
    case popupWillShow(PopupType)
    case popupDidShow(PopupType)
    case popupWillDismiss(PopupType)
    case popupDidDismiss(PopupType)
    case chainCompleted
}

/// Log severity levels
enum LogLevel {
    case debug
    case info
    case warning
    case error
}

// MARK: - Codable Conformance for PopupType

extension PopupType: Codable {}

import Foundation

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

    /// Creates a new state marking the popup as shown
    func markingAsShown() -> PopupState {
        PopupState(
            type: type,
            hasShown: true,
            lastShownDate: Date(),
            showCount: showCount + 1
        )
    }

    /// Creates a reset state for this popup type
    func reset() -> PopupState {
        PopupState(type: type)
    }
}

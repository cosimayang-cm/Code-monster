import Foundation

/// Popup state persistence model
public struct PopupState: Codable, Equatable {
    public let type: PopupType
    public let hasShown: Bool
    public let lastShownDate: Date?
    public let showCount: Int

    public init(
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

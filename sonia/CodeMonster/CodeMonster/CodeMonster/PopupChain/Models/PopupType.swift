import Foundation

/// Popup types in priority order.
public enum PopupType: String, CaseIterable, Codable {
    case tutorial = "tutorial"
    case interstitialAd = "interstitialAd"
    case newFeature = "newFeature"
    case dailyCheckIn = "dailyCheckIn"
    case predictionResult = "predictionResult"

    /// Priority order (1 = highest)
    public var priority: Int {
        switch self {
        case .tutorial: return 1
        case .interstitialAd: return 2
        case .newFeature: return 3
        case .dailyCheckIn: return 4
        case .predictionResult: return 5
        }
    }

    /// Human-readable display name
    public var displayName: String {
        switch self {
        case .tutorial: return "新手教學"
        case .interstitialAd: return "插頁式廣告"
        case .newFeature: return "新功能公告"
        case .dailyCheckIn: return "每日簽到"
        case .predictionResult: return "猜多空結果"
        }
    }

    /// Whether this popup terminates the chain after display
    public var terminatesChain: Bool {
        self == .tutorial
    }

    /// Reset policy for this popup type
    public var resetPolicy: ResetPolicy {
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
public enum ResetPolicy {
    /// Never resets (shown only once per user)
    case permanent
    /// Resets daily (can show once per calendar day)
    case daily
    /// Resets when new result is available
    case onNewResult
}

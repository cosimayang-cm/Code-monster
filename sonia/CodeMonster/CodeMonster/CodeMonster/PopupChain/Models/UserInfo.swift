import Foundation

/// User information passed to the popup chain
public struct UserInfo {
    public let memberId: String
    public let hasSeenTutorial: Bool
    public let hasSeenAd: Bool
    public let hasSeenNewFeature: Bool
    public let lastCheckInDate: Date?
    public let hasPredictionResult: Bool

    public init(
        memberId: String,
        hasSeenTutorial: Bool = false,
        hasSeenAd: Bool = false,
        hasSeenNewFeature: Bool = false,
        lastCheckInDate: Date? = nil,
        hasPredictionResult: Bool = false
    ) {
        self.memberId = memberId
        self.hasSeenTutorial = hasSeenTutorial
        self.hasSeenAd = hasSeenAd
        self.hasSeenNewFeature = hasSeenNewFeature
        self.lastCheckInDate = lastCheckInDate
        self.hasPredictionResult = hasPredictionResult
    }

    // MARK: - Test Profiles

    public static let newUser = UserInfo(
        memberId: "1",
        hasSeenTutorial: false,
        hasSeenAd: false,
        hasSeenNewFeature: false,
        lastCheckInDate: nil,
        hasPredictionResult: false
    )

    public static let returningUser = UserInfo(
        memberId: "2",
        hasSeenTutorial: true,
        hasSeenAd: false,
        hasSeenNewFeature: false,
        lastCheckInDate: Date().addingTimeInterval(-86400 * 7),
        hasPredictionResult: false
    )

    public static let experiencedUser = UserInfo(
        memberId: "3",
        hasSeenTutorial: true,
        hasSeenAd: true,
        hasSeenNewFeature: false,
        lastCheckInDate: Date().addingTimeInterval(-86400),
        hasPredictionResult: false
    )

    public static let checkedInUser = UserInfo(
        memberId: "4",
        hasSeenTutorial: true,
        hasSeenAd: true,
        hasSeenNewFeature: true,
        lastCheckInDate: Date(),
        hasPredictionResult: false
    )

    public static let allCompletedUser = UserInfo(
        memberId: "5",
        hasSeenTutorial: true,
        hasSeenAd: true,
        hasSeenNewFeature: true,
        lastCheckInDate: Date(),
        hasPredictionResult: true
    )
}

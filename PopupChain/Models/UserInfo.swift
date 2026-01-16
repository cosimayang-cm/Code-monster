import Foundation

/// User information passed to the popup chain
struct UserInfo {
    let memberId: String
    let hasSeenTutorial: Bool
    let hasSeenAd: Bool
    let hasSeenNewFeature: Bool
    let lastCheckInDate: Date?
    let hasPredictionResult: Bool

    init(
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

    // MARK: - Test Profiles (Fixed IDs for reproducibility)

    /// New user - has seen nothing
    static let newUser = UserInfo(
        memberId: "1",
        hasSeenTutorial: false,
        hasSeenAd: false,
        hasSeenNewFeature: false,
        lastCheckInDate: nil,
        hasPredictionResult: false
    )

    /// Returning user - has seen tutorial, not ad
    static let returningUser = UserInfo(
        memberId: "2",
        hasSeenTutorial: true,
        hasSeenAd: false,
        hasSeenNewFeature: false,
        lastCheckInDate: Date().addingTimeInterval(-86400 * 7),
        hasPredictionResult: false
    )

    /// Experienced user - has seen tutorial and ad
    static let experiencedUser = UserInfo(
        memberId: "3",
        hasSeenTutorial: true,
        hasSeenAd: true,
        hasSeenNewFeature: false,
        lastCheckInDate: Date().addingTimeInterval(-86400),
        hasPredictionResult: false
    )

    /// Checked in user - already checked in today
    static let checkedInUser = UserInfo(
        memberId: "4",
        hasSeenTutorial: true,
        hasSeenAd: true,
        hasSeenNewFeature: true,
        lastCheckInDate: Date(),
        hasPredictionResult: false
    )

    /// All completed user - has seen everything
    static let allCompletedUser = UserInfo(
        memberId: "5",
        hasSeenTutorial: true,
        hasSeenAd: true,
        hasSeenNewFeature: true,
        lastCheckInDate: Date(),
        hasPredictionResult: true
    )
}

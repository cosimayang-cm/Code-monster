import Foundation

/// 表示當前使用者的狀態，用於彈窗決策
struct UserContext {
    var hasSeenTutorial: Bool
    var hasSeenInterstitialAd: Bool
    var hasSeenNewFeature: Bool
    var hasCheckedInToday: Bool
    var hasPredictionResult: Bool

    init(
        hasSeenTutorial: Bool = false,
        hasSeenInterstitialAd: Bool = false,
        hasSeenNewFeature: Bool = false,
        hasCheckedInToday: Bool = false,
        hasPredictionResult: Bool = false
    ) {
        self.hasSeenTutorial = hasSeenTutorial
        self.hasSeenInterstitialAd = hasSeenInterstitialAd
        self.hasSeenNewFeature = hasSeenNewFeature
        self.hasCheckedInToday = hasCheckedInToday
        self.hasPredictionResult = hasPredictionResult
    }
}

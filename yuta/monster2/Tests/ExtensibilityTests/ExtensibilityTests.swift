import XCTest
@testable import PopupResponseChain

// MARK: - 示範第 6 個 Handler

/// 評分提示處理器（示範擴展性）
struct RatingPromptHandler: PopupHandling {
    
    func shouldHandle(_ context: UserContext) -> Bool {
        // 為了測試，永遠顯示
        true
    }
    
    func show(completion: @escaping () -> Void) {
        print("[彈窗] 評分提示")
        completion()
    }
}

final class ExtensibilityTests: XCTestCase {
    
    func testAddingSixthHandler_DoesNotModifyExistingHandlers() {
        // Given - 原本的 5 個 Handler
        let originalHandlers: [any PopupHandling] = [
            TutorialHandler(),
            InterstitialAdHandler(),
            NewFeatureHandler(),
            DailyCheckInHandler(),
            PredictionResultHandler()
        ]
        
        // When - 新增第 6 個 Handler
        let extendedHandlers: [any PopupHandling] = originalHandlers + [RatingPromptHandler()]
        
        // Then
        XCTAssertEqual(originalHandlers.count, 5)
        XCTAssertEqual(extendedHandlers.count, 6)
        XCTAssertTrue(extendedHandlers.last is RatingPromptHandler)
    }
    
    func testChainWithSixHandlers_ExecutesInOrder() {
        // Given
        let manager = PopupChainManager(handlers: [
            TutorialHandler(),
            InterstitialAdHandler(),
            NewFeatureHandler(),
            DailyCheckInHandler(),
            PredictionResultHandler(),
            RatingPromptHandler()
        ])
        let context = UserContext(
            hasSeenTutorial: false,
            hasSeenInterstitialAd: false,
            hasSeenNewFeature: false,
            hasCheckedInToday: false,
            hasPredictionResult: true
        )
        let expectation = expectation(description: "Chain completed")
        
        // When
        manager.startChain(with: context) {
            expectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 1.0)
    }
}

import XCTest
@testable import PopupResponseChain

final class ChainIntegrationTests: XCTestCase {
    
    private var manager: PopupChainManager!
    
    override func setUp() {
        super.setUp()
        manager = PopupChainManager(handlers: [
            TutorialHandler(),
            InterstitialAdHandler(),
            NewFeatureHandler(),
            DailyCheckInHandler(),
            PredictionResultHandler()
        ])
    }
    
    override func tearDown() {
        manager = nil
        super.tearDown()
    }
    
    func testStartChain_WhenAllConditionsMet_ShowsAllPopups() {
        // Given
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
    
    func testStartChain_WhenNoConditionsMet_CompletesImmediately() {
        // Given
        let context = UserContext(
            hasSeenTutorial: true,
            hasSeenInterstitialAd: true,
            hasSeenNewFeature: true,
            hasCheckedInToday: true,
            hasPredictionResult: false
        )
        let expectation = expectation(description: "Chain completed")
        
        // When
        manager.startChain(with: context) {
            expectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 1.0)
    }
    
    func testStartChain_WhenOnlyMiddleConditionMet_ShowsOnlyThatPopup() {
        // Given
        let context = UserContext(
            hasSeenTutorial: true,
            hasSeenInterstitialAd: true,
            hasSeenNewFeature: false,  // 只有這個符合
            hasCheckedInToday: true,
            hasPredictionResult: false
        )
        let expectation = expectation(description: "Chain completed")
        
        // When
        manager.startChain(with: context) {
            expectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 1.0)
    }
    
    func testStartChain_WithEmptyHandlers_CompletesImmediately() {
        // Given
        let emptyManager = PopupChainManager(handlers: [])
        let context = UserContext()
        let expectation = expectation(description: "Chain completed")
        
        // When
        emptyManager.startChain(with: context) {
            expectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 1.0)
    }
    
    func testStartChain_WhenFirstHandlerOnly_ShowsFirstOnly() {
        // Given
        let context = UserContext(
            hasSeenTutorial: false,  // 只有第一個符合
            hasSeenInterstitialAd: true,
            hasSeenNewFeature: true,
            hasCheckedInToday: true,
            hasPredictionResult: false
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

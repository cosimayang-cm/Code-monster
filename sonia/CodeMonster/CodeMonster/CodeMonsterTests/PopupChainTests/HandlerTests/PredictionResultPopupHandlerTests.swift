import XCTest
@testable import CodeMonster

/// Unit tests for PredictionResultPopupHandler
class PredictionResultPopupHandlerTests: XCTestCase {
    
    var sut: PredictionResultPopupHandler!
    var mockRepository: MockPopupStateRepository!
    var mockPresenter: MockPopupPresenter!
    var mockLogger: MockLogger!
    var context: PopupContext!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockPopupStateRepository()
        mockPresenter = MockPopupPresenter()
        mockLogger = MockLogger()
        sut = PredictionResultPopupHandler()
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        mockPresenter = nil
        mockLogger = nil
        context = nil
        super.tearDown()
    }
    
    // MARK: - Test: Handler Type
    
    func testHandlerType() {
        XCTAssertEqual(sut.popupType, .predictionResult)
    }
    
    // MARK: - Test: Shows When Has Prediction Result
    
    func testShowsWhenHasPredictionResult() {
        // Given: User with prediction result available
        let userWithResult = UserInfo(
            memberId: "test",
            hasSeenTutorial: true,
            hasSeenAd: true,
            hasSeenNewFeature: true,
            lastCheckInDate: Date(),
            hasPredictionResult: true
        )
        
        context = PopupContext(
            userInfo: userWithResult,
            stateRepository: mockRepository,
            presenter: mockPresenter,
            logger: mockLogger,
            popupTransitionDelay: 0
        )
        
        // When: Handle is called
        let result = sut.handle(context: context)
        
        // Then: Should be shown
        switch result {
        case .success(.shown(.predictionResult)):
            XCTAssertTrue(true)
        default:
            XCTFail("Expected prediction result to be shown, got \(result)")
        }
    }
    
    // MARK: - Test: Skips When No Prediction Result
    
    func testSkipsWhenNoPredictionResult() {
        // Given: User without prediction result
        let userWithoutResult = UserInfo(
            memberId: "test",
            hasSeenTutorial: true,
            hasSeenAd: true,
            hasSeenNewFeature: true,
            lastCheckInDate: Date(),
            hasPredictionResult: false
        )
        
        context = PopupContext(
            userInfo: userWithoutResult,
            stateRepository: mockRepository,
            presenter: mockPresenter,
            logger: mockLogger,
            popupTransitionDelay: 0
        )
        
        // When: Handle is called
        let result = sut.handle(context: context)
        
        // Then: Should skip and terminate chain (PredictionResult is the last handler)
        switch result {
        case .success(.chainTerminated):
            XCTAssertTrue(true, "Chain terminated as expected for last handler")
        default:
            XCTFail("Expected chain termination when no result, got \(result)")
        }
    }
    
    // MARK: - Test: Resets On New Result
    
    func testResetsOnNewResult() {
        // Given: User who has seen previous result but has new result
        let userWithNewResult = UserInfo(
            memberId: "test",
            hasSeenTutorial: true,
            hasSeenAd: true,
            hasSeenNewFeature: true,
            lastCheckInDate: Date(),
            hasPredictionResult: true
        )
        
        // Previously shown
        mockRepository.setState(
            PopupState(type: .predictionResult, hasShown: true, lastShownDate: Date(), showCount: 1),
            for: userWithNewResult.memberId
        )
        
        context = PopupContext(
            userInfo: userWithNewResult,
            stateRepository: mockRepository,
            presenter: mockPresenter,
            logger: mockLogger,
            popupTransitionDelay: 0
        )
        
        // When: Handle is called (new result available)
        let result = sut.handle(context: context)
        
        // Then: Should show again (reset on new result)
        switch result {
        case .success(.shown(.predictionResult)):
            XCTAssertTrue(true)
        default:
            XCTFail("Expected prediction result to show on new result, got \(result)")
        }
    }
}

import XCTest
@testable import CodeMonster

/// Unit tests for InterstitialAdPopupHandler
class InterstitialAdPopupHandlerTests: XCTestCase {
    
    var sut: InterstitialAdPopupHandler!
    var mockRepository: MockPopupStateRepository!
    var mockPresenter: MockPopupPresenter!
    var mockLogger: MockLogger!
    var context: PopupContext!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockPopupStateRepository()
        mockPresenter = MockPopupPresenter()
        mockLogger = MockLogger()
        sut = InterstitialAdPopupHandler()
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
        XCTAssertEqual(sut.popupType, .interstitialAd)
    }
    
    // MARK: - Test: Shows Ad When Not Seen
    
    func testShowsAdWhenNotSeen() {
        // Given: User who hasn't seen ad
        let user = UserInfo.returningUser
        context = PopupContext(
            userInfo: user,
            stateRepository: mockRepository,
            presenter: mockPresenter,
            logger: mockLogger,
            popupTransitionDelay: 0
        )
        
        // When: Handle is called
        let result = sut.handle(context: context)
        
        // Then: Ad should be shown
        switch result {
        case .success(.shown(.interstitialAd)):
            XCTAssertTrue(true)
        default:
            XCTFail("Expected ad to be shown, got \(result)")
        }
        
        // And: State marked as shown
        XCTAssertEqual(mockRepository.markAsShownCalls.count, 1)
    }
    
    // MARK: - Test: Skips Ad When Already Seen
    
    func testSkipsAdWhenAlreadySeen() {
        // Given: User who has seen ad and a next handler
        let user = UserInfo.experiencedUser
        mockRepository.setState(
            PopupState(type: .interstitialAd, hasShown: true, lastShownDate: Date(), showCount: 1),
            for: user.memberId
        )
        
        let nextHandler = MockPopupHandler(popupType: .newFeature)
        sut.next = nextHandler
        
        context = PopupContext(
            userInfo: user,
            stateRepository: mockRepository,
            presenter: mockPresenter,
            logger: mockLogger,
            popupTransitionDelay: 0
        )
        
        // When: Handle is called
        let result = sut.handle(context: context)
        
        // Then: Should skip and continue to next handler
        switch result {
        case .success(.skipped):
            XCTAssertTrue(true)
        default:
            XCTFail("Expected skip, got \(result)")
        }
        
        // And: Next handler should be called
        XCTAssertTrue(nextHandler.handleWasCalled)
    }
    
    // MARK: - Test: Continues to Next Handler
    
    func testContinuesToNextHandler() {
        // Given: Handler with next in chain
        let nextHandler = MockPopupHandler(popupType: .newFeature)
        sut.next = nextHandler
        
        let user = UserInfo.returningUser
        context = PopupContext(
            userInfo: user,
            stateRepository: mockRepository,
            presenter: mockPresenter,
            logger: mockLogger,
            popupTransitionDelay: 0
        )
        
        // When: Ad is shown and dismissed
        _ = sut.handle(context: context)
        sut.onPopupDismissed()
        
        // Then: Next handler should be called
        XCTAssertTrue(nextHandler.handleWasCalled)
    }
}

import XCTest
@testable import CodeMonster

/// Unit tests for NewFeaturePopupHandler
class NewFeaturePopupHandlerTests: XCTestCase {
    
    var sut: NewFeaturePopupHandler!
    var mockRepository: MockPopupStateRepository!
    var mockPresenter: MockPopupPresenter!
    var mockLogger: MockLogger!
    var context: PopupContext!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockPopupStateRepository()
        mockPresenter = MockPopupPresenter()
        mockLogger = MockLogger()
        sut = NewFeaturePopupHandler()
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
        XCTAssertEqual(sut.popupType, .newFeature)
    }
    
    // MARK: - Test: Shows When Not Seen
    
    func testShowsWhenNotSeen() {
        // Given: User who hasn't seen new feature
        let user = UserInfo.experiencedUser
        context = PopupContext(
            userInfo: user,
            stateRepository: mockRepository,
            presenter: mockPresenter,
            logger: mockLogger,
            popupTransitionDelay: 0
        )
        
        // When: Handle is called
        let result = sut.handle(context: context)
        
        // Then: Should be shown
        switch result {
        case .success(.shown(.newFeature)):
            XCTAssertTrue(true)
        default:
            XCTFail("Expected new feature to be shown, got \(result)")
        }
    }
    
    // MARK: - Test: Skips When Already Seen
    
    func testSkipsWhenAlreadySeen() {
        // Given: User who has seen new feature and a next handler
        let user = UserInfo.checkedInUser
        mockRepository.setState(
            PopupState(type: .newFeature, hasShown: true, lastShownDate: Date(), showCount: 1),
            for: user.memberId
        )
        
        let nextHandler = MockPopupHandler(popupType: .dailyCheckIn)
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
        
        // Then: Should skip and continue
        switch result {
        case .success(.skipped):
            XCTAssertTrue(true)
        default:
            XCTFail("Expected skip, got \(result)")
        }
        
        // And: Next handler should be called
        XCTAssertTrue(nextHandler.handleWasCalled)
    }
    
    // MARK: - Test: Ad Exclusivity - Skips When Ad Shown
    
    func testSkipsWhenAdAlreadyShown() {
        // Given: User who has seen ad (ad and new feature are mutually exclusive) and a next handler
        let user = UserInfo.experiencedUser
        mockRepository.setState(
            PopupState(type: .interstitialAd, hasShown: true, lastShownDate: Date(), showCount: 1),
            for: user.memberId
        )
        
        let nextHandler = MockPopupHandler(popupType: .dailyCheckIn)
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
        
        // Then: Should skip (ad exclusivity) and continue
        switch result {
        case .success(.skipped):
            XCTAssertTrue(true)
        default:
            XCTFail("Expected skip due to ad exclusivity, got \(result)")
        }
        
        // And: Next handler should be called
        XCTAssertTrue(nextHandler.handleWasCalled)
    }
}

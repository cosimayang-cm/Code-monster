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
    
    // MARK: - Test: Shows When Ad Already Seen
    
    func testShowsWhenAdAlreadySeen() {
        // Given: User who HAS seen ad (so new feature can show)
        let user = UserInfo.experiencedUser  // hasSeenTutorial=true, hasSeenAd=true
        mockRepository.setState(
            PopupState(type: .interstitialAd, hasShown: true, lastShownDate: Date(), showCount: 1),
            for: user.memberId
        )
        
        context = PopupContext(
            userInfo: user,
            stateRepository: mockRepository,
            presenter: mockPresenter,
            logger: mockLogger,
            popupTransitionDelay: 0
        )
        
        // When: Handle is called
        let result = sut.handle(context: context)
        
        // Then: Should be shown (因為 Ad 已經看過，NewFeature 可以顯示)
        switch result {
        case .success(.shown(.newFeature)):
            XCTAssertTrue(true)
        default:
            XCTFail("Expected new feature to be shown when ad already seen, got \(result)")
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
    
    // MARK: - Test: Ad Exclusivity - Skips When Ad NOT Shown Yet
    
    func testSkipsWhenAdNotShownYet() {
        // Given: User who has NOT seen ad yet (ad has priority over new feature)
        let user = UserInfo.returningUser  // hasSeenTutorial=true, hasSeenAd=false
        // Don't set any ad state, meaning ad hasn't been shown yet
        
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
        
        // Then: Should skip (ad has priority) and continue
        switch result {
        case .success(.skipped):
            XCTAssertTrue(true)
        default:
            XCTFail("Expected skip because ad not shown yet (ad has priority), got \(result)")
        }
        
        // And: Next handler should be called
        XCTAssertTrue(nextHandler.handleWasCalled)
    }
}

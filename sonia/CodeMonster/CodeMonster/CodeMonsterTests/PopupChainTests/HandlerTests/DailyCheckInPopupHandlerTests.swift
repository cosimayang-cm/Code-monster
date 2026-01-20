import XCTest
@testable import CodeMonster

/// Unit tests for DailyCheckInPopupHandler
class DailyCheckInPopupHandlerTests: XCTestCase {
    
    var sut: DailyCheckInPopupHandler!
    var mockRepository: MockPopupStateRepository!
    var mockPresenter: MockPopupPresenter!
    var mockLogger: MockLogger!
    var context: PopupContext!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockPopupStateRepository()
        mockPresenter = MockPopupPresenter()
        mockLogger = MockLogger()
        sut = DailyCheckInPopupHandler()
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
        XCTAssertEqual(sut.popupType, .dailyCheckIn)
    }
    
    // MARK: - Test: Shows When Not Checked In Today
    
    func testShowsWhenNotCheckedInToday() {
        // Given: User who hasn't checked in today
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
        
        // Then: Should be shown
        switch result {
        case .success(.shown(.dailyCheckIn)):
            XCTAssertTrue(true)
        default:
            XCTFail("Expected check-in to be shown, got \(result)")
        }
    }
    
    // MARK: - Test: Skips When Already Checked In Today
    
    func testSkipsWhenAlreadyCheckedInToday() {
        // Given: User who checked in today and a next handler
        let user = UserInfo.checkedInUser
        mockRepository.setState(
            PopupState(type: .dailyCheckIn, hasShown: true, lastShownDate: Date(), showCount: 1),
            for: user.memberId
        )
        
        let nextHandler = MockPopupHandler(popupType: .predictionResult)
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
    
    // MARK: - Test: Shows Again Next Day (Daily Reset)
    
    func testShowsAgainNextDay() {
        // Given: User who checked in yesterday
        let user = UserInfo.returningUser
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        mockRepository.setState(
            PopupState(type: .dailyCheckIn, hasShown: true, lastShownDate: yesterday, showCount: 1),
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
        
        // Then: Should be shown (daily reset)
        switch result {
        case .success(.shown(.dailyCheckIn)):
            XCTAssertTrue(true)
        default:
            XCTFail("Expected check-in to be shown after daily reset, got \(result)")
        }
    }
}

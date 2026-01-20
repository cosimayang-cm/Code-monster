import XCTest
@testable import CodeMonster

/// Unit tests for TutorialPopupHandler
/// Tests User Story 1 - First-Time User Tutorial Flow
class TutorialPopupHandlerTests: XCTestCase {
    
    var sut: TutorialPopupHandler!
    var mockRepository: MockPopupStateRepository!
    var mockPresenter: MockPopupPresenter!
    var mockLogger: MockLogger!
    var context: PopupContext!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockPopupStateRepository()
        mockPresenter = MockPopupPresenter()
        mockLogger = MockLogger()
        sut = TutorialPopupHandler()
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
        XCTAssertEqual(sut.popupType, .tutorial)
    }
    
    // MARK: - Test: New User Sees Tutorial
    
    func testNewUserSeesTutorial() {
        // Given: New user who hasn't seen tutorial
        let newUser = UserInfo.newUser
        context = PopupContext(
            userInfo: newUser,
            stateRepository: mockRepository,
            presenter: mockPresenter,
            logger: mockLogger
        )
        
        // When: Handle is called
        let result = sut.handle(context: context)
        
        // Then: Tutorial should terminate chain (tutorial always terminates)
        switch result {
        case .success(.chainTerminated):
            XCTAssertTrue(true, "Tutorial terminates chain correctly")
        default:
            XCTFail("Expected chain termination, got \(result)")
        }
        
        // And: State should be marked as shown
        XCTAssertEqual(mockRepository.markAsShownCalls.count, 1)
        XCTAssertEqual(mockRepository.markAsShownCalls.first?.type, .tutorial)
    }
    
    // MARK: - Test: Returning User Skips Tutorial
    
    func testReturningUserSkipsTutorial() {
        // Given: User who has already seen tutorial
        let returningUser = UserInfo.returningUser
        mockRepository.setState(
            PopupState(type: .tutorial, hasShown: true, lastShownDate: Date(), showCount: 1),
            for: returningUser.memberId
        )
        
        context = PopupContext(
            userInfo: returningUser,
            stateRepository: mockRepository,
            presenter: mockPresenter,
            logger: mockLogger
        )
        
        // When: Handle is called
        let result = sut.handle(context: context)
        
        // Then: Tutorial should be skipped
        switch result {
        case .success(.skipped):
            XCTAssertTrue(true, "Tutorial skipped correctly")
        default:
            XCTFail("Expected tutorial to be skipped, got \(result)")
        }
        
        // And: Presenter should not be called
        XCTAssertEqual(mockPresenter.presentCalls.count, 0)
    }
    
    // MARK: - Test: Chain Terminates After Tutorial
    
    func testChainTerminatesAfterTutorial() {
        // Given: New user and a next handler in chain
        let newUser = UserInfo.newUser
        let nextHandler = MockPopupHandler(popupType: .interstitialAd)
        sut.next = nextHandler
        
        context = PopupContext(
            userInfo: newUser,
            stateRepository: mockRepository,
            presenter: mockPresenter,
            logger: mockLogger
        )
        
        // When: Handle is called
        let result = sut.handle(context: context)
        
        // Then: Result should be chainTerminated
        switch result {
        case .success(.chainTerminated):
            XCTAssertTrue(true, "Chain terminated correctly")
        default:
            XCTFail("Expected chain termination, got \(result)")
        }
        
        // And: Next handler should not be called
        XCTAssertFalse(nextHandler.handleWasCalled)
    }
    
    // MARK: - Test: Repository Read Failure Handling
    
    func testRepositoryReadFailureSkipsPopup() {
        // Given: Repository that fails to read
        mockRepository.shouldFailRead = true
        let user = UserInfo.newUser
        
        context = PopupContext(
            userInfo: user,
            stateRepository: mockRepository,
            presenter: mockPresenter,
            logger: mockLogger
        )
        
        // When: Handle is called
        let result = sut.handle(context: context)
        
        // Then: Popup should be skipped
        switch result {
        case .success(.skipped):
            XCTAssertTrue(true, "Skipped on read failure")
        default:
            XCTFail("Expected skip on read failure, got \(result)")
        }
        
        // And: Error should be logged
        XCTAssertTrue(mockLogger.hasLogged("Failed to read state", level: .warning))
    }
    
    // MARK: - Test: No Presenter Available
    
    func testNoPresenterSkipsDisplay() {
        // Given: Context without presenter
        let newUser = UserInfo.newUser
        context = PopupContext(
            userInfo: newUser,
            stateRepository: mockRepository,
            presenter: nil,  // No presenter
            logger: mockLogger
        )
        
        // When: Handle is called
        let result = sut.handle(context: context)
        
        // Then: Should still return chainTerminated (tutorial behavior)
        switch result {
        case .success(.chainTerminated):
            XCTAssertTrue(true, "Chain terminated even without presenter")
        default:
            XCTFail("Expected chain termination, got \(result)")
        }
        
        // And: Warning should be logged
        XCTAssertTrue(mockLogger.hasLogged("No presenter", level: .warning))
    }
}

// MARK: - Mock Handler for Testing

class MockPopupHandler: PopupHandler {
    let popupType: PopupType
    weak var next: PopupHandler?
    var handleWasCalled = false
    
    init(popupType: PopupType) {
        self.popupType = popupType
    }
    
    func handle(context: PopupContext) -> Result<PopupHandleResult, PopupError> {
        handleWasCalled = true
        return .success(.skipped)
    }
    
    func onPopupDismissed(context: PopupContext) {
        // No-op for mock
    }
}

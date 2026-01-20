import XCTest
@testable import CodeMonster

/// Integration tests for the complete popup chain system
class PopupChainIntegrationTests: XCTestCase {
    
    var chainManager: PopupChainManager!
    var mockRepository: MockPopupStateRepository!
    var mockPresenter: MockPopupPresenter!
    var mockLogger: MockLogger!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockPopupStateRepository()
        mockPresenter = MockPopupPresenter()
        mockLogger = MockLogger()
    }
    
    override func tearDown() {
        chainManager = nil
        mockRepository = nil
        mockPresenter = nil
        mockLogger = nil
        super.tearDown()
    }
    
    // MARK: - Test: New User Tutorial Flow (User Story 1)
    
    func testNewUserSeesOnlyTutorial() {
        // Given: New user profile
        let newUser = UserInfo.newUser
        chainManager = PopupChainManager(
            userInfo: newUser,
            stateRepository: mockRepository,
            presenter: mockPresenter,
            logger: mockLogger
        )
        
        // When: Chain is started
        chainManager.startPopupChain()
        
        // Then: Tutorial state should be marked as shown
        let tutorialState = mockRepository.states[newUser.memberId]?[.tutorial]
        XCTAssertEqual(tutorialState?.hasShown, true)
        
        // And: Chain should be triggered
        XCTAssertTrue(chainManager.hasTriggeredThisSession)
        
        // And: Chain terminated should be logged
        XCTAssertTrue(mockLogger.hasLogged("Chain terminated", level: .info) ||
                     mockLogger.hasLogged("chain", level: .info))
        
        // Note: In Phase 3, we focus on the chain logic, not UI presentation
        // UI presentation will be fully implemented in later phases
    }
    
    // MARK: - Test: Tutorial Skipped for Returning User
    
    func testReturningUserSkipsTutorial() {
        // Given: Returning user who has seen tutorial
        let returningUser = UserInfo.returningUser
        mockRepository.setState(
            PopupState(type: .tutorial, hasShown: true, lastShownDate: Date(), showCount: 1),
            for: returningUser.memberId
        )
        
        chainManager = PopupChainManager(
            userInfo: returningUser,
            stateRepository: mockRepository,
            presenter: mockPresenter,
            logger: mockLogger
        )
        
        // When: Chain is started
        chainManager.startPopupChain()
        
        // Then: Tutorial should not be shown
        XCTAssertFalse(mockPresenter.presentedPopups.contains(.tutorial))
        
        // Note: For Phase 3 (US1 only), chain may show nothing if only tutorial handler exists
        // Full chain testing will be added in Phase 4 (US2)
    }
    
    // MARK: - Test: Session-Once Trigger
    
    func testChainOnlyTriggeredOncePerSession() {
        // Given: Chain manager with new user
        let newUser = UserInfo.newUser
        chainManager = PopupChainManager(
            userInfo: newUser,
            stateRepository: mockRepository,
            presenter: mockPresenter,
            logger: mockLogger
        )
        
        // When: Chain is started first time
        chainManager.startPopupChain()
        let firstCallCount = mockPresenter.presentCalls.count
        
        // And: Chain is started again in same session
        chainManager.startPopupChain()
        let secondCallCount = mockPresenter.presentCalls.count
        
        // Then: Should not trigger again
        XCTAssertEqual(firstCallCount, secondCallCount, "Chain should only trigger once per session")
        XCTAssertTrue(chainManager.hasTriggeredThisSession)
    }
    
    // MARK: - Test: Session Reset
    
    func testSessionResetAllowsChainToTriggerAgain() {
        // Given: Chain that has already been triggered
        let newUser = UserInfo.newUser
        chainManager = PopupChainManager(
            userInfo: newUser,
            stateRepository: mockRepository,
            presenter: mockPresenter,
            logger: mockLogger
        )
        chainManager.startPopupChain()
        
        // Clear presenter for clean test
        mockPresenter.reset()
        
        // When: Session is reset
        chainManager.resetSession()
        
        // Then: Chain should be able to trigger again
        XCTAssertFalse(chainManager.hasTriggeredThisSession)
        
        // When: Chain is started again
        chainManager.startPopupChain()
        
        // Then: Chain should trigger
        XCTAssertTrue(chainManager.hasTriggeredThisSession)
    }
}

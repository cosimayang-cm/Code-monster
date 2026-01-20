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
            logger: mockLogger, popupTransitionDelay: 0
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
            logger: mockLogger, popupTransitionDelay: 0
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
            logger: mockLogger, popupTransitionDelay: 0
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
            logger: mockLogger, popupTransitionDelay: 0
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
    
    // MARK: - Test: Returning User Full Chain (User Story 2)
    
    func testReturningUserSeesFullChain() {
        // Given: Returning user with ad not seen
        let returningUser = UserInfo.returningUser
        mockRepository.setState(
            PopupState(type: .tutorial, hasShown: true, lastShownDate: Date(), showCount: 1),
            for: returningUser.memberId
        )
        
        chainManager = PopupChainManager(
            userInfo: returningUser,
            stateRepository: mockRepository,
            presenter: mockPresenter,
            logger: mockLogger, popupTransitionDelay: 0
        )
        
        // When: Chain is started (synchronous execution in tests)
        chainManager.startPopupChain()
        
        // Then: Tutorial should be skipped (already shown)
        let tutorialState = mockRepository.states[returningUser.memberId]?[.tutorial]
        XCTAssertEqual(tutorialState?.hasShown, true)
        
        // And: Ad should be marked as shown (next in chain)
        let adState = mockRepository.states[returningUser.memberId]?[.interstitialAd]
        XCTAssertEqual(adState?.hasShown, true, "Ad should be shown for returning user")
    }
    
    // MARK: - Test: Ad/Feature Exclusivity
    
    func testAdAndFeatureExclusivity() {
        // Given: User who has seen ad
        let experiencedUser = UserInfo.experiencedUser
        mockRepository.setState(
            PopupState(type: .tutorial, hasShown: true, lastShownDate: Date(), showCount: 1),
            for: experiencedUser.memberId
        )
        mockRepository.setState(
            PopupState(type: .interstitialAd, hasShown: true, lastShownDate: Date(), showCount: 1),
            for: experiencedUser.memberId
        )
        
        chainManager = PopupChainManager(
            userInfo: experiencedUser,
            stateRepository: mockRepository,
            presenter: mockPresenter,
            logger: mockLogger, popupTransitionDelay: 0
        )
        
        // When: Chain is started (synchronous execution in tests)
        chainManager.startPopupChain()
        
        // Then: New feature should be skipped (ad exclusivity)
        let featureState = mockRepository.states[experiencedUser.memberId]?[.newFeature]
        // Feature not shown due to ad exclusivity - either nil or hasShown is false
        XCTAssertTrue(featureState == nil || featureState?.hasShown == false, "Feature should be skipped due to ad exclusivity")
        
        // And: Daily check-in should be shown (next in chain)
        let checkInState = mockRepository.states[experiencedUser.memberId]?[.dailyCheckIn]
        XCTAssertEqual(checkInState?.hasShown, true, "Daily check-in should be shown")
    }
    
    // MARK: - Test: Daily Reset Logic
    
    func testDailyCheckInResets() {
        // Given: User who checked in yesterday
        let user = UserInfo.returningUser
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        mockRepository.setState(
            PopupState(type: .tutorial, hasShown: true, lastShownDate: Date(), showCount: 1),
            for: user.memberId
        )
        mockRepository.setState(
            PopupState(type: .dailyCheckIn, hasShown: true, lastShownDate: yesterday, showCount: 1),
            for: user.memberId
        )
        
        chainManager = PopupChainManager(
            userInfo: user,
            stateRepository: mockRepository,
            presenter: mockPresenter,
            logger: mockLogger, popupTransitionDelay: 0
        )
        
        // When: Chain is started today (synchronous execution in tests)
        chainManager.startPopupChain()
        
        // Then: Daily check-in should be shown again (daily reset)
        let checkInState = mockRepository.states[user.memberId]?[.dailyCheckIn]
        XCTAssertEqual(checkInState?.showCount, 2, "Check-in count should increment on daily reset")
    }
    
    // MARK: - Test: State Persistence (User Story 3)
    
    func testStatePersistenceWithUserDefaults() {
        // Given: UserDefaults-backed repository
        let suiteName = "com.codemonster.popupchain.persistence.test"
        let testDefaults = UserDefaults(suiteName: suiteName)!
        testDefaults.removePersistentDomain(forName: suiteName)
        
        let persistentRepository = UserDefaultsPopupStateRepository(defaults: testDefaults)
        let user = UserInfo.returningUser
        
        // When: First session - user sees tutorial
        let firstManager = PopupChainManager(
            userInfo: user,
            stateRepository: persistentRepository,
            presenter: mockPresenter,
            logger: mockLogger,
            popupTransitionDelay: 0
        )
        firstManager.startPopupChain()
        
        // Wait for async write
        Thread.sleep(forTimeInterval: 0.2)
        
        // Then: Create new manager instance (simulating app restart)
        let secondMockPresenter = MockPopupPresenter()
        let secondManager = PopupChainManager(
            userInfo: user,
            stateRepository: persistentRepository,
            presenter: secondMockPresenter,
            logger: mockLogger,
            popupTransitionDelay: 0
        )
        
        secondManager.startPopupChain()
        
        // Verify tutorial was not shown again (state persisted)
        let tutorialResult = persistentRepository.getState(for: .tutorial, memberId: user.memberId)
        guard case .success(let tutorialState) = tutorialResult else {
            XCTFail("Should retrieve tutorial state")
            return
        }
        
        XCTAssertTrue(tutorialState.hasShown, "Tutorial state should persist across sessions")
        XCTAssertGreaterThan(tutorialState.showCount, 0, "Show count should be persisted")
        
        // Cleanup
        testDefaults.removePersistentDomain(forName: suiteName)
    }
    
    func testMultiAccountStateIsolation() {
        // Given: UserDefaults-backed repository with two users
        let suiteName = "com.codemonster.popupchain.multiuser.test"
        let testDefaults = UserDefaults(suiteName: suiteName)!
        testDefaults.removePersistentDomain(forName: suiteName)
        
        let persistentRepository = UserDefaultsPopupStateRepository(defaults: testDefaults)
        
        let user1 = UserInfo(memberId: "user1", hasSeenTutorial: false, hasSeenAd: false, hasSeenNewFeature: false, hasPredictionResult: false)
        let user2 = UserInfo(memberId: "user2", hasSeenTutorial: false, hasSeenAd: false, hasSeenNewFeature: false, hasPredictionResult: false)
        
        let presenter1 = MockPopupPresenter()
        let presenter2 = MockPopupPresenter()
        
        // When: User1 sees tutorial
        let manager1 = PopupChainManager(
            userInfo: user1,
            stateRepository: persistentRepository,
            presenter: presenter1,
            logger: mockLogger,
            popupTransitionDelay: 0
        )
        manager1.startPopupChain()
        
        Thread.sleep(forTimeInterval: 0.2)
        
        // And: User2 starts session
        let manager2 = PopupChainManager(
            userInfo: user2,
            stateRepository: persistentRepository,
            presenter: presenter2,
            logger: mockLogger,
            popupTransitionDelay: 0
        )
        manager2.startPopupChain()
        
        Thread.sleep(forTimeInterval: 0.2)
        
        // Then: User1's state should be independent from User2's state
        let user1TutorialResult = persistentRepository.getState(for: .tutorial, memberId: user1.memberId)
        let user2TutorialResult = persistentRepository.getState(for: .tutorial, memberId: user2.memberId)
        
        guard case .success(let user1State) = user1TutorialResult,
              case .success(let user2State) = user2TutorialResult else {
            XCTFail("Should retrieve states")
            return
        }
        
        XCTAssertTrue(user1State.hasShown, "User1 should have seen tutorial")
        XCTAssertTrue(user2State.hasShown, "User2 should also have seen tutorial")
        XCTAssertEqual(user1State.showCount, 1)
        XCTAssertEqual(user2State.showCount, 1)
        
        // Cleanup
        testDefaults.removePersistentDomain(forName: suiteName)
    }
}

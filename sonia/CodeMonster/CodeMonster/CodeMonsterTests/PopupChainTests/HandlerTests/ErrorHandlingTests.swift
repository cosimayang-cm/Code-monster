//
//  ErrorHandlingTests.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/20.
//

import XCTest
@testable import CodeMonster

final class ErrorHandlingTests: XCTestCase {
    var faultyRepository: FaultyMockRepository!
    var mockPresenter: MockPopupPresenter!
    var mockLogger: MockLogger!
    let testMemberId = "errorTestUser"
    
    override func setUp() {
        super.setUp()
        faultyRepository = FaultyMockRepository()
        mockPresenter = MockPopupPresenter()
        mockLogger = MockLogger()
    }
    
    override func tearDown() {
        faultyRepository = nil
        mockPresenter = nil
        mockLogger = nil
        super.tearDown()
    }
    
    // MARK: - Repository Read Failure Tests
    
    func testRepositoryReadFailure_ContinuesToNextHandler() {
        // Given: Repository fails to read tutorial state
        faultyRepository.enableReadFailure(for: .tutorial)
        
        let user = UserInfo(memberId: testMemberId)
        let context = PopupContext(
            userInfo: user,
            stateRepository: faultyRepository,
            presenter: mockPresenter,
            logger: mockLogger,
            popupTransitionDelay: 0
        )
        
        // When: Tutorial handler processes
        let tutorialHandler = TutorialPopupHandler()
        let adHandler = InterstitialAdPopupHandler()
        
        tutorialHandler.next = adHandler
        
        let result = tutorialHandler.handle(context: context)
        
        // Then: Should handle error gracefully and not crash
        switch result {
        case .success:
            XCTAssertTrue(true, "Should handle read failure gracefully")
        case .failure(let error):
            XCTFail("Should not fail fatally: \(error)")
        }
    }
    
    func testRepositoryReadFailure_LogsError() {
        // Given: Repository fails to read
        faultyRepository.enableReadFailure()
        
        let user = UserInfo(memberId: testMemberId)
        let context = PopupContext(
            userInfo: user,
            stateRepository: faultyRepository,
            presenter: mockPresenter,
            logger: mockLogger,
            popupTransitionDelay: 0
        )
        
        let handler = TutorialPopupHandler()
        
        // When: Handler processes
        _ = handler.handle(context: context)
        
        // Then: Error should be logged
        let errors = mockLogger.loggedMessages(for: .error)
        XCTAssertTrue(errors.contains { $0.contains("Failed to read") || $0.contains("repository") },
                      "Should log repository read error")
    }
    
    // MARK: - Repository Write Failure Tests
    
    func testRepositoryWriteFailure_ContinuesToNextHandler() {
        // Given: Repository fails to write
        faultyRepository.enableWriteFailure(for: .tutorial)
        
        let user = UserInfo(memberId: testMemberId)
        let context = PopupContext(
            userInfo: user,
            stateRepository: faultyRepository,
            presenter: mockPresenter,
            logger: mockLogger,
            popupTransitionDelay: 0
        )
        
        let tutorialHandler = TutorialPopupHandler()
        
        // When: Handler processes (write will fail)
        let result = tutorialHandler.handle(context: context)
        
        // Then: Should not crash despite write failure (graceful degradation)
        switch result {
        case .success:
            XCTAssertTrue(true, "Should handle write failure gracefully")
        case .failure(let error):
            XCTFail("Should not fail fatally: \(error)")
        }
    }
    
    func testRepositoryWriteFailure_LogsError() {
        // Given: Repository fails to write
        faultyRepository.enableWriteFailure()
        
        let user = UserInfo(memberId: testMemberId)
        let context = PopupContext(
            userInfo: user,
            stateRepository: faultyRepository,
            presenter: mockPresenter,
            logger: mockLogger,
            popupTransitionDelay: 0
        )
        
        let handler = TutorialPopupHandler()
        
        // When: Handler processes
        let result = handler.handle(context: context)
        
        // Then: Should complete without fatal error
        switch result {
        case .success:
            // Check that error was logged
            let allLogs = mockLogger.logs
            let hasErrorLog = allLogs.contains { $0.level == .error && ($0.message.contains("write") || $0.message.contains("Repository")) }
            XCTAssertTrue(hasErrorLog, "Should log write error")
        case .failure(let error):
            XCTFail("Should not fail fatally: \(error)")
        }
    }
    
    // MARK: - Presenter Failure Tests
    
    func testPresenterNil_SkipsPopup() {
        // Given: No presenter available
        let user = UserInfo(memberId: testMemberId)
        let context = PopupContext(
            userInfo: user,
            stateRepository: faultyRepository,
            presenter: nil,  // No presenter
            logger: mockLogger,
            popupTransitionDelay: 0
        )
        
        let handler = TutorialPopupHandler()
        let nextHandler = InterstitialAdPopupHandler()
        
        handler.next = nextHandler
        
        // When: Handler processes without presenter
        let result = handler.handle(context: context)
        
        // Then: Should skip this popup and continue to next
        // The skip() method will call next handler's handle()
        switch result {
        case .success:
            XCTAssertTrue(true, "Should handle successfully")
        case .failure(let error):
            XCTFail("Should not fail: \(error)")
        }
        
        let warnings = mockLogger.loggedMessages(for: .warning)
        XCTAssertTrue(warnings.contains { $0.contains("No presenter") || $0.contains("presenter") },
                      "Should log warning about missing presenter")
    }
    
    // MARK: - Multiple Failures Tests
    
    func testMultipleRepositoryFailures_ChainContinues() {
        // Given: Multiple handlers with repository failures
        faultyRepository.enableReadFailure()
        
        let user = UserInfo.returningUser
        let context = PopupContext(
            userInfo: user,
            stateRepository: faultyRepository,
            presenter: mockPresenter,
            logger: mockLogger,
            popupTransitionDelay: 0
        )
        
        // Build chain: Tutorial -> Ad -> Feature
        let tutorialHandler = TutorialPopupHandler()
        let adHandler = InterstitialAdPopupHandler()
        let featureHandler = NewFeaturePopupHandler()
        
        tutorialHandler.next = adHandler
        adHandler.next = featureHandler
        
        // When: Chain processes with failures
        let result = tutorialHandler.handle(context: context)
        
        // Then: Chain should complete despite errors
        guard case .success = result else {
            XCTFail("Should succeed despite errors")
            return
        }
        let errors = mockLogger.loggedMessages(for: .error)
        XCTAssertGreaterThan(errors.count, 0, "Should log errors")
    }
    
    func testMixedSuccessAndFailure_ChainContinues() {
        // Given: Some handlers succeed, some fail
        faultyRepository.enableReadFailure(for: .interstitialAd)
        
        // Set tutorial as seen (will succeed)
        faultyRepository.setState(
            PopupState(type: .tutorial, hasShown: true, lastShownDate: Date(), showCount: 1),
            for: testMemberId
        )
        
        let user = UserInfo.returningUser
        let context = PopupContext(
            userInfo: user,
            stateRepository: faultyRepository,
            presenter: mockPresenter,
            logger: mockLogger,
            popupTransitionDelay: 0
        )
        
        let tutorialHandler = TutorialPopupHandler()
        let adHandler = InterstitialAdPopupHandler()
        let featureHandler = NewFeaturePopupHandler()
        
        tutorialHandler.next = adHandler
        adHandler.next = featureHandler
        
        // When: Chain processes
        let result = tutorialHandler.handle(context: context)
        
        // Then: Chain should complete despite mixed success/failure
        switch result {
        case .success:
            XCTAssertTrue(true, "Chain handled mixed success/failure gracefully")
        case .failure(let error):
            XCTFail("Should not fail: \(error)")
        }
    }
    
    // MARK: - Recovery Behavior Tests
    
    func testRepositoryFailure_DoesNotBlockSubsequentOperations() {
        // Given: Repository fails once
        faultyRepository.enableReadFailure(for: .tutorial)
        
        let user = UserInfo(memberId: testMemberId)
        let context = PopupContext(
            userInfo: user,
            stateRepository: faultyRepository,
            presenter: mockPresenter,
            logger: mockLogger,
            popupTransitionDelay: 0
        )
        
        let handler = TutorialPopupHandler()
        
        // When: First call with failure
        let result1 = handler.handle(context: context)
        
        // Then: Should not crash
        switch result1 {
        case .success:
            XCTAssertTrue(true, "First call handled gracefully")
        case .failure:
            XCTFail("Should not fail fatally")
        }
        
        // Disable failure for next attempt
        faultyRepository.disableFailures()
        
        // When: Second call succeeds
        let result2 = handler.handle(context: context)
        
        // Then: Should work normally after recovery
        switch result2 {
        case .success:
            XCTAssertTrue(true, "Second call succeeded after recovery")
        case .failure:
            XCTFail("Should succeed after repository recovered")
        }
    }
}

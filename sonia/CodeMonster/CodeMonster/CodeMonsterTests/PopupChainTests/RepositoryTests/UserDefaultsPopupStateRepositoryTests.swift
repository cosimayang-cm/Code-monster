//
//  UserDefaultsPopupStateRepositoryTests.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/20.
//

import XCTest
@testable import CodeMonster

final class UserDefaultsPopupStateRepositoryTests: XCTestCase {
    var sut: UserDefaultsPopupStateRepository!
    var testDefaults: UserDefaults!
    let testMemberId = "user123"
    let testMemberId2 = "user456"
    let suiteName = "com.codemonster.popupchain.tests"
    
    override func setUp() {
        super.setUp()
        testDefaults = UserDefaults(suiteName: suiteName)!
        testDefaults.removePersistentDomain(forName: suiteName)
        sut = UserDefaultsPopupStateRepository(defaults: testDefaults)
    }
    
    override func tearDown() {
        testDefaults.removePersistentDomain(forName: suiteName)
        testDefaults = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - getState Tests
    
    func testGetState_ReturnsDefaultStateWhenNotFound() {
        let result = sut.getState(for: .tutorial, memberId: testMemberId)
        
        guard case .success(let state) = result else {
            XCTFail("Expected success")
            return
        }
        
        XCTAssertEqual(state.type, .tutorial)
        XCTAssertFalse(state.hasShown)
        XCTAssertNil(state.lastShownDate)
        XCTAssertEqual(state.showCount, 0)
    }
    
    func testGetState_ReturnsStoredState() {
        let expectedState = PopupState(
            type: .tutorial,
            hasShown: true,
            lastShownDate: Date(),
            showCount: 1
        )
        
        _ = sut.updateState(expectedState, memberId: testMemberId)
        
        // Wait for async write
        Thread.sleep(forTimeInterval: 0.1)
        
        let result = sut.getState(for: .tutorial, memberId: testMemberId)
        
        guard case .success(let state) = result else {
            XCTFail("Expected success")
            return
        }
        
        XCTAssertEqual(state.type, expectedState.type)
        XCTAssertEqual(state.hasShown, expectedState.hasShown)
        XCTAssertEqual(state.showCount, expectedState.showCount)
    }
    
    // MARK: - updateState Tests
    
    func testUpdateState_PersistsState() {
        let state = PopupState(
            type: .interstitialAd,
            hasShown: true,
            lastShownDate: Date(),
            showCount: 2
        )
        
        let updateResult = sut.updateState(state, memberId: testMemberId)
        XCTAssertTrue(updateResult.isSuccess)
        
        // Wait for async write
        Thread.sleep(forTimeInterval: 0.1)
        
        let getResult = sut.getState(for: .interstitialAd, memberId: testMemberId)
        guard case .success(let retrievedState) = getResult else {
            XCTFail("Expected success")
            return
        }
        
        XCTAssertEqual(retrievedState.hasShown, true)
        XCTAssertEqual(retrievedState.showCount, 2)
    }
    
    func testUpdateState_OverwritesExistingState() {
        let initialState = PopupState(type: .tutorial, hasShown: true, lastShownDate: Date(), showCount: 1)
        _ = sut.updateState(initialState, memberId: testMemberId)
        
        Thread.sleep(forTimeInterval: 0.1)
        
        let updatedState = PopupState(type: .tutorial, hasShown: true, lastShownDate: Date(), showCount: 5)
        _ = sut.updateState(updatedState, memberId: testMemberId)
        
        Thread.sleep(forTimeInterval: 0.1)
        
        let result = sut.getState(for: .tutorial, memberId: testMemberId)
        guard case .success(let state) = result else {
            XCTFail("Expected success")
            return
        }
        
        XCTAssertEqual(state.showCount, 5)
    }
    
    // MARK: - markAsShown Tests
    
    func testMarkAsShown_CreatesNewStateWhenNotExists() {
        let result = sut.markAsShown(type: .dailyCheckIn, memberId: testMemberId)
        XCTAssertTrue(result.isSuccess)
        
        Thread.sleep(forTimeInterval: 0.1)
        
        let getResult = sut.getState(for: .dailyCheckIn, memberId: testMemberId)
        guard case .success(let state) = getResult else {
            XCTFail("Expected success")
            return
        }
        
        XCTAssertTrue(state.hasShown)
        XCTAssertNotNil(state.lastShownDate)
        XCTAssertEqual(state.showCount, 1)
    }
    
    func testMarkAsShown_IncrementsShowCount() {
        _ = sut.markAsShown(type: .newFeature, memberId: testMemberId)
        Thread.sleep(forTimeInterval: 0.1)
        
        _ = sut.markAsShown(type: .newFeature, memberId: testMemberId)
        Thread.sleep(forTimeInterval: 0.1)
        
        let result = sut.getState(for: .newFeature, memberId: testMemberId)
        guard case .success(let state) = result else {
            XCTFail("Expected success")
            return
        }
        
        XCTAssertEqual(state.showCount, 2)
    }
    
    // MARK: - Daily Reset Tests
    
    func testDailyCheckIn_ResetsNextDay() {
        // Create a state from yesterday
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let yesterdayState = PopupState(
            type: .dailyCheckIn,
            hasShown: true,
            lastShownDate: yesterday,
            showCount: 5
        )
        
        _ = sut.updateState(yesterdayState, memberId: testMemberId)
        Thread.sleep(forTimeInterval: 0.1)
        
        // Retrieve state - should be reset
        let result = sut.getState(for: .dailyCheckIn, memberId: testMemberId)
        guard case .success(let state) = result else {
            XCTFail("Expected success")
            return
        }
        
        XCTAssertFalse(state.hasShown)
        XCTAssertEqual(state.showCount, 0)
    }
    
    func testDailyCheckIn_NoResetSameDay() {
        _ = sut.markAsShown(type: .dailyCheckIn, memberId: testMemberId)
        Thread.sleep(forTimeInterval: 0.1)
        
        let result = sut.getState(for: .dailyCheckIn, memberId: testMemberId)
        guard case .success(let state) = result else {
            XCTFail("Expected success")
            return
        }
        
        XCTAssertTrue(state.hasShown)
        XCTAssertEqual(state.showCount, 1)
    }
    
    func testNonDailyPopup_NeverResets() {
        // Create an old tutorial state
        let longAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        let oldState = PopupState(
            type: .tutorial,
            hasShown: true,
            lastShownDate: longAgo,
            showCount: 1
        )
        
        _ = sut.updateState(oldState, memberId: testMemberId)
        Thread.sleep(forTimeInterval: 0.1)
        
        // Retrieve state - should NOT be reset
        let result = sut.getState(for: .tutorial, memberId: testMemberId)
        guard case .success(let state) = result else {
            XCTFail("Expected success")
            return
        }
        
        XCTAssertTrue(state.hasShown)
        XCTAssertEqual(state.showCount, 1)
    }
    
    // MARK: - Multi-User Isolation Tests
    
    func testMultiUser_StatesAreIsolated() {
        _ = sut.markAsShown(type: .tutorial, memberId: testMemberId)
        Thread.sleep(forTimeInterval: 0.1)
        
        let user1Result = sut.getState(for: .tutorial, memberId: testMemberId)
        let user2Result = sut.getState(for: .tutorial, memberId: testMemberId2)
        
        guard case .success(let user1State) = user1Result,
              case .success(let user2State) = user2Result else {
            XCTFail("Expected success")
            return
        }
        
        XCTAssertTrue(user1State.hasShown)
        XCTAssertFalse(user2State.hasShown)
    }
    
    func testMultiUser_DifferentPopupTypes() {
        _ = sut.markAsShown(type: .tutorial, memberId: testMemberId)
        _ = sut.markAsShown(type: .interstitialAd, memberId: testMemberId2)
        Thread.sleep(forTimeInterval: 0.1)
        
        let user1Tutorial = sut.getState(for: .tutorial, memberId: testMemberId)
        let user1Ad = sut.getState(for: .interstitialAd, memberId: testMemberId)
        let user2Tutorial = sut.getState(for: .tutorial, memberId: testMemberId2)
        let user2Ad = sut.getState(for: .interstitialAd, memberId: testMemberId2)
        
        guard case .success(let u1t) = user1Tutorial,
              case .success(let u1a) = user1Ad,
              case .success(let u2t) = user2Tutorial,
              case .success(let u2a) = user2Ad else {
            XCTFail("Expected success")
            return
        }
        
        XCTAssertTrue(u1t.hasShown)
        XCTAssertFalse(u1a.hasShown)
        XCTAssertFalse(u2t.hasShown)
        XCTAssertTrue(u2a.hasShown)
    }
    
    // MARK: - resetUser Tests
    
    func testResetUser_ClearsUserStates() {
        _ = sut.markAsShown(type: .tutorial, memberId: testMemberId)
        _ = sut.markAsShown(type: .interstitialAd, memberId: testMemberId)
        Thread.sleep(forTimeInterval: 0.1)
        
        sut.resetUser(memberId: testMemberId)
        Thread.sleep(forTimeInterval: 0.1)
        
        let tutorialResult = sut.getState(for: .tutorial, memberId: testMemberId)
        let adResult = sut.getState(for: .interstitialAd, memberId: testMemberId)
        
        guard case .success(let tutorialState) = tutorialResult,
              case .success(let adState) = adResult else {
            XCTFail("Expected success")
            return
        }
        
        XCTAssertFalse(tutorialState.hasShown)
        XCTAssertFalse(adState.hasShown)
    }
    
    func testResetUser_DoesNotAffectOtherUsers() {
        _ = sut.markAsShown(type: .tutorial, memberId: testMemberId)
        _ = sut.markAsShown(type: .tutorial, memberId: testMemberId2)
        Thread.sleep(forTimeInterval: 0.1)
        
        sut.resetUser(memberId: testMemberId)
        Thread.sleep(forTimeInterval: 0.1)
        
        let user1Result = sut.getState(for: .tutorial, memberId: testMemberId)
        let user2Result = sut.getState(for: .tutorial, memberId: testMemberId2)
        
        guard case .success(let user1State) = user1Result,
              case .success(let user2State) = user2Result else {
            XCTFail("Expected success")
            return
        }
        
        XCTAssertFalse(user1State.hasShown)
        XCTAssertTrue(user2State.hasShown)
    }
    
    // MARK: - resetAll Tests
    
    func testResetAll_ClearsAllStates() {
        _ = sut.markAsShown(type: .tutorial, memberId: testMemberId)
        _ = sut.markAsShown(type: .interstitialAd, memberId: testMemberId2)
        Thread.sleep(forTimeInterval: 0.1)
        
        sut.resetAll()
        Thread.sleep(forTimeInterval: 0.1)
        
        let user1Result = sut.getState(for: .tutorial, memberId: testMemberId)
        let user2Result = sut.getState(for: .interstitialAd, memberId: testMemberId2)
        
        guard case .success(let user1State) = user1Result,
              case .success(let user2State) = user2Result else {
            XCTFail("Expected success")
            return
        }
        
        XCTAssertFalse(user1State.hasShown)
        XCTAssertFalse(user2State.hasShown)
    }
    
    // MARK: - Persistence Tests
    
    func testStatePersistsAcrossRepositoryInstances() {
        // Save state with first repository instance
        _ = sut.markAsShown(type: .tutorial, memberId: testMemberId)
        Thread.sleep(forTimeInterval: 0.1)
        
        // Create new repository instance with same defaults
        let newRepository = UserDefaultsPopupStateRepository(defaults: testDefaults)
        
        let result = newRepository.getState(for: .tutorial, memberId: testMemberId)
        guard case .success(let state) = result else {
            XCTFail("Expected success")
            return
        }
        
        XCTAssertTrue(state.hasShown)
    }
}

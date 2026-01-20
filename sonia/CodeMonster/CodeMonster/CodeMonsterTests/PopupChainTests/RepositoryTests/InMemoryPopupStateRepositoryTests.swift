//
//  InMemoryPopupStateRepositoryTests.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/20.
//

import XCTest
@testable import CodeMonster

final class InMemoryPopupStateRepositoryTests: XCTestCase {
    var sut: InMemoryPopupStateRepository!
    let testMemberId = "user123"
    let testMemberId2 = "user456"
    
    override func setUp() {
        super.setUp()
        sut = InMemoryPopupStateRepository()
    }
    
    override func tearDown() {
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
    
    func testUpdateState_StoresNewState() {
        let state = PopupState(
            type: .interstitialAd,
            hasShown: true,
            lastShownDate: Date(),
            showCount: 2
        )
        
        let updateResult = sut.updateState(state, memberId: testMemberId)
        XCTAssertTrue(updateResult.isSuccess)
        
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
        
        let updatedState = PopupState(type: .tutorial, hasShown: true, lastShownDate: Date(), showCount: 5)
        _ = sut.updateState(updatedState, memberId: testMemberId)
        
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
        _ = sut.markAsShown(type: .newFeature, memberId: testMemberId)
        
        let result = sut.getState(for: .newFeature, memberId: testMemberId)
        guard case .success(let state) = result else {
            XCTFail("Expected success")
            return
        }
        
        XCTAssertEqual(state.showCount, 2)
    }
    
    func testMarkAsShown_UpdatesLastShownDate() {
        let beforeMark = Date()
        _ = sut.markAsShown(type: .predictionResult, memberId: testMemberId)
        
        let result = sut.getState(for: .predictionResult, memberId: testMemberId)
        guard case .success(let state) = result else {
            XCTFail("Expected success")
            return
        }
        
        XCTAssertNotNil(state.lastShownDate)
        XCTAssertGreaterThanOrEqual(state.lastShownDate!, beforeMark)
    }
    
    // MARK: - Multi-User Isolation Tests
    
    func testMultiUser_StatesAreIsolated() {
        _ = sut.markAsShown(type: .tutorial, memberId: testMemberId)
        
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
        
        sut.resetUser(memberId: testMemberId)
        
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
        
        sut.resetUser(memberId: testMemberId)
        
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
        
        sut.resetAll()
        
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
}

//
//  PopupHandlerTests.swift
//  CarSystemTests
//
//  Created by PopupChain Feature
//  彈窗連鎖顯示機制 (Popup Response Chain)
//

import XCTest
@testable import CarSystem

final class PopupHandlerTests: XCTestCase {

    // MARK: - TutorialPopupHandler Tests

    func testTutorialHandler_ShouldDisplay_WhenNotSeenTutorial() {
        // Given
        let handler = TutorialPopupHandler()
        var state = PopupUserState()
        state.hasSeenTutorial = false

        // When & Then
        XCTAssertTrue(handler.shouldDisplay(state: state))
    }

    func testTutorialHandler_ShouldNotDisplay_WhenAlreadySeenTutorial() {
        // Given
        let handler = TutorialPopupHandler()
        var state = PopupUserState()
        state.hasSeenTutorial = true

        // When & Then
        XCTAssertFalse(handler.shouldDisplay(state: state))
    }

    // MARK: - DailyCheckInHandler Tests

    func testDailyCheckInHandler_ShouldDisplay_WhenNotCheckedInToday() {
        // Given
        let handler = DailyCheckInHandler()
        var state = PopupUserState()
        state.lastCheckInDate = nil

        // When & Then
        XCTAssertTrue(handler.shouldDisplay(state: state))
    }

    func testDailyCheckInHandler_ShouldNotDisplay_WhenAlreadyCheckedInToday() {
        // Given
        let handler = DailyCheckInHandler()
        var state = PopupUserState()
        state.lastCheckInDate = Date() // 今天

        // When & Then
        XCTAssertFalse(handler.shouldDisplay(state: state))
    }

    func testDailyCheckInHandler_ShouldDisplay_WhenCheckedInYesterday() {
        // Given
        let handler = DailyCheckInHandler()
        var state = PopupUserState()
        state.lastCheckInDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())

        // When & Then
        XCTAssertTrue(handler.shouldDisplay(state: state))
    }

    // MARK: - InterstitialAdHandler Tests (FR-012)

    func testInterstitialAdHandler_ShouldDisplay_WhenHasAdAndNotShownToday() {
        // Given
        let handler = InterstitialAdHandler()
        handler.hasAvailableAd = true
        var state = PopupUserState()
        state.lastAdShownDate = nil

        // When & Then
        XCTAssertTrue(handler.shouldDisplay(state: state))
    }

    func testInterstitialAdHandler_ShouldNotDisplay_WhenAlreadyShownToday() {
        // Given
        let handler = InterstitialAdHandler()
        handler.hasAvailableAd = true
        var state = PopupUserState()
        state.lastAdShownDate = Date() // 今天已顯示

        // When & Then - FR-012: 每日最多 1 次
        XCTAssertFalse(handler.shouldDisplay(state: state))
    }

    func testInterstitialAdHandler_ShouldNotDisplay_WhenNoAdAvailable() {
        // Given
        let handler = InterstitialAdHandler()
        handler.hasAvailableAd = false
        let state = PopupUserState()

        // When & Then
        XCTAssertFalse(handler.shouldDisplay(state: state))
    }

    // MARK: - NewFeaturePopupHandler Tests

    func testNewFeatureHandler_ShouldDisplay_WhenHasUnseenAnnouncement() {
        // Given
        let handler = NewFeaturePopupHandler()
        handler.announcements = [
            FeatureAnnouncement(id: "v2.0", title: "New Feature", description: "Description")
        ]
        let state = PopupUserState()

        // When & Then
        XCTAssertTrue(handler.shouldDisplay(state: state))
    }

    func testNewFeatureHandler_ShouldNotDisplay_WhenAllAnnouncementsSeen() {
        // Given
        let handler = NewFeaturePopupHandler()
        handler.announcements = [
            FeatureAnnouncement(id: "v2.0", title: "New Feature", description: "Description")
        ]
        var state = PopupUserState()
        state.seenFeatureAnnouncements = ["v2.0"]

        // When & Then
        XCTAssertFalse(handler.shouldDisplay(state: state))
    }

    // MARK: - PredictionResultHandler Tests

    func testPredictionResultHandler_ShouldDisplay_WhenHasPendingResults() {
        // Given
        let handler = PredictionResultHandler()
        handler.pendingResults = [(id: "pred_001", isCorrect: true)]
        let state = PopupUserState()

        // When & Then
        XCTAssertTrue(handler.shouldDisplay(state: state))
    }

    func testPredictionResultHandler_ShouldNotDisplay_WhenAllResultsNotified() {
        // Given
        let handler = PredictionResultHandler()
        handler.pendingResults = [(id: "pred_001", isCorrect: true)]
        var state = PopupUserState()
        state.notifiedPredictionResults = ["pred_001"]

        // When & Then
        XCTAssertFalse(handler.shouldDisplay(state: state))
    }

    func testPredictionResultHandler_ShouldNotDisplay_WhenNoPendingResults() {
        // Given
        let handler = PredictionResultHandler()
        handler.pendingResults = []
        let state = PopupUserState()

        // When & Then
        XCTAssertFalse(handler.shouldDisplay(state: state))
    }

    // MARK: - PopupType Tests

    func testPopupType_DisplayName() {
        XCTAssertEqual(PopupType.tutorial.displayName, "新手教學")
        XCTAssertEqual(PopupType.interstitialAd.displayName, "插頁式廣告")
        XCTAssertEqual(PopupType.newFeature.displayName, "新功能公告")
        XCTAssertEqual(PopupType.dailyCheckIn.displayName, "每日簽到")
        XCTAssertEqual(PopupType.predictionResult.displayName, "猜多空結果")
    }
}

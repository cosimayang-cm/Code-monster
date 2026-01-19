//
//  PopupStateStorageTests.swift
//  CarSystemTests
//
//  Created by PopupChain Feature
//  彈窗連鎖顯示機制 (Popup Response Chain)
//

import XCTest
@testable import CarSystem

final class PopupStateStorageTests: XCTestCase {

    var sut: PopupStateStorage!
    var testUserDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        // 使用獨立的 UserDefaults 進行測試，避免影響真實資料
        testUserDefaults = UserDefaults(suiteName: "PopupStateStorageTests")
        testUserDefaults.removePersistentDomain(forName: "PopupStateStorageTests")
        sut = PopupStateStorage(userDefaults: testUserDefaults)
    }

    override func tearDown() {
        sut.reset()
        testUserDefaults = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Load & Save Tests

    func testLoad_WhenNoDataExists_ReturnsDefaultState() {
        // When
        let state = sut.load()

        // Then
        XCTAssertFalse(state.hasSeenTutorial)
        XCTAssertNil(state.lastCheckInDate)
        XCTAssertNil(state.lastAdShownDate)
        XCTAssertTrue(state.seenFeatureAnnouncements.isEmpty)
        XCTAssertTrue(state.notifiedPredictionResults.isEmpty)
    }

    func testSaveAndLoad_PreservesState() {
        // Given
        var state = PopupUserState()
        state.hasSeenTutorial = true
        state.lastCheckInDate = Date()
        state.seenFeatureAnnouncements = ["feature1", "feature2"]

        // When
        sut.save(state)
        let loadedState = sut.load()

        // Then
        XCTAssertTrue(loadedState.hasSeenTutorial)
        XCTAssertNotNil(loadedState.lastCheckInDate)
        XCTAssertEqual(loadedState.seenFeatureAnnouncements.count, 2)
    }

    // MARK: - Mark Methods Tests

    func testMarkTutorialSeen_SetsHasSeenTutorialToTrue() {
        // When
        sut.markTutorialSeen()
        let state = sut.load()

        // Then
        XCTAssertTrue(state.hasSeenTutorial)
    }

    func testMarkDailyCheckIn_SetsLastCheckInDateToToday() {
        // When
        sut.markDailyCheckIn()
        let state = sut.load()

        // Then
        XCTAssertNotNil(state.lastCheckInDate)
        XCTAssertTrue(Calendar.current.isDateInToday(state.lastCheckInDate!))
    }

    func testMarkAdShown_SetsLastAdShownDateToToday() {
        // When
        sut.markAdShown()
        let state = sut.load()

        // Then
        XCTAssertNotNil(state.lastAdShownDate)
        XCTAssertTrue(Calendar.current.isDateInToday(state.lastAdShownDate!))
    }

    func testMarkFeatureSeen_AddsFeatureIdToSet() {
        // When
        sut.markFeatureSeen(id: "feature_v1.0")
        sut.markFeatureSeen(id: "feature_v1.1")
        let state = sut.load()

        // Then
        XCTAssertTrue(state.seenFeatureAnnouncements.contains("feature_v1.0"))
        XCTAssertTrue(state.seenFeatureAnnouncements.contains("feature_v1.1"))
        XCTAssertEqual(state.seenFeatureAnnouncements.count, 2)
    }

    func testMarkPredictionNotified_AddsPredictionIdToSet() {
        // When
        sut.markPredictionNotified(id: "prediction_001")
        let state = sut.load()

        // Then
        XCTAssertTrue(state.notifiedPredictionResults.contains("prediction_001"))
    }

    // MARK: - Reset Test

    func testReset_ClearsAllData() {
        // Given
        sut.markTutorialSeen()
        sut.markDailyCheckIn()

        // When
        sut.reset()
        let state = sut.load()

        // Then
        XCTAssertFalse(state.hasSeenTutorial)
        XCTAssertNil(state.lastCheckInDate)
    }
}

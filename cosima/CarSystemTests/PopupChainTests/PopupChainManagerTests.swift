//
//  PopupChainManagerTests.swift
//  CarSystemTests
//
//  Created by PopupChain Feature
//  彈窗連鎖顯示機制 (Popup Response Chain)
//

import XCTest
import Combine
@testable import CarSystem

final class PopupChainManagerTests: XCTestCase {

    var sut: PopupChainManager!
    var mockStorage: MockPopupStateStorage!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockStorage = MockPopupStateStorage()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        sut = nil
        mockStorage = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Priority Order Tests (FR-002)

    func testStartChain_ExecutesHandlersInArrayOrder() {
        // Given - 陣列順序即優先順序
        let handler1 = MockPopupHandler(type: .tutorial, shouldShow: true)
        let handler2 = MockPopupHandler(type: .dailyCheckIn, shouldShow: true)

        // handler1 在前，所以優先
        sut = PopupChainManager(handlers: [handler1, handler2], stateStorage: mockStorage)

        // When
        let viewController = UIViewController()
        sut.startChain(on: viewController)

        // Then - 第一個顯示的應該是 tutorial
        XCTAssertEqual(sut.currentPopup, .tutorial)
    }

    // MARK: - Max Popups Limit Tests (FR-010)

    func testStartChain_StopsAfterThreePopups() {
        // Given - 5 個都要顯示的 handler
        let handlers = [
            MockPopupHandler(type: .tutorial, shouldShow: true),
            MockPopupHandler(type: .interstitialAd, shouldShow: true),
            MockPopupHandler(type: .newFeature, shouldShow: true),
            MockPopupHandler(type: .dailyCheckIn, shouldShow: true),
            MockPopupHandler(type: .predictionResult, shouldShow: true)
        ]
        sut = PopupChainManager(handlers: handlers, stateStorage: mockStorage)

        let expectation = XCTestExpectation(description: "Chain should finish")

        sut.$isRunning
            .dropFirst() // 跳過初始值
            .filter { !$0 }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        let viewController = UIViewController()
        sut.startChain(on: viewController)

        // Simulate completing 3 popups
        handlers[0].simulateCompletion?(.completed)
        handlers[1].simulateCompletion?(.completed)
        handlers[2].simulateCompletion?(.completed)

        // Then - 應該只顯示 3 個
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.displayedCount, 3)
    }

    // MARK: - Skip on Failure Tests (FR-011)

    func testStartChain_SkipsFailedPopupWithoutRetry() {
        // Given
        let failingHandler = MockPopupHandler(type: .tutorial, shouldShow: true)
        let successHandler = MockPopupHandler(type: .dailyCheckIn, shouldShow: true)

        sut = PopupChainManager(handlers: [failingHandler, successHandler], stateStorage: mockStorage)

        // When
        let viewController = UIViewController()
        sut.startChain(on: viewController)

        // Simulate failure
        failingHandler.simulateCompletion?(.failed(NSError(domain: "test", code: -1)))

        // Then - 應該跳到下一個 handler
        XCTAssertEqual(sut.currentPopup, .dailyCheckIn)
    }

    // MARK: - Should Not Display Tests

    func testStartChain_SkipsHandlerWhenShouldDisplayReturnsFalse() {
        // Given
        let skipHandler = MockPopupHandler(type: .tutorial, shouldShow: false)
        let showHandler = MockPopupHandler(type: .dailyCheckIn, shouldShow: true)

        sut = PopupChainManager(handlers: [skipHandler, showHandler], stateStorage: mockStorage)

        // When
        let viewController = UIViewController()
        sut.startChain(on: viewController)

        // Then - 應該跳過 tutorial，直接顯示 dailyCheckIn
        XCTAssertEqual(sut.currentPopup, .dailyCheckIn)
    }

    // MARK: - Cancel Chain Tests

    func testCancelChain_StopsExecution() {
        // Given
        let handler = MockPopupHandler(type: .tutorial, shouldShow: true)
        sut = PopupChainManager(handlers: [handler], stateStorage: mockStorage)

        let viewController = UIViewController()
        sut.startChain(on: viewController)

        // When
        sut.cancelChain()

        // Then
        XCTAssertFalse(sut.isRunning)
        XCTAssertNil(sut.currentPopup)
    }
}

// MARK: - Mock Classes

class MockPopupStateStorage: PopupStateStorageProtocol {
    private var state = PopupUserState()

    func load() -> PopupUserState { return state }
    func save(_ state: PopupUserState) { self.state = state }
    func markTutorialSeen() { state.hasSeenTutorial = true }
    func markDailyCheckIn() { state.lastCheckInDate = Date() }
    func markAdShown() { state.lastAdShownDate = Date() }
    func markFeatureSeen(id: String) { state.seenFeatureAnnouncements.insert(id) }
    func markPredictionNotified(id: String) { state.notifiedPredictionResults.insert(id) }
}

class MockPopupHandler: PopupHandler {
    let popupType: PopupType
    private let shouldShow: Bool
    var simulateCompletion: ((PopupResult) -> Void)?

    init(type: PopupType, shouldShow: Bool) {
        self.popupType = type
        self.shouldShow = shouldShow
    }

    func shouldDisplay(state: PopupUserState) -> Bool {
        return shouldShow
    }

    func display(on viewController: UIViewController, completion: @escaping (PopupResult) -> Void) {
        simulateCompletion = completion
    }

    func updateState(storage: PopupStateStorage) {
        // Mock - do nothing
    }
}

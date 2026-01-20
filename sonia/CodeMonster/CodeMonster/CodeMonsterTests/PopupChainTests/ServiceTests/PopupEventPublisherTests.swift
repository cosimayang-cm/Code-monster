//
//  PopupEventPublisherTests.swift
//  CodeMonsterTests
//
//  Created by Sonia Wu on 2026/1/20.
//

import XCTest
@testable import CodeMonster

final class PopupEventPublisherTests: XCTestCase {
    
    var sut: PopupEventPublisher!
    var observer1: SpyPopupEventObserver!
    var observer2: SpyPopupEventObserver!
    
    override func setUp() {
        super.setUp()
        sut = PopupEventPublisher()
        observer1 = SpyPopupEventObserver()
        observer2 = SpyPopupEventObserver()
    }
    
    override func tearDown() {
        sut = nil
        observer1 = nil
        observer2 = nil
        super.tearDown()
    }
    
    // MARK: - Observer Management Tests
    
    func testAddObserver() {
        // When: Add observer
        sut.addObserver(observer1)
        
        // Then: Should notify observer
        let expectation = XCTestExpectation(description: "Observer notified")
        observer1.onEventReceived = { _ in
            expectation.fulfill()
        }
        
        sut.publish(.chainCompleted)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(observer1.receivedEvents.count, 1)
    }
    
    func testAddMultipleObservers() {
        // Given: Two observers
        sut.addObserver(observer1)
        sut.addObserver(observer2)
        
        // When: Publish event
        let exp1 = XCTestExpectation(description: "Observer 1")
        let exp2 = XCTestExpectation(description: "Observer 2")
        
        observer1.onEventReceived = { _ in exp1.fulfill() }
        observer2.onEventReceived = { _ in exp2.fulfill() }
        
        sut.publish(.popupWillShow(.tutorial))
        
        // Then: Both observers notified
        wait(for: [exp1, exp2], timeout: 1.0)
        XCTAssertEqual(observer1.receivedEvents.count, 1)
        XCTAssertEqual(observer2.receivedEvents.count, 1)
    }
    
    func testRemoveObserver() {
        // Given: Observer added
        sut.addObserver(observer1)
        
        // When: Remove observer
        sut.removeObserver(observer1)
        
        // Then: Should not receive events
        sut.publish(.chainCompleted)
        
        // Wait briefly to ensure no events delivered
        let exp = XCTestExpectation(description: "Wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.5)
        
        XCTAssertEqual(observer1.receivedEvents.count, 0)
    }
    
    func testRemoveAllObservers() {
        // Given: Multiple observers
        sut.addObserver(observer1)
        sut.addObserver(observer2)
        
        // When: Remove all
        sut.removeAllObservers()
        
        // Then: None receive events
        sut.publish(.chainCompleted)
        
        let exp = XCTestExpectation(description: "Wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.5)
        
        XCTAssertEqual(observer1.receivedEvents.count, 0)
        XCTAssertEqual(observer2.receivedEvents.count, 0)
    }
    
    func testWeakReferencePreventsRetainCycle() {
        // Given: Create observer in scope
        weak var weakObserver: SpyPopupEventObserver?
        
        autoreleasepool {
            let observer = SpyPopupEventObserver()
            weakObserver = observer
            sut.addObserver(observer)
            
            XCTAssertNotNil(weakObserver, "Observer should exist in scope")
        }
        
        // When: Observer goes out of scope
        // Then: Should be deallocated
        XCTAssertNil(weakObserver, "Observer should be deallocated")
    }
    
    // MARK: - Event Publishing Tests
    
    func testPublishWillShowEvent() {
        // Given: Observer registered
        sut.addObserver(observer1)
        
        let exp = XCTestExpectation(description: "WillShow event")
        observer1.onEventReceived = { event in
            if case .popupWillShow(.tutorial) = event {
                exp.fulfill()
            }
        }
        
        // When: Publish willShow
        sut.publishWillShow(.tutorial)
        
        // Then: Correct event received
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(observer1.receivedEvents.first, .popupWillShow(.tutorial))
    }
    
    func testPublishDidShowEvent() {
        // Given: Observer registered
        sut.addObserver(observer1)
        
        let exp = XCTestExpectation(description: "DidShow event")
        observer1.onEventReceived = { event in
            if case .popupDidShow(.interstitialAd) = event {
                exp.fulfill()
            }
        }
        
        // When: Publish didShow
        sut.publishDidShow(.interstitialAd)
        
        // Then: Correct event received
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(observer1.receivedEvents.first, .popupDidShow(.interstitialAd))
    }
    
    func testPublishMultipleEvents() {
        // Given: Observer registered
        sut.addObserver(observer1)
        
        let exp = XCTestExpectation(description: "Multiple events")
        exp.expectedFulfillmentCount = 3
        
        observer1.onEventReceived = { _ in
            exp.fulfill()
        }
        
        // When: Publish multiple events
        sut.publishWillShow(.tutorial)
        sut.publishDidShow(.tutorial)
        sut.publishChainCompleted()
        
        // Then: All events received in order
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(observer1.receivedEvents.count, 3)
        XCTAssertEqual(observer1.receivedEvents[0], .popupWillShow(.tutorial))
        XCTAssertEqual(observer1.receivedEvents[1], .popupDidShow(.tutorial))
        XCTAssertEqual(observer1.receivedEvents[2], .chainCompleted)
    }
    
    func testEventsDeliveredOnMainThread() {
        // Given: Observer registered
        sut.addObserver(observer1)
        
        let exp = XCTestExpectation(description: "Main thread delivery")
        observer1.onEventReceived = { _ in
            XCTAssertTrue(Thread.isMainThread, "Events should be delivered on main thread")
            exp.fulfill()
        }
        
        // When: Publish from background
        DispatchQueue.global().async {
            self.sut.publish(.chainCompleted)
        }
        
        // Then: Received on main thread
        wait(for: [exp], timeout: 1.0)
    }
    
    func testNoEventsAfterObserverDeallocated() {
        // Given: Observer in autorelease pool
        autoreleasepool {
            let observer = SpyPopupEventObserver()
            sut.addObserver(observer)
        }
        
        // When: Publish after observer deallocated
        sut.publish(.chainCompleted)
        
        // Then: No crash, event silently ignored
        let exp = XCTestExpectation(description: "Wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.5)
        
        // Test passes if no crash occurs
        XCTAssertTrue(true)
    }
}

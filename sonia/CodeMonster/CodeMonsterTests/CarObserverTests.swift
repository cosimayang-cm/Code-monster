//
//  CarObserverTests.swift
//  CodeMonsterTests
//
//  Created by Sonia Wu on 2026/1/11.
//

import XCTest
@testable import CodeMonster

/// Observer Pattern 測試（使用 CarEventPublisher）
final class CarObserverTests: XCTestCase {
    
    var car: Car!
    var observer: MockCarObserver!
    var eventPublisher: CarEventPublisher!
    
    override func setUp() {
        super.setUp()
        eventPublisher = CarEventPublisher()
        car = Car(eventPublisher: eventPublisher)
        observer = MockCarObserver()
        car.addObserver(observer)
    }
    
    override func tearDown() {
        car = nil
        observer = nil
        eventPublisher = nil
        super.tearDown()
    }
    
    // MARK: - 基本通知測試
    
    func testObserver_ReceivesNotificationWhenCentralComputerTurnsOn() {
        car.turnOnCentralComputer()
        
        XCTAssertEqual(observer.events.count, 1)
        if case .centralComputerTurnedOn = observer.events.first {
            // Success
        } else {
            XCTFail("Expected centralComputerTurnedOn event")
        }
    }
    
    func testObserver_ReceivesNotificationWhenCentralComputerTurnsOff() {
        car.turnOnCentralComputer()
        observer.events.removeAll()
        
        car.turnOffCentralComputer()
        
        XCTAssertTrue(observer.events.contains(where: {
            if case .centralComputerTurnedOff = $0 { return true }
            return false
        }))
    }
    
    func testObserver_ReceivesNotificationWhenEngineStarts() {
        car.turnOnCentralComputer()
        observer.events.removeAll()
        
        car.startEngine()
        
        XCTAssertEqual(observer.events.count, 1)
        if case .engineStarted = observer.events.first {
            // Success
        } else {
            XCTFail("Expected engineStarted event")
        }
    }
    
    func testObserver_ReceivesNotificationWhenEngineStops() {
        car.turnOnCentralComputer()
        car.startEngine()
        observer.events.removeAll()
        
        car.stopEngine()
        
        XCTAssertTrue(observer.events.contains(where: {
            if case .engineStopped = $0 { return true }
            return false
        }))
    }
    
    func testObserver_ReceivesNotificationWhenFeatureEnabled() {
        car.turnOnCentralComputer()
        observer.events.removeAll()
        
        _ = car.enableFeature(.airConditioner)
        
        XCTAssertTrue(observer.events.contains(where: {
            if case .featureEnabled(let feature) = $0, feature == .airConditioner {
                return true
            }
            return false
        }))
    }
    
    func testObserver_ReceivesNotificationWhenFeatureDisabled() {
        car.turnOnCentralComputer()
        _ = car.enableFeature(.airConditioner)
        observer.events.removeAll()
        
        _ = car.disableFeature(.airConditioner)
        
        XCTAssertTrue(observer.events.contains(where: {
            if case .featureDisabled(let feature) = $0, feature == .airConditioner {
                return true
            }
            return false
        }))
    }
    
    // MARK: - 連鎖停用通知測試
    
    func testObserver_ReceivesCascadeDisableNotification() {
        car.turnOnCentralComputer()
        _ = car.enableFeature(.rearCamera)
        _ = car.enableFeature(.surroundView)
        observer.events.removeAll()
        
        _ = car.disableFeature(.rearCamera)
        
        // 應該收到連鎖停用通知
        XCTAssertTrue(observer.events.contains(where: {
            if case .featuresCascadeDisabled(let features) = $0 {
                return features.contains(.rearCamera) && features.contains(.surroundView)
            }
            return false
        }))
    }
    
    func testObserver_ReceivesCascadeDisableWhenCentralComputerTurnsOff() {
        car.turnOnCentralComputer()
        _ = car.enableFeature(.airConditioner)
        _ = car.enableFeature(.bluetooth)
        _ = car.enableFeature(.navigation)
        observer.events.removeAll()
        
        car.turnOffCentralComputer()
        
        // 應該收到連鎖停用通知
        XCTAssertTrue(observer.events.contains(where: {
            if case .featuresCascadeDisabled(let features) = $0 {
                return features.count == 3
            }
            return false
        }))
    }
    
    func testObserver_ReceivesCascadeDisableWhenEngineStops() {
        car.turnOnCentralComputer()
        car.startEngine()
        _ = car.enableFeature(.navigation)
        _ = car.enableFeature(.frontRadar)
        _ = car.enableFeature(.laneKeeping)
        _ = car.enableFeature(.emergencyBraking)
        observer.events.removeAll()
        
        car.stopEngine()
        
        // 應該收到連鎖停用通知（車道維持、緊急煞車）
        XCTAssertTrue(observer.events.contains(where: {
            if case .featuresCascadeDisabled(let features) = $0 {
                return features.contains(.laneKeeping) && features.contains(.emergencyBraking)
            }
            return false
        }))
    }
    
    // MARK: - 多觀察者測試
    
    func testMultipleObservers_AllReceiveNotifications() {
        let observer2 = MockCarObserver()
        car.addObserver(observer2)
        
        car.turnOnCentralComputer()
        
        XCTAssertEqual(observer.events.count, 1)
        XCTAssertEqual(observer2.events.count, 1)
    }
    
    func testRemoveObserver_StopsReceivingNotifications() {
        car.turnOnCentralComputer()
        XCTAssertEqual(observer.events.count, 1)
        
        car.removeObserver(observer)
        observer.events.removeAll()
        
        car.startEngine()
        XCTAssertEqual(observer.events.count, 0, "Observer should not receive events after removal")
    }
    
    func testAddSameObserverTwice_OnlyReceivesOnce() {
        car.addObserver(observer) // 重複加入
        
        car.turnOnCentralComputer()
        
        XCTAssertEqual(observer.events.count, 1, "Should only receive one notification")
    }
    
    // MARK: - 記憶體管理測試
    
    func testWeakReference_ObserverReleasedAutomatically() {
        var tempObserver: MockCarObserver? = MockCarObserver()
        car.addObserver(tempObserver!)
        
        car.turnOnCentralComputer()
        XCTAssertEqual(tempObserver?.events.count, 1)
        
        // 釋放觀察者
        tempObserver = nil
        
        // 再次觸發事件（應該自動清理已釋放的觀察者）
        car.startEngine()
        
        // 驗證：不會 crash（因為使用 weak reference）
        XCTAssertTrue(true, "Should not crash when observer is deallocated")
    }
    
    // MARK: - 複雜場景測試
    
    func testObserver_ReceivesCompleteEventSequence() {
        car.turnOnCentralComputer()
        _ = car.enableFeature(.rearCamera)
        _ = car.enableFeature(.surroundView)
        _ = car.disableFeature(.rearCamera)
        car.turnOffCentralComputer()
        
        // 期望的事件序列
        let expectedEvents: [CarEvent] = [
            .centralComputerTurnedOn,
            .featureEnabled(.rearCamera),
            .featureEnabled(.surroundView),
            .featuresCascadeDisabled([.surroundView, .rearCamera]), // 先停依賴者，再停被依賴者
            .centralComputerTurnedOff
        ]
        
        // 直接比較事件序列
        XCTAssertEqual(observer.events, expectedEvents)
    }
}

// MARK: - Mock Observer

class MockCarObserver: CarEventObserver {
    var events: [CarEvent] = []
    
    func carDidChangeState(_ event: CarEvent) {
        events.append(event)
    }
}

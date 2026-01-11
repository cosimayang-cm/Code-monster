//
//  FeatureAvailabilityTests.swift
//  CodeMonsterTests
//
//  Created by Sonia Wu on 2026/1/11.
//

import XCTest
@testable import CodeMonster

/// Available vs Enabled 語意分離測試
final class FeatureAvailabilityTests: XCTestCase {
    
    var car: Car!
    
    override func setUp() {
        super.setUp()
        car = Car()
    }
    
    override func tearDown() {
        car = nil
        super.tearDown()
    }
    
    // MARK: - isFeatureAvailable 測試
    
    func testAirConditioner_NotAvailableWhenCentralComputerOff() {
        // 中控關閉時，冷氣不可用
        XCTAssertFalse(car.isFeatureAvailable(.airConditioner))
        XCTAssertFalse(car.isFeatureEnabled(.airConditioner))
    }
    
    func testAirConditioner_AvailableWhenCentralComputerOn() {
        car.turnOnCentralComputer()
        
        // 中控開啟時，冷氣變成可用（但尚未啟用）
        XCTAssertTrue(car.isFeatureAvailable(.airConditioner))
        XCTAssertFalse(car.isFeatureEnabled(.airConditioner))
    }
    
    func testAirConditioner_EnabledAfterActivation() {
        car.turnOnCentralComputer()
        _ = car.enableFeature(.airConditioner)
        
        // 啟用後，既可用又已啟用
        XCTAssertTrue(car.isFeatureAvailable(.airConditioner))
        XCTAssertTrue(car.isFeatureEnabled(.airConditioner))
    }
    
    func testSurroundView_NotAvailableWithoutRearCamera() {
        car.turnOnCentralComputer()
        
        // 沒有倒車鏡頭時，環景不可用
        XCTAssertFalse(car.isFeatureAvailable(.surroundView))
        XCTAssertFalse(car.isFeatureEnabled(.surroundView))
    }
    
    func testSurroundView_AvailableWithRearCamera() {
        car.turnOnCentralComputer()
        _ = car.enableFeature(.rearCamera)
        
        // 有倒車鏡頭後，環景變成可用（但尚未啟用）
        XCTAssertTrue(car.isFeatureAvailable(.surroundView))
        XCTAssertFalse(car.isFeatureEnabled(.surroundView))
    }
    
    func testLaneKeeping_NotAvailableWithoutEngine() {
        car.turnOnCentralComputer()
        _ = car.enableFeature(.navigation)
        _ = car.enableFeature(.frontRadar)
        
        // 引擎未啟動時，車道維持不可用
        XCTAssertFalse(car.isFeatureAvailable(.laneKeeping))
    }
    
    func testLaneKeeping_AvailableWithEngine() {
        car.turnOnCentralComputer()
        _ = car.enableFeature(.navigation)
        _ = car.enableFeature(.frontRadar)
        car.startEngine()
        
        // 引擎啟動後，車道維持變成可用
        XCTAssertTrue(car.isFeatureAvailable(.laneKeeping))
        XCTAssertFalse(car.isFeatureEnabled(.laneKeeping))
    }
    
    func testAutoPilot_NotAvailableWithPartialDependencies() {
        car.turnOnCentralComputer()
        car.startEngine()
        _ = car.enableFeature(.navigation)
        _ = car.enableFeature(.frontRadar)
        _ = car.enableFeature(.laneKeeping)
        
        // 只有部分依賴時，自動駕駛不可用
        XCTAssertFalse(car.isFeatureAvailable(.autoPilot))
    }
    
    func testAutoPilot_AvailableWithAllDependencies() {
        car.turnOnCentralComputer()
        car.startEngine()
        _ = car.enableFeature(.navigation)
        _ = car.enableFeature(.frontRadar)
        _ = car.enableFeature(.laneKeeping)
        _ = car.enableFeature(.emergencyBraking)
        _ = car.enableFeature(.rearCamera)
        _ = car.enableFeature(.surroundView)
        
        // 所有依賴都滿足時，自動駕駛可用
        XCTAssertTrue(car.isFeatureAvailable(.autoPilot))
        XCTAssertFalse(car.isFeatureEnabled(.autoPilot))
    }
    
    // MARK: - getAvailableFeatures 測試
    
    func testGetAvailableFeatures_EmptyWhenCentralComputerOff() {
        let available = car.getAvailableFeatures()
        XCTAssertTrue(available.isEmpty, "No features should be available when central computer is off")
    }
    
    func testGetAvailableFeatures_ShowsBasicFeaturesWhenCentralComputerOn() {
        car.turnOnCentralComputer()
        
        let available = car.getAvailableFeatures()
        
        // 應該包含基本功能（不需其他依賴的功能）
        XCTAssertTrue(available.contains(.airConditioner))
        XCTAssertTrue(available.contains(.navigation))
        XCTAssertTrue(available.contains(.bluetooth))
        XCTAssertTrue(available.contains(.entertainment))
        XCTAssertTrue(available.contains(.rearCamera))
        XCTAssertTrue(available.contains(.frontRadar))
        XCTAssertTrue(available.contains(.blindSpotDetection))
        
        // 不應該包含需要其他依賴的功能
        XCTAssertFalse(available.contains(.surroundView), "Surround view requires rear camera")
        XCTAssertFalse(available.contains(.laneKeeping), "Lane keeping requires engine")
    }
    
    func testGetAvailableFeatures_ExcludesEnabledFeatures() {
        car.turnOnCentralComputer()
        _ = car.enableFeature(.airConditioner)
        _ = car.enableFeature(.bluetooth)
        
        let available = car.getAvailableFeatures()
        
        // 已啟用的功能不應該出現在可用列表中
        XCTAssertFalse(available.contains(.airConditioner))
        XCTAssertFalse(available.contains(.bluetooth))
        
        // 其他未啟用的基本功能應該還在
        XCTAssertTrue(available.contains(.navigation))
        XCTAssertTrue(available.contains(.entertainment))
    }
    
    func testGetAvailableFeatures_UpdatesWhenDependenciesMet() {
        car.turnOnCentralComputer()
        
        var available = car.getAvailableFeatures()
        XCTAssertFalse(available.contains(.surroundView))
        
        // 啟用倒車鏡頭後，環景應該變成可用
        _ = car.enableFeature(.rearCamera)
        available = car.getAvailableFeatures()
        XCTAssertTrue(available.contains(.surroundView))
    }
    
    // MARK: - getUnavailableFeatures 測試
    
    func testGetUnavailableFeatures_AllWhenCentralComputerOff() {
        let unavailable = car.getUnavailableFeatures()
        
        // 中控關閉時，所有功能都不可用
        XCTAssertEqual(unavailable.count, Feature.allCases.count)
    }
    
    func testGetUnavailableFeatures_UpdatesWhenCentralComputerOn() {
        car.turnOnCentralComputer()
        
        let unavailable = car.getUnavailableFeatures()
        
        // 基本功能應該不在不可用列表中
        XCTAssertFalse(unavailable.contains(.airConditioner))
        XCTAssertFalse(unavailable.contains(.bluetooth))
        
        // 需要引擎的功能應該還是不可用
        XCTAssertTrue(unavailable.contains(.laneKeeping))
        XCTAssertTrue(unavailable.contains(.emergencyBraking))
    }
    
    func testGetUnavailableFeatures_UpdatesWhenEngineStarts() {
        car.turnOnCentralComputer()
        _ = car.enableFeature(.navigation)
        _ = car.enableFeature(.frontRadar)
        
        var unavailable = car.getUnavailableFeatures()
        XCTAssertTrue(unavailable.contains(.laneKeeping))
        
        // 啟動引擎後，車道維持應該變成可用
        car.startEngine()
        unavailable = car.getUnavailableFeatures()
        XCTAssertFalse(unavailable.contains(.laneKeeping))
    }
    
    // MARK: - 綜合場景測試
    
    func testFeatureLifecycle_FromUnavailableToAvailableToEnabled() {
        // 初始：環景不可用
        XCTAssertFalse(car.isFeatureAvailable(.surroundView))
        XCTAssertFalse(car.isFeatureEnabled(.surroundView))
        XCTAssertTrue(car.getUnavailableFeatures().contains(.surroundView))
        
        // 開啟中控：環景還是不可用（缺少倒車鏡頭）
        car.turnOnCentralComputer()
        XCTAssertFalse(car.isFeatureAvailable(.surroundView))
        XCTAssertTrue(car.getUnavailableFeatures().contains(.surroundView))
        XCTAssertFalse(car.getAvailableFeatures().contains(.surroundView))
        
        // 啟用倒車鏡頭：環景變成可用
        _ = car.enableFeature(.rearCamera)
        XCTAssertTrue(car.isFeatureAvailable(.surroundView))
        XCTAssertFalse(car.isFeatureEnabled(.surroundView))
        XCTAssertTrue(car.getAvailableFeatures().contains(.surroundView))
        XCTAssertFalse(car.getUnavailableFeatures().contains(.surroundView))
        
        // 啟用環景：變成已啟用
        _ = car.enableFeature(.surroundView)
        XCTAssertTrue(car.isFeatureAvailable(.surroundView))
        XCTAssertTrue(car.isFeatureEnabled(.surroundView))
        XCTAssertFalse(car.getAvailableFeatures().contains(.surroundView)) // 已啟用的不出現在可用列表
        XCTAssertTrue(car.getEnabledFeatures().contains(.surroundView))
    }
    
    func testAvailabilityChangesWhenDependencyDisabled() {
        car.turnOnCentralComputer()
        _ = car.enableFeature(.rearCamera)
        _ = car.enableFeature(.surroundView)
        _ = car.enableFeature(.blindSpotDetection)
        
        // 停車輔助現在可用（依賴環景和盲點）
        XCTAssertTrue(car.isFeatureAvailable(.parkingAssist))
        
        // 停用環景後，停車輔助應該變成不可用
        _ = car.disableFeature(.surroundView)
        XCTAssertFalse(car.isFeatureAvailable(.parkingAssist))
        XCTAssertTrue(car.getUnavailableFeatures().contains(.parkingAssist))
    }
}

//
//  CarTests.swift
//  CarSystemTests
//
//  Created by Claude on 2026/1/11.
//
import XCTest
@testable import CarSystem

final class CarTests: XCTestCase {
    
    var car: Car!
    
    override func setUp() {
        super.setUp()
        car = Car()
    }
    
    override func tearDown() {
        car = nil
        super.tearDown()
    }
    
    // MARK: - 基本狀態測試
    
    func testInitialState() {
        XCTAssertFalse(car.centralComputer.isOn)
        XCTAssertFalse(car.engine.isRunning)
        XCTAssertTrue(car.enabledFeatures.isEmpty)
    }
    
    func testCentralComputerToggle() {
        car.centralComputer.turnOn()
        XCTAssertTrue(car.centralComputer.isOn)
        
        car.centralComputer.turnOff()
        XCTAssertFalse(car.centralComputer.isOn)
    }
    
    func testEngineToggle() {
        car.engine.start()
        XCTAssertTrue(car.engine.isRunning)
        
        car.engine.stop()
        XCTAssertFalse(car.engine.isRunning)
    }
    
    // MARK: - 功能啟用測試
    
    func testEnableFeatureWithoutCentralComputer() {
        let result = car.enable(.airConditioner)
        
        if case .failure(let error) = result {
            XCTAssertEqual(error.errorDescription, FeatureError.centralComputerOff.errorDescription)
        } else {
            XCTFail("應該回傳錯誤")
        }
    }
    
    func testEnableBasicFeature() {
        car.centralComputer.turnOn()
        let result = car.enable(.airConditioner)
        
        XCTAssertTrue(result.isSuccess)
        XCTAssertTrue(car.isFeatureEnabled(.airConditioner))
    }
    
    func testEnableFeatureWithDependency() {
        car.centralComputer.turnOn()
        
        // 環景攝影需要倒車鏡頭
        let result = car.enable(.surroundView)
        
        if case .failure(let error) = result {
            XCTAssertEqual(error.errorDescription, FeatureError.dependencyNotEnabled(.rearCamera).errorDescription)
        } else {
            XCTFail("應該回傳錯誤")
        }
    }
    
    func testEnableFeatureWithDependencySatisfied() {
        car.centralComputer.turnOn()
        car.enable(.rearCamera)
        
        let result = car.enable(.surroundView)
        
        XCTAssertTrue(result.isSuccess)
        XCTAssertTrue(car.isFeatureEnabled(.surroundView))
    }
    
    func testEnableLaneKeepingWithoutEngine() {
        car.centralComputer.turnOn()
        car.enable(.navigation)
        car.enable(.frontRadar)
        
        // 車道維持需要引擎運行中
        let result = car.enable(.laneKeeping)
        
        if case .failure(let error) = result {
            XCTAssertEqual(error.errorDescription, FeatureError.engineNotRunning.errorDescription)
        } else {
            XCTFail("應該回傳錯誤")
        }
    }
    
    func testEnableLaneKeepingWithEngine() {
        car.centralComputer.turnOn()
        car.engine.start()
        car.enable(.navigation)
        car.enable(.frontRadar)
        
        let result = car.enable(.laneKeeping)
        
        XCTAssertTrue(result.isSuccess)
        XCTAssertTrue(car.isFeatureEnabled(.laneKeeping))
    }
    
    // MARK: - 功能停用測試
    
    func testDisableFeature() {
        car.centralComputer.turnOn()
        car.enable(.airConditioner)
        
        let result = car.disable(.airConditioner)
        
        XCTAssertTrue(result.isSuccess)
        XCTAssertFalse(car.isFeatureEnabled(.airConditioner))
    }
    
    func testCascadeDisable() {
        car.centralComputer.turnOn()
        car.enable(.rearCamera)
        car.enable(.surroundView)
        car.enable(.blindSpotDetection)
        car.enable(.parkingAssist)
        
        // 停用倒車鏡頭應該連鎖停用環景和停車輔助
        car.disable(.rearCamera)
        
        XCTAssertFalse(car.isFeatureEnabled(.rearCamera))
        XCTAssertFalse(car.isFeatureEnabled(.surroundView))
        XCTAssertFalse(car.isFeatureEnabled(.parkingAssist))
        // 盲點偵測不依賴倒車鏡頭，應該保持啟用
        XCTAssertTrue(car.isFeatureEnabled(.blindSpotDetection))
    }
    
    // MARK: - 自動駕駛測試
    
    func testEnableAutoPilot() {
        car.centralComputer.turnOn()
        car.engine.start()
        
        // 依序啟用所有相依功能
        car.enable(.rearCamera)
        car.enable(.surroundView)
        car.enable(.blindSpotDetection)
        car.enable(.frontRadar)
        car.enable(.navigation)
        car.enable(.laneKeeping)
        car.enable(.emergencyBraking)
        
        let result = car.enable(.autoPilot)
        
        XCTAssertTrue(result.isSuccess)
        XCTAssertTrue(car.isFeatureEnabled(.autoPilot))
    }
    
    func testDisableAutoPilotDependency() {
        car.centralComputer.turnOn()
        car.engine.start()
        
        // 啟用自動駕駛
        car.enable(.rearCamera)
        car.enable(.surroundView)
        car.enable(.blindSpotDetection)
        car.enable(.frontRadar)
        car.enable(.navigation)
        car.enable(.laneKeeping)
        car.enable(.emergencyBraking)
        car.enable(.autoPilot)
        
        // 停用車道維持應該連鎖停用自動駕駛
        car.disable(.laneKeeping)
        
        XCTAssertFalse(car.isFeatureEnabled(.laneKeeping))
        XCTAssertFalse(car.isFeatureEnabled(.autoPilot))
    }
}

// MARK: - Result Extension for Testing

extension Result {
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
    
    var isFailure: Bool {
        return !isSuccess
    }
}

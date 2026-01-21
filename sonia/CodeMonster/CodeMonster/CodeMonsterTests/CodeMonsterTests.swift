//
//  CodeMonsterTests.swift
//  CodeMonsterTests
//
//  Created by Sonia Wu on 2026/1/8.
//

import XCTest
@testable import CodeMonster

/// Car 功能测试套件
final class CodeMonsterTests: XCTestCase {
    
    var car: Car!
    
    override func setUp() {
        super.setUp()
        car = Car()
    }
    
    override func tearDown() {
        car = nil
        super.tearDown()
    }
    
    // MARK: - 基础功能测试
    
    func testCarInitialization() {
        XCTAssertNotNil(car, "Car should be initialized")
        XCTAssertFalse(car.isCentralComputerOn, "Central computer should be off initially")
        XCTAssertFalse(car.isEngineRunning, "Engine should be stopped initially")
        XCTAssertTrue(car.getEnabledFeatures().isEmpty, "No features should be enabled initially")
    }
    
    func testCentralComputerControl() {
        // 开启中控
        car.turnOnCentralComputer()
        XCTAssertTrue(car.isCentralComputerOn, "Central computer should be on")
        
        // 关闭中控
        car.turnOffCentralComputer()
        XCTAssertFalse(car.isCentralComputerOn, "Central computer should be off")
    }
    
    func testEngineControl() {        // 開啟中控電腦（引擎依賴中控電腦）
        car.turnOnCentralComputer()
                // 启动引擎
        car.startEngine()
        XCTAssertTrue(car.isEngineRunning, "Engine should be running")
        
        // 停止引擎
        car.stopEngine()
        XCTAssertFalse(car.isEngineRunning, "Engine should be stopped")
    }
    
    // MARK: - 重复操作检查测试
    
    func testCannotEnableFeatureTwice() {
        car.turnOnCentralComputer()
        
        // 第一次启用
        _ = car.enableFeature(.airConditioner)
        XCTAssertTrue(car.isFeatureEnabled(.airConditioner))
        
        // 第二次启用（应该跳过）
        let result = car.enableFeature(.airConditioner)
        XCTAssertTrue(result.isSuccess, "Second enable should return success but skip")
        XCTAssertTrue(car.isFeatureEnabled(.airConditioner))
    }
    
    func testCannotDisableFeatureTwice() {
        car.turnOnCentralComputer()
        _ = car.enableFeature(.airConditioner)
        
        // 第一次停用
        _ = car.disableFeature(.airConditioner)
        XCTAssertFalse(car.isFeatureEnabled(.airConditioner))
        
        // 第二次停用（应该跳过）
        let result = car.disableFeature(.airConditioner)
        XCTAssertTrue(result.isSuccess, "Second disable should return success but skip")
        XCTAssertFalse(car.isFeatureEnabled(.airConditioner))
    }
    
    func testCannotTurnOnCentralComputerTwice() {
        car.turnOnCentralComputer()
        XCTAssertTrue(car.isCentralComputerOn)
        
        // 重复开启（应该跳过）
        car.turnOnCentralComputer()
        XCTAssertTrue(car.isCentralComputerOn)
    }
    
    func testCannotStartEngineTwice() {        car.turnOnCentralComputer()  // 引擎依賴中控電腦
                car.startEngine()
        XCTAssertTrue(car.isEngineRunning)
        
        // 重复启动（应该跳过）
        car.startEngine()
        XCTAssertTrue(car.isEngineRunning)
    }
    
    // MARK: - 依赖验证测试：中控电脑
    
    func testAirConditioner_RequiresCentralComputer() {
        // 中控关闭时无法启用冷气
        let result = car.enableFeature(.airConditioner)
        XCTAssertTrue(result.isFailure, "Should fail when central computer is off")
        XCTAssertFalse(car.isFeatureEnabled(.airConditioner))
        
        // 开启中控后可以启用
        car.turnOnCentralComputer()
        _ = car.enableFeature(.airConditioner)
        XCTAssertTrue(car.isFeatureEnabled(.airConditioner))
    }
    
    func testNavigation_RequiresCentralComputer() {
        let result = car.enableFeature(.navigation)
        XCTAssertTrue(result.isFailure, "Should fail when central computer is off")
        
        car.turnOnCentralComputer()
        _ = car.enableFeature(.navigation)
        XCTAssertTrue(car.isFeatureEnabled(.navigation))
    }
    
    func testEntertainment_RequiresCentralComputer() {
        let result = car.enableFeature(.entertainment)
        XCTAssertTrue(result.isFailure)
        
        car.turnOnCentralComputer()
        _ = car.enableFeature(.entertainment)
        XCTAssertTrue(car.isFeatureEnabled(.entertainment))
    }
    
    func testBluetooth_RequiresCentralComputer() {
        let result = car.enableFeature(.bluetooth)
        XCTAssertTrue(result.isFailure)
        
        car.turnOnCentralComputer()
        _ = car.enableFeature(.bluetooth)
        XCTAssertTrue(car.isFeatureEnabled(.bluetooth))
    }
    
    func testRearCamera_RequiresCentralComputer() {
        let result = car.enableFeature(.rearCamera)
        XCTAssertTrue(result.isFailure)
        
        car.turnOnCentralComputer()
        _ = car.enableFeature(.rearCamera)
        XCTAssertTrue(car.isFeatureEnabled(.rearCamera))
    }
    
    // MARK: - 依赖验证测试：功能相依
    
    func testSurroundView_RequiresRearCamera() {
        car.turnOnCentralComputer()
        
        // 没有倒车镜头时无法启用环景
        let result = car.enableFeature(.surroundView)
        XCTAssertTrue(result.isFailure, "Should fail without rear camera")
        
        // 启用倒车镜头后可以启用环景
        _ = car.enableFeature(.rearCamera)
        _ = car.enableFeature(.surroundView)
        XCTAssertTrue(car.isFeatureEnabled(.surroundView))
    }
    
    func testParkingAssist_RequiresSurroundViewAndBlindSpot() {
        car.turnOnCentralComputer()
        
        // 缺少依赖时无法启用
        let result = car.enableFeature(.parkingAssist)
        XCTAssertTrue(result.isFailure)
        
        // 只有环景，缺少盲点侦测
        _ = car.enableFeature(.rearCamera)
        _ = car.enableFeature(.surroundView)
        let result2 = car.enableFeature(.parkingAssist)
        XCTAssertTrue(result2.isFailure, "Should fail without blind spot detection")
        
        // 两个依赖都满足
        _ = car.enableFeature(.blindSpotDetection)
        _ = car.enableFeature(.parkingAssist)
        XCTAssertTrue(car.isFeatureEnabled(.parkingAssist))
    }
    
    func testLaneKeeping_RequiresNavigationAndRadarAndEngine() {
        car.turnOnCentralComputer()
        
        // 缺少引擎
        _ = car.enableFeature(.navigation)
        _ = car.enableFeature(.frontRadar)
        let result = car.enableFeature(.laneKeeping)
        XCTAssertTrue(result.isFailure, "Should fail without engine running")
        
        // 启动引擎
        car.startEngine()
        _ = car.enableFeature(.laneKeeping)
        XCTAssertTrue(car.isFeatureEnabled(.laneKeeping))
    }
    
    func testEmergencyBraking_RequiresRadarAndEngine() {
        car.turnOnCentralComputer()
        _ = car.enableFeature(.frontRadar)
        
        // 缺少引擎
        let result = car.enableFeature(.emergencyBraking)
        XCTAssertTrue(result.isFailure, "Should fail without engine")
        
        // 启动引擎
        car.startEngine()
        _ = car.enableFeature(.emergencyBraking)
        XCTAssertTrue(car.isFeatureEnabled(.emergencyBraking))
    }
    
    func testAutoPilot_RequiresThreeFeatures() {
        car.turnOnCentralComputer()
        car.startEngine()
        
        // 缺少所有依赖
        let result = car.enableFeature(.autoPilot)
        XCTAssertTrue(result.isFailure)
        
        // 只有部分依赖
        _ = car.enableFeature(.navigation)
        _ = car.enableFeature(.frontRadar)
        _ = car.enableFeature(.laneKeeping)
        let result2 = car.enableFeature(.autoPilot)
        XCTAssertTrue(result2.isFailure, "Should fail without all three features")
        
        // 满足所有依赖：车道维持 + 紧急煞车 + 环景摄影
        _ = car.enableFeature(.emergencyBraking)
        _ = car.enableFeature(.rearCamera)
        _ = car.enableFeature(.surroundView)
        _ = car.enableFeature(.autoPilot)
        XCTAssertTrue(car.isFeatureEnabled(.autoPilot))
    }
    
    // MARK: - 连锁停用测试
    
    func testDisableRearCamera_DisablesSurroundView() {
        car.turnOnCentralComputer()
        _ = car.enableFeature(.rearCamera)
        _ = car.enableFeature(.surroundView)
        
        XCTAssertTrue(car.isFeatureEnabled(.rearCamera))
        XCTAssertTrue(car.isFeatureEnabled(.surroundView))
        
        // 停用倒车镜头应该连锁停用环景
        _ = car.disableFeature(.rearCamera)
        
        XCTAssertFalse(car.isFeatureEnabled(.rearCamera))
        XCTAssertFalse(car.isFeatureEnabled(.surroundView), "Surround view should be disabled")
    }
    
    func testDisableRearCamera_DisablesEntireChain() {
        car.turnOnCentralComputer()
        
        // 建立依赖链：倒车镜头 → 环景 → 停车辅助
        _ = car.enableFeature(.rearCamera)
        _ = car.enableFeature(.surroundView)
        _ = car.enableFeature(.blindSpotDetection)
        _ = car.enableFeature(.parkingAssist)
        
        XCTAssertTrue(car.isFeatureEnabled(.parkingAssist))
        
        // 停用倒车镜头应该连锁停用整条链
        _ = car.disableFeature(.rearCamera)
        
        XCTAssertFalse(car.isFeatureEnabled(.rearCamera))
        XCTAssertFalse(car.isFeatureEnabled(.surroundView))
        XCTAssertFalse(car.isFeatureEnabled(.parkingAssist))
        
        // 盲点侦测没有依赖倒车镜头，应该保持启用
        XCTAssertTrue(car.isFeatureEnabled(.blindSpotDetection), "Blind spot should remain enabled")
    }
    
    func testDisableFrontRadar_DisablesMultipleFeatures() {
        car.turnOnCentralComputer()
        car.startEngine()
        _ = car.enableFeature(.navigation)
        _ = car.enableFeature(.frontRadar)
        _ = car.enableFeature(.laneKeeping)
        _ = car.enableFeature(.emergencyBraking)
        
        // 停用前方雷达应该连锁停用车道维持和紧急煞车
        _ = car.disableFeature(.frontRadar)
        
        XCTAssertFalse(car.isFeatureEnabled(.frontRadar))
        XCTAssertFalse(car.isFeatureEnabled(.laneKeeping), "Lane keeping should be disabled")
        XCTAssertFalse(car.isFeatureEnabled(.emergencyBraking), "Emergency braking should be disabled")
        
        // 导航没有依赖前方雷达，应该保持启用
        XCTAssertTrue(car.isFeatureEnabled(.navigation), "Navigation should remain enabled")
    }
    
    func testTurnOffCentralComputer_DisablesAllFeatures() {
        car.turnOnCentralComputer()
        
        // 启用多个功能
        _ = car.enableFeature(.airConditioner)
        _ = car.enableFeature(.navigation)
        _ = car.enableFeature(.bluetooth)
        
        XCTAssertEqual(car.getEnabledFeatures().count, 3)
        
        // 关闭中控应该连锁停用所有功能
        car.turnOffCentralComputer()
        
        XCTAssertTrue(car.getEnabledFeatures().isEmpty, "All features should be disabled")
        XCTAssertFalse(car.isFeatureEnabled(.airConditioner))
        XCTAssertFalse(car.isFeatureEnabled(.navigation))
        XCTAssertFalse(car.isFeatureEnabled(.bluetooth))
    }
    
    func testStopEngine_CascadesFromEngineDependentFeatures() {
        car.turnOnCentralComputer()
        car.startEngine()
        
        // 建立完整的自动驾驶依赖链
        _ = car.enableFeature(.navigation)
        _ = car.enableFeature(.frontRadar)
        _ = car.enableFeature(.laneKeeping)  // 需要引擎
        _ = car.enableFeature(.emergencyBraking)  // 需要引擎
        _ = car.enableFeature(.rearCamera)
        _ = car.enableFeature(.surroundView)
        _ = car.enableFeature(.autoPilot)  // 需要引擎（通过车道维持、紧急煞车、环景）
        
        XCTAssertTrue(car.isFeatureEnabled(.autoPilot))
        
        // 停止引擎应该连锁停用所有需要引擎的功能
        car.stopEngine()
        
        // 直接需要引擎的功能应该被停用
        XCTAssertFalse(car.isFeatureEnabled(.laneKeeping), "Lane keeping should be disabled")
        XCTAssertFalse(car.isFeatureEnabled(.emergencyBraking), "Emergency braking should be disabled")
        
        // 间接需要引擎的自动驾驶也应该被停用
        XCTAssertFalse(car.isFeatureEnabled(.autoPilot), "Auto pilot should be disabled when engine stops")
        
        // 不需要引擎的功能应该保持启用
        XCTAssertTrue(car.isFeatureEnabled(.navigation), "Navigation should remain enabled")
        XCTAssertTrue(car.isFeatureEnabled(.frontRadar), "Front radar should remain enabled")
        XCTAssertTrue(car.isFeatureEnabled(.rearCamera), "Rear camera should remain enabled")
        XCTAssertTrue(car.isFeatureEnabled(.surroundView), "Surround view should remain enabled")
    }
    
    func testDisableAutoPilot_DoesNotAffectDependencies() {
        car.turnOnCentralComputer()
        car.startEngine()
        
        // 建立自动驾驶的所有依赖
        _ = car.enableFeature(.navigation)
        _ = car.enableFeature(.frontRadar)
        _ = car.enableFeature(.laneKeeping)
        _ = car.enableFeature(.emergencyBraking)
        _ = car.enableFeature(.rearCamera)
        _ = car.enableFeature(.surroundView)
        _ = car.enableFeature(.autoPilot)
        
        // 停用自动驾驶
        _ = car.disableFeature(.autoPilot)
        
        XCTAssertFalse(car.isFeatureEnabled(.autoPilot))
        
        // 所有依赖应该保持启用（向上停用不影响依赖）
        XCTAssertTrue(car.isFeatureEnabled(.laneKeeping))
        XCTAssertTrue(car.isFeatureEnabled(.emergencyBraking))
        XCTAssertTrue(car.isFeatureEnabled(.surroundView))
    }
    
    // MARK: - 复杂场景测试
    
    func testComplexDependencyChain() {
        car.turnOnCentralComputer()
        car.startEngine()
        
        // 建立完整的依赖链
        _ = car.enableFeature(.rearCamera)
        _ = car.enableFeature(.surroundView)
        _ = car.enableFeature(.blindSpotDetection)
        _ = car.enableFeature(.parkingAssist)
        _ = car.enableFeature(.navigation)
        _ = car.enableFeature(.frontRadar)
        _ = car.enableFeature(.laneKeeping)
        _ = car.enableFeature(.emergencyBraking)
        _ = car.enableFeature(.autoPilot)
        
        XCTAssertEqual(car.getEnabledFeatures().count, 9)
        
        // 停用环景摄影应该连锁停用停车辅助和自动驾驶
        _ = car.disableFeature(.surroundView)
        
        XCTAssertFalse(car.isFeatureEnabled(.surroundView))
        XCTAssertFalse(car.isFeatureEnabled(.parkingAssist))
        XCTAssertFalse(car.isFeatureEnabled(.autoPilot))
        
        // 其他功能应该保持启用
        XCTAssertTrue(car.isFeatureEnabled(.rearCamera))
        XCTAssertTrue(car.isFeatureEnabled(.laneKeeping))
        XCTAssertTrue(car.isFeatureEnabled(.emergencyBraking))
    }
    
    func testIndependentFeatures_CanExistTogether() {
        car.turnOnCentralComputer()
        
        // 冷气、蓝牙、娱乐系统互不依赖
        _ = car.enableFeature(.airConditioner)
        _ = car.enableFeature(.bluetooth)
        _ = car.enableFeature(.entertainment)
        
        XCTAssertTrue(car.isFeatureEnabled(.airConditioner))
        XCTAssertTrue(car.isFeatureEnabled(.bluetooth))
        XCTAssertTrue(car.isFeatureEnabled(.entertainment))
        
        // 停用其中一个不应影响其他
        _ = car.disableFeature(.bluetooth)
        
        XCTAssertFalse(car.isFeatureEnabled(.bluetooth))
        XCTAssertTrue(car.isFeatureEnabled(.airConditioner))
        XCTAssertTrue(car.isFeatureEnabled(.entertainment))
    }
}

// MARK: - Result Extension for Testing

extension Result {
    var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }
    
    var isFailure: Bool {
        if case .failure = self {
            return true
        }
        return false
    }
}

// MARK: - Engine Dependency Tests

extension CodeMonsterTests {
    
    func testEngine_RequiresCentralComputer() {
        // 中控電腦關閉時無法啟動引擎
        car.startEngine()
        XCTAssertFalse(car.isEngineRunning, "Engine should not start when central computer is off")
        
        // 開啟中控電腦後可以啟動引擎
        car.turnOnCentralComputer()
        car.startEngine()
        XCTAssertTrue(car.isEngineRunning, "Engine should start when central computer is on")
    }
    
    func testTurnOffCentralComputer_StopsEngine() {
        // 開啟中控電腦並啟動引擎
        car.turnOnCentralComputer()
        car.startEngine()
        XCTAssertTrue(car.isEngineRunning, "Engine should be running")
        
        // 關閉中控電腦應該停止引擎
        car.turnOffCentralComputer()
        XCTAssertFalse(car.isEngineRunning, "Engine should stop when central computer is turned off")
        XCTAssertFalse(car.isCentralComputerOn, "Central computer should be off")
    }
}

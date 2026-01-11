//
//  CarFeatureToggleTests.swift
//  CodeMonsterTests
//
//  Created by Copilot on 2026/1/11.
//

import XCTest
@testable import CodeMonster

/// 測試 Car 的功能啟用/停用與連鎖停用邏輯
final class CarFeatureToggleTests: XCTestCase {
    
    var car: Car!
    
    override func setUp() {
        super.setUp()
        car = Car()
    }
    
    override func tearDown() {
        car = nil
        super.tearDown()
    }
    
    // MARK: - 基礎啟用/停用測試
    
    func testEnableFeature_FailsWhenCentralComputerOff() {
        // Given: 中控電腦未開啟
        
        // When: 嘗試啟用冷氣
        let result = car.enableFeature(.airConditioner)
        
        // Then: 應該失敗
        switch result {
        case .success:
            XCTFail("應該失敗：中控電腦未開啟")
        case .failure:
            break
        }
    }
    
    func testEnableFeature_SucceedsWhenDependenciesMet() {
        // Given: 中控電腦已開啟
        car.turnOnCentralComputer()
        
        // When: 嘗試啟用冷氣
        let result = car.enableFeature(.airConditioner)
        
        // Then: 應該成功
        XCTAssertNoThrow(try result.get())
        XCTAssertTrue(car.isFeatureEnabled(.airConditioner))
    }
    
    func testDisableFeature_SucceedsWhenEnabled() {
        // Given: 功能已啟用
        car.turnOnCentralComputer()
        _ = car.enableFeature(.airConditioner)
        
        // When: 停用功能
        let result = car.disableFeature(.airConditioner)
        
        // Then: 應該成功
        XCTAssertNoThrow(try result.get())
        XCTAssertFalse(car.isFeatureEnabled(.airConditioner))
    }
    
    // MARK: - 重複操作檢查測試
    
    func testEnableFeature_SkipsWhenAlreadyEnabled() {
        // Given: 功能已啟用
        car.turnOnCentralComputer()
        _ = car.enableFeature(.airConditioner)
        
        // When: 再次啟用
        let result = car.enableFeature(.airConditioner)
        
        // Then: 應該返回成功但跳過操作
        XCTAssertNoThrow(try result.get())
    }
    
    func testDisableFeature_SkipsWhenAlreadyDisabled() {
        // Given: 功能已停用
        
        // When: 嘗試停用
        let result = car.disableFeature(.airConditioner)
        
        // Then: 應該返回成功但跳過操作
        XCTAssertNoThrow(try result.get())
    }
    
    func testTurnOnCentralComputer_SkipsWhenAlreadyOn() {
        // Given: 中控已開啟
        car.turnOnCentralComputer()
        
        // When: 再次開啟
        car.turnOnCentralComputer()
        
        // Then: 應該跳過（不會崩潰或出錯）
        XCTAssertTrue(car.isCentralComputerOn)
    }
    
    func testStartEngine_SkipsWhenAlreadyRunning() {
        // Given: 引擎已啟動
        car.startEngine()
        
        // When: 再次啟動
        car.startEngine()
        
        // Then: 應該跳過
        XCTAssertTrue(car.isEngineRunning)
    }
    
    // MARK: - 連鎖停用測試
    
    func testCascadeDisable_RearCamera_DisablesSurroundView() {
        // Given: 倒車鏡頭和環景都已啟用
        car.turnOnCentralComputer()
        _ = car.enableFeature(.rearCamera)
        _ = car.enableFeature(.surroundView)
        
        // When: 停用倒車鏡頭
        _ = car.disableFeature(.rearCamera)
        
        // Then: 環景應該被連鎖停用
        XCTAssertFalse(car.isFeatureEnabled(.rearCamera))
        XCTAssertFalse(car.isFeatureEnabled(.surroundView))
    }
    
    func testCascadeDisable_SurroundView_DisablesParkingAssist() {
        // Given: 環景和停車輔助都已啟用
        car.turnOnCentralComputer()
        _ = car.enableFeature(.rearCamera)
        _ = car.enableFeature(.surroundView)
        _ = car.enableFeature(.blindSpotDetection)
        _ = car.enableFeature(.parkingAssist)
        
        // When: 停用環景
        _ = car.disableFeature(.surroundView)
        
        // Then: 停車輔助應該被連鎖停用
        XCTAssertFalse(car.isFeatureEnabled(.surroundView))
        XCTAssertFalse(car.isFeatureEnabled(.parkingAssist))
        // 但盲點偵測不應受影響
        XCTAssertTrue(car.isFeatureEnabled(.blindSpotDetection))
    }
    
    func testCascadeDisable_RearCamera_DisablesEntireChain() {
        // Given: 建立完整的依賴鏈：倒車鏡頭 → 環景 → 停車輔助
        car.turnOnCentralComputer()
        _ = car.enableFeature(.rearCamera)
        _ = car.enableFeature(.surroundView)
        _ = car.enableFeature(.blindSpotDetection)
        _ = car.enableFeature(.parkingAssist)
        
        // When: 停用最底層的倒車鏡頭
        _ = car.disableFeature(.rearCamera)
        
        // Then: 整條鏈都應該被停用
        XCTAssertFalse(car.isFeatureEnabled(.rearCamera))
        XCTAssertFalse(car.isFeatureEnabled(.surroundView))
        XCTAssertFalse(car.isFeatureEnabled(.parkingAssist))
        // 但獨立的功能不受影響
        XCTAssertTrue(car.isFeatureEnabled(.blindSpotDetection))
    }
    
    func testCascadeDisable_FrontRadar_DisablesBothLaneKeepingAndEmergencyBraking() {
        // Given: 前方雷達、車道維持、緊急煞車都已啟用
        car.turnOnCentralComputer()
        car.startEngine()
        _ = car.enableFeature(.navigation)
        _ = car.enableFeature(.frontRadar)
        _ = car.enableFeature(.laneKeeping)
        _ = car.enableFeature(.emergencyBraking)
        
        // When: 停用前方雷達
        _ = car.disableFeature(.frontRadar)
        
        // Then: 兩個依賴它的功能都應該被停用
        XCTAssertFalse(car.isFeatureEnabled(.frontRadar))
        XCTAssertFalse(car.isFeatureEnabled(.laneKeeping))
        XCTAssertFalse(car.isFeatureEnabled(.emergencyBraking))
        // 但導航不受影響
        XCTAssertTrue(car.isFeatureEnabled(.navigation))
    }
    
    func testCascadeDisable_AutoPilot_OnlyDisablesAutoPilot() {
        // Given: 自動駕駛已啟用（沒有功能依賴它）
        car.turnOnCentralComputer()
        car.startEngine()
        _ = car.enableFeature(.navigation)
        _ = car.enableFeature(.frontRadar)
        _ = car.enableFeature(.laneKeeping)
        _ = car.enableFeature(.emergencyBraking)
        _ = car.enableFeature(.rearCamera)
        _ = car.enableFeature(.surroundView)
        _ = car.enableFeature(.autoPilot)
        
        // When: 停用自動駕駛
        _ = car.disableFeature(.autoPilot)
        
        // Then: 只有自動駕駛被停用，其他功能不受影響
        XCTAssertFalse(car.isFeatureEnabled(.autoPilot))
        XCTAssertTrue(car.isFeatureEnabled(.laneKeeping))
        XCTAssertTrue(car.isFeatureEnabled(.emergencyBraking))
        XCTAssertTrue(car.isFeatureEnabled(.surroundView))
    }
    
    // MARK: - 中控電腦與引擎整合測試
    
    func testTurnOffCentralComputer_DisablesAllFeatures() {
        // Given: 多個功能已啟用
        car.turnOnCentralComputer()
        _ = car.enableFeature(.airConditioner)
        _ = car.enableFeature(.navigation)
        _ = car.enableFeature(.bluetooth)
        
        // When: 關閉中控電腦
        car.turnOffCentralComputer()
        
        // Then: 所有功能都應該被停用
        XCTAssertFalse(car.isFeatureEnabled(.airConditioner))
        XCTAssertFalse(car.isFeatureEnabled(.navigation))
        XCTAssertFalse(car.isFeatureEnabled(.bluetooth))
        XCTAssertEqual(car.getEnabledFeatures().count, 0)
    }
    
    func testStopEngine_OnlyDisablesEngineDependentFeatures() {
        // Given: 多個功能已啟用，部分需要引擎
        car.turnOnCentralComputer()
        car.startEngine()
        _ = car.enableFeature(.airConditioner)  // 不需要引擎
        _ = car.enableFeature(.navigation)
        _ = car.enableFeature(.frontRadar)
        _ = car.enableFeature(.laneKeeping)  // 需要引擎
        _ = car.enableFeature(.emergencyBraking)  // 需要引擎
        
        // When: 停止引擎
        car.stopEngine()
        
        // Then: 只有需要引擎的功能被停用
        XCTAssertFalse(car.isFeatureEnabled(.laneKeeping))
        XCTAssertFalse(car.isFeatureEnabled(.emergencyBraking))
        // 不需要引擎的功能仍然啟用
        XCTAssertTrue(car.isFeatureEnabled(.airConditioner))
        XCTAssertTrue(car.isFeatureEnabled(.navigation))
        XCTAssertTrue(car.isFeatureEnabled(.frontRadar))
    }
    
    func testStopEngine_CascadesFromEngineDependentFeatures() {
        // Given: 完整的自動駕駛系統已啟用
        car.turnOnCentralComputer()
        car.startEngine()
        _ = car.enableFeature(.navigation)
        _ = car.enableFeature(.frontRadar)
        _ = car.enableFeature(.laneKeeping)  // 需要引擎
        _ = car.enableFeature(.emergencyBraking)  // 需要引擎
        _ = car.enableFeature(.rearCamera)
        _ = car.enableFeature(.surroundView)
        _ = car.enableFeature(.autoPilot)  // 依賴車道維持和緊急煞車
        
        // When: 停止引擎
        car.stopEngine()
        
        // Then: 車道維持、緊急煞車被停用，導致自動駕駛也被連鎖停用
        XCTAssertFalse(car.isFeatureEnabled(.laneKeeping))
        XCTAssertFalse(car.isFeatureEnabled(.emergencyBraking))
        XCTAssertFalse(car.isFeatureEnabled(.autoPilot))  // 連鎖停用
        // 但其他不依賴引擎的功能仍然啟用
        XCTAssertTrue(car.isFeatureEnabled(.navigation))
        XCTAssertTrue(car.isFeatureEnabled(.surroundView))
    }
    
    // MARK: - 查詢功能測試
    
    func testGetEnabledFeatures_ReturnsCorrectList() {
        // Given: 啟用多個功能
        car.turnOnCentralComputer()
        _ = car.enableFeature(.airConditioner)
        _ = car.enableFeature(.navigation)
        _ = car.enableFeature(.bluetooth)
        
        // When: 查詢已啟用功能
        let enabledFeatures = car.getEnabledFeatures()
        
        // Then: 應該返回正確的列表
        XCTAssertEqual(enabledFeatures.count, 3)
        XCTAssertTrue(enabledFeatures.contains(.airConditioner))
        XCTAssertTrue(enabledFeatures.contains(.navigation))
        XCTAssertTrue(enabledFeatures.contains(.bluetooth))
    }
}

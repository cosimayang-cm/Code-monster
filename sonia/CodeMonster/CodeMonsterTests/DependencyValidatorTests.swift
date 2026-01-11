//
//  DependencyValidatorTests.swift
//  CodeMonsterTests
//
//  Created by Copilot on 2026/1/11.
//

import XCTest
@testable import CodeMonster

/// 測試 DependencyValidator 的相依性驗證邏輯
final class DependencyValidatorTests: XCTestCase {
    
    var validator: DependencyValidator!
    
    override func setUp() {
        super.setUp()
        validator = DependencyValidator()
    }
    
    override func tearDown() {
        validator = nil
        super.tearDown()
    }
    
    // MARK: - 基礎功能測試（只依賴中控電腦）
    
    func testAirConditioner_RequiresCentralComputer() {
        // Given: 中控電腦關閉
        let centralComputerOn = false
        let engineRunning = false
        let enabledFeatures: Set<Feature> = []
        
        // When: 嘗試啟用冷氣
        let result = validator.validateEnable(
            feature: .airConditioner,
            centralComputerOn: centralComputerOn,
            engineRunning: engineRunning,
            enabledFeatures: enabledFeatures
        )
        
        // Then: 應該失敗
        switch result {
        case .success:
            XCTFail("應該失敗：中控電腦未開啟")
        case .failure(let error):
            if case .dependencyNotMet(let feature, let missing) = error {
                XCTAssertEqual(feature, .airConditioner)
                XCTAssertTrue(missing.contains("Central Computer (must be ON)"))
            } else {
                XCTFail("錯誤類型不正確")
            }
        }
    }
    
    func testAirConditioner_SucceedsWhenCentralComputerOn() {
        // Given: 中控電腦開啟
        let centralComputerOn = true
        let engineRunning = false
        let enabledFeatures: Set<Feature> = []
        
        // When: 嘗試啟用冷氣
        let result = validator.validateEnable(
            feature: .airConditioner,
            centralComputerOn: centralComputerOn,
            engineRunning: engineRunning,
            enabledFeatures: enabledFeatures
        )
        
        // Then: 應該成功
        XCTAssertNoThrow(try result.get())
    }
    
    func testNavigation_RequiresCentralComputer() {
        // Given: 中控電腦關閉
        let result = validator.validateEnable(
            feature: .navigation,
            centralComputerOn: false,
            engineRunning: false,
            enabledFeatures: []
        )
        
        // Then: 應該失敗
        XCTAssertThrowsError(try result.get())
    }
    
    func testBluetooth_RequiresCentralComputer() {
        // Given: 中控電腦關閉
        let result = validator.validateEnable(
            feature: .bluetooth,
            centralComputerOn: false,
            engineRunning: false,
            enabledFeatures: []
        )
        
        // Then: 應該失敗
        XCTAssertThrowsError(try result.get())
    }
    
    // MARK: - 單一功能依賴測試
    
    func testSurroundView_RequiresRearCamera() {
        // Given: 中控開啟，但倒車鏡頭未啟用
        let centralComputerOn = true
        let enabledFeatures: Set<Feature> = []
        
        // When: 嘗試啟用環景攝影
        let result = validator.validateEnable(
            feature: .surroundView,
            centralComputerOn: centralComputerOn,
            engineRunning: false,
            enabledFeatures: enabledFeatures
        )
        
        // Then: 應該失敗
        switch result {
        case .success:
            XCTFail("應該失敗：缺少倒車鏡頭")
        case .failure(let error):
            if case .dependencyNotMet(_, let missing) = error {
                XCTAssertTrue(missing.contains("Rear Camera"))
            }
        }
    }
    
    func testSurroundView_SucceedsWhenRearCameraEnabled() {
        // Given: 中控開啟，倒車鏡頭已啟用
        let centralComputerOn = true
        let enabledFeatures: Set<Feature> = [.rearCamera]
        
        // When: 嘗試啟用環景攝影
        let result = validator.validateEnable(
            feature: .surroundView,
            centralComputerOn: centralComputerOn,
            engineRunning: false,
            enabledFeatures: enabledFeatures
        )
        
        // Then: 應該成功
        XCTAssertNoThrow(try result.get())
    }
    
    // MARK: - 多重依賴測試
    
    func testParkingAssist_RequiresSurroundViewAndBlindSpot() {
        // Given: 中控開啟，但缺少環景和盲點
        let result = validator.validateEnable(
            feature: .parkingAssist,
            centralComputerOn: true,
            engineRunning: false,
            enabledFeatures: []
        )
        
        // Then: 應該失敗，提示缺少兩個功能
        switch result {
        case .success:
            XCTFail("應該失敗：缺少環景和盲點")
        case .failure(let error):
            if case .dependencyNotMet(_, let missing) = error {
                XCTAssertTrue(missing.contains("Surround View Camera"))
                XCTAssertTrue(missing.contains("Blind Spot Detection"))
            }
        }
    }
    
    func testParkingAssist_SucceedsWhenAllDependenciesMet() {
        // Given: 所有依賴都滿足
        let enabledFeatures: Set<Feature> = [.surroundView, .blindSpotDetection]
        
        // When: 嘗試啟用停車輔助
        let result = validator.validateEnable(
            feature: .parkingAssist,
            centralComputerOn: true,
            engineRunning: false,
            enabledFeatures: enabledFeatures
        )
        
        // Then: 應該成功
        XCTAssertNoThrow(try result.get())
    }
    
    // MARK: - 引擎依賴測試
    
    func testLaneKeeping_RequiresEngineRunning() {
        // Given: 中控開啟，導航和雷達已啟用，但引擎未啟動
        let enabledFeatures: Set<Feature> = [.navigation, .frontRadar]
        
        // When: 嘗試啟用車道維持
        let result = validator.validateEnable(
            feature: .laneKeeping,
            centralComputerOn: true,
            engineRunning: false,
            enabledFeatures: enabledFeatures
        )
        
        // Then: 應該失敗
        switch result {
        case .success:
            XCTFail("應該失敗：引擎未啟動")
        case .failure(let error):
            if case .dependencyNotMet(_, let missing) = error {
                XCTAssertTrue(missing.contains("Engine (must be running)"))
            }
        }
    }
    
    func testLaneKeeping_SucceedsWhenEngineRunning() {
        // Given: 所有依賴都滿足，包括引擎
        let enabledFeatures: Set<Feature> = [.navigation, .frontRadar]
        
        // When: 嘗試啟用車道維持
        let result = validator.validateEnable(
            feature: .laneKeeping,
            centralComputerOn: true,
            engineRunning: true,
            enabledFeatures: enabledFeatures
        )
        
        // Then: 應該成功
        XCTAssertNoThrow(try result.get())
    }
    
    func testEmergencyBraking_RequiresEngineRunning() {
        // Given: 前方雷達已啟用，但引擎未啟動
        let enabledFeatures: Set<Feature> = [.frontRadar]
        
        // When: 嘗試啟用緊急煞車
        let result = validator.validateEnable(
            feature: .emergencyBraking,
            centralComputerOn: true,
            engineRunning: false,
            enabledFeatures: enabledFeatures
        )
        
        // Then: 應該失敗
        XCTAssertThrowsError(try result.get())
    }
    
    // MARK: - 複雜依賴鏈測試（AutoPilot）
    
    func testAutoPilot_RequiresThreeFeatures() {
        // Given: 只有中控開啟，其他都未啟用
        let result = validator.validateEnable(
            feature: .autoPilot,
            centralComputerOn: true,
            engineRunning: true,
            enabledFeatures: []
        )
        
        // Then: 應該失敗，提示缺少三個功能
        switch result {
        case .success:
            XCTFail("應該失敗：缺少車道維持、緊急煞車、環景攝影")
        case .failure(let error):
            if case .dependencyNotMet(_, let missing) = error {
                XCTAssertTrue(missing.contains("Lane Keeping"))
                XCTAssertTrue(missing.contains("Emergency Braking"))
                XCTAssertTrue(missing.contains("Surround View Camera"))
            }
        }
    }
    
    func testAutoPilot_SucceedsWhenAllDependenciesMet() {
        // Given: 所有依賴的功能都已啟用
        let enabledFeatures: Set<Feature> = [
            .laneKeeping,
            .emergencyBraking,
            .surroundView
        ]
        
        // When: 嘗試啟用自動駕駛
        let result = validator.validateEnable(
            feature: .autoPilot,
            centralComputerOn: true,
            engineRunning: false,  // AutoPilot 本身不需要引擎
            enabledFeatures: enabledFeatures
        )
        
        // Then: 應該成功
        XCTAssertNoThrow(try result.get())
    }
    
    // MARK: - 取得依賴者測試
    
    func testGetDependentFeatures_RearCamera() {
        // Given: 倒車鏡頭和環景攝影都已啟用
        let enabledFeatures: Set<Feature> = [.rearCamera, .surroundView]
        
        // When: 查詢依賴倒車鏡頭的功能
        let dependents = validator.getDependentFeatures(
            of: .rearCamera,
            from: enabledFeatures
        )
        
        // Then: 應該返回環景攝影
        XCTAssertEqual(dependents.count, 1)
        XCTAssertTrue(dependents.contains(.surroundView))
    }
    
    func testGetDependentFeatures_SurroundView() {
        // Given: 環景、停車輔助、自動駕駛都已啟用
        let enabledFeatures: Set<Feature> = [.surroundView, .parkingAssist, .autoPilot]
        
        // When: 查詢依賴環景的功能
        let dependents = validator.getDependentFeatures(
            of: .surroundView,
            from: enabledFeatures
        )
        
        // Then: 應該返回停車輔助和自動駕駛
        XCTAssertEqual(dependents.count, 2)
        XCTAssertTrue(dependents.contains(.parkingAssist))
        XCTAssertTrue(dependents.contains(.autoPilot))
    }
    
    func testGetEngineRequiredFeatures() {
        // When: 查詢需要引擎的功能
        let engineRequired = validator.getEngineRequiredFeatures()
        
        // Then: 應該返回車道維持和緊急煞車
        XCTAssertEqual(engineRequired.count, 2)
        XCTAssertTrue(engineRequired.contains(.laneKeeping))
        XCTAssertTrue(engineRequired.contains(.emergencyBraking))
    }
}

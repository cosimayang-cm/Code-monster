//
//  CarConfigurationTests.swift
//  CodeMonsterTests
//
//  Created by Sonia Wu on 2026/1/8.
//

import XCTest
@testable import CodeMonster

class CarConfigurationTests: XCTestCase {
    
    // MARK: - Configuration Factory Tests
    
    func testBasicConfiguration_HasOnlyBasicFeatures() {
        // Given: 建立基本配置
        let config = CarConfiguration.basic()
        
        // Then: 應包含 3 個基本功能
        XCTAssertEqual(config.features.count, 3, "Basic config should have 3 features")
        XCTAssertTrue(config.features.contains(.airConditioner))
        XCTAssertTrue(config.features.contains(.bluetooth))
        XCTAssertTrue(config.features.contains(.rearCamera))
    }
    
    func testLuxuryConfiguration_HasLuxuryFeatures() {
        // Given: 建立豪華配置
        let config = CarConfiguration.luxury()
        
        // Then: 應包含 9 個豪華功能
        XCTAssertEqual(config.features.count, 9, "Luxury config should have 9 features")
        XCTAssertTrue(config.features.contains(.navigation))
        XCTAssertTrue(config.features.contains(.entertainment))
        XCTAssertTrue(config.features.contains(.surroundView))
        XCTAssertTrue(config.features.contains(.blindSpotDetection))
        XCTAssertTrue(config.features.contains(.frontRadar))
        XCTAssertTrue(config.features.contains(.parkingAssist))
    }
    
    func testFullConfiguration_HasAllFeatures() {
        // Given: 建立完整配置
        let config = CarConfiguration.full()
        
        // Then: 應包含所有 12 個功能
        XCTAssertEqual(config.features.count, 12, "Full config should have all 12 features")
        XCTAssertTrue(config.features.contains(.autoPilot))
        XCTAssertTrue(config.features.contains(.laneKeeping))
        XCTAssertTrue(config.features.contains(.emergencyBraking))
    }
    
    // MARK: - Builder Tests
    
    func testBuilder_EmptyConfiguration() {
        // Given: 空的建構器
        // When: 建構配置
        let config = CarConfigurationBuilder()
            .build()
        
        // Then: 應該是空配置
        XCTAssertEqual(config.features.count, 0, "Empty builder should create empty config")
    }
    
    func testBuilder_AddSingleFeature() {
        // Given: 建構器
        // When: 新增單一功能
        let config = CarConfigurationBuilder()
            .add(.airConditioner)
            .build()
        
        // Then: 配置應包含該功能
        XCTAssertEqual(config.features.count, 1)
        XCTAssertTrue(config.features.contains(.airConditioner))
    }
    
    func testBuilder_AddMultipleFeatures() {
        // Given: 建構器
        // When: 連續新增多個功能
        let config = CarConfigurationBuilder()
            .add(.airConditioner)
            .add(.bluetooth)
            .add(.navigation)
            .build()
        
        // Then: 配置應包含所有功能
        XCTAssertEqual(config.features.count, 3)
        XCTAssertTrue(config.features.contains(.airConditioner))
        XCTAssertTrue(config.features.contains(.bluetooth))
        XCTAssertTrue(config.features.contains(.navigation))
    }
    
    func testBuilder_AddAll() {
        // Given: 建構器和功能列表
        // When: 批次新增多個功能
        let config = CarConfigurationBuilder()
            .addAll([.airConditioner, .bluetooth, .navigation])
            .build()
        
        // Then: 配置應包含所有功能
        XCTAssertEqual(config.features.count, 3)
        XCTAssertTrue(config.features.contains(.airConditioner))
        XCTAssertTrue(config.features.contains(.bluetooth))
        XCTAssertTrue(config.features.contains(.navigation))
    }
    
    func testBuilder_RemoveFeature() {
        // Given: 建構器已新增 3 個功能
        // When: 移除其中一個功能
        let config = CarConfigurationBuilder()
            .addAll([.airConditioner, .bluetooth, .navigation])
            .remove(.bluetooth)
            .build()
        
        // Then: 配置應只包含未移除的功能
        XCTAssertEqual(config.features.count, 2)
        XCTAssertTrue(config.features.contains(.airConditioner))
        XCTAssertTrue(config.features.contains(.navigation))
        XCTAssertFalse(config.features.contains(.bluetooth))
    }
    
    func testBuilder_CustomConfiguration() {
        // Given: 建構器
        // When: 基於基本配置新增客製功能
        let config = CarConfigurationBuilder()
            .addAll(CarConfiguration.basic().features)
            .add(.navigation)
            .add(.entertainment)
            .build()
        
        // Then: 應包含基本配置 + 客製功能
        XCTAssertEqual(config.features.count, 5)
        XCTAssertTrue(config.features.contains(.navigation))
        XCTAssertTrue(config.features.contains(.entertainment))
    }
    
    // MARK: - Car with Configuration Tests
    
    func testCar_WithBasicConfiguration() {
        // Given: 基本配置
        // When: 創建車輛
        let car = Car(configuration: .basic())
        
        // Then: 應安裝 3 個功能
        let installed = car.getInstalledFeatures()
        XCTAssertEqual(installed.count, 3)
    }
    
    func testCar_WithLuxuryConfiguration() {
        // Given: 豪華配置
        // When: 創建車輛
        let car = Car(configuration: .luxury())
        
        // Then: 應安裝 9 個功能
        let installed = car.getInstalledFeatures()
        XCTAssertEqual(installed.count, 9)
    }
    
    func testCar_WithFullConfiguration() {
        // Given: 完整配置
        // When: 創建車輛
        let car = Car(configuration: .full())
        
        // Then: 應安裝所有 12 個功能
        let installed = car.getInstalledFeatures()
        XCTAssertEqual(installed.count, 12)
    }
    
    func testCar_CannotEnableUninstalledFeature() {
        // Given: 車輛只安裝空調
        let config = CarConfigurationBuilder()
            .add(.airConditioner)
            .build()
        let car = Car(configuration: config)
        car.turnOnCentralComputer()
        
        // When: 嘗試啟用未安裝的導航功能
        let result = car.enableFeature(.navigation)
        
        // Then: 應該失敗並返回 featureNotInstalled 錯誤
        XCTAssertTrue(result.isFailure, "Should fail to enable uninstalled feature")
        if case .failure(let error) = result {
            XCTAssertEqual(error, .featureNotInstalled)
        }
    }
    
    func testCar_CanEnableInstalledFeature() {
        // Given: 車輛已安裝空調
        let config = CarConfigurationBuilder()
            .add(.airConditioner)
            .build()
        let car = Car(configuration: config)
        car.turnOnCentralComputer()
        
        // When: 啟用已安裝的空調
        let result = car.enableFeature(.airConditioner)
        
        // Then: 應該成功
        XCTAssertTrue(result.isSuccess, "Should succeed enabling installed feature")
    }
    
    func testCar_GetAvailableFeatures_OnlyIncludesInstalledFeatures() {
        // Given: 車輛已安裝空調和藍牙
        let config = CarConfigurationBuilder()
            .add(.airConditioner)
            .add(.bluetooth)
            .build()
        let car = Car(configuration: config)
        car.turnOnCentralComputer()
        
        // When: 查詢可用功能
        let available = car.getAvailableFeatures()
        
        // Then: 只應包含已安裝的功能
        XCTAssertEqual(available.count, 2)
        XCTAssertTrue(available.contains(.airConditioner))
        XCTAssertTrue(available.contains(.bluetooth))
    }
    
    func testCar_CustomConfiguration_MixAndMatch() {
        // Given: 客製配置（基本 + 導航 - 藍牙）
        let config = CarConfigurationBuilder()
            .addAll(CarConfiguration.basic().features)  // 從基本配置開始
            .add(.navigation)                           // 新增導航
            .remove(.bluetooth)                         // 移除藍牙
            .build()
        
        // When: 創建車輛並開機
        let car = Car(configuration: config)
        car.turnOnCentralComputer()
        
        // Then: 應包含正確的功能組合
        let installed = car.getInstalledFeatures()
        XCTAssertEqual(installed.count, 3)
        XCTAssertTrue(installed.contains(.airConditioner))
        XCTAssertTrue(installed.contains(.rearCamera))
        XCTAssertTrue(installed.contains(.navigation))
        XCTAssertFalse(installed.contains(.bluetooth))
    }
}

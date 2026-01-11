//
//  CarTests.swift
//  CarSystemTests
//
//  Created by Claude on 2026/1/11.
//
import XCTest
import Combine
@testable import CarSystem

final class CarTests: XCTestCase {
    
    var car: Car!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        car = Car()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
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
    
    // MARK: - Combine 自動綁定測試
    
    func testCombineAutoDisableOnCentralComputerOff() {
        let expectation = XCTestExpectation(description: "Features should be disabled when computer turns off")
        
        car.centralComputer.turnOn()
        car.enable(.airConditioner)
        car.enable(.navigation)
        
        XCTAssertTrue(car.isFeatureEnabled(.airConditioner))
        XCTAssertTrue(car.isFeatureEnabled(.navigation))
        
        // 訂閱 enabledFeatures 變化
        car.$enabledFeatures
            .dropFirst() // 跳過初始值
            .sink { features in
                // 當中控電腦關閉時，所有功能應該被自動停用
                if features.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // 關閉中控電腦（Combine 應自動觸發連鎖停用）
        car.centralComputer.turnOff()
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(car.isFeatureEnabled(.airConditioner))
        XCTAssertFalse(car.isFeatureEnabled(.navigation))
    }
    
    func testCombineAutoDisableOnEngineStop() {
        let expectation = XCTestExpectation(description: "Engine-dependent features should be disabled when engine stops")
        
        car.centralComputer.turnOn()
        car.engine.start()
        car.enable(.navigation)
        car.enable(.frontRadar)
        car.enable(.laneKeeping)
        
        XCTAssertTrue(car.isFeatureEnabled(.laneKeeping))
        
        // 訂閱 enabledFeatures 變化
        car.$enabledFeatures
            .dropFirst()
            .sink { features in
                // 當引擎停止時，laneKeeping 應該被自動停用
                if !features.contains(.laneKeeping) {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // 停止引擎（Combine 應自動觸發連鎖停用）
        car.engine.stop()
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(car.isFeatureEnabled(.laneKeeping))
        // 其他不依賴引擎的功能應該保持啟用
        XCTAssertTrue(car.isFeatureEnabled(.navigation))
        XCTAssertTrue(car.isFeatureEnabled(.frontRadar))
    }
    
    func testPublishedStateSync() {
        // 測試 @Published 狀態同步
        car.centralComputer.turnOn()
        XCTAssertTrue(car.isComputerOn)
        
        car.centralComputer.turnOff()
        XCTAssertFalse(car.isComputerOn)
        
        car.engine.start()
        XCTAssertTrue(car.isEngineRunning)
        
        car.engine.stop()
        XCTAssertFalse(car.isEngineRunning)
    }
    
    // MARK: - 元件測試
    
    func testAllComponentsExist() {
        // 測試所有 16 個元件都已建立
        XCTAssertEqual(car.wheels.count, 4)
        XCTAssertNotNil(car.engine)
        XCTAssertNotNil(car.battery)
        XCTAssertNotNil(car.centralComputer)
        XCTAssertNotNil(car.airConditioner)
        XCTAssertNotNil(car.navigationSystem)
        XCTAssertNotNil(car.entertainmentSystem)
        XCTAssertNotNil(car.bluetoothSystem)
        XCTAssertNotNil(car.rearCamera)
        XCTAssertNotNil(car.surroundViewCamera)
        XCTAssertNotNil(car.blindSpotDetection)
        XCTAssertNotNil(car.frontRadar)
        XCTAssertNotNil(car.parkingAssist)
        XCTAssertNotNil(car.laneKeeping)
        XCTAssertNotNil(car.emergencyBraking)
        XCTAssertNotNil(car.autoPilot)
    }
    
    func testAllComponentsImplementCarComponent() {
        // 測試所有元件都實作 CarComponent Protocol
        let allComponents = car.allComponents
        XCTAssertEqual(allComponents.count, 19) // 4 輪 + 3 個必要元件(引擎、電池、中控) + 12 個選配元件
        
        for component in allComponents {
            XCTAssertFalse(component.name.isEmpty)
        }
    }
    
    func testComponentForFeatureMapping() {
        // 測試每個 Feature 都能正確對應到其 CarComponent
        XCTAssertEqual(car.component(for: .airConditioner).name, "空調系統")
        XCTAssertEqual(car.component(for: .navigation).name, "導航系統")
        XCTAssertEqual(car.component(for: .entertainment).name, "娛樂系統")
        XCTAssertEqual(car.component(for: .bluetooth).name, "藍牙系統")
        XCTAssertEqual(car.component(for: .rearCamera).name, "倒車鏡頭")
        XCTAssertEqual(car.component(for: .surroundView).name, "環景攝影")
        XCTAssertEqual(car.component(for: .blindSpotDetection).name, "盲點偵測")
        XCTAssertEqual(car.component(for: .frontRadar).name, "前方雷達")
        XCTAssertEqual(car.component(for: .parkingAssist).name, "停車輔助")
        XCTAssertEqual(car.component(for: .laneKeeping).name, "車道維持")
        XCTAssertEqual(car.component(for: .emergencyBraking).name, "緊急煞車")
        XCTAssertEqual(car.component(for: .autoPilot).name, "自動駕駛")
    }
    
    func testOptionalAndRequiredComponents() {
        // 測試必要元件數量
        let required = car.requiredComponents
        XCTAssertEqual(required.count, 7) // 4 輪 + 引擎 + 電池 + 中控電腦
        XCTAssertTrue(required.allSatisfy { $0.isRequired })
        
        // 測試選配元件數量
        let optional = car.optionalComponents
        XCTAssertEqual(optional.count, 12)
        XCTAssertTrue(optional.allSatisfy { !$0.isRequired })
    }
    
    // MARK: - ToggleableComponent 測試
    
    func testToggleableComponentProperties() {
        // 測試元件自帶的依賴資訊
        let surroundView = car.component(for: .surroundView)
        XCTAssertEqual(surroundView.dependencies, [.rearCamera])
        XCTAssertTrue(surroundView.requiresCentralComputer)
        XCTAssertFalse(surroundView.requiresEngineRunning)
        
        let laneKeeping = car.component(for: .laneKeeping)
        XCTAssertEqual(laneKeeping.dependencies, [.navigation, .frontRadar])
        XCTAssertTrue(laneKeeping.requiresCentralComputer)
        XCTAssertTrue(laneKeeping.requiresEngineRunning)
        
        let autoPilot = car.component(for: .autoPilot)
        XCTAssertEqual(autoPilot.dependencies, [.laneKeeping, .emergencyBraking, .surroundView])
    }
    
    func testAllToggleableComponentsHaveFeature() {
        // 每個選配元件都應該有對應的 Feature
        for component in car.toggleableComponents {
            XCTAssertNotNil(component.feature)
            XCTAssertFalse(component.name.isEmpty)
            XCTAssertFalse(component.description.isEmpty)
        }
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

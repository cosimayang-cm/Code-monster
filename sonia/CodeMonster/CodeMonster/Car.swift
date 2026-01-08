//
//  Car.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/8.
//

import Foundation

/// 車輛主類別 - Facade Pattern
class Car {
    
    // MARK: - Components
    
    private let wheel = Wheel()
    private let engine = Engine()
    private let battery = Battery()
    private let centralComputer = CentralComputer()
    
    private let airConditioner = AirConditioner()
    private let navigation = NavigationSystem()
    private let entertainment = EntertainmentSystem()
    private let bluetooth = BluetoothSystem()
    private let rearCamera = RearCamera()
    private let surroundView = SurroundViewCamera()
    private let blindSpotDetection = BlindSpotDetection()
    private let frontRadar = FrontRadar()
    private let parkingAssist = ParkingAssist()
    private let laneKeeping = LaneKeeping()
    private let emergencyBraking = EmergencyBraking()
    private let autoPilot = AutoPilot()
    
    // MARK: - Services
    
    private let dependencyValidator = DependencyValidator()
    
    // MARK: - State
    
    /// 已啟用的功能集合
    private var enabledFeatures: Set<Feature> = []

    
    // MARK: - Initialization
    
    init() {
        print("🚗 Car initialized")
    }
    
    // MARK: - Central Computer Control
    
    func turnOnCentralComputer() {
        centralComputer.turnOn()
    }
    
    func turnOffCentralComputer() {
        centralComputer.turnOff()
        
        // 連鎖停用所有依賴中控電腦的功能
        let affectedFeatures = enabledFeatures.filter { _ in true } // 所有功能都依賴中控電腦
        for feature in affectedFeatures {
            disableFeatureCascade(feature)
        }
        
        if !affectedFeatures.isEmpty {
            print("⚠️ Central Computer OFF - Disabled features: \(affectedFeatures.map { $0.displayName }.joined(separator: ", "))")
        }
    }
    
    var isCentralComputerOn: Bool {
        return centralComputer.isActive
    }
    
    // MARK: - Engine Control
    
    func startEngine() {
        engine.turnOn()
    }
    
    func stopEngine() {
        engine.turnOff()
        
        // 只影響需要引擎運行的功能
        let engineRequiredFeatures = dependencyValidator.getEngineRequiredFeatures()
        let affectedFeatures = enabledFeatures.filter { engineRequiredFeatures.contains($0) }
        
        for feature in affectedFeatures {
            disableFeatureCascade(feature)
        }
        
        if !affectedFeatures.isEmpty {
            print("⚠️ Engine stopped - Disabled features: \(affectedFeatures.map { $0.displayName }.joined(separator: ", "))")
        }
    }
    
    var isEngineRunning: Bool {
        return engine.isActive
    }
    
    // MARK: - Feature Toggle
    
    /// 啟用指定功能
    func enableFeature(_ feature: Feature) -> Result<Void, FeatureError> {
        // 檢查是否已啟用
        if enabledFeatures.contains(feature) {
            print("ℹ️ \(feature.displayName) is already enabled")
            return .success(())
        }
        
        // 驗證相依性
        let validationResult = dependencyValidator.validateEnable(
            feature: feature,
            centralComputerOn: centralComputer.isActive,
            engineRunning: engine.isActive,
            enabledFeatures: enabledFeatures
        )
        
        switch validationResult {
        case .success:
            // 啟用功能
            setFeatureEnabled(feature, enabled: true)
            enabledFeatures.insert(feature)
            print("✅ Enabled: \(feature.displayName)")
            return .success(())
            
        case .failure(let error):
            print("❌ Failed to enable \(feature.displayName): \(error.localizedDescription)")
            return .failure(error)
        }
    }
    
    /// 停用指定功能（連鎖停用依賴它的功能）
    func disableFeature(_ feature: Feature) -> Result<Void, FeatureError> {
        // 檢查是否已停用
        guard enabledFeatures.contains(feature) else {
            print("ℹ️ \(feature.displayName) is already disabled")
            return .success(())
        }
        
        // 遞迴停用所有依賴功能
        let allDisabled = disableFeatureRecursive(feature)
        
        if allDisabled.count > 1 {
            let dependents = allDisabled.filter { $0 != feature }
            print("⚠️ Also disabled dependent features: \(dependents.map { $0.displayName }.joined(separator: ", "))")
        }
        
        return .success(())
    }
    
    /// 遞迴停用功能及其所有依賴者
    private func disableFeatureRecursive(_ feature: Feature) -> [Feature] {
        var disabledFeatures: [Feature] = []
        
        // 先找出直接依賴此功能的其他功能
        let directDependents = dependencyValidator.getDependentFeatures(
            of: feature,
            from: enabledFeatures
        )
        
        // 遞迴停用每個依賴者（深度優先）
        for dependent in directDependents {
            let cascadeDisabled = disableFeatureRecursive(dependent)
            disabledFeatures.append(contentsOf: cascadeDisabled)
        }
        
        // 最後停用自己
        if enabledFeatures.contains(feature) {
            disableFeatureCascade(feature)
            disabledFeatures.append(feature)
        }
        
        return disabledFeatures
    }
    
    /// 直接停用功能（無檢查）
    private func disableFeatureCascade(_ feature: Feature) {
        setFeatureEnabled(feature, enabled: false)
        enabledFeatures.remove(feature)
        print("🔴 Disabled: \(feature.displayName)")
    }
    
    /// 設定功能元件的啟用狀態
    private func setFeatureEnabled(_ feature: Feature, enabled: Bool) {
        switch feature {
        case .airConditioner:
            airConditioner.isEnabled = enabled
        case .navigation:
            navigation.isEnabled = enabled
        case .entertainment:
            entertainment.isEnabled = enabled
        case .bluetooth:
            bluetooth.isEnabled = enabled
        case .rearCamera:
            rearCamera.isEnabled = enabled
        case .surroundView:
            surroundView.isEnabled = enabled
        case .blindSpotDetection:
            blindSpotDetection.isEnabled = enabled
        case .frontRadar:
            frontRadar.isEnabled = enabled
        case .parkingAssist:
            parkingAssist.isEnabled = enabled
        case .laneKeeping:
            laneKeeping.isEnabled = enabled
        case .emergencyBraking:
            emergencyBraking.isEnabled = enabled
        case .autoPilot:
            autoPilot.isEnabled = enabled
        }
    }
    
    // MARK: - Query
    
    /// 查詢指定功能是否已啟用
    func isFeatureEnabled(_ feature: Feature) -> Bool {
        return enabledFeatures.contains(feature)
    }
    
    /// 取得所有已啟用功能的列表
    func getEnabledFeatures() -> [Feature] {
        return Array(enabledFeatures).sorted { $0.displayName < $1.displayName }
    }
    
    /// 印出當前狀態
    func printStatus() {
        print("\n" + String(repeating: "=", count: 50))
        print("🚗 CAR STATUS")
        print(String(repeating: "=", count: 50))
        print("Central Computer: \(centralComputer.isActive ? "ON 💻" : "OFF")")
        print("Engine: \(engine.isActive ? "RUNNING 🏃" : "STOPPED")")
        print("\nEnabled Features (\(enabledFeatures.count)):")
        if enabledFeatures.isEmpty {
            print("  (none)")
        } else {
            for feature in getEnabledFeatures() {
                print("  ✓ \(feature.displayName)")
            }
        }
        print(String(repeating: "=", count: 50) + "\n")
    }
}

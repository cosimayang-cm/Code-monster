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
    
    private let dependencyValidator: DependencyValidating
    private let eventPublisher: CarEventPublisher
    
    // MARK: - State
    
    /// 已啟用的功能集合
    private var enabledFeatures: Set<Feature> = []

    
    // MARK: - Initialization
    
    init(dependencyValidator: DependencyValidating = DependencyValidator(),
         eventPublisher: CarEventPublisher = CarEventPublisher()) {
        self.dependencyValidator = dependencyValidator
        self.eventPublisher = eventPublisher
        print("🚗 Car initialized")
    }
    
    // MARK: - Central Computer Control
    
    func turnOnCentralComputer() {
        // ✅ 檢查是否已開啟（避免重複操作）
        guard !centralComputer.isActive else {
            print("⚠️ Central Computer is already ON - skipping")
            return
        }
        centralComputer.turnOn()
        eventPublisher.publish(.centralComputerTurnedOn)
    }
    
    func turnOffCentralComputer() {
        // ✅ 檢查是否已關閉（避免重複操作）
        guard centralComputer.isActive else {
            print("⚠️ Central Computer is already OFF - skipping")
            return
        }
        centralComputer.turnOff()
        
        // 連鎖停用所有依賴中控電腦的功能
        let affectedFeatures = enabledFeatures.filter { _ in true } // 所有功能都依賴中控電腦
        
        var allDisabledFeatures: [Feature] = []
        for feature in affectedFeatures {
            let disabled = disableFeatureRecursive(feature)
            allDisabledFeatures.append(contentsOf: disabled)
        }
        
        if !allDisabledFeatures.isEmpty {
            print("⚠️ Central Computer OFF - Disabled features: \(allDisabledFeatures.map { $0.displayName }.joined(separator: ", "))")
            eventPublisher.publish(.featuresCascadeDisabled(allDisabledFeatures))
        }
        
        eventPublisher.publish(.centralComputerTurnedOff)
    }
    
    var isCentralComputerOn: Bool {
        return centralComputer.isActive
    }
    
    // MARK: - Engine Control
    
    func startEngine() {
        // ✅ 檢查是否已啟動（避免重複操作）
        guard !engine.isActive else {
            print("⚠️ Engine is already running - skipping")
            return
        }
        engine.turnOn()
        eventPublisher.publish(.engineStarted)
    }
    
    func stopEngine() {
        // ✅ 檢查是否已停止（避免重複操作）
        guard engine.isActive else {
            print("⚠️ Engine is already stopped - skipping")
            return
        }
        engine.turnOff()
        
        // 只影響需要引擎運行的功能（使用連鎖停用）
        let engineRequiredFeatures = dependencyValidator.getEngineRequiredFeatures()
        let affectedFeatures = enabledFeatures.filter { engineRequiredFeatures.contains($0) }
        
        var allDisabledFeatures: [Feature] = []
        for feature in affectedFeatures {
            let disabled = disableFeatureRecursive(feature)
            allDisabledFeatures.append(contentsOf: disabled)
        }
        
        if !allDisabledFeatures.isEmpty {
            print("⚠️ Engine stopped - Disabled features: \(allDisabledFeatures.map { $0.displayName }.joined(separator: ", "))")
            eventPublisher.publish(.featuresCascadeDisabled(allDisabledFeatures))
        }
        
        eventPublisher.publish(.engineStopped)
    }
    
    var isEngineRunning: Bool {
        return engine.isActive
    }
    
    // MARK: - Feature Toggle
    
    /// 啟用指定功能
    func enableFeature(_ feature: Feature) -> Result<Void, FeatureError> {
        // ✅ 檢查是否已啟用（避免重複操作）
        guard !enabledFeatures.contains(feature) else {
            print("⚠️ \(feature.displayName) is already enabled - skipping")
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
            eventPublisher.publish(.featureEnabled(feature))
            return .success(())
            
        case .failure(let error):
            print("❌ Failed to enable \(feature.displayName): \(error.localizedDescription)")
            return .failure(error)
        }
    }
    
    /// 停用指定功能（連鎖停用依賴它的功能）
    func disableFeature(_ feature: Feature) -> Result<Void, FeatureError> {
        // ✅ 檢查是否已停用（避免重複操作）
        guard enabledFeatures.contains(feature) else {
            print("⚠️ \(feature.displayName) is already disabled - skipping")
            return .success(())
        }
        
        // 遞迴停用所有依賴功能
        let allDisabled = disableFeatureRecursive(feature)
        
        if allDisabled.count > 1 {
            let dependents = allDisabled.filter { $0 != feature }
            print("⚠️ Also disabled dependent features: \(dependents.map { $0.displayName }.joined(separator: ", "))")
            eventPublisher.publish(.featuresCascadeDisabled(allDisabled))
        } else if allDisabled.count == 1 {
            eventPublisher.publish(.featureDisabled(feature))
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
    
    /// 查詢指定功能是否可以啟用（依賴條件是否滿足）
    func isFeatureAvailable(_ feature: Feature) -> Bool {
        let validationResult = dependencyValidator.validateEnable(
            feature: feature,
            centralComputerOn: centralComputer.isActive,
            engineRunning: engine.isActive,
            enabledFeatures: enabledFeatures
        )
        
        return validationResult.isSuccess
    }
    
    /// 取得所有已啟用功能的列表
    func getEnabledFeatures() -> [Feature] {
        return Array(enabledFeatures).sorted { $0.displayName < $1.displayName }
    }
    
    /// 取得所有可用（可啟用）但尚未啟用的功能列表
    func getAvailableFeatures() -> [Feature] {
        return Feature.allCases.filter { feature in
            !isFeatureEnabled(feature) && isFeatureAvailable(feature)
        }
    }
    
    /// 取得所有不可用（無法啟用）的功能列表
    func getUnavailableFeatures() -> [Feature] {
        return Feature.allCases.filter { feature in
            !isFeatureAvailable(feature)
        }
    }
    
    // MARK: - Observer Management
    
    /// 加入觀察者
    func addObserver(_ observer: CarEventObserver) {
        eventPublisher.addObserver(observer)
    }
    
    /// 移除觀察者
    func removeObserver(_ observer: CarEventObserver) {
        eventPublisher.removeObserver(observer)
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

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
    
    /// 功能元件字典（根據車輛配置動態安裝）
    private var featureComponents: [Feature: FeatureToggleComponent] = [:]
    
    // MARK: - Services
    
    private let dependencyValidator: DependencyValidating
    private let eventPublisher: CarEventPublisher
    private let logger: Logger
    
    // MARK: - State
    
    /// 已啟用的功能集合
    private var enabledFeatures: Set<Feature> = []

    
    // MARK: - Initialization
    
    init(configuration: CarConfiguration = .full(),
         dependencyValidator: DependencyValidating = DependencyValidator(),
         eventPublisher: CarEventPublisher = CarEventPublisher(),
         logger: Logger = ConsoleLogger()) {
        self.dependencyValidator = dependencyValidator
        self.eventPublisher = eventPublisher
        self.logger = logger
        
        // 根據配置安裝元件
        configuration.features.forEach { feature in
            featureComponents[feature] = ComponentFactory.create(feature)
        }
        
        logger.log("Car initialized with \(configuration.features.count) features", level: .info)
    }
    
    // MARK: - Central Computer Control
    
    func turnOnCentralComputer() {
        // ✅ 檢查是否已開啟（避免重複操作）
        guard !centralComputer.isActive else {
            logger.log("Central Computer is already ON - skipping", level: .warning)
            return
        }
        centralComputer.turnOn()
        eventPublisher.publish(.centralComputerTurnedOn)
    }
    
    func turnOffCentralComputer() {
        // ✅ 檢查是否已關閉（避免重複操作）
        guard centralComputer.isActive else {
            logger.log("Central Computer is already OFF - skipping", level: .warning)
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
            logger.log("Central Computer OFF - Disabled features: \(allDisabledFeatures.map { $0.displayName }.joined(separator: ", "))", level: .warning)
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
            logger.log("Engine is already running - skipping", level: .warning)
            return
        }
        engine.turnOn()
        eventPublisher.publish(.engineStarted)
    }
    
    func stopEngine() {
        // ✅ 檢查是否已停止（避免重複操作）
        guard engine.isActive else {
            logger.log("Engine is already stopped - skipping", level: .warning)
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
            logger.log("Engine stopped - Disabled features: \(allDisabledFeatures.map { $0.displayName }.joined(separator: ", "))", level: .warning)
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
        // ✅ 檢查功能是否已安裝
        guard featureComponents[feature] != nil else {
            print("❌ \(feature.displayName) is not installed in this car")
            return .failure(.featureNotInstalled)
        }
        
        // ✅ 檢查是否已啟用（避免重複操作）
        guard !enabledFeatures.contains(feature) else {
            logger.log("\(feature.displayName) is already enabled - skipping", level: .warning)
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
            logger.log("Enabled: \(feature.displayName)", level: .info)
            eventPublisher.publish(.featureEnabled(feature))
            return .success(())
            
        case .failure(let error):
            logger.log("Failed to enable \(feature.displayName): \(error.localizedDescription)", level: .error)
            return .failure(error)
        }
    }
    
    /// 停用指定功能（連鎖停用依賴它的功能）
    func disableFeature(_ feature: Feature) -> Result<Void, FeatureError> {
        // ✅ 檢查功能是否已安裝
        guard featureComponents[feature] != nil else {
            logger.log("\(feature.displayName) is not installed in this car", level: .error)
            return .failure(.featureNotInstalled)
        }
        
        // ✅ 檢查是否已停用（避免重複操作）
        guard enabledFeatures.contains(feature) else {
            logger.log("\(feature.displayName) is already disabled - skipping", level: .warning)
            return .success(())
        }
        
        // 遞迴停用所有依賴功能
        let allDisabled = disableFeatureRecursive(feature)
        
        if allDisabled.count > 1 {
            let dependents = allDisabled.filter { $0 != feature }
            logger.log("Also disabled dependent features: \(dependents.map { $0.displayName }.joined(separator: ", "))", level: .warning)
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
        logger.log("Disabled: \(feature.displayName)", level: .info)
    }
    
    /// 設定功能元件的啟用狀態
    private func setFeatureEnabled(_ feature: Feature, enabled: Bool) {
        featureComponents[feature]?.isEnabled = enabled
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
        // 只包含已安裝的功能
        return featureComponents.keys.filter { feature in
            !isFeatureEnabled(feature) && isFeatureAvailable(feature)
        }
    }
    
    /// 取得所有不可用（無法啟用）的功能列表
    func getUnavailableFeatures() -> [Feature] {
        // 只包含已安裝但不可用的功能
        return featureComponents.keys.filter { feature in
            !isFeatureAvailable(feature)
        }
    }
    
    /// 取得車輛已安裝的所有功能
    func getInstalledFeatures() -> [Feature] {
        return Array(featureComponents.keys).sorted { $0.displayName < $1.displayName }
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

//
//  Car.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/8.
//

import Foundation

/// 車輛主類別 - Facade Pattern
/// 負責協調各 Manager，發布事件，記錄日誌
class Car {
    
    // MARK: - Managers
    
    private let lifecycle: ComponentLifecycleManager
    private let features: FeatureStateManager
    private let eventPublisher: CarEventPublisher
    private let logger: Logger
    
    // MARK: - Initialization
    
    init(configuration: CarConfiguration = .full(),
         lifecycle: ComponentLifecycleManager = ComponentLifecycleManager(),
         features: FeatureStateManager? = nil,
         validator: DependencyValidating = DependencyValidator(),
         eventPublisher: CarEventPublisher = CarEventPublisher(),
         logger: Logger = ConsoleLogger()) {
        
        self.lifecycle = lifecycle
        self.features = features ?? FeatureStateManager(
            configuration: configuration,
            validator: validator
        )
        self.eventPublisher = eventPublisher
        self.logger = logger
        
        logger.log("Car initialized with \(configuration.features.count) features", level: .info)
    }
    
    // MARK: - Central Computer Control
    
    func turnOnCentralComputer() {
        guard !lifecycle.isCentralComputerOn else {
            logger.log("Central Computer is already ON - skipping", level: .warning)
            return
        }
        
        lifecycle.turnOnCentralComputer()
        eventPublisher.publish(.centralComputerTurnedOn)
    }
    
    func turnOffCentralComputer() {
        guard lifecycle.isCentralComputerOn else {
            logger.log("Central Computer is already OFF - skipping", level: .warning)
            return
        }
        
        // 先停止引擎（引擎依賴中控電腦）
        if lifecycle.isEngineRunning {
            lifecycle.stopEngine()
            logger.log("Central Computer OFF - Engine stopped", level: .warning)
            eventPublisher.publish(.engineStopped)
        }
        
        lifecycle.turnOffCentralComputer()
        
        // 連鎖停用所有功能
        let enabledFeatures = features.getEnabledFeatures()
        var allDisabled: [Feature] = []
        
        for feature in enabledFeatures {
            if let result = try? features.disable(feature).get() {
                allDisabled.append(contentsOf: result)
            }
        }
        
        if !allDisabled.isEmpty {
            logger.log("Central Computer OFF - Disabled features: \(allDisabled.map { $0.displayName }.joined(separator: ", "))", level: .warning)
            eventPublisher.publish(.featuresCascadeDisabled(allDisabled))
        }
        
        eventPublisher.publish(.centralComputerTurnedOff)
    }
    
    var isCentralComputerOn: Bool {
        lifecycle.isCentralComputerOn
    }
    
    // MARK: - Engine Control
    
    func startEngine() {
        guard !lifecycle.isEngineRunning else {
            logger.log("Engine is already running - skipping", level: .warning)
            return
        }
        
        // 檢查中控電腦是否已開啟（引擎依賴中控電腦）
        guard lifecycle.isCentralComputerOn else {
            logger.log("Cannot start engine: Central Computer is OFF", level: .error)
            return
        }
        
        lifecycle.startEngine()
        eventPublisher.publish(.engineStarted)
    }
    
    func stopEngine() {
        guard lifecycle.isEngineRunning else {
            logger.log("Engine is already stopped - skipping", level: .warning)
            return
        }
        
        lifecycle.stopEngine()
        
        // 停用需要引擎的功能
        let validator = DependencyValidator()
        let engineFeatures = validator.getEngineRequiredFeatures()
        let enabledEngineFeatures = features.getEnabledFeatures()
            .filter { engineFeatures.contains($0) }
        
        var allDisabled: [Feature] = []
        for feature in enabledEngineFeatures {
            if let result = try? features.disable(feature).get() {
                allDisabled.append(contentsOf: result)
            }
        }
        
        if !allDisabled.isEmpty {
            logger.log("Engine stopped - Disabled features: \(allDisabled.map { $0.displayName }.joined(separator: ", "))", level: .warning)
            eventPublisher.publish(.featuresCascadeDisabled(allDisabled))
        }
        
        eventPublisher.publish(.engineStopped)
    }
    
    var isEngineRunning: Bool {
        lifecycle.isEngineRunning
    }
    
    // MARK: - Feature Toggle
    
    /// 啟用指定功能
    func enableFeature(_ feature: Feature) -> Result<Void, FeatureError> {
        let result = features.enable(
            feature,
            centralComputerOn: lifecycle.isCentralComputerOn,
            engineRunning: lifecycle.isEngineRunning
        )
        
        switch result {
        case .success:
            logger.log("Enabled: \(feature.displayName)", level: .info)
            eventPublisher.publish(.featureEnabled(feature))
        case .failure(let error):
            logger.log("Failed to enable \(feature.displayName): \(error.localizedDescription)", level: .error)
        }
        
        return result
    }
    
    /// 停用指定功能（連鎖停用依賴它的功能）
    func disableFeature(_ feature: Feature) -> Result<Void, FeatureError> {
        let result = features.disable(feature)
        
        switch result {
        case .success(let disabled):
            if disabled.count > 1 {
                let dependents = disabled.filter { $0 != feature }
                logger.log("Also disabled dependent features: \(dependents.map { $0.displayName }.joined(separator: ", "))", level: .warning)
                eventPublisher.publish(.featuresCascadeDisabled(disabled))
            } else if disabled.count == 1 {
                eventPublisher.publish(.featureDisabled(feature))
            }
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
    
    // MARK: - Query
    
    /// 查詢指定功能是否已啟用
    func isFeatureEnabled(_ feature: Feature) -> Bool {
        features.isEnabled(feature)
    }
    
    /// 查詢指定功能是否可以啟用（依賴條件是否滿足）
    func isFeatureAvailable(_ feature: Feature) -> Bool {
        features.isAvailable(
            feature,
            centralComputerOn: lifecycle.isCentralComputerOn,
            engineRunning: lifecycle.isEngineRunning
        )
    }
    
    /// 取得所有已啟用功能的列表
    func getEnabledFeatures() -> [Feature] {
        features.getEnabledFeatures()
    }
    
    /// 取得所有可用（可啟用）但尚未啟用的功能列表
    func getAvailableFeatures() -> [Feature] {
        features.getInstalledFeatures().filter { feature in
            !isFeatureEnabled(feature) && isFeatureAvailable(feature)
        }
    }
    
    /// 取得所有不可用（無法啟用）的功能列表
    func getUnavailableFeatures() -> [Feature] {
        features.getInstalledFeatures().filter { feature in
            !isFeatureAvailable(feature)
        }
    }
    
    /// 取得車輛已安裝的所有功能
    func getInstalledFeatures() -> [Feature] {
        features.getInstalledFeatures()
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
        print("Central Computer: \(lifecycle.isCentralComputerOn ? "ON 💻" : "OFF")")
        print("Engine: \(lifecycle.isEngineRunning ? "RUNNING 🏃" : "STOPPED")")
        print("\nEnabled Features (\(features.getEnabledFeatures().count)):")
        if features.getEnabledFeatures().isEmpty {
            print("  (none)")
        } else {
            for feature in getEnabledFeatures() {
                print("  ✓ \(feature.displayName)")
            }
        }
        print(String(repeating: "=", count: 50) + "\n")
    }
}

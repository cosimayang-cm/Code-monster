//
//  Car.swift
//  CarSystem 車輛主類別
//
//  Created by Claude on 2026/1/11.
//

import Foundation
import Combine

/// 車輛主類別 - 使用 ObservableObject 實現資料綁定
class Car: ObservableObject {
    
    // MARK: - 必要元件（4 個）
    let wheels: [Wheel]
    let engine: Engine
    let battery: Battery
    let centralComputer: CentralComputer
    
    // MARK: - 選配元件（12 個）
    let airConditioner: AirConditioner
    let navigationSystem: NavigationSystem
    let entertainmentSystem: EntertainmentSystem
    let bluetoothSystem: BluetoothSystem
    let rearCamera: RearCamera
    let surroundViewCamera: SurroundViewCamera
    let blindSpotDetection: BlindSpotDetection
    let frontRadar: FrontRadar
    let parkingAssist: ParkingAssist
    let laneKeeping: LaneKeeping
    let emergencyBraking: EmergencyBraking
    let autoPilot: AutoPilot
    
    // MARK: - 發布狀態（使用 Combine）
    @Published private(set) var enabledFeatures: Set<Feature> = []
    @Published private(set) var isComputerOn: Bool = false
    @Published private(set) var isEngineRunning: Bool = false
    
    // MARK: - Combine 訂閱管理
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 元件查詢
    
    /// 所有選配元件（實作 ToggleableComponent）
    var toggleableComponents: [ToggleableComponent] {
        [
            airConditioner, navigationSystem, entertainmentSystem, bluetoothSystem,
            rearCamera, surroundViewCamera, blindSpotDetection, frontRadar,
            parkingAssist, laneKeeping, emergencyBraking, autoPilot
        ]
    }
    
    /// 所有元件
    var allComponents: [CarComponent] {
        var components: [CarComponent] = []
        components.append(contentsOf: wheels as [CarComponent])
        components.append(contentsOf: [engine, battery, centralComputer] as [CarComponent])
        components.append(contentsOf: toggleableComponents as [CarComponent])
        return components
    }
    
    /// 根據 Feature 取得對應的元件
    func component(for feature: Feature) -> ToggleableComponent {
        guard let component = toggleableComponents.first(where: { $0.feature == feature }) else {
            fatalError("Component not found for feature: \(feature). Please ensure all features have corresponding components.")
        }
        return component
    }
    
    /// 取得所有必要元件
    var requiredComponents: [CarComponent] {
        var components: [CarComponent] = []
        components.append(contentsOf: wheels as [CarComponent])
        components.append(contentsOf: [engine, battery, centralComputer] as [CarComponent])
        return components
    }
    
    /// 取得所有選配元件
    var optionalComponents: [CarComponent] {
        toggleableComponents as [CarComponent]
    }
    
    // MARK: - 初始化
    
    init() {
        // 必要元件
        self.wheels = [Wheel(), Wheel(), Wheel(), Wheel()]
        self.engine = Engine()
        self.battery = Battery()
        self.centralComputer = CentralComputer()
        
        // 選配元件
        self.airConditioner = AirConditioner()
        self.navigationSystem = NavigationSystem()
        self.entertainmentSystem = EntertainmentSystem()
        self.bluetoothSystem = BluetoothSystem()
        self.rearCamera = RearCamera()
        self.surroundViewCamera = SurroundViewCamera()
        self.blindSpotDetection = BlindSpotDetection()
        self.frontRadar = FrontRadar()
        self.parkingAssist = ParkingAssist()
        self.laneKeeping = LaneKeeping()
        self.emergencyBraking = EmergencyBraking()
        self.autoPilot = AutoPilot()
        
        setupBindings()
    }
    
    // MARK: - Combine 綁定
    
    private func setupBindings() {
        centralComputer.$isOn
            .sink { [weak self] isOn in
                guard let self = self else { return }
                self.isComputerOn = isOn
                if !isOn { self.onCentralComputerOff() }
            }
            .store(in: &cancellables)
        
        engine.$isRunning
            .sink { [weak self] isRunning in
                guard let self = self else { return }
                self.isEngineRunning = isRunning
                if !isRunning { self.onEngineStop() }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 元件控制 API
    
    /// 切換中控電腦狀態
    func toggleCentralComputer() {
        if centralComputer.isOn {
            centralComputer.turnOff()
        } else {
            centralComputer.turnOn()
        }
    }
    
    /// 切換引擎狀態
    func toggleEngine() {
        if engine.isRunning {
            engine.stop()
        } else {
            engine.start()
        }
    }
    
    // MARK: - 功能管理 API
    
    func isFeatureEnabled(_ feature: Feature) -> Bool {
        enabledFeatures.contains(feature)
    }
    
    @discardableResult
    func enable(_ feature: Feature) -> Result<Void, FeatureError> {
        let comp = component(for: feature)
        
        if isFeatureEnabled(feature) {
            return .failure(.featureAlreadyEnabled)
        }
        
        if comp.requiresCentralComputer && !centralComputer.isOn {
            return .failure(.centralComputerOff)
        }
        
        if comp.requiresEngineRunning && !engine.isRunning {
            return .failure(.engineNotRunning)
        }
        
        for dep in comp.dependencies {
            if !isFeatureEnabled(dep) {
                return .failure(.dependencyNotEnabled(dep))
            }
        }
        
        enabledFeatures.insert(feature)
        return .success(())
    }
    
    @discardableResult
    func disable(_ feature: Feature) -> Result<Void, FeatureError> {
        if !isFeatureEnabled(feature) {
            return .failure(.featureAlreadyDisabled)
        }
        cascadeDisable(feature)
        return .success(())
    }
    
    var enabledFeaturesList: [Feature] {
        Array(enabledFeatures).sorted { $0.rawValue < $1.rawValue }
    }
    
    // MARK: - 私有方法
    
    private func cascadeDisable(_ feature: Feature) {
        let dependents = toggleableComponents.filter {
            $0.dependencies.contains(feature) && isFeatureEnabled($0.feature)
        }
        
        for dependent in dependents {
            cascadeDisable(dependent.feature)
        }
        
        enabledFeatures.remove(feature)
    }
    
    func getDependents(of feature: Feature) -> [Feature] {
        toggleableComponents
            .filter { $0.dependencies.contains(feature) && isFeatureEnabled($0.feature) }
            .map { $0.feature }
    }
    
    private func onCentralComputerOff() {
        let toDisable = toggleableComponents.filter {
            $0.requiresCentralComputer && isFeatureEnabled($0.feature)
        }
        for comp in toDisable {
            cascadeDisable(comp.feature)
        }
    }
    
    private func onEngineStop() {
        let toDisable = toggleableComponents.filter {
            $0.requiresEngineRunning && isFeatureEnabled($0.feature)
        }
        for comp in toDisable {
            cascadeDisable(comp.feature)
        }
    }
}

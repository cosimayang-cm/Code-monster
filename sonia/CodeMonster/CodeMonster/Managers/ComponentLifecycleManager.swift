import Foundation

/// 管理 4 個基礎元件的生命週期
class ComponentLifecycleManager {
    
    // MARK: - Properties
    private let engine: Engine
    private let centralComputer: CentralComputer
    private let wheel: Wheel
    private let battery: Battery
    
    // MARK: - Initialization
    init(engine: Engine = Engine(),
         centralComputer: CentralComputer = CentralComputer(),
         wheel: Wheel = Wheel(),
         battery: Battery = Battery()) {
        self.engine = engine
        self.centralComputer = centralComputer
        self.wheel = wheel
        self.battery = battery
    }
    
    // MARK: - Engine Control
    func startEngine() {
        guard !engine.isActive else { return }
        engine.turnOn()
    }
    
    func stopEngine() {
        guard engine.isActive else { return }
        engine.turnOff()
    }
    
    var isEngineRunning: Bool {
        engine.isActive
    }
    
    // MARK: - Central Computer Control
    func turnOnCentralComputer() {
        guard !centralComputer.isActive else { return }
        centralComputer.turnOn()
    }
    
    func turnOffCentralComputer() {
        guard centralComputer.isActive else { return }
        centralComputer.turnOff()
    }
    
    var isCentralComputerOn: Bool {
        centralComputer.isActive
    }
}

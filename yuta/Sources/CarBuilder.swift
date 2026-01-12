/// 車輛建構器 (Builder Pattern)
/// 使用 Fluent API 逐步建構車輛
class CarBuilder {

    private let car: Car

    init() {
        car = Car()
        car.turnOnComputer()  // 預設開啟中控
    }

    // MARK: - 基本功能

    @discardableResult
    func withAirConditioner() -> CarBuilder {
        car.enable(.airConditioner)
        return self
    }

    @discardableResult
    func withNavigation() -> CarBuilder {
        car.enable(.navigation)
        return self
    }

    @discardableResult
    func withEntertainment() -> CarBuilder {
        car.enable(.entertainment)
        return self
    }

    @discardableResult
    func withBluetooth() -> CarBuilder {
        car.enable(.bluetooth)
        return self
    }

    // MARK: - 攝影功能

    @discardableResult
    func withRearCamera() -> CarBuilder {
        car.enable(.rearCamera)
        return self
    }

    @discardableResult
    func withSurroundView() -> CarBuilder {
        car.enable(.rearCamera)      // 自動啟用相依
        car.enable(.surroundView)
        return self
    }

    // MARK: - 安全功能

    @discardableResult
    func withBlindSpotDetection() -> CarBuilder {
        car.enable(.blindSpotDetection)
        return self
    }

    @discardableResult
    func withFrontRadar() -> CarBuilder {
        car.enable(.frontRadar)
        return self
    }

    @discardableResult
    func withParkingAssist() -> CarBuilder {
        car.enable(.rearCamera)
        car.enable(.surroundView)
        car.enable(.blindSpotDetection)
        car.enable(.parkingAssist)
        return self
    }

    // MARK: - 進階駕駛功能

    @discardableResult
    func withLaneKeeping() -> CarBuilder {
        car.enable(.navigation)
        car.enable(.frontRadar)
        car.startEngine()
        car.enable(.laneKeeping)
        return self
    }

    @discardableResult
    func withEmergencyBraking() -> CarBuilder {
        car.enable(.frontRadar)
        car.startEngine()
        car.enable(.emergencyBraking)
        return self
    }

    @discardableResult
    func withAutoPilot() -> CarBuilder {
        // 啟用所有 AutoPilot 相依功能
        car.enable(.rearCamera)
        car.enable(.surroundView)
        car.enable(.navigation)
        car.enable(.frontRadar)
        car.startEngine()
        car.enable(.laneKeeping)
        car.enable(.emergencyBraking)
        car.enable(.autoPilot)
        return self
    }

    // MARK: - 引擎

    @discardableResult
    func withEngineStarted() -> CarBuilder {
        car.startEngine()
        return self
    }

    // MARK: - Build

    func build() -> Car {
        return car
    }
}

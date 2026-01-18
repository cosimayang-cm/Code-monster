/// 車輛類別 (Facade Pattern)
/// 整合所有元件與 Feature Toggle 功能
class Car {

    // MARK: - 必要元件

    let wheels: [Wheel]
    var engine: Engine
    let battery: Battery
    var centralComputer: CentralComputer

    // MARK: - 選配元件

    let airConditioner = AirConditioner()
    let navigationSystem = NavigationSystem()
    let entertainmentSystem = EntertainmentSystem()
    let bluetoothSystem = BluetoothSystem()
    let rearCamera = RearCamera()
    let surroundViewCamera = SurroundViewCamera()
    let blindSpotDetection = BlindSpotDetection()
    let frontRadar = FrontRadar()
    let parkingAssist = ParkingAssist()
    let laneKeeping = LaneKeeping()
    let emergencyBraking = EmergencyBraking()
    let autoPilot = AutoPilot()

    // MARK: - Feature Toggle 狀態

    private var enabledFeatures: Set<Feature> = []

    // MARK: - 初始化

    init() {
        wheels = [
            Wheel(position: .frontLeft),
            Wheel(position: .frontRight),
            Wheel(position: .rearLeft),
            Wheel(position: .rearRight)
        ]
        engine = Engine()
        battery = Battery()
        centralComputer = CentralComputer()
    }

    // MARK: - 中控電腦控制

    var isComputerOn: Bool { centralComputer.isRunning }

    func turnOnComputer() {
        centralComputer.turnOn()
    }

    func turnOffComputer() {
        centralComputer.turnOff()
        // 連鎖停用所有功能
        enabledFeatures.removeAll()
    }

    // MARK: - 引擎控制

    var isEngineRunning: Bool { engine.isRunning }

    func startEngine() {
        engine.start()
    }

    func stopEngine() {
        engine.stop()
        // 連鎖停用需要引擎運行的功能
        disableFeaturesRequiringEngine()
    }

    // MARK: - Feature Toggle API

    /// 啟用功能
    @discardableResult
    func enable(_ feature: Feature) -> Result<Void, FeatureError> {
        // 1. 檢查中控電腦
        guard isComputerOn else {
            return .failure(.computerOff)
        }

        // 2. 檢查引擎（如果需要）
        if feature.requiresEngineRunning && !isEngineRunning {
            return .failure(.engineNotRunning)
        }

        // 3. 檢查前置功能
        let missing = feature.requiredFeatures.filter { !enabledFeatures.contains($0) }
        if !missing.isEmpty {
            return .failure(.missingDependencies(missing))
        }

        // 4. 啟用
        enabledFeatures.insert(feature)
        return .success(())
    }

    /// 停用功能（連鎖停用依賴者）
    func disable(_ feature: Feature) {
        guard enabledFeatures.contains(feature) else { return }

        // 1. 找出所有依賴此功能的功能，並遞迴停用
        for f in Feature.allCases where f.requiredFeatures.contains(feature) {
            disable(f)
        }

        // 2. 停用本功能
        enabledFeatures.remove(feature)
    }

    /// 查詢功能是否啟用
    func isEnabled(_ feature: Feature) -> Bool {
        enabledFeatures.contains(feature)
    }

    /// 取得所有已啟用功能
    func getEnabledFeatures() -> [Feature] {
        Array(enabledFeatures)
    }

    // MARK: - Private

    private func disableFeaturesRequiringEngine() {
        for feature in Feature.allCases where feature.requiresEngineRunning {
            disable(feature)
        }
    }
}

// MARK: - CustomStringConvertible

extension Car: CustomStringConvertible {
    var description: String {
        let computer = isComputerOn ? "開啟" : "關閉"
        let engine = isEngineRunning ? "運行中" : "停止"
        let features = enabledFeatures.isEmpty
            ? "無"
            : enabledFeatures.map(\.displayName).joined(separator: ", ")

        return """
        === 車輛狀態 ===
        中控電腦: \(computer)
        引擎: \(engine)
        已啟用功能: \(features)
        """
    }
}

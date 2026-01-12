/// 預設車型
enum CarModel: String, CaseIterable {
    case basic      = "基本款"
    case standard   = "標準款"
    case premium    = "豪華款"
    case sport      = "運動款"
    case autonomous = "自駕款"
}

/// 車輛工廠 (Factory Pattern)
class CarFactory {

    /// 生產指定車型
    static func create(_ model: CarModel) -> Car {
        let builder = CarBuilder()

        switch model {
        case .basic:
            return builder.build()

        case .standard:
            return builder
                .withAirConditioner()
                .withEntertainment()
                .withBluetooth()
                .build()

        case .premium:
            return builder
                .withAirConditioner()
                .withEntertainment()
                .withBluetooth()
                .withNavigation()
                .withSurroundView()
                .build()

        case .sport:
            return builder
                .withAirConditioner()
                .withEntertainment()
                .withBluetooth()
                .withNavigation()
                .withSurroundView()
                .withBlindSpotDetection()
                .withFrontRadar()
                .build()

        case .autonomous:
            return builder
                .withAirConditioner()
                .withEntertainment()
                .withBluetooth()
                .withAutoPilot()
                .build()
        }
    }

    /// 批量生產
    static func createBatch(_ model: CarModel, count: Int) -> [Car] {
        (0..<count).map { _ in create(model) }
    }
}

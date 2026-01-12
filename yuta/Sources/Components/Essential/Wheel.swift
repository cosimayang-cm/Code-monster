/// 車輪（必要元件）
struct Wheel: CarComponent {
    enum Position: String {
        case frontLeft = "左前"
        case frontRight = "右前"
        case rearLeft = "左後"
        case rearRight = "右後"
    }

    let position: Position
    var name: String { "車輪(\(position.rawValue))" }
}

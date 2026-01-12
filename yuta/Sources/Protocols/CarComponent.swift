/// 車輛元件協定
protocol CarComponent {
    var name: String { get }
}

/// 可運行的元件（如引擎、中控電腦）
protocol Runnable {
    var isRunning: Bool { get }
    mutating func start()
    mutating func stop()
}

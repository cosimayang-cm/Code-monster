/// 中控電腦（必要元件，可開關）
struct CentralComputer: CarComponent, Runnable {
    let name = "中控電腦"
    private(set) var isRunning = false

    mutating func start() { isRunning = true }
    mutating func stop() { isRunning = false }

    mutating func turnOn() { start() }
    mutating func turnOff() { stop() }
}

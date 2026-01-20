/// 引擎（必要元件，可啟動/停止）
struct Engine: CarComponent, Runnable {
    let name = "引擎"
    private(set) var isRunning = false

    mutating func start() { isRunning = true }
    mutating func stop() { isRunning = false }
}

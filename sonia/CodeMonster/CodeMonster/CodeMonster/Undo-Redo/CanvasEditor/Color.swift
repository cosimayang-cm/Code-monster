import Foundation

/// Color - UIKit-independent 顏色結構
/// 使用 RGBA 數值表示，可輕易轉換為 UIColor
struct Color: Equatable {

    // MARK: - Properties

    let red: Double    // 0.0 - 1.0
    let green: Double  // 0.0 - 1.0
    let blue: Double   // 0.0 - 1.0
    let alpha: Double  // 0.0 - 1.0

    // MARK: - Initialization

    init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red.clamped(to: 0...1)
        self.green = green.clamped(to: 0...1)
        self.blue = blue.clamped(to: 0...1)
        self.alpha = alpha.clamped(to: 0...1)
    }

    // MARK: - Predefined Colors

    static let clear = Color(red: 0, green: 0, blue: 0, alpha: 0)
    static let black = Color(red: 0, green: 0, blue: 0, alpha: 1)
    static let white = Color(red: 1, green: 1, blue: 1, alpha: 1)
    static let red = Color(red: 1, green: 0, blue: 0, alpha: 1)
    static let green = Color(red: 0, green: 1, blue: 0, alpha: 1)
    static let blue = Color(red: 0, green: 0, blue: 1, alpha: 1)
}

// MARK: - Double Extension

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}

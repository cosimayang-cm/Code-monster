import Foundation

/// Foundation-only color representation.
///
/// This type allows the Model layer to remain independent of UIKit/AppKit.
/// Use Color+UIKit extension (in View layer) to convert to UIColor when needed.
///
/// Design rationale:
/// - Model layer must not import UIKit or CoreGraphics
/// - RGBA components provide full color specification
/// - Can be easily converted to platform-specific colors in View layer
public struct Color: Equatable, Hashable, Codable {
    // MARK: - Properties

    /// Red component (0.0 to 1.0)
    public let red: Double

    /// Green component (0.0 to 1.0)
    public let green: Double

    /// Blue component (0.0 to 1.0)
    public let blue: Double

    /// Alpha (opacity) component (0.0 to 1.0)
    public let alpha: Double

    // MARK: - Initialization

    /// Creates a color with RGBA components.
    ///
    /// - Parameters:
    ///   - red: Red component (0.0 to 1.0)
    ///   - green: Green component (0.0 to 1.0)
    ///   - blue: Blue component (0.0 to 1.0)
    ///   - alpha: Alpha component (0.0 to 1.0), defaults to 1.0 (opaque)
    public init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red.clamped(to: 0.0...1.0)
        self.green = green.clamped(to: 0.0...1.0)
        self.blue = blue.clamped(to: 0.0...1.0)
        self.alpha = alpha.clamped(to: 0.0...1.0)
    }

    // MARK: - Predefined Colors

    public static let black = Color(red: 0, green: 0, blue: 0)
    public static let white = Color(red: 1, green: 1, blue: 1)
    public static let red = Color(red: 1, green: 0, blue: 0)
    public static let green = Color(red: 0, green: 1, blue: 0)
    public static let blue = Color(red: 0, green: 0, blue: 1)
    public static let yellow = Color(red: 1, green: 1, blue: 0)
    public static let cyan = Color(red: 0, green: 1, blue: 1)
    public static let magenta = Color(red: 1, green: 0, blue: 1)
    public static let orange = Color(red: 1, green: 0.5, blue: 0)
    public static let purple = Color(red: 0.5, green: 0, blue: 0.5)
    public static let gray = Color(red: 0.5, green: 0.5, blue: 0.5)
    public static let clear = Color(red: 0, green: 0, blue: 0, alpha: 0)
}

// MARK: - Double Extension

private extension Double {
    /// Clamps a value to the specified range.
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

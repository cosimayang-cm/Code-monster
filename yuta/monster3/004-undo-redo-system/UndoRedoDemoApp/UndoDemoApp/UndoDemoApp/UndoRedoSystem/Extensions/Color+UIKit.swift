#if canImport(UIKit)
import UIKit

/// Extension to bridge Foundation-only Color to UIKit's UIColor.
///
/// This extension provides conversion between the Model layer's Color type
/// and UIKit's UIColor for use in the View layer.
///
/// Design rationale:
/// - Model layer uses Foundation-only Color (no UIKit dependency)
/// - View layer needs UIColor for rendering
/// - Extension provides clean separation and type conversion
///
/// Usage:
/// ```swift
/// let modelColor = Color.red
/// let uiColor = modelColor.uiColor  // Convert to UIColor
///
/// let uiColor = UIColor.systemBlue
/// let modelColor = Color(uiColor: uiColor)  // Convert from UIColor
/// ```
extension Color {
    /// Converts this Color to UIColor.
    ///
    /// - Returns: A UIColor with the same RGBA values
    public var uiColor: UIColor {
        UIColor(
            red: CGFloat(red),
            green: CGFloat(green),
            blue: CGFloat(blue),
            alpha: CGFloat(alpha)
        )
    }

    /// Creates a Color from a UIColor.
    ///
    /// - Parameter uiColor: The UIColor to convert
    public init(uiColor: UIColor) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        // Extract RGBA components from UIColor
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)

        self.init(
            red: Double(r),
            green: Double(g),
            blue: Double(b),
            alpha: Double(a)
        )
    }
}
#endif

#if canImport(CoreGraphics)
import CoreGraphics

/// Extension to bridge Foundation-only Point to CoreGraphics' CGPoint.
///
/// This extension provides conversion between the Model layer's Point type
/// and CoreGraphics' CGPoint for use in the View layer.
///
/// Design rationale:
/// - Model layer uses Foundation-only Point (no CoreGraphics dependency)
/// - View layer needs CGPoint for rendering and geometry calculations
/// - Extension provides clean separation and type conversion
///
/// Usage:
/// ```swift
/// let modelPoint = Point(x: 100, y: 200)
/// let cgPoint = modelPoint.cgPoint  // Convert to CGPoint
///
/// let cgPoint = CGPoint(x: 50, y: 75)
/// let modelPoint = Point(cgPoint: cgPoint)  // Convert from CGPoint
/// ```
extension Point {
    /// Converts this Point to CGPoint.
    ///
    /// - Returns: A CGPoint with the same x and y coordinates
    public var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }

    /// Creates a Point from a CGPoint.
    ///
    /// - Parameter cgPoint: The CGPoint to convert
    public init(cgPoint: CGPoint) {
        self.init(x: Double(cgPoint.x), y: Double(cgPoint.y))
    }
}
#endif

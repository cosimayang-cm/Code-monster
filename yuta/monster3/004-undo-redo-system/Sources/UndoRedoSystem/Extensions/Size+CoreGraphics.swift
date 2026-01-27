#if canImport(CoreGraphics)
import CoreGraphics

/// Extension to bridge Foundation-only Size to CoreGraphics' CGSize.
///
/// This extension provides conversion between the Model layer's Size type
/// and CoreGraphics' CGSize for use in the View layer.
///
/// Design rationale:
/// - Model layer uses Foundation-only Size (no CoreGraphics dependency)
/// - View layer needs CGSize for rendering and layout
/// - Extension provides clean separation and type conversion
///
/// Usage:
/// ```swift
/// let modelSize = Size(width: 100, height: 200)
/// let cgSize = modelSize.cgSize  // Convert to CGSize
///
/// let cgSize = CGSize(width: 50, height: 75)
/// let modelSize = Size(cgSize: cgSize)  // Convert from CGSize
/// ```
extension Size {
    /// Converts this Size to CGSize.
    ///
    /// - Returns: A CGSize with the same width and height
    public var cgSize: CGSize {
        CGSize(width: width, height: height)
    }

    /// Creates a Size from a CGSize.
    ///
    /// - Parameter cgSize: The CGSize to convert
    public init(cgSize: CGSize) {
        self.init(width: Double(cgSize.width), height: Double(cgSize.height))
    }
}
#endif

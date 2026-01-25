import Foundation

/// Foundation-only 2D size representation.
///
/// This type allows the Model layer to remain independent of CoreGraphics.
/// Use Size+CoreGraphics extension (in View layer) to convert to CGSize when needed.
///
/// Design rationale:
/// - Model layer must not import CoreGraphics
/// - Represents dimensions in 2D space
/// - Can be easily converted to CGSize in View layer
public struct Size: Equatable, Hashable, Codable {
    // MARK: - Properties

    /// Width dimension
    public let width: Double

    /// Height dimension
    public let height: Double

    // MARK: - Initialization

    /// Creates a size with the specified dimensions.
    ///
    /// - Parameters:
    ///   - width: The width (non-negative)
    ///   - height: The height (non-negative)
    ///
    /// - Note: Negative values are clamped to 0
    public init(width: Double, height: Double) {
        self.width = max(0, width)
        self.height = max(0, height)
    }

    // MARK: - Predefined Sizes

    /// The zero size (0, 0)
    public static let zero = Size(width: 0, height: 0)

    // MARK: - Computed Properties

    /// The area of the size (width × height)
    public var area: Double {
        width * height
    }

    /// Whether this size has zero area
    public var isEmpty: Bool {
        width == 0 || height == 0
    }

    /// The aspect ratio (width / height)
    ///
    /// Returns nil if height is zero
    public var aspectRatio: Double? {
        guard height != 0 else { return nil }
        return width / height
    }

    // MARK: - Operations

    /// Scales the size by the specified factor.
    ///
    /// - Parameter factor: The scaling factor
    /// - Returns: A new size with both dimensions scaled
    public func scaled(by factor: Double) -> Size {
        Size(width: width * factor, height: height * factor)
    }
}

// MARK: - CustomStringConvertible

extension Size: CustomStringConvertible {
    public var description: String {
        "\(width) × \(height)"
    }
}

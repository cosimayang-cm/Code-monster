import Foundation

/// Foundation-only 2D point representation.
///
/// This type allows the Model layer to remain independent of CoreGraphics.
/// Use Point+CoreGraphics extension (in View layer) to convert to CGPoint when needed.
///
/// Design rationale:
/// - Model layer must not import CoreGraphics
/// - Represents position in 2D coordinate space
/// - Can be easily converted to CGPoint in View layer
public struct Point: Equatable, Hashable, Codable {
    // MARK: - Properties

    /// X coordinate
    public let x: Double

    /// Y coordinate
    public let y: Double

    // MARK: - Initialization

    /// Creates a point at the specified coordinates.
    ///
    /// - Parameters:
    ///   - x: The x-coordinate
    ///   - y: The y-coordinate
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    // MARK: - Predefined Points

    /// The origin point (0, 0)
    public static let zero = Point(x: 0, y: 0)

    // MARK: - Operations

    /// Calculates the distance to another point.
    ///
    /// - Parameter other: The other point
    /// - Returns: The Euclidean distance between the two points
    public func distance(to other: Point) -> Double {
        let dx = x - other.x
        let dy = y - other.y
        return sqrt(dx * dx + dy * dy)
    }

    /// Translates the point by the specified offset.
    ///
    /// - Parameters:
    ///   - dx: The x-offset
    ///   - dy: The y-offset
    /// - Returns: A new point with the offset applied
    public func offset(dx: Double, dy: Double) -> Point {
        Point(x: x + dx, y: y + dy)
    }
}

// MARK: - CustomStringConvertible

extension Point: CustomStringConvertible {
    public var description: String {
        "(\(x), \(y))"
    }
}

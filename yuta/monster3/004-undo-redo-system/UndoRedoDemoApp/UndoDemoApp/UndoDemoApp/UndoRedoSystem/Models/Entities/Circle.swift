import Foundation

/// Circle 圓形圖形
///
/// 使用 position 作為圓心座標，radius 定義半徑。
/// 支援填充顏色和邊框顏色。
///
/// Design rationale:
/// - Foundation-only implementation
/// - Reference type (class) 以支援 Command Pattern 的狀態修改
/// - 實作 deep copy 以支援 Memento Pattern
public final class Circle: Shape {
    // MARK: - Properties

    public let id: UUID
    public var position: Point // 圓心
    public var radius: Double
    public var fillColor: Color?
    public var strokeColor: Color?

    // MARK: - Initialization

    /// 建立圓形圖形
    ///
    /// - Parameters:
    ///   - position: 圓心座標
    ///   - radius: 半徑
    ///   - fillColor: 填充顏色（nil 表示無填充）
    ///   - strokeColor: 邊框顏色（nil 表示無邊框）
    public init(
        position: Point,
        radius: Double,
        fillColor: Color? = nil,
        strokeColor: Color? = nil
    ) {
        self.id = UUID()
        self.position = position
        self.radius = radius
        self.fillColor = fillColor
        self.strokeColor = strokeColor
    }

    // MARK: - Shape Protocol

    public func copy() -> Shape {
        Circle(
            position: position,
            radius: radius,
            fillColor: fillColor,
            strokeColor: strokeColor
        )
    }
}

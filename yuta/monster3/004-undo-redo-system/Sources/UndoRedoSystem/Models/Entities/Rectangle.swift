import Foundation

/// Rectangle 矩形圖形
///
/// 使用 position 作為左上角座標，size 定義寬高。
/// 支援填充顏色和邊框顏色。
///
/// Design rationale:
/// - Foundation-only implementation
/// - Reference type (class) 以支援 Command Pattern 的狀態修改
/// - 實作 deep copy 以支援 Memento Pattern
public final class Rectangle: Shape {
    // MARK: - Properties

    public let id: UUID
    public var position: Point
    public var size: Size
    public var fillColor: Color?
    public var strokeColor: Color?

    // MARK: - Initialization

    /// 建立矩形圖形
    ///
    /// - Parameters:
    ///   - position: 左上角座標
    ///   - size: 矩形大小
    ///   - fillColor: 填充顏色（nil 表示無填充）
    ///   - strokeColor: 邊框顏色（nil 表示無邊框）
    public init(
        position: Point,
        size: Size,
        fillColor: Color? = nil,
        strokeColor: Color? = nil
    ) {
        self.id = UUID()
        self.position = position
        self.size = size
        self.fillColor = fillColor
        self.strokeColor = strokeColor
    }

    // MARK: - Shape Protocol

    public func copy() -> Shape {
        Rectangle(
            position: position,
            size: size,
            fillColor: fillColor,
            strokeColor: strokeColor
        )
    }
}

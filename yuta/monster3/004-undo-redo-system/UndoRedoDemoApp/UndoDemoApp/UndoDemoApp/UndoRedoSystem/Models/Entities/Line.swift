import Foundation

/// Line 線條圖形
///
/// 使用 position 作為起點座標，endPoint 定義終點座標。
/// 線條不使用填充顏色，僅支援邊框顏色。
///
/// Design rationale:
/// - Foundation-only implementation
/// - Reference type (class) 以支援 Command Pattern 的狀態修改
/// - 實作 deep copy 以支援 Memento Pattern
/// - fillColor 保持為 nil，因為線條不需要填充
public final class Line: Shape {
    // MARK: - Properties

    public let id: UUID
    public var position: Point // 起點
    public var endPoint: Point // 終點
    public var fillColor: Color? // 線條不使用填充色，永遠為 nil
    public var strokeColor: Color?

    // MARK: - Initialization

    /// 建立線條圖形
    ///
    /// - Parameters:
    ///   - position: 起點座標
    ///   - endPoint: 終點座標
    ///   - strokeColor: 線條顏色（nil 表示無顏色）
    public init(
        position: Point,
        endPoint: Point,
        strokeColor: Color? = nil
    ) {
        self.id = UUID()
        self.position = position
        self.endPoint = endPoint
        self.fillColor = nil // 線條不使用填充色
        self.strokeColor = strokeColor
    }

    // MARK: - Shape Protocol

    public func copy() -> Shape {
        Line(
            position: position,
            endPoint: endPoint,
            strokeColor: strokeColor
        )
    }
}

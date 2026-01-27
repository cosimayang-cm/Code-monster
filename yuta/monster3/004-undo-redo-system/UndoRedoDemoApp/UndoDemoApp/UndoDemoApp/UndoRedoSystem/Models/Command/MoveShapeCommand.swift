import Foundation

/// MoveShapeCommand - 移動圖形命令
///
/// 實作 Command Pattern，將移動圖形操作封裝為可撤銷的命令。
///
/// Design rationale:
/// - 使用 weak reference 避免 retain cycle
/// - 透過 CanvasProtocol 解耦，提升可測試性
/// - 支援 Undo/Redo：execute 移動圖形，undo 反向移動圖形
/// - 保存位移量，undo 時使用反向位移
/// - Foundation-only implementation
public final class MoveShapeCommand: Command {
    // MARK: - Properties

    /// Canvas reference (weak to avoid retain cycle)
    private weak var canvas: CanvasProtocol?

    /// 要移動的圖形
    private let shape: Shape

    /// 位移量
    private let offset: Point

    // MARK: - Initialization

    /// 建立移動圖形命令
    ///
    /// - Parameters:
    ///   - canvas: 目標畫布（使用 weak reference）
    ///   - shape: 要移動的圖形
    ///   - offset: 位移量
    public init(canvas: CanvasProtocol, shape: Shape, offset: Point) {
        self.canvas = canvas
        self.shape = shape
        self.offset = offset
    }

    // MARK: - Command Protocol

    public func execute() {
        canvas?.move(shape: shape, by: offset)
    }

    public func undo() {
        // 反向移動：使用負位移
        let reverseOffset = Point(x: -offset.x, y: -offset.y)
        canvas?.move(shape: shape, by: reverseOffset)
    }

    public var description: String {
        let shapeType = type(of: shape)
        return "移動\(shapeType)圖形"
    }
}

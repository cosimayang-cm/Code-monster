import Foundation

/// AddShapeCommand - 新增圖形命令
///
/// 實作 Command Pattern，將新增圖形操作封裝為可撤銷的命令。
///
/// Design rationale:
/// - 使用 weak reference 避免 retain cycle
/// - 透過 CanvasProtocol 解耦，提升可測試性
/// - 支援 Undo/Redo：execute 新增圖形，undo 移除圖形
/// - Foundation-only implementation
public final class AddShapeCommand: Command {
    // MARK: - Properties

    /// Canvas reference (weak to avoid retain cycle)
    private weak var canvas: CanvasProtocol?

    /// 要新增的圖形
    private let shape: Shape

    // MARK: - Initialization

    /// 建立新增圖形命令
    ///
    /// - Parameters:
    ///   - canvas: 目標畫布（使用 weak reference）
    ///   - shape: 要新增的圖形
    public init(canvas: CanvasProtocol, shape: Shape) {
        self.canvas = canvas
        self.shape = shape
    }

    // MARK: - Command Protocol

    public func execute() {
        canvas?.add(shape: shape)
    }

    public func undo() {
        canvas?.remove(shape: shape)
    }

    public var description: String {
        let shapeType = type(of: shape)
        return "新增\(shapeType)圖形"
    }
}

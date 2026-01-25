import Foundation

/// ResizeShapeCommand - 縮放圖形命令
///
/// 實作 Command Pattern，將縮放圖形操作封裝為可撤銷的命令。
///
/// Design rationale:
/// - 使用 weak reference 避免 retain cycle
/// - 透過 CanvasProtocol 解耦，提升可測試性
/// - 支援 Undo/Redo：execute 縮放圖形，undo 還原尺寸
/// - Foundation-only implementation
/// - 使用 Memento Pattern 保存舊尺寸以支援 undo
public final class ResizeShapeCommand: Command {
    // MARK: - Properties

    /// Canvas reference (weak to avoid retain cycle)
    private weak var canvas: CanvasProtocol?

    /// 要縮放的圖形
    private let shape: Shape

    /// 新的尺寸
    private let newSize: Size

    /// 舊的尺寸（用於 undo）
    private let oldSize: Size

    // MARK: - Initialization

    /// 建立縮放圖形命令
    ///
    /// - Parameters:
    ///   - canvas: 目標畫布（使用 weak reference）
    ///   - shape: 要縮放的圖形
    ///   - newSize: 新的尺寸
    public init(canvas: CanvasProtocol, shape: Shape, newSize: Size) {
        self.canvas = canvas
        self.shape = shape
        self.newSize = newSize

        // 保存舊尺寸以支援 undo
        if let rectangle = shape as? Rectangle {
            self.oldSize = rectangle.size
        } else if let circle = shape as? Circle {
            // Circle 使用 diameter 作為 size
            self.oldSize = Size(width: circle.radius * 2, height: circle.radius * 2)
        } else {
            // Line 不支援縮放，使用 zero size
            self.oldSize = Size.zero
        }
    }

    // MARK: - Command Protocol

    public func execute() {
        canvas?.resize(shape: shape, to: newSize)
    }

    public func undo() {
        canvas?.resize(shape: shape, to: oldSize)
    }

    public var description: String {
        let shapeType = type(of: shape)
        return "縮放\(shapeType)圖形"
    }
}

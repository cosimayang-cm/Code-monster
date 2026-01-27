import Foundation

/// ChangeStrokeColorCommand - 變更邊框顏色命令
///
/// 實作 Command Pattern，將變更邊框顏色操作封裝為可撤銷的命令。
///
/// Design rationale:
/// - 使用 weak reference 避免 retain cycle
/// - 透過 CanvasProtocol 解耦，提升可測試性
/// - 支援 Undo/Redo：execute 變更顏色，undo 還原顏色
/// - Foundation-only implementation
/// - 使用 Memento Pattern 保存舊顏色以支援 undo
public final class ChangeStrokeColorCommand: Command {
    // MARK: - Properties

    /// Canvas reference (weak to avoid retain cycle)
    private weak var canvas: CanvasProtocol?

    /// 要變更的圖形
    private let shape: Shape

    /// 新的邊框顏色（nil 表示清除邊框）
    private let newColor: Color?

    /// 舊的邊框顏色（用於 undo）
    private let oldColor: Color?

    // MARK: - Initialization

    /// 建立變更邊框顏色命令
    ///
    /// - Parameters:
    ///   - canvas: 目標畫布（使用 weak reference）
    ///   - shape: 要變更的圖形
    ///   - newColor: 新的邊框顏色（nil 表示清除邊框）
    public init(canvas: CanvasProtocol, shape: Shape, newColor: Color?) {
        self.canvas = canvas
        self.shape = shape
        self.newColor = newColor
        self.oldColor = shape.strokeColor
    }

    // MARK: - Command Protocol

    public func execute() {
        canvas?.changeColor(shape: shape, fillColor: nil, strokeColor: .some(newColor))
    }

    public func undo() {
        canvas?.changeColor(shape: shape, fillColor: nil, strokeColor: .some(oldColor))
    }

    public var description: String {
        let shapeType = type(of: shape)
        return "變更邊框顏色 (\(shapeType))"
    }
}

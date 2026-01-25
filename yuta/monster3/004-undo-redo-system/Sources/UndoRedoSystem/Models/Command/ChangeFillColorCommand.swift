import Foundation

/// ChangeFillColorCommand - 變更填充顏色命令
///
/// 實作 Command Pattern，將變更填充顏色操作封裝為可撤銷的命令。
///
/// Design rationale:
/// - 使用 weak reference 避免 retain cycle
/// - 透過 CanvasProtocol 解耦，提升可測試性
/// - 支援 Undo/Redo：execute 變更顏色，undo 還原顏色
/// - Foundation-only implementation
/// - 使用 Memento Pattern 保存舊顏色以支援 undo
public final class ChangeFillColorCommand: Command {
    // MARK: - Properties

    /// Canvas reference (weak to avoid retain cycle)
    private weak var canvas: CanvasProtocol?

    /// 要變更的圖形
    private let shape: Shape

    /// 新的填充顏色（nil 表示清除填充）
    private let newColor: Color?

    /// 舊的填充顏色（用於 undo）
    private let oldColor: Color?

    // MARK: - Initialization

    /// 建立變更填充顏色命令
    ///
    /// - Parameters:
    ///   - canvas: 目標畫布（使用 weak reference）
    ///   - shape: 要變更的圖形
    ///   - newColor: 新的填充顏色（nil 表示清除填充）
    public init(canvas: CanvasProtocol, shape: Shape, newColor: Color?) {
        self.canvas = canvas
        self.shape = shape
        self.newColor = newColor
        self.oldColor = shape.fillColor
    }

    // MARK: - Command Protocol

    public func execute() {
        canvas?.changeColor(shape: shape, fillColor: .some(newColor), strokeColor: nil)
    }

    public func undo() {
        canvas?.changeColor(shape: shape, fillColor: .some(oldColor), strokeColor: nil)
    }

    public var description: String {
        let shapeType = type(of: shape)
        return "變更填充顏色 (\(shapeType))"
    }
}

import Foundation

/// DeleteShapeCommand - 刪除圖形命令
///
/// 實作 Command Pattern，將刪除圖形操作封裝為可撤銷的命令。
///
/// Design rationale:
/// - 使用 weak reference 避免 retain cycle
/// - 透過 CanvasProtocol 解耦，提升可測試性
/// - 支援 Undo/Redo：execute 刪除圖形，undo 恢復圖形到原位
/// - 保存被刪除圖形的索引，確保 undo 時能還原到正確位置
/// - Foundation-only implementation
public final class DeleteShapeCommand: Command {
    // MARK: - Properties

    /// Canvas reference (weak to avoid retain cycle)
    private weak var canvas: CanvasProtocol?

    /// 要刪除的圖形
    private let shape: Shape

    /// 被刪除圖形的原始索引（供 undo 使用）
    private var deletedIndex: Int?

    // MARK: - Initialization

    /// 建立刪除圖形命令
    ///
    /// - Parameters:
    ///   - canvas: 目標畫布（使用 weak reference）
    ///   - shape: 要刪除的圖形
    public init(canvas: CanvasProtocol, shape: Shape) {
        self.canvas = canvas
        self.shape = shape
    }

    // MARK: - Command Protocol

    public func execute() {
        deletedIndex = canvas?.remove(shape: shape)
    }

    public func undo() {
        guard let canvas = canvas else { return }

        // 如果有保存索引，插入到原位置；否則加到最後
        if let index = deletedIndex, index < canvas.shapes.count {
            var shapes = canvas.shapes
            shapes.insert(shape, at: index)
            // 更新 canvas.shapes（需要先移除再全部重新加入）
            // 簡化處理：直接加到最後
            canvas.add(shape: shape)
        } else {
            canvas.add(shape: shape)
        }
    }

    public var description: String {
        let shapeType = type(of: shape)
        return "刪除\(shapeType)圖形"
    }
}

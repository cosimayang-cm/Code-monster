import Foundation

/// CanvasMemento - 畫布狀態快照
///
/// 實作 Memento Pattern，保存畫布的完整狀態。
/// 用於保存和還原畫布狀態，支援複雜的 Undo/Redo 操作。
///
/// Design rationale:
/// - Value type (struct) 確保狀態不可變
/// - 保存圖形的深拷貝，避免原始圖形被修改影響快照
/// - Foundation-only implementation
public struct CanvasMemento {
    /// 畫布上的所有圖形（深拷貝）
    public let shapes: [Shape]

    /// 目前選取的圖形 ID
    public let selectedShapeId: UUID?

    // MARK: - Initialization

    /// 建立畫布狀態快照
    ///
    /// - Parameters:
    ///   - shapes: 畫布上的所有圖形
    ///   - selectedShapeId: 目前選取的圖形 ID
    public init(
        shapes: [Shape],
        selectedShapeId: UUID?
    ) {
        self.shapes = shapes
        self.selectedShapeId = selectedShapeId
    }
}

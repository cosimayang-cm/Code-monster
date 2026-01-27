//
//  CanvasMemento.swift
//  CarSystem
//
//  Code Monster #3: Undo/Redo 系統
//  畫布快照 (Memento)
//

import Foundation

/// 畫布快照 - Memento Pattern
///
/// 保存 `Canvas` 的完整狀態，可用於：
/// - 複雜批次操作的撤銷
/// - 跳轉到特定歷史版本
/// - 自動儲存功能
///
/// ## 使用範例
/// ```swift
/// // 建立快照
/// let memento = canvas.createMemento()
///
/// // 執行一些操作...
/// canvas.add(circle)
/// canvas.add(rectangle)
///
/// // 還原快照
/// canvas.restore(from: memento)
/// ```
///
struct CanvasMemento: Equatable, Codable {
    
    /// 所有圖形的快照
    let shapeSnapshots: [ShapeSnapshot]
    
    /// 選取的圖形 ID
    let selectedShapeId: UUID?
    
    /// 快照建立時間
    let timestamp: Date
    
    // MARK: - Computed Properties
    
    /// 圖形數量
    var shapeCount: Int { shapeSnapshots.count }
    
    /// 是否為空畫布
    var isEmpty: Bool { shapeSnapshots.isEmpty }
}

// MARK: - CustomStringConvertible

extension CanvasMemento: CustomStringConvertible {
    var description: String {
        let selected = selectedShapeId?.uuidString.prefix(8) ?? "none"
        return "CanvasMemento(shapes: \(shapeCount), selected: \(selected))"
    }
}

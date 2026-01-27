//
//  Canvas.swift
//  CarSystem
//
//  Code Monster #3: Undo/Redo 系統
//  畫布模型 (Receiver)
//

import Foundation
import Combine

/// 畫布模型 - Command Pattern 的 Receiver
///
/// 負責管理畫布上的所有圖形，提供基本的 CRUD 方法供 Command 呼叫。
/// 使用 `@Published` 讓 UI 可以即時反映變更。
///
/// ## 使用範例
/// ```swift
/// let canvas = Canvas()
/// let circle = Circle(position: Point(x: 100, y: 100), radius: 50)
/// canvas.add(circle)
///
/// canvas.select(shapeId: circle.id)
/// print(canvas.selectedShape?.typeName)  // "圓形"
/// ```
///
final class Canvas: ObservableObject {
    
    // MARK: - Published Properties
    
    /// 畫布上的所有圖形
    @Published private(set) var shapes: [Shape] = []
    
    /// 目前選取的圖形 ID
    @Published private(set) var selectedShapeId: UUID?
    
    // MARK: - Computed Properties
    
    /// 目前選取的圖形
    var selectedShape: Shape? {
        guard let id = selectedShapeId else { return nil }
        return shape(withId: id)
    }
    
    /// 圖形數量
    var count: Int { shapes.count }
    
    /// 畫布是否為空
    var isEmpty: Bool { shapes.isEmpty }
    
    // MARK: - Initialization
    
    /// 初始化空畫布
    init() {}
    
    // MARK: - Shape Operations
    
    /// 新增圖形
    ///
    /// - Parameter shape: 要新增的圖形
    func add(_ shape: Shape) {
        shapes.append(shape)
    }
    
    /// 在指定位置插入圖形（用於 Undo 還原順序）
    ///
    /// - Parameters:
    ///   - shape: 要插入的圖形
    ///   - index: 插入位置
    func insert(_ shape: Shape, at index: Int) {
        let safeIndex = min(max(index, 0), shapes.count)
        shapes.insert(shape, at: safeIndex)
    }
    
    /// 移除圖形
    ///
    /// - Parameter shapeId: 要移除的圖形 ID
    /// - Returns: 被移除的圖形及其索引位置（供 Undo 使用），若找不到則回傳 nil
    @discardableResult
    func remove(shapeId: UUID) -> (shape: Shape, index: Int)? {
        guard let index = shapes.firstIndex(where: { $0.id == shapeId }) else {
            return nil
        }
        let shape = shapes.remove(at: index)
        
        // 若移除的是選取中的圖形，清除選取
        if selectedShapeId == shapeId {
            selectedShapeId = nil
        }
        
        return (shape, index)
    }
    
    /// 取得指定 ID 的圖形
    ///
    /// - Parameter id: 圖形 ID
    /// - Returns: 圖形，若找不到則回傳 nil
    func shape(withId id: UUID) -> Shape? {
        return shapes.first { $0.id == id }
    }
    
    /// 取得圖形在陣列中的索引
    ///
    /// - Parameter id: 圖形 ID
    /// - Returns: 索引，若找不到則回傳 nil
    func index(of id: UUID) -> Int? {
        return shapes.firstIndex { $0.id == id }
    }
    
    // MARK: - Selection
    
    /// 選取圖形
    ///
    /// - Parameter shapeId: 要選取的圖形 ID，傳 nil 可清除選取
    func select(shapeId: UUID?) {
        selectedShapeId = shapeId
    }
    
    /// 清除選取
    func clearSelection() {
        selectedShapeId = nil
    }
    
    // MARK: - Memento
    
    /// 建立畫布快照
    func createMemento() -> CanvasMemento {
        return CanvasMemento(
            shapeSnapshots: shapes.map { $0.snapshot() },
            selectedShapeId: selectedShapeId,
            timestamp: Date()
        )
    }
    
    /// 從快照還原
    func restore(from memento: CanvasMemento) {
        shapes = memento.shapeSnapshots.map { $0.restore() }
        selectedShapeId = memento.selectedShapeId
    }
    
    // MARK: - Bulk Operations

    /// 清空畫布
    func clear() {
        shapes.removeAll()
        selectedShapeId = nil
    }

    // MARK: - Change Notification

    /// 通知 Shape 屬性已變更，觸發 UI 更新
    ///
    /// 因為 `shapes` 是 reference type 陣列，當 Shape 內部屬性變更時
    /// （如 position、fillColor），`@Published` 不會自動觸發。
    /// Command 在修改 Shape 屬性後應呼叫此方法。
    func notifyShapesChanged() {
        objectWillChange.send()
    }
}

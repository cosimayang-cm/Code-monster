import Foundation

/// Canvas 畫布模型（Receiver）
///
/// 管理圖形的集合和操作，是 Command Pattern 中的 Receiver。
/// 支援圖形新增、刪除、移動、縮放、顏色變更等操作。
///
/// Design rationale:
/// - Foundation-only implementation
/// - Reference type (class) 以支援 Command Pattern
/// - 實作 CanvasProtocol 以解耦 Commands
/// - 支援 Memento Pattern 以保存和還原狀態
public final class Canvas: CanvasProtocol {
    // MARK: - Properties

    /// 畫布上的所有圖形
    private(set) public var shapes: [Shape] = []

    /// 目前選取的圖形 ID
    public var selectedShapeId: UUID?

    // MARK: - Initialization

    public init() {}

    // MARK: - Shape Operations

    /// 新增圖形到畫布
    ///
    /// - Parameter shape: 要新增的圖形
    public func add(shape: Shape) {
        shapes.append(shape)
    }

    /// 從畫布移除圖形
    ///
    /// - Parameter shape: 要移除的圖形
    /// - Returns: 圖形在陣列中的索引（供 undo 使用），nil 表示圖形不存在
    @discardableResult
    public func remove(shape: Shape) -> Int? {
        guard let index = shapes.firstIndex(where: { $0.id == shape.id }) else {
            return nil
        }
        shapes.remove(at: index)
        return index
    }

    /// 移動圖形
    ///
    /// - Parameters:
    ///   - shape: 要移動的圖形
    ///   - offset: 位移量
    public func move(shape: Shape, by offset: Point) {
        // 因為 Point 是 immutable struct，需要建立新的 Point 並賦值
        let newPosition = Point(
            x: shape.position.x + offset.x,
            y: shape.position.y + offset.y
        )
        shape.position = newPosition
    }

    /// 縮放圖形
    ///
    /// - Parameters:
    ///   - shape: 要縮放的圖形
    ///   - size: 新的大小
    public func resize(shape: Shape, to size: Size) {
        if let rectangle = shape as? Rectangle {
            rectangle.size = size
        } else if let circle = shape as? Circle {
            // 使用寬度的一半作為半徑
            circle.radius = size.width / 2
        }
        // Line 不支援 resize，忽略
    }

    /// 變更圖形顏色
    ///
    /// - Parameters:
    ///   - shape: 要變更的圖形
    ///   - fillColor: 填充顏色（nil 表示不變更，Optional.some(nil) 表示清除填充）
    ///   - strokeColor: 邊框顏色（nil 表示不變更，Optional.some(nil) 表示清除邊框）
    public func changeColor(
        shape: Shape,
        fillColor: Color?? = nil,
        strokeColor: Color?? = nil
    ) {
        // Line 不支援填充顏色，忽略 fillColor 參數
        if let fill = fillColor, !(shape is Line) {
            shape.fillColor = fill
        }
        if let stroke = strokeColor {
            shape.strokeColor = stroke
        }
    }

    /// 根據 ID 尋找圖形
    ///
    /// - Parameter id: 圖形 ID
    /// - Returns: 找到的圖形，不存在則為 nil
    public func findShape(by id: UUID) -> Shape? {
        shapes.first { $0.id == id }
    }

    // MARK: - Memento Support

    /// 建立當前狀態的快照
    ///
    /// 執行深拷貝以確保快照不受後續修改影響。
    ///
    /// - Returns: 畫布狀態的 Memento
    public func createMemento() -> CanvasMemento {
        // Deep copy shapes
        let shapesCopy = shapes.map { $0.copy() }
        return CanvasMemento(
            shapes: shapesCopy,
            selectedShapeId: selectedShapeId
        )
    }

    /// 從快照還原狀態
    ///
    /// 執行深拷貝以確保還原後的狀態獨立於 Memento。
    ///
    /// - Parameter memento: 要還原的狀態快照
    public func restore(from memento: CanvasMemento) {
        self.shapes = memento.shapes.map { $0.copy() }
        self.selectedShapeId = memento.selectedShapeId
    }
}

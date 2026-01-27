import Foundation
@testable import UndoRedoSystem

/// MockCanvas - Canvas 的 Mock 實作
///
/// 用於測試 Commands 和 ViewModels，提供可控制的測試環境。
///
/// Design rationale:
/// - 實作 CanvasProtocol 以支援 dependency injection
/// - 追蹤方法呼叫以驗證行為
/// - Foundation-only implementation
final class MockCanvas: CanvasProtocol {
    // MARK: - CanvasProtocol Properties

    private(set) var shapes: [Shape] = []
    var selectedShapeId: UUID?

    // MARK: - Method Call Tracking

    private(set) var addShapeCalled = false
    private(set) var removeShapeCalled = false
    private(set) var moveShapeCalled = false
    private(set) var resizeShapeCalled = false
    private(set) var changeColorCalled = false

    // MARK: - Initialization

    init() {}

    // MARK: - CanvasProtocol Methods

    func add(shape: Shape) {
        addShapeCalled = true
        shapes.append(shape)
    }

    @discardableResult
    func remove(shape: Shape) -> Int? {
        removeShapeCalled = true
        guard let index = shapes.firstIndex(where: { $0.id == shape.id }) else {
            return nil
        }
        shapes.remove(at: index)
        return index
    }

    func move(shape: Shape, by offset: Point) {
        moveShapeCalled = true
        let newPosition = Point(
            x: shape.position.x + offset.x,
            y: shape.position.y + offset.y
        )
        shape.position = newPosition
    }

    func resize(shape: Shape, to size: Size) {
        resizeShapeCalled = true
        if let rectangle = shape as? Rectangle {
            rectangle.size = size
        } else if let circle = shape as? Circle {
            circle.radius = size.width / 2
        }
    }

    func changeColor(shape: Shape, fillColor: Color??, strokeColor: Color??) {
        changeColorCalled = true
        // 使用 Optional<Optional<Color>> 來區分:
        // - nil: 不變更
        // - .some(nil): 清除顏色
        // - .some(.some(color)): 設定新顏色
        // Line 不支援填充顏色，忽略 fillColor 參數
        if let fill = fillColor, !(shape is Line) {
            shape.fillColor = fill
        }
        if let stroke = strokeColor {
            shape.strokeColor = stroke
        }
    }

    func findShape(by id: UUID) -> Shape? {
        shapes.first { $0.id == id }
    }

    // MARK: - Test Helper Methods

    func reset() {
        shapes.removeAll()
        selectedShapeId = nil
        addShapeCalled = false
        removeShapeCalled = false
        moveShapeCalled = false
        resizeShapeCalled = false
        changeColorCalled = false
    }
}

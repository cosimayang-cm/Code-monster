import Foundation

/// MoveShapeCommand - 移動圖形的命令
/// FR-014: MoveShapeCommand supports changing shape position
/// FR-019: Supports coalescing for consecutive moves
final class MoveShapeCommand: Command, CoalescibleCommand {

    // MARK: - Properties

    private let canvas: Canvas
    private let shapeId: UUID
    private(set) var offset: Point
    private var previousPosition: Point?

    // MARK: - Command Protocol

    var description: String {
        return "移動圖形"
    }

    // MARK: - CoalescibleCommand Protocol

    var coalescingTimeout: TimeInterval { return 0.5 }
    var lastExecutionTime: Date = Date()

    // MARK: - Initialization

    init(canvas: Canvas, shapeId: UUID, offset: Point) {
        self.canvas = canvas
        self.shapeId = shapeId
        self.offset = offset
    }

    // MARK: - Execute & Undo

    func execute() {
        guard var shape = canvas.shape(withId: shapeId) else { return }
        previousPosition = shape.position
        shape.position = shape.position.offset(by: offset)
        canvas.updateShape(id: shapeId, with: shape)
    }

    func undo() {
        guard var shape = canvas.shape(withId: shapeId),
              let prevPos = previousPosition else { return }
        shape.position = prevPos
        canvas.updateShape(id: shapeId, with: shape)
    }

    // MARK: - Coalescing

    /// 嘗試與另一個命令合併（連續移動合併）
    func coalesce(with other: Command) -> Bool {
        guard let otherMove = other as? MoveShapeCommand,
              otherMove.canvas === canvas,
              otherMove.shapeId == shapeId else {
            return false
        }

        // 累加偏移量
        offset = Point(x: offset.x + otherMove.offset.x, y: offset.y + otherMove.offset.y)
        return true
    }
}

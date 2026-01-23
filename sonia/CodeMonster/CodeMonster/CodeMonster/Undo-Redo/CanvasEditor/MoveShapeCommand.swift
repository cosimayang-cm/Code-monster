import Foundation

/// MoveShapeCommand - 移動圖形的命令
/// FR-014: MoveShapeCommand supports changing shape position
final class MoveShapeCommand: Command {

    // MARK: - Properties

    private let canvas: Canvas
    private let shapeId: UUID
    private let offset: Point
    private var previousPosition: Point?

    // MARK: - Command Protocol

    var description: String {
        return "移動圖形"
    }

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
}

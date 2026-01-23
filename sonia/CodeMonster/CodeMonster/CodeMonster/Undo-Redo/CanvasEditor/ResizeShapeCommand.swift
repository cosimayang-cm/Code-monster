import Foundation

/// ResizeShapeCommand - 縮放圖形的命令
/// FR-015: ResizeShapeCommand supports changing shape size
final class ResizeShapeCommand: Command {

    // MARK: - Properties

    private let canvas: Canvas
    private let shapeId: UUID
    private let newSize: Size
    private var previousSize: Size?

    // MARK: - Command Protocol

    var description: String {
        return "縮放圖形"
    }

    // MARK: - Initialization

    init(canvas: Canvas, shapeId: UUID, newSize: Size) {
        self.canvas = canvas
        self.shapeId = shapeId
        self.newSize = newSize
    }

    // MARK: - Execute & Undo

    func execute() {
        guard let shape = canvas.shape(withId: shapeId) else { return }

        if var rect = shape as? Rectangle {
            previousSize = rect.size
            rect.size = newSize
            canvas.updateShape(id: shapeId, with: rect)
        } else if var circle = shape as? Circle {
            // For circle, use width as diameter
            previousSize = Size(width: circle.radius * 2, height: circle.radius * 2)
            circle.radius = newSize.width / 2
            canvas.updateShape(id: shapeId, with: circle)
        }
    }

    func undo() {
        guard let shape = canvas.shape(withId: shapeId),
              let prevSize = previousSize else { return }

        if var rect = shape as? Rectangle {
            rect.size = prevSize
            canvas.updateShape(id: shapeId, with: rect)
        } else if var circle = shape as? Circle {
            circle.radius = prevSize.width / 2
            canvas.updateShape(id: shapeId, with: circle)
        }
    }
}

import Foundation

/// AddShapeCommand - 新增圖形的命令
/// FR-012: AddShapeCommand supports adding shapes to canvas
final class AddShapeCommand: Command {

    // MARK: - Properties

    private let canvas: Canvas
    private let shape: any Shape

    // MARK: - Command Protocol

    var description: String {
        return "新增圖形"
    }

    // MARK: - Initialization

    init(canvas: Canvas, shape: any Shape) {
        self.canvas = canvas
        self.shape = shape
    }

    // MARK: - Execute & Undo

    func execute() {
        canvas.add(shape)
    }

    func undo() {
        canvas.remove(id: shape.id)
    }
}

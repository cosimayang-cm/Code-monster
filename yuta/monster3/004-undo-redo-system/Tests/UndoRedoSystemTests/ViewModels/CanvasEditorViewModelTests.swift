import XCTest
import Combine
@testable import UndoRedoSystem

/// CanvasEditorViewModelTests - CanvasEditorViewModel 測試
///
/// 遵循 PAGEs Framework 測試標準，使用 Given-When-Then 結構。
/// 測試 ViewModel 的 Canvas 操作和 Undo/Redo 功能。
final class CanvasEditorViewModelTests: XCTestCase {
    // MARK: - Properties

    private var sut: CanvasEditorViewModel!
    private var canvas: MockCanvas!
    private var commandHistory: CommandHistory!
    private var cancellables: Set<AnyCancellable>!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        canvas = MockCanvas()
        commandHistory = CommandHistory()
        sut = CanvasEditorViewModel(
            canvas: canvas,
            commandHistory: commandHistory
        )
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
        commandHistory = nil
        canvas = nil
        super.tearDown()
    }

    // MARK: - Resize Shape Tests

    func testResizeShapeWhenValidRectangleThenSizeChanged() {
        // Given
        sut.addRectangle(
            at: Point(x: 100, y: 100),
            size: Size(width: 50, height: 50)
        )
        let shapeId = canvas.shapes.first!.id
        let newSize = Size(width: 100, height: 80)

        // When
        sut.resizeShape(id: shapeId, newSize: newSize)

        // Then
        let rectangle = canvas.shapes.first as? Rectangle
        XCTAssertNotNil(rectangle)
        XCTAssertEqual(rectangle?.size, newSize)
    }

    func testResizeShapeWhenValidCircleThenRadiusChanged() {
        // Given
        sut.addCircle(
            at: Point(x: 200, y: 200),
            radius: 25
        )
        let shapeId = canvas.shapes.first!.id
        let newSize = Size(width: 80, height: 80)

        // When
        sut.resizeShape(id: shapeId, newSize: newSize)

        // Then
        let circle = canvas.shapes.first as? Circle
        XCTAssertNotNil(circle)
        XCTAssertEqual(circle?.radius, 40.0) // width 80 / 2 = radius 40
    }

    func testResizeShapeWhenInvalidIdThenNoChange() {
        // Given
        sut.addRectangle(
            at: Point(x: 100, y: 100),
            size: Size(width: 50, height: 50)
        )
        let originalSize = (canvas.shapes.first as? Rectangle)?.size
        let invalidId = UUID()

        // When
        sut.resizeShape(id: invalidId, newSize: Size(width: 100, height: 100))

        // Then
        let currentSize = (canvas.shapes.first as? Rectangle)?.size
        XCTAssertEqual(currentSize, originalSize)
    }

    func testResizeShapeWhenExecutedThenCanUndo() {
        // Given
        sut.addRectangle(
            at: Point(x: 100, y: 100),
            size: Size(width: 50, height: 50)
        )
        let shapeId = canvas.shapes.first!.id
        let originalSize = Size(width: 50, height: 50)

        // When
        sut.resizeShape(id: shapeId, newSize: Size(width: 100, height: 80))
        sut.undo()

        // Then
        let rectangle = canvas.shapes.first as? Rectangle
        XCTAssertEqual(rectangle?.size, originalSize)
    }

    // MARK: - Change Fill Color Tests

    func testChangeFillColorWhenValidShapeThenColorChanged() {
        // Given
        sut.addRectangle(
            at: Point(x: 100, y: 100),
            size: Size(width: 50, height: 50),
            fillColor: .red
        )
        let shapeId = canvas.shapes.first!.id
        let newColor = Color.green

        // When
        sut.changeFillColor(id: shapeId, color: newColor)

        // Then
        XCTAssertEqual(canvas.shapes.first?.fillColor, newColor)
    }

    func testChangeFillColorWhenSetToNilThenColorCleared() {
        // Given
        sut.addRectangle(
            at: Point(x: 100, y: 100),
            size: Size(width: 50, height: 50),
            fillColor: .red
        )
        let shapeId = canvas.shapes.first!.id

        // When
        sut.changeFillColor(id: shapeId, color: nil)

        // Then
        XCTAssertNil(canvas.shapes.first?.fillColor)
    }

    func testChangeFillColorWhenInvalidIdThenNoChange() {
        // Given
        sut.addRectangle(
            at: Point(x: 100, y: 100),
            size: Size(width: 50, height: 50),
            fillColor: .red
        )
        let originalColor = canvas.shapes.first?.fillColor
        let invalidId = UUID()

        // When
        sut.changeFillColor(id: invalidId, color: .green)

        // Then
        XCTAssertEqual(canvas.shapes.first?.fillColor, originalColor)
    }

    func testChangeFillColorWhenExecutedThenCanUndo() {
        // Given
        sut.addRectangle(
            at: Point(x: 100, y: 100),
            size: Size(width: 50, height: 50),
            fillColor: .red
        )
        let shapeId = canvas.shapes.first!.id
        let originalColor = Color.red

        // When
        sut.changeFillColor(id: shapeId, color: .green)
        sut.undo()

        // Then
        XCTAssertEqual(canvas.shapes.first?.fillColor, originalColor)
    }

    // MARK: - Change Stroke Color Tests

    func testChangeStrokeColorWhenValidShapeThenColorChanged() {
        // Given
        sut.addRectangle(
            at: Point(x: 100, y: 100),
            size: Size(width: 50, height: 50),
            strokeColor: .black
        )
        let shapeId = canvas.shapes.first!.id
        let newColor = Color.blue

        // When
        sut.changeStrokeColor(id: shapeId, color: newColor)

        // Then
        XCTAssertEqual(canvas.shapes.first?.strokeColor, newColor)
    }

    func testChangeStrokeColorWhenSetToNilThenColorCleared() {
        // Given
        sut.addRectangle(
            at: Point(x: 100, y: 100),
            size: Size(width: 50, height: 50),
            strokeColor: .black
        )
        let shapeId = canvas.shapes.first!.id

        // When
        sut.changeStrokeColor(id: shapeId, color: nil)

        // Then
        XCTAssertNil(canvas.shapes.first?.strokeColor)
    }

    func testChangeStrokeColorWhenInvalidIdThenNoChange() {
        // Given
        sut.addRectangle(
            at: Point(x: 100, y: 100),
            size: Size(width: 50, height: 50),
            strokeColor: .black
        )
        let originalColor = canvas.shapes.first?.strokeColor
        let invalidId = UUID()

        // When
        sut.changeStrokeColor(id: invalidId, color: .blue)

        // Then
        XCTAssertEqual(canvas.shapes.first?.strokeColor, originalColor)
    }

    func testChangeStrokeColorWhenExecutedThenCanUndo() {
        // Given
        sut.addRectangle(
            at: Point(x: 100, y: 100),
            size: Size(width: 50, height: 50),
            strokeColor: .black
        )
        let shapeId = canvas.shapes.first!.id
        let originalColor = Color.black

        // When
        sut.changeStrokeColor(id: shapeId, color: .blue)
        sut.undo()

        // Then
        XCTAssertEqual(canvas.shapes.first?.strokeColor, originalColor)
    }

    // MARK: - Integration Tests

    func testComplexWorkflowWhenMultipleAppearanceChangesThenBehavesCorrectly() {
        // Given
        sut.addRectangle(
            at: Point(x: 100, y: 100),
            size: Size(width: 50, height: 50),
            fillColor: .red,
            strokeColor: .black
        )
        let shapeId = canvas.shapes.first!.id

        // When
        sut.resizeShape(id: shapeId, newSize: Size(width: 100, height: 80))
        sut.changeFillColor(id: shapeId, color: .green)
        sut.changeStrokeColor(id: shapeId, color: .blue)

        // Then
        let rectangle = canvas.shapes.first as? Rectangle
        XCTAssertEqual(rectangle?.size, Size(width: 100, height: 80))
        XCTAssertEqual(rectangle?.fillColor, .green)
        XCTAssertEqual(rectangle?.strokeColor, .blue)

        // When - undo all changes
        sut.undo() // Undo stroke color change
        sut.undo() // Undo fill color change
        sut.undo() // Undo resize

        // Then
        XCTAssertEqual(rectangle?.size, Size(width: 50, height: 50))
        XCTAssertEqual(rectangle?.fillColor, .red)
        XCTAssertEqual(rectangle?.strokeColor, .black)

        // When - redo all changes
        sut.redo()
        sut.redo()
        sut.redo()

        // Then
        XCTAssertEqual(rectangle?.size, Size(width: 100, height: 80))
        XCTAssertEqual(rectangle?.fillColor, .green)
        XCTAssertEqual(rectangle?.strokeColor, .blue)
    }

    // MARK: - Publisher Tests

    func testPublishersWhenAppearanceChangedThenValuesPublished() {
        // Given
        var shapesValues: [[Shape]] = []

        sut.$shapes
            .sink { shapesValues.append($0) }
            .store(in: &cancellables)

        sut.addRectangle(
            at: Point(x: 100, y: 100),
            size: Size(width: 50, height: 50)
        )
        let shapeId = canvas.shapes.first!.id

        // When
        sut.changeFillColor(id: shapeId, color: .red)

        // Then
        XCTAssertEqual(shapesValues.count, 3) // Initial + addRectangle + changeFillColor
    }
}

import XCTest
@testable import CodeMonster

final class CanvasTests: XCTestCase {

    var sut: Canvas!
    var history: CommandHistory!

    override func setUp() {
        super.setUp()
        sut = Canvas()
        history = CommandHistory()
    }

    override func tearDown() {
        sut = nil
        history = nil
        super.tearDown()
    }

    // MARK: - Color Tests

    func testColorWhenCreatedWithRGBAThenValuesCorrect() {
        let color = Color(red: 0.5, green: 0.3, blue: 0.8, alpha: 0.9)
        XCTAssertEqual(color.red, 0.5)
        XCTAssertEqual(color.green, 0.3)
        XCTAssertEqual(color.blue, 0.8)
        XCTAssertEqual(color.alpha, 0.9)
    }

    func testColorWhenPredefinedThenValuesCorrect() {
        XCTAssertEqual(Color.red, Color(red: 1, green: 0, blue: 0, alpha: 1))
        XCTAssertEqual(Color.blue, Color(red: 0, green: 0, blue: 1, alpha: 1))
        XCTAssertEqual(Color.black, Color(red: 0, green: 0, blue: 0, alpha: 1))
    }

    // MARK: - Point Tests

    func testPointWhenOffsetAppliedThenPositionUpdated() {
        let point = Point(x: 100, y: 100)
        let newPoint = point.offset(by: Point(x: 20, y: 30))
        XCTAssertEqual(newPoint.x, 120)
        XCTAssertEqual(newPoint.y, 130)
    }

    // MARK: - Size Tests

    func testSizeWhenCreatedThenDimensionsCorrect() {
        let size = Size(width: 50, height: 100)
        XCTAssertEqual(size.width, 50)
        XCTAssertEqual(size.height, 100)
    }

    // MARK: - Shape Tests

    func testCircleWhenCreatedThenPropertiesCorrect() {
        let circle = Circle(position: Point(x: 100, y: 100), radius: 50, fillColor: .blue)
        XCTAssertEqual(circle.position.x, 100)
        XCTAssertEqual(circle.position.y, 100)
        XCTAssertEqual(circle.radius, 50)
        XCTAssertEqual(circle.fillColor, .blue)
    }

    func testRectangleWhenCreatedThenPropertiesCorrect() {
        let rect = Rectangle(position: Point(x: 0, y: 0), size: Size(width: 50, height: 50), fillColor: .blue)
        XCTAssertEqual(rect.size.width, 50)
        XCTAssertEqual(rect.size.height, 50)
    }

    // MARK: - Canvas Tests

    func testCanvasWhenShapeAddedThenContainsShape() {
        let circle = Circle(position: Point(x: 100, y: 100), radius: 50)
        sut.add(circle)
        XCTAssertEqual(sut.shapes.count, 1)
        XCTAssertNotNil(sut.shape(withId: circle.id))
    }

    func testCanvasWhenShapeRemovedThenNoLongerContains() {
        let circle = Circle(position: Point(x: 100, y: 100), radius: 50)
        sut.add(circle)
        sut.remove(id: circle.id)
        XCTAssertEqual(sut.shapes.count, 0)
    }

    // MARK: - AddShapeCommand Tests

    func testAddShapeWhenExecutedThenShapeOnCanvas() {
        let circle = Circle(position: Point(x: 100, y: 100), radius: 50)
        let command = AddShapeCommand(canvas: sut, shape: circle)

        history.execute(command)

        XCTAssertEqual(sut.shapes.count, 1)
    }

    func testAddShapeWhenUndoThenShapeRemoved() {
        let circle = Circle(position: Point(x: 100, y: 100), radius: 50)
        let command = AddShapeCommand(canvas: sut, shape: circle)

        history.execute(command)
        history.undo()

        XCTAssertEqual(sut.shapes.count, 0)
    }

    // MARK: - MoveShapeCommand Tests

    func testMoveShapeWhenExecutedThenPositionChanged() {
        let circle = Circle(position: Point(x: 100, y: 100), radius: 50)
        sut.add(circle)

        let moveCommand = MoveShapeCommand(canvas: sut, shapeId: circle.id, offset: Point(x: 20, y: 30))
        history.execute(moveCommand)

        let movedCircle = sut.shape(withId: circle.id) as? Circle
        XCTAssertEqual(movedCircle?.position.x, 120)
        XCTAssertEqual(movedCircle?.position.y, 130)
    }

    func testMoveShapeWhenUndoThenPositionRestored() {
        let circle = Circle(position: Point(x: 100, y: 100), radius: 50)
        sut.add(circle)

        let moveCommand = MoveShapeCommand(canvas: sut, shapeId: circle.id, offset: Point(x: 20, y: 30))
        history.execute(moveCommand)
        history.undo()

        let restoredCircle = sut.shape(withId: circle.id) as? Circle
        XCTAssertEqual(restoredCircle?.position.x, 100)
        XCTAssertEqual(restoredCircle?.position.y, 100)
    }

    // MARK: - ResizeShapeCommand Tests

    func testResizeShapeWhenExecutedThenSizeChanged() {
        let rect = Rectangle(position: Point(x: 0, y: 0), size: Size(width: 50, height: 50))
        sut.add(rect)

        let resizeCommand = ResizeShapeCommand(canvas: sut, shapeId: rect.id, newSize: Size(width: 100, height: 100))
        history.execute(resizeCommand)

        let resizedRect = sut.shape(withId: rect.id) as? Rectangle
        XCTAssertEqual(resizedRect?.size.width, 100)
        XCTAssertEqual(resizedRect?.size.height, 100)
    }

    func testResizeShapeWhenUndoThenSizeRestored() {
        let rect = Rectangle(position: Point(x: 0, y: 0), size: Size(width: 50, height: 50))
        sut.add(rect)

        let resizeCommand = ResizeShapeCommand(canvas: sut, shapeId: rect.id, newSize: Size(width: 100, height: 100))
        history.execute(resizeCommand)
        history.undo()

        let restoredRect = sut.shape(withId: rect.id) as? Rectangle
        XCTAssertEqual(restoredRect?.size.width, 50)
        XCTAssertEqual(restoredRect?.size.height, 50)
    }

    // MARK: - ChangeColorCommand Tests

    func testChangeColorWhenExecutedThenColorChanged() {
        let rect = Rectangle(fillColor: .blue)
        sut.add(rect)

        let colorCommand = ChangeColorCommand(canvas: sut, shapeId: rect.id, fillColor: .red)
        history.execute(colorCommand)

        let changedRect = sut.shape(withId: rect.id) as? Rectangle
        XCTAssertEqual(changedRect?.fillColor, .red)
    }

    func testChangeColorWhenUndoThenColorRestored() {
        let rect = Rectangle(fillColor: .blue)
        sut.add(rect)

        let colorCommand = ChangeColorCommand(canvas: sut, shapeId: rect.id, fillColor: .red)
        history.execute(colorCommand)
        history.undo()

        let restoredRect = sut.shape(withId: rect.id) as? Rectangle
        XCTAssertEqual(restoredRect?.fillColor, .blue)
    }

    // MARK: - Integration Tests

    func testUndoRedoFlowWhenMultipleOperationsThenStateCorrect() {
        // Add circle
        let circle = Circle(position: Point(x: 100, y: 100), radius: 50, fillColor: .blue)
        history.execute(AddShapeCommand(canvas: sut, shape: circle))

        // Move circle
        history.execute(MoveShapeCommand(canvas: sut, shapeId: circle.id, offset: Point(x: 20, y: 30)))

        // Change color
        history.execute(ChangeColorCommand(canvas: sut, shapeId: circle.id, fillColor: .red))

        // Verify final state
        var currentCircle = sut.shape(withId: circle.id) as? Circle
        XCTAssertEqual(currentCircle?.position.x, 120)
        XCTAssertEqual(currentCircle?.fillColor, .red)

        // Undo color change
        history.undo()
        currentCircle = sut.shape(withId: circle.id) as? Circle
        XCTAssertEqual(currentCircle?.fillColor, .blue)

        // Undo move
        history.undo()
        currentCircle = sut.shape(withId: circle.id) as? Circle
        XCTAssertEqual(currentCircle?.position.x, 100)

        // Undo add
        history.undo()
        XCTAssertEqual(sut.shapes.count, 0)
    }
}

import XCTest
@testable import UndoRedoSystem

/// ChangeFillColorCommandTests - 變更填充顏色命令測試
///
/// 遵循 PAGEs Framework 測試標準，使用 Given-When-Then 結構。
/// 測試 ChangeFillColorCommand 的執行、撤銷、重做功能。
final class ChangeFillColorCommandTests: XCTestCase {
    // MARK: - Properties

    private var canvas: MockCanvas!
    private var rectangle: Rectangle!
    private var circle: Circle!
    private var line: Line!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        canvas = MockCanvas()
        rectangle = Rectangle(
            position: Point(x: 100, y: 100),
            size: Size(width: 50, height: 50),
            fillColor: .red
        )
        circle = Circle(
            position: Point(x: 200, y: 200),
            radius: 25,
            fillColor: .blue
        )
        line = Line(
            position: Point(x: 0, y: 0),
            endPoint: Point(x: 100, y: 100),
            strokeColor: .black
        )
    }

    override func tearDown() {
        canvas = nil
        rectangle = nil
        circle = nil
        line = nil
        super.tearDown()
    }

    // MARK: - Execute Tests

    func testExecuteWhenChangeFillColorThenColorChanged() {
        // Given
        canvas.add(shape: rectangle)
        let newColor = Color.green
        let command = ChangeFillColorCommand(
            canvas: canvas,
            shape: rectangle,
            newColor: newColor
        )

        // When
        command.execute()

        // Then
        XCTAssertEqual(rectangle.fillColor, newColor)
    }

    func testExecuteWhenChangeToNilThenColorCleared() {
        // Given
        canvas.add(shape: rectangle)
        let command = ChangeFillColorCommand(
            canvas: canvas,
            shape: rectangle,
            newColor: nil
        )

        // When
        command.execute()

        // Then
        XCTAssertNil(rectangle.fillColor)
    }

    func testExecuteWhenLineShapeThenFillColorRemainsNil() {
        // Given
        canvas.add(shape: line)
        let command = ChangeFillColorCommand(
            canvas: canvas,
            shape: line,
            newColor: .red
        )

        // When
        command.execute()

        // Then
        XCTAssertNil(line.fillColor, "Line should not have fill color")
    }

    // MARK: - Undo Tests

    func testUndoWhenAfterChangeColorThenColorRestored() {
        // Given
        canvas.add(shape: rectangle)
        let originalColor = rectangle.fillColor
        let command = ChangeFillColorCommand(
            canvas: canvas,
            shape: rectangle,
            newColor: .green
        )
        command.execute()

        // When
        command.undo()

        // Then
        XCTAssertEqual(rectangle.fillColor, originalColor)
    }

    func testUndoWhenOriginalWasNilThenColorIsNil() {
        // Given
        let shapeWithoutFill = Rectangle(
            position: Point(x: 0, y: 0),
            size: Size(width: 50, height: 50),
            fillColor: nil
        )
        canvas.add(shape: shapeWithoutFill)
        let command = ChangeFillColorCommand(
            canvas: canvas,
            shape: shapeWithoutFill,
            newColor: .red
        )
        command.execute()

        // When
        command.undo()

        // Then
        XCTAssertNil(shapeWithoutFill.fillColor)
    }

    // MARK: - Redo Tests

    func testRedoWhenAfterUndoThenColorChangedAgain() {
        // Given
        canvas.add(shape: rectangle)
        let newColor = Color.green
        let command = ChangeFillColorCommand(
            canvas: canvas,
            shape: rectangle,
            newColor: newColor
        )
        command.execute()
        command.undo()

        // When
        command.execute() // Redo by executing again

        // Then
        XCTAssertEqual(rectangle.fillColor, newColor)
    }

    // MARK: - Description Tests

    func testDescriptionWhenCreatedThenReturnCorrectText() {
        // Given
        let command = ChangeFillColorCommand(
            canvas: canvas,
            shape: rectangle,
            newColor: .green
        )

        // When
        let description = command.description

        // Then
        XCTAssertTrue(description.contains("變更填充顏色"))
        XCTAssertTrue(description.contains("Rectangle"))
    }

    // MARK: - Edge Cases

    func testExecuteWhenCanvasReleasedThenNoChange() {
        // Given
        canvas.add(shape: rectangle)
        let originalColor = rectangle.fillColor
        let command = ChangeFillColorCommand(
            canvas: canvas,
            shape: rectangle,
            newColor: .green
        )
        canvas = nil // Release canvas

        // When
        command.execute()

        // Then
        XCTAssertEqual(rectangle.fillColor, originalColor, "Color should not change when canvas is released")
    }

    func testExecuteWhenMultipleChangesInSequenceThenColorTracked() {
        // Given
        canvas.add(shape: rectangle)
        let command1 = ChangeFillColorCommand(
            canvas: canvas,
            shape: rectangle,
            newColor: .green
        )
        command1.execute()

        let command2 = ChangeFillColorCommand(
            canvas: canvas,
            shape: rectangle,
            newColor: .blue
        )

        // When
        command2.execute()

        // Then
        XCTAssertEqual(rectangle.fillColor, .blue)

        // When - undo command2
        command2.undo()

        // Then - should be green
        XCTAssertEqual(rectangle.fillColor, .green)
    }
}

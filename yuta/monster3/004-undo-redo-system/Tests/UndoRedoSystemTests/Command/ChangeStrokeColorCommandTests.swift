import XCTest
@testable import UndoRedoSystem

/// ChangeStrokeColorCommandTests - 變更邊框顏色命令測試
///
/// 遵循 PAGEs Framework 測試標準，使用 Given-When-Then 結構。
/// 測試 ChangeStrokeColorCommand 的執行、撤銷、重做功能。
final class ChangeStrokeColorCommandTests: XCTestCase {
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
            strokeColor: .red
        )
        circle = Circle(
            position: Point(x: 200, y: 200),
            radius: 25,
            strokeColor: .blue
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

    func testExecuteWhenChangeStrokeColorThenColorChanged() {
        // Given
        canvas.add(shape: rectangle)
        let newColor = Color.green
        let command = ChangeStrokeColorCommand(
            canvas: canvas,
            shape: rectangle,
            newColor: newColor
        )

        // When
        command.execute()

        // Then
        XCTAssertEqual(rectangle.strokeColor, newColor)
    }

    func testExecuteWhenChangeToNilThenColorCleared() {
        // Given
        canvas.add(shape: rectangle)
        let command = ChangeStrokeColorCommand(
            canvas: canvas,
            shape: rectangle,
            newColor: nil
        )

        // When
        command.execute()

        // Then
        XCTAssertNil(rectangle.strokeColor)
    }

    func testExecuteWhenLineStrokeColorChangedThenApplied() {
        // Given
        canvas.add(shape: line)
        let newColor = Color.red
        let command = ChangeStrokeColorCommand(
            canvas: canvas,
            shape: line,
            newColor: newColor
        )

        // When
        command.execute()

        // Then
        XCTAssertEqual(line.strokeColor, newColor)
    }

    // MARK: - Undo Tests

    func testUndoWhenAfterChangeColorThenColorRestored() {
        // Given
        canvas.add(shape: rectangle)
        let originalColor = rectangle.strokeColor
        let command = ChangeStrokeColorCommand(
            canvas: canvas,
            shape: rectangle,
            newColor: .green
        )
        command.execute()

        // When
        command.undo()

        // Then
        XCTAssertEqual(rectangle.strokeColor, originalColor)
    }

    func testUndoWhenOriginalWasNilThenColorIsNil() {
        // Given
        let shapeWithoutStroke = Rectangle(
            position: Point(x: 0, y: 0),
            size: Size(width: 50, height: 50),
            strokeColor: nil
        )
        canvas.add(shape: shapeWithoutStroke)
        let command = ChangeStrokeColorCommand(
            canvas: canvas,
            shape: shapeWithoutStroke,
            newColor: .red
        )
        command.execute()

        // When
        command.undo()

        // Then
        XCTAssertNil(shapeWithoutStroke.strokeColor)
    }

    // MARK: - Redo Tests

    func testRedoWhenAfterUndoThenColorChangedAgain() {
        // Given
        canvas.add(shape: rectangle)
        let newColor = Color.green
        let command = ChangeStrokeColorCommand(
            canvas: canvas,
            shape: rectangle,
            newColor: newColor
        )
        command.execute()
        command.undo()

        // When
        command.execute() // Redo by executing again

        // Then
        XCTAssertEqual(rectangle.strokeColor, newColor)
    }

    // MARK: - Description Tests

    func testDescriptionWhenCreatedThenReturnCorrectText() {
        // Given
        let command = ChangeStrokeColorCommand(
            canvas: canvas,
            shape: rectangle,
            newColor: .green
        )

        // When
        let description = command.description

        // Then
        XCTAssertTrue(description.contains("變更邊框顏色"))
        XCTAssertTrue(description.contains("Rectangle"))
    }

    // MARK: - Edge Cases

    func testExecuteWhenCanvasReleasedThenNoChange() {
        // Given
        canvas.add(shape: rectangle)
        let originalColor = rectangle.strokeColor
        let command = ChangeStrokeColorCommand(
            canvas: canvas,
            shape: rectangle,
            newColor: .green
        )
        canvas = nil // Release canvas

        // When
        command.execute()

        // Then
        XCTAssertEqual(rectangle.strokeColor, originalColor, "Color should not change when canvas is released")
    }

    func testExecuteWhenMultipleChangesInSequenceThenColorTracked() {
        // Given
        canvas.add(shape: line)
        let command1 = ChangeStrokeColorCommand(
            canvas: canvas,
            shape: line,
            newColor: .green
        )
        command1.execute()

        let command2 = ChangeStrokeColorCommand(
            canvas: canvas,
            shape: line,
            newColor: .blue
        )

        // When
        command2.execute()

        // Then
        XCTAssertEqual(line.strokeColor, .blue)

        // When - undo command2
        command2.undo()

        // Then - should be green
        XCTAssertEqual(line.strokeColor, .green)
    }

    func testExecuteWhenChangeBothFillAndStrokeThenOnlyStrokeChanged() {
        // Given
        canvas.add(shape: rectangle)
        let originalFillColor = rectangle.fillColor
        let command = ChangeStrokeColorCommand(
            canvas: canvas,
            shape: rectangle,
            newColor: .green
        )

        // When
        command.execute()

        // Then
        XCTAssertEqual(rectangle.strokeColor, .green)
        XCTAssertEqual(rectangle.fillColor, originalFillColor, "Fill color should remain unchanged")
    }
}

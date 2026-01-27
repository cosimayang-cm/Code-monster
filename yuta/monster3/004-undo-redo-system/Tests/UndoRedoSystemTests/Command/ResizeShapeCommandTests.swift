import XCTest
@testable import UndoRedoSystem

/// ResizeShapeCommandTests - 縮放圖形命令測試
///
/// 遵循 PAGEs Framework 測試標準，使用 Given-When-Then 結構。
/// 測試 ResizeShapeCommand 的執行、撤銷、重做功能。
final class ResizeShapeCommandTests: XCTestCase {
    // MARK: - Properties

    private var canvas: MockCanvas!
    private var rectangle: Rectangle!
    private var circle: Circle!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        canvas = MockCanvas()
        rectangle = Rectangle(
            position: Point(x: 100, y: 100),
            size: Size(width: 50, height: 50)
        )
        circle = Circle(
            position: Point(x: 200, y: 200),
            radius: 25
        )
    }

    override func tearDown() {
        canvas = nil
        rectangle = nil
        circle = nil
        super.tearDown()
    }

    // MARK: - Execute Tests

    func testExecuteWhenResizeRectangleThenSizeChanged() {
        // Given
        canvas.add(shape: rectangle)
        let newSize = Size(width: 100, height: 80)
        let command = ResizeShapeCommand(
            canvas: canvas,
            shape: rectangle,
            newSize: newSize
        )

        // When
        command.execute()

        // Then
        XCTAssertEqual(rectangle.size, newSize)
    }

    func testExecuteWhenResizeCircleThenRadiusChanged() {
        // Given
        canvas.add(shape: circle)
        let newSize = Size(width: 80, height: 80) // For circle, width determines diameter
        let command = ResizeShapeCommand(
            canvas: canvas,
            shape: circle,
            newSize: newSize
        )

        // When
        command.execute()

        // Then
        XCTAssertEqual(circle.radius, 40.0) // diameter 80 -> radius 40
    }

    // MARK: - Undo Tests

    func testUndoWhenAfterResizeThenSizeRestored() {
        // Given
        canvas.add(shape: rectangle)
        let originalSize = rectangle.size
        let newSize = Size(width: 100, height: 80)
        let command = ResizeShapeCommand(
            canvas: canvas,
            shape: rectangle,
            newSize: newSize
        )
        command.execute()

        // When
        command.undo()

        // Then
        XCTAssertEqual(rectangle.size, originalSize)
    }

    func testUndoWhenAfterResizeCircleThenRadiusRestored() {
        // Given
        canvas.add(shape: circle)
        let originalRadius = circle.radius
        let newSize = Size(width: 80, height: 80)
        let command = ResizeShapeCommand(
            canvas: canvas,
            shape: circle,
            newSize: newSize
        )
        command.execute()

        // When
        command.undo()

        // Then
        XCTAssertEqual(circle.radius, originalRadius)
    }

    // MARK: - Redo Tests

    func testRedoWhenAfterUndoThenSizeChangedAgain() {
        // Given
        canvas.add(shape: rectangle)
        let newSize = Size(width: 100, height: 80)
        let command = ResizeShapeCommand(
            canvas: canvas,
            shape: rectangle,
            newSize: newSize
        )
        command.execute()
        command.undo()

        // When
        command.execute() // Redo by executing again

        // Then
        XCTAssertEqual(rectangle.size, newSize)
    }

    // MARK: - Description Tests

    func testDescriptionWhenCreatedThenReturnCorrectText() {
        // Given
        let command = ResizeShapeCommand(
            canvas: canvas,
            shape: rectangle,
            newSize: Size(width: 100, height: 80)
        )

        // When
        let description = command.description

        // Then
        XCTAssertTrue(description.contains("縮放"))
        XCTAssertTrue(description.contains("Rectangle"))
    }

    // MARK: - Edge Cases

    func testExecuteWhenCanvasReleasedThenNoChange() {
        // Given
        canvas.add(shape: rectangle)
        let originalSize = rectangle.size
        let command = ResizeShapeCommand(
            canvas: canvas,
            shape: rectangle,
            newSize: Size(width: 100, height: 80)
        )
        canvas = nil // Release canvas

        // When
        command.execute()

        // Then
        XCTAssertEqual(rectangle.size, originalSize, "Size should not change when canvas is released")
    }

    func testExecuteWhenZeroSizeThenSizeIsZero() {
        // Given
        canvas.add(shape: rectangle)
        let zeroSize = Size(width: 0, height: 0)
        let command = ResizeShapeCommand(
            canvas: canvas,
            shape: rectangle,
            newSize: zeroSize
        )

        // When
        command.execute()

        // Then
        XCTAssertEqual(rectangle.size, zeroSize)
    }
}

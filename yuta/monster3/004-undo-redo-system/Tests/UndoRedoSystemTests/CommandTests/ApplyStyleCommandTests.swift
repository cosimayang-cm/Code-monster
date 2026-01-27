import XCTest
import Foundation
@testable import UndoRedoSystem

/// Tests for ApplyStyleCommand implementing FR-004 to FR-010.
///
/// Covers:
/// - FR-004: Bold style application
/// - FR-005: Italic style application
/// - FR-006: Underline style application
/// - FR-009: Style operations must be undoable
/// - FR-010: Style operations must be redoable
///
/// Test naming: testMethodNameWhenConditionThenExpectedResult
final class ApplyStyleCommandTests: XCTestCase {
    // MARK: - Properties

    private var document: TextDocument!
    private var history: CommandHistory!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        document = TextDocument(text: "Hello World")
        history = CommandHistory()
    }

    override func tearDown() {
        document = nil
        history = nil
        super.tearDown()
    }

    // MARK: - FR-004: Bold Style Tests

    func testExecuteWhenApplyingBoldStyleThenTextHasBoldInRange() {
        // Given: Document with "Hello World" and no styles
        let range = NSRange(location: 0, length: 5) // "Hello"
        let command = ApplyStyleCommand(
            document: document,
            style: .bold,
            range: range
        )

        // When: Execute apply bold command
        command.execute()

        // Then: "Hello" range has bold style
        let appliedStyle = document.getStyle(in: range)
        XCTAssertEqual(appliedStyle, .bold, "Expected bold style in range")
    }

    func testExecuteWhenApplyingBoldToMultipleRangesThenEachRangeHasBold() {
        // Given: Document with "Hello World"
        let range1 = NSRange(location: 0, length: 5) // "Hello"
        let range2 = NSRange(location: 6, length: 5) // "World"

        let command1 = ApplyStyleCommand(document: document, style: .bold, range: range1)
        let command2 = ApplyStyleCommand(document: document, style: .bold, range: range2)

        // When: Apply bold to both ranges
        command1.execute()
        command2.execute()

        // Then: Both ranges have bold style
        XCTAssertEqual(document.getStyle(in: range1), .bold)
        XCTAssertEqual(document.getStyle(in: range2), .bold)
    }

    // MARK: - FR-005: Italic Style Tests

    func testExecuteWhenApplyingItalicStyleThenTextHasItalicInRange() {
        // Given: Document with "Hello World"
        let range = NSRange(location: 6, length: 5) // "World"
        let command = ApplyStyleCommand(
            document: document,
            style: .italic,
            range: range
        )

        // When: Execute apply italic command
        command.execute()

        // Then: "World" range has italic style
        let appliedStyle = document.getStyle(in: range)
        XCTAssertEqual(appliedStyle, .italic, "Expected italic style in range")
    }

    // MARK: - FR-006: Underline Style Tests

    func testExecuteWhenApplyingUnderlineStyleThenTextHasUnderlineInRange() {
        // Given: Document with "Hello World"
        let range = NSRange(location: 0, length: 11) // "Hello World"
        let command = ApplyStyleCommand(
            document: document,
            style: .underline,
            range: range
        )

        // When: Execute apply underline command
        command.execute()

        // Then: Full text has underline style
        let appliedStyle = document.getStyle(in: range)
        XCTAssertEqual(appliedStyle, .underline, "Expected underline style in range")
    }

    // MARK: - FR-009: Undo Style Operations

    func testUndoWhenStyleAppliedThenStyleIsRemoved() {
        // Given: Document with bold style applied to "Hello"
        let range = NSRange(location: 0, length: 5)
        let command = ApplyStyleCommand(document: document, style: .bold, range: range)
        command.execute()
        XCTAssertEqual(document.getStyle(in: range), .bold, "Precondition: Bold should be applied")

        // When: Undo the style command
        command.undo()

        // Then: Style is removed from range
        let styleAfterUndo = document.getStyle(in: range)
        XCTAssertNil(styleAfterUndo, "Expected no style after undo")
    }

    func testUndoWhenMultipleStylesAppliedThenLastStyleIsRemoved() {
        // Given: Apply bold then italic to same range
        let range = NSRange(location: 0, length: 5)
        let boldCommand = ApplyStyleCommand(document: document, style: .bold, range: range)
        let italicCommand = ApplyStyleCommand(document: document, style: .italic, range: range)

        boldCommand.execute()
        italicCommand.execute()
        XCTAssertEqual(document.getStyle(in: range), .italic, "Precondition: Italic should be last style")

        // When: Undo italic command
        italicCommand.undo()

        // Then: Bold style is restored
        XCTAssertEqual(document.getStyle(in: range), .bold, "Expected bold style restored after undo")
    }

    // MARK: - FR-010: Redo Style Operations

    func testRedoWhenStyleUndoneThenStyleIsReapplied() {
        // Given: Document with style applied and then undone
        let range = NSRange(location: 0, length: 5)
        let command = ApplyStyleCommand(document: document, style: .bold, range: range)

        command.execute()
        command.undo()
        XCTAssertNil(document.getStyle(in: range), "Precondition: Style should be removed after undo")

        // When: Redo the command
        command.execute() // Redo is same as re-execute

        // Then: Style is reapplied
        XCTAssertEqual(document.getStyle(in: range), .bold, "Expected bold style reapplied after redo")
    }

    // MARK: - Integration with CommandHistory

    func testIntegrationWhenApplyStyleThroughHistoryThenUndoRedoWorks() {
        // Given: Clean command history
        let range = NSRange(location: 0, length: 5)
        let command = ApplyStyleCommand(document: document, style: .bold, range: range)

        // When: Execute through history
        history.execute(command)

        // Then: Style is applied and can undo
        XCTAssertEqual(document.getStyle(in: range), .bold)
        XCTAssertTrue(history.canUndo)

        // When: Undo through history
        history.undo()

        // Then: Style is removed and can redo
        XCTAssertNil(document.getStyle(in: range))
        XCTAssertTrue(history.canRedo)

        // When: Redo through history
        history.redo()

        // Then: Style is reapplied
        XCTAssertEqual(document.getStyle(in: range), .bold)
    }

    // MARK: - Edge Cases

    func testExecuteWhenInvalidRangeThenNoStyleApplied() {
        // Given: Document with "Hello World" (11 chars)
        let invalidRange = NSRange(location: 20, length: 5) // Out of bounds
        let command = ApplyStyleCommand(document: document, style: .bold, range: invalidRange)

        // When: Execute with invalid range
        command.execute()

        // Then: No crash, no style applied
        let style = document.getStyle(in: invalidRange)
        XCTAssertNil(style, "Expected no style for invalid range")
    }

    func testExecuteWhenZeroLengthRangeThenNoStyleApplied() {
        // Given: Zero-length range
        let zeroRange = NSRange(location: 0, length: 0)
        let command = ApplyStyleCommand(document: document, style: .bold, range: zeroRange)

        // When: Execute with zero-length range
        command.execute()

        // Then: No style applied (or implementation-defined behavior)
        let style = document.getStyle(in: zeroRange)
        XCTAssertNil(style, "Expected no style for zero-length range")
    }

    func testExecuteWhenDocumentDeallocatedThenNoActionTaken() {
        // Given: Command with weak reference to document
        var tempDocument: TextDocument? = TextDocument(text: "Test")
        let range = NSRange(location: 0, length: 4)
        let command = ApplyStyleCommand(document: tempDocument!, style: .bold, range: range)

        // When: Document is deallocated
        tempDocument = nil

        // Then: Execute doesn't crash (weak reference becomes nil)
        command.execute()
        command.undo()
        // No crash expected
    }

    // MARK: - Command Description

    func testDescriptionWhenCreatedThenReturnsReadableDescription() {
        // Given: Apply bold command
        let range = NSRange(location: 0, length: 5)
        let command = ApplyStyleCommand(document: document, style: .bold, range: range)

        // When: Get description
        let description = command.description

        // Then: Description is human-readable
        XCTAssertFalse(description.isEmpty, "Description should not be empty")
        XCTAssertTrue(description.contains("粗體") || description.contains("樣式") || description.contains("套用"), "Description should mention style operation")
    }
}

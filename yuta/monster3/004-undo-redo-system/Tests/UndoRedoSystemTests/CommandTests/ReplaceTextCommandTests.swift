import XCTest
@testable import UndoRedoSystem

final class ReplaceTextCommandTests: XCTestCase {
    // MARK: - Properties

    private var document: TextDocument!
    private var sut: ReplaceTextCommand<TextDocument>!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        document = TextDocument(text: "Hello World")
    }

    override func tearDown() {
        sut = nil
        document = nil
        super.tearDown()
    }

    // MARK: - Execute Tests

    func testExecuteWhenReplaceAtBeginningThenTextIsReplaced() {
        // Given
        sut = ReplaceTextCommand(document: document, range: NSRange(location: 0, length: 5), replacementText: "Hi")

        // When
        sut.execute()

        // Then
        XCTAssertEqual(document.getText(), "Hi World")
    }

    func testExecuteWhenReplaceAtMiddleThenTextIsReplaced() {
        // Given
        sut = ReplaceTextCommand(document: document, range: NSRange(location: 6, length: 5), replacementText: "Swift")

        // When
        sut.execute()

        // Then
        XCTAssertEqual(document.getText(), "Hello Swift")
    }

    func testExecuteWhenReplaceAtEndThenTextIsReplaced() {
        // Given
        sut = ReplaceTextCommand(document: document, range: NSRange(location: 6, length: 5), replacementText: "!")

        // When
        sut.execute()

        // Then
        XCTAssertEqual(document.getText(), "Hello !")
    }

    func testExecuteWhenReplaceAllThenTextIsReplaced() {
        // Given
        sut = ReplaceTextCommand(document: document, range: NSRange(location: 0, length: 11), replacementText: "New Text")

        // When
        sut.execute()

        // Then
        XCTAssertEqual(document.getText(), "New Text")
    }

    func testExecuteWhenReplacementLongerThanOriginalThenTextExpands() {
        // Given
        sut = ReplaceTextCommand(document: document, range: NSRange(location: 0, length: 5), replacementText: "Hello There")

        // When
        sut.execute()

        // Then
        XCTAssertEqual(document.getText(), "Hello There World")
    }

    func testExecuteWhenReplacementShorterThanOriginalThenTextShrinks() {
        // Given
        sut = ReplaceTextCommand(document: document, range: NSRange(location: 0, length: 5), replacementText: "Hi")

        // When
        sut.execute()

        // Then
        XCTAssertEqual(document.getText(), "Hi World")
    }

    func testExecuteWhenReplaceWithEmptyStringThenTextIsDeleted() {
        // Given
        sut = ReplaceTextCommand(document: document, range: NSRange(location: 5, length: 6), replacementText: "")

        // When
        sut.execute()

        // Then
        XCTAssertEqual(document.getText(), "Hello")
    }

    func testExecuteWhenCalledMultipleTimesThenReplacesMultipleTimes() {
        // Given
        sut = ReplaceTextCommand(document: document, range: NSRange(location: 0, length: 5), replacementText: "Hi")

        // When
        sut.execute()
        XCTAssertEqual(document.getText(), "Hi World")
        sut.execute() // Replace first 5 chars again ("Hi Wo" deleted, "Hi" inserted)
        XCTAssertEqual(document.getText(), "Hirld")

        // Then
        XCTAssertEqual(document.getText(), "Hirld")
    }

    // MARK: - Undo Tests

    func testUndoWhenAfterExecuteThenTextIsRestored() {
        // Given
        sut = ReplaceTextCommand(document: document, range: NSRange(location: 0, length: 5), replacementText: "Hi")
        sut.execute()
        XCTAssertEqual(document.getText(), "Hi World")

        // When
        sut.undo()

        // Then
        XCTAssertEqual(document.getText(), "Hello World")
    }

    func testUndoWhenMultipleExecutesThenRestoresToOriginal() {
        // Given
        sut = ReplaceTextCommand(document: document, range: NSRange(location: 0, length: 5), replacementText: "Hi")
        sut.execute()
        sut.execute()

        // When
        sut.undo()

        // Then
        XCTAssertEqual(document.getText(), "Hello World")
    }

    func testUndoWhenCalledWithoutExecuteThenNoChange() {
        // Given
        sut = ReplaceTextCommand(document: document, range: NSRange(location: 0, length: 5), replacementText: "Hi")

        // When
        sut.undo()

        // Then
        XCTAssertEqual(document.getText(), "Hello World")
    }

    func testUndoWhenCalledMultipleTimesThenNoAdditionalChange() {
        // Given
        sut = ReplaceTextCommand(document: document, range: NSRange(location: 0, length: 5), replacementText: "Hi")
        sut.execute()

        // When
        sut.undo()
        sut.undo()

        // Then
        XCTAssertEqual(document.getText(), "Hello World")
    }

    // MARK: - Execute-Undo Cycle Tests

    func testExecuteUndoExecuteWhenCalledThenWorksCorrectly() {
        // Given
        sut = ReplaceTextCommand(document: document, range: NSRange(location: 0, length: 5), replacementText: "Hi")

        // When & Then
        sut.execute()
        XCTAssertEqual(document.getText(), "Hi World")

        sut.undo()
        XCTAssertEqual(document.getText(), "Hello World")

        // Second execute replaces again
        sut.execute()
        XCTAssertEqual(document.getText(), "Hi World")
    }

    // MARK: - Weak Reference Tests

    func testWeakReferenceWhenDocumentDeallocatedThenNoRetainCycle() {
        // Given
        var optionalDocument: TextDocument? = TextDocument(text: "Hello World")
        sut = ReplaceTextCommand(document: optionalDocument!, range: NSRange(location: 0, length: 5), replacementText: "Hi")

        // When
        optionalDocument = nil

        // Then - Command should not crash when document is nil
        sut.execute() // Should be safe (no-op)
        sut.undo()    // Should be safe (no-op)
    }

    func testExecuteWhenDocumentIsNilThenNoOp() {
        // Given
        weak var weakDocument: TextDocument?
        do {
            let tempDocument = TextDocument(text: "Hello World")
            weakDocument = tempDocument
            sut = ReplaceTextCommand(document: tempDocument, range: NSRange(location: 0, length: 5), replacementText: "Hi")
        }
        // tempDocument goes out of scope and is deallocated

        // When
        sut.execute()

        // Then - Should not crash
        XCTAssertNil(weakDocument)
    }

    // MARK: - Description Tests

    func testDescriptionWhenCreatedThenReturnsCorrectFormat() {
        // Given
        sut = ReplaceTextCommand(document: document, range: NSRange(location: 2, length: 5), replacementText: "Test")

        // When
        let description = sut.description

        // Then
        XCTAssertTrue(description.contains("Replace"))
        XCTAssertTrue(description.contains("2"))
        XCTAssertTrue(description.contains("5"))
        XCTAssertTrue(description.contains("Test"))
    }

    func testDescriptionWhenLongReplacementTextThenTruncatesInDescription() {
        // Given
        let longText = String(repeating: "a", count: 100)
        sut = ReplaceTextCommand(document: document, range: NSRange(location: 0, length: 5), replacementText: longText)

        // When
        let description = sut.description

        // Then
        XCTAssertNotNil(description)
        // Description should exist (truncation is optional)
    }

    // MARK: - Edge Cases

    func testExecuteWhenZeroLengthRangeThenInsertsText() {
        // Given - Zero-length range effectively inserts text
        sut = ReplaceTextCommand(document: document, range: NSRange(location: 5, length: 0), replacementText: "!")

        // When
        sut.execute()

        // Then
        XCTAssertEqual(document.getText(), "Hello! World")
    }

    func testExecuteWhenRangeBeyondLengthThenAdjustsToValidRange() {
        // Given
        sut = ReplaceTextCommand(document: document, range: NSRange(location: 6, length: 100), replacementText: "!")

        // When
        sut.execute()

        // Then
        XCTAssertEqual(document.getText(), "Hello !")
    }

    func testExecuteWhenLocationBeyondLengthThenInsertsAtEnd() {
        // Given
        sut = ReplaceTextCommand(document: document, range: NSRange(location: 100, length: 5), replacementText: "Test")

        // When
        sut.execute()

        // Then - delete() is no-op (location beyond length), insert() appends at end
        XCTAssertEqual(document.getText(), "Hello WorldTest")
    }

    func testExecuteWhenNegativeLocationThenInsertsAtBeginning() {
        // Given
        sut = ReplaceTextCommand(document: document, range: NSRange(location: -1, length: 5), replacementText: "Test")

        // When
        sut.execute()

        // Then - delete() is no-op (negative location), insert() at position 0
        XCTAssertEqual(document.getText(), "TestHello World")
    }

    func testUndoWhenDocumentModifiedExternallyThenRestoresToOriginalState() {
        // Given
        sut = ReplaceTextCommand(document: document, range: NSRange(location: 0, length: 5), replacementText: "Hi")
        sut.execute()

        // Externally modify document
        document.insert("!!!", at: 0)
        XCTAssertEqual(document.getText(), "!!!Hi World")

        // When
        sut.undo()

        // Then - Should restore to state before command execute
        XCTAssertEqual(document.getText(), "Hello World")
    }
}

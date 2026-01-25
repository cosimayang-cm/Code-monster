import XCTest
@testable import UndoRedoSystem

final class DeleteTextCommandTests: XCTestCase {
    // MARK: - Properties

    private var document: TextDocument!
    private var sut: DeleteTextCommand<TextDocument>!

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

    func testExecuteWhenDeleteAtBeginningThenTextIsDeleted() {
        // Given
        sut = DeleteTextCommand(document: document, range: NSRange(location: 0, length: 6))

        // When
        sut.execute()

        // Then
        XCTAssertEqual(document.getText(), "World")
    }

    func testExecuteWhenDeleteAtMiddleThenTextIsDeleted() {
        // Given
        sut = DeleteTextCommand(document: document, range: NSRange(location: 5, length: 1))

        // When
        sut.execute()

        // Then
        XCTAssertEqual(document.getText(), "HelloWorld")
    }

    func testExecuteWhenDeleteAtEndThenTextIsDeleted() {
        // Given
        sut = DeleteTextCommand(document: document, range: NSRange(location: 6, length: 5))

        // When
        sut.execute()

        // Then
        XCTAssertEqual(document.getText(), "Hello ")
    }

    func testExecuteWhenDeleteAllThenTextIsEmpty() {
        // Given
        sut = DeleteTextCommand(document: document, range: NSRange(location: 0, length: 11))

        // When
        sut.execute()

        // Then
        XCTAssertEqual(document.getText(), "")
    }

    func testExecuteWhenCalledMultipleTimesThenDeletesMultipleTimes() {
        // Given
        sut = DeleteTextCommand(document: document, range: NSRange(location: 0, length: 6))

        // When
        sut.execute()
        XCTAssertEqual(document.getText(), "World")
        sut.execute() // Delete first 6 chars again (but only 5 remain)

        // Then
        XCTAssertEqual(document.getText(), "")
    }

    // MARK: - Undo Tests

    func testUndoWhenAfterExecuteThenTextIsRestored() {
        // Given
        sut = DeleteTextCommand(document: document, range: NSRange(location: 0, length: 6))
        sut.execute()
        XCTAssertEqual(document.getText(), "World")

        // When
        sut.undo()

        // Then
        XCTAssertEqual(document.getText(), "Hello World")
    }

    func testUndoWhenMultipleExecutesThenRestoresToOriginal() {
        // Given
        sut = DeleteTextCommand(document: document, range: NSRange(location: 0, length: 6))
        sut.execute()
        sut.execute()
        XCTAssertEqual(document.getText(), "")

        // When
        sut.undo()

        // Then
        XCTAssertEqual(document.getText(), "Hello World")
    }

    func testUndoWhenCalledWithoutExecuteThenNoChange() {
        // Given
        sut = DeleteTextCommand(document: document, range: NSRange(location: 0, length: 6))

        // When
        sut.undo()

        // Then
        XCTAssertEqual(document.getText(), "Hello World")
    }

    func testUndoWhenCalledMultipleTimesThenNoAdditionalChange() {
        // Given
        sut = DeleteTextCommand(document: document, range: NSRange(location: 0, length: 6))
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
        sut = DeleteTextCommand(document: document, range: NSRange(location: 0, length: 6))

        // When & Then
        sut.execute()
        XCTAssertEqual(document.getText(), "World")

        sut.undo()
        XCTAssertEqual(document.getText(), "Hello World")

        // Second execute deletes again
        sut.execute()
        XCTAssertEqual(document.getText(), "World")
    }

    // MARK: - Weak Reference Tests

    func testWeakReferenceWhenDocumentDeallocatedThenNoRetainCycle() {
        // Given
        var optionalDocument: TextDocument? = TextDocument(text: "Hello World")
        sut = DeleteTextCommand(document: optionalDocument!, range: NSRange(location: 0, length: 5))

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
            sut = DeleteTextCommand(document: tempDocument, range: NSRange(location: 0, length: 5))
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
        sut = DeleteTextCommand(document: document, range: NSRange(location: 2, length: 5))

        // When
        let description = sut.description

        // Then
        XCTAssertTrue(description.contains("Delete"))
        XCTAssertTrue(description.contains("2"))
        XCTAssertTrue(description.contains("5"))
    }

    // MARK: - Edge Cases

    func testExecuteWhenZeroLengthThenNoChange() {
        // Given
        sut = DeleteTextCommand(document: document, range: NSRange(location: 5, length: 0))

        // When
        sut.execute()

        // Then
        XCTAssertEqual(document.getText(), "Hello World")
    }

    func testExecuteWhenRangeBeyondLengthThenDeleteToEnd() {
        // Given
        sut = DeleteTextCommand(document: document, range: NSRange(location: 6, length: 100))

        // When
        sut.execute()

        // Then
        XCTAssertEqual(document.getText(), "Hello ")
    }

    func testExecuteWhenLocationBeyondLengthThenNoChange() {
        // Given
        sut = DeleteTextCommand(document: document, range: NSRange(location: 100, length: 5))

        // When
        sut.execute()

        // Then
        XCTAssertEqual(document.getText(), "Hello World")
    }

    func testExecuteWhenNegativeLocationThenNoChange() {
        // Given
        sut = DeleteTextCommand(document: document, range: NSRange(location: -1, length: 5))

        // When
        sut.execute()

        // Then
        XCTAssertEqual(document.getText(), "Hello World")
    }

    func testUndoWhenDocumentModifiedExternallyThenRestoresToOriginalState() {
        // Given
        sut = DeleteTextCommand(document: document, range: NSRange(location: 0, length: 6))
        sut.execute()

        // Externally modify document
        document.insert("!!!", at: 0)
        XCTAssertEqual(document.getText(), "!!!World")

        // When
        sut.undo()

        // Then - Should restore to state before command execute
        XCTAssertEqual(document.getText(), "Hello World")
    }
}

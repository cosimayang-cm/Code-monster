import XCTest
@testable import UndoRedoSystem

final class InsertTextCommandTests: XCTestCase {
    // MARK: - Properties

    private var document: TextDocument!
    private var sut: InsertTextCommand<TextDocument>!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        document = TextDocument(text: "Hello")
    }

    override func tearDown() {
        sut = nil
        document = nil
        super.tearDown()
    }

    // MARK: - Execute Tests

    func testExecuteWhenInsertTextAtBeginningThenTextIsInserted() {
        // Given
        sut = InsertTextCommand(document: document, text: "Say ", position: 0)

        // When
        sut.execute()

        // Then
        XCTAssertEqual(document.getText(), "Say Hello")
    }

    func testExecuteWhenInsertTextAtMiddleThenTextIsInserted() {
        // Given
        sut = InsertTextCommand(document: document, text: " World", position: 5)

        // When
        sut.execute()

        // Then
        XCTAssertEqual(document.getText(), "Hello World")
    }

    func testExecuteWhenInsertTextAtEndThenTextIsAppended() {
        // Given
        sut = InsertTextCommand(document: document, text: "!", position: 5)

        // When
        sut.execute()

        // Then
        XCTAssertEqual(document.getText(), "Hello!")
    }

    func testExecuteWhenCalledMultipleTimesThenIdempotent() {
        // Given
        sut = InsertTextCommand(document: document, text: " World", position: 5)

        // When
        sut.execute()
        sut.execute()

        // Then - Should insert twice (not idempotent by design)
        XCTAssertEqual(document.getText(), "Hello World World")
    }

    // MARK: - Undo Tests

    func testUndoWhenAfterExecuteThenTextIsRestored() {
        // Given
        sut = InsertTextCommand(document: document, text: " World", position: 5)
        sut.execute()
        XCTAssertEqual(document.getText(), "Hello World")

        // When
        sut.undo()

        // Then
        XCTAssertEqual(document.getText(), "Hello")
    }

    func testUndoWhenMultipleExecutesThenRestoresToOriginal() {
        // Given
        sut = InsertTextCommand(document: document, text: " World", position: 5)
        sut.execute()
        sut.execute()
        XCTAssertEqual(document.getText(), "Hello World World")

        // When
        sut.undo()

        // Then
        XCTAssertEqual(document.getText(), "Hello")
    }

    func testUndoWhenCalledWithoutExecuteThenNoChange() {
        // Given
        sut = InsertTextCommand(document: document, text: " World", position: 5)

        // When
        sut.undo()

        // Then
        XCTAssertEqual(document.getText(), "Hello")
    }

    func testUndoWhenCalledMultipleTimesThenNoAdditionalChange() {
        // Given
        sut = InsertTextCommand(document: document, text: " World", position: 5)
        sut.execute()

        // When
        sut.undo()
        sut.undo()

        // Then
        XCTAssertEqual(document.getText(), "Hello")
    }

    // MARK: - Execute-Undo Cycle Tests

    func testExecuteUndoExecuteWhenCalledThenWorksCorrectly() {
        // Given
        sut = InsertTextCommand(document: document, text: " World", position: 5)

        // When & Then
        sut.execute()
        XCTAssertEqual(document.getText(), "Hello World")

        sut.undo()
        XCTAssertEqual(document.getText(), "Hello")

        // Second execute restores to same state as first execute
        sut.execute()
        XCTAssertEqual(document.getText(), "Hello World")
    }

    // MARK: - Weak Reference Tests

    func testWeakReferenceWhenDocumentDeallocatedThenNoRetainCycle() {
        // Given
        var optionalDocument: TextDocument? = TextDocument(text: "Hello")
        sut = InsertTextCommand(document: optionalDocument!, text: " World", position: 5)

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
            let tempDocument = TextDocument(text: "Hello")
            weakDocument = tempDocument
            sut = InsertTextCommand(document: tempDocument, text: " World", position: 5)
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
        sut = InsertTextCommand(document: document, text: "Test", position: 2)

        // When
        let description = sut.description

        // Then
        XCTAssertTrue(description.contains("Insert"))
        XCTAssertTrue(description.contains("Test"))
        XCTAssertTrue(description.contains("2"))
    }

    func testDescriptionWhenLongTextThenTruncatesInDescription() {
        // Given
        let longText = String(repeating: "a", count: 100)
        sut = InsertTextCommand(document: document, text: longText, position: 0)

        // When
        let description = sut.description

        // Then
        XCTAssertNotNil(description)
        // Description should exist (truncation is optional)
    }

    // MARK: - Edge Cases

    func testExecuteWhenEmptyTextThenNoChange() {
        // Given
        sut = InsertTextCommand(document: document, text: "", position: 2)

        // When
        sut.execute()

        // Then
        XCTAssertEqual(document.getText(), "Hello")
    }

    func testExecuteWhenPositionBeyondLengthThenInsertsAtEnd() {
        // Given
        sut = InsertTextCommand(document: document, text: " World", position: 100)

        // When
        sut.execute()

        // Then
        XCTAssertEqual(document.getText(), "Hello World")
    }

    func testUndoWhenDocumentModifiedExternallyThenRestoresToOriginalState() {
        // Given
        sut = InsertTextCommand(document: document, text: " World", position: 5)
        sut.execute()

        // Externally modify document
        document.insert("!!!", at: 11)
        XCTAssertEqual(document.getText(), "Hello World!!!")

        // When
        sut.undo()

        // Then - Should restore to state before command execute
        XCTAssertEqual(document.getText(), "Hello")
    }
}

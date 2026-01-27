import XCTest
@testable import UndoRedoSystem

final class TextDocumentTests: XCTestCase {
    // MARK: - Properties

    private var sut: TextDocument!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        sut = TextDocument()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitWhenCreatedThenTextIsEmpty() {
        // Given & When
        let document = TextDocument()

        // Then
        XCTAssertEqual(document.getText(), "")
    }

    func testInitWithTextWhenCreatedThenTextIsSet() {
        // Given
        let initialText = "Hello, World!"

        // When
        let document = TextDocument(text: initialText)

        // Then
        XCTAssertEqual(document.getText(), initialText)
    }

    // MARK: - Insert Tests

    func testInsertWhenInsertAtBeginningThenTextIsInserted() {
        // Given
        sut = TextDocument(text: "World")

        // When
        sut.insert("Hello ", at: 0)

        // Then
        XCTAssertEqual(sut.getText(), "Hello World")
    }

    func testInsertWhenInsertAtMiddleThenTextIsInserted() {
        // Given
        sut = TextDocument(text: "HelloWorld")

        // When
        sut.insert(" ", at: 5)

        // Then
        XCTAssertEqual(sut.getText(), "Hello World")
    }

    func testInsertWhenInsertAtEndThenTextIsAppended() {
        // Given
        sut = TextDocument(text: "Hello")

        // When
        sut.insert(" World", at: 5)

        // Then
        XCTAssertEqual(sut.getText(), "Hello World")
    }

    func testInsertWhenPositionBeyondLengthThenTextIsAppended() {
        // Given
        sut = TextDocument(text: "Hello")

        // When
        sut.insert(" World", at: 100)

        // Then
        XCTAssertEqual(sut.getText(), "Hello World")
    }

    func testInsertWhenEmptyStringThenNoChange() {
        // Given
        sut = TextDocument(text: "Hello")

        // When
        sut.insert("", at: 2)

        // Then
        XCTAssertEqual(sut.getText(), "Hello")
    }

    // MARK: - Delete Tests

    func testDeleteWhenDeleteAtBeginningThenTextIsDeleted() {
        // Given
        sut = TextDocument(text: "Hello World")

        // When
        sut.delete(in: NSRange(location: 0, length: 6))

        // Then
        XCTAssertEqual(sut.getText(), "World")
    }

    func testDeleteWhenDeleteAtMiddleThenTextIsDeleted() {
        // Given
        sut = TextDocument(text: "Hello World")

        // When
        sut.delete(in: NSRange(location: 5, length: 1))

        // Then
        XCTAssertEqual(sut.getText(), "HelloWorld")
    }

    func testDeleteWhenDeleteAtEndThenTextIsDeleted() {
        // Given
        sut = TextDocument(text: "Hello World")

        // When
        sut.delete(in: NSRange(location: 6, length: 5))

        // Then
        XCTAssertEqual(sut.getText(), "Hello ")
    }

    func testDeleteWhenDeleteAllThenTextIsEmpty() {
        // Given
        sut = TextDocument(text: "Hello World")

        // When
        sut.delete(in: NSRange(location: 0, length: 11))

        // Then
        XCTAssertEqual(sut.getText(), "")
    }

    func testDeleteWhenRangeBeyondLengthThenDeleteToEnd() {
        // Given
        sut = TextDocument(text: "Hello")

        // When
        sut.delete(in: NSRange(location: 3, length: 100))

        // Then
        XCTAssertEqual(sut.getText(), "Hel")
    }

    func testDeleteWhenLocationBeyondLengthThenNoChange() {
        // Given
        sut = TextDocument(text: "Hello")

        // When
        sut.delete(in: NSRange(location: 100, length: 5))

        // Then
        XCTAssertEqual(sut.getText(), "Hello")
    }

    func testDeleteWhenZeroLengthThenNoChange() {
        // Given
        sut = TextDocument(text: "Hello")

        // When
        sut.delete(in: NSRange(location: 2, length: 0))

        // Then
        XCTAssertEqual(sut.getText(), "Hello")
    }

    // MARK: - Replace Tests

    func testReplaceWhenReplaceAtBeginningThenTextIsReplaced() {
        // Given
        sut = TextDocument(text: "Hello World")

        // When
        sut.replace(in: NSRange(location: 0, length: 5), with: "Hi")

        // Then
        XCTAssertEqual(sut.getText(), "Hi World")
    }

    func testReplaceWhenReplaceAtMiddleThenTextIsReplaced() {
        // Given
        sut = TextDocument(text: "Hello World")

        // When
        sut.replace(in: NSRange(location: 6, length: 5), with: "Swift")

        // Then
        XCTAssertEqual(sut.getText(), "Hello Swift")
    }

    func testReplaceWhenReplaceAtEndThenTextIsReplaced() {
        // Given
        sut = TextDocument(text: "Hello World")

        // When
        sut.replace(in: NSRange(location: 6, length: 5), with: "!")

        // Then
        XCTAssertEqual(sut.getText(), "Hello !")
    }

    func testReplaceWhenReplacementLongerThanOriginalThenTextExpands() {
        // Given
        sut = TextDocument(text: "Hi")

        // When
        sut.replace(in: NSRange(location: 0, length: 2), with: "Hello World")

        // Then
        XCTAssertEqual(sut.getText(), "Hello World")
    }

    func testReplaceWhenRangeBeyondLengthThenAdjustToValidRange() {
        // Given
        sut = TextDocument(text: "Hello")

        // When
        sut.replace(in: NSRange(location: 3, length: 100), with: "p!")

        // Then
        XCTAssertEqual(sut.getText(), "Help!")
    }

    // MARK: - Memento Tests

    func testCreateMementoWhenCalledThenReturnsMemento() {
        // Given
        sut = TextDocument(text: "Hello World")

        // When
        let memento = sut.createMemento()

        // Then
        XCTAssertNotNil(memento)
        XCTAssertTrue(memento.timestamp <= Date())
    }

    func testRestoreFromMementoWhenCalledThenStateIsRestored() {
        // Given
        sut = TextDocument(text: "Original")
        let memento = sut.createMemento()

        // When
        sut.insert(" Modified", at: 8)
        XCTAssertEqual(sut.getText(), "Original Modified")

        sut.restore(from: memento)

        // Then
        XCTAssertEqual(sut.getText(), "Original")
    }

    func testRestoreFromMementoWhenMultipleChangesThenStateIsRestored() {
        // Given
        sut = TextDocument(text: "A")
        let memento1 = sut.createMemento()

        sut.insert("B", at: 1)
        let memento2 = sut.createMemento()

        sut.insert("C", at: 2)
        XCTAssertEqual(sut.getText(), "ABC")

        // When & Then
        sut.restore(from: memento2)
        XCTAssertEqual(sut.getText(), "AB")

        sut.restore(from: memento1)
        XCTAssertEqual(sut.getText(), "A")
    }

    func testRestoreFromMementoWhenRestoredToEmptyThenTextIsEmpty() {
        // Given
        let emptyMemento = sut.createMemento()
        sut.insert("Hello", at: 0)

        // When
        sut.restore(from: emptyMemento)

        // Then
        XCTAssertEqual(sut.getText(), "")
    }

    // MARK: - Edge Cases

    func testMultipleOperationsWhenSequentialThenAllApplied() {
        // Given
        sut = TextDocument()

        // When
        sut.insert("Hello", at: 0)
        sut.insert(" ", at: 5)
        sut.insert("World", at: 6)
        sut.delete(in: NSRange(location: 5, length: 1))

        // Then
        XCTAssertEqual(sut.getText(), "HelloWorld")
    }

    func testInsertWhenNegativePositionThenTreatedAsZero() {
        // Given
        sut = TextDocument(text: "World")

        // When
        sut.insert("Hello ", at: -1)

        // Then
        XCTAssertEqual(sut.getText(), "Hello World")
    }

    func testDeleteWhenNegativeLocationThenNoChange() {
        // Given
        sut = TextDocument(text: "Hello")

        // When
        sut.delete(in: NSRange(location: -1, length: 5))

        // Then
        XCTAssertEqual(sut.getText(), "Hello")
    }
}

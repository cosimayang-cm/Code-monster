import XCTest
@testable import CodeMonster

final class TextDocumentTests: XCTestCase {

    var sut: TextDocument!

    override func setUp() {
        super.setUp()
        sut = TextDocument()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitWhenCreatedThenContentIsEmpty() {
        XCTAssertEqual(sut.content, "", "Initial content should be empty")
    }

    // MARK: - Insert Tests

    func testInsertWhenTextInsertedAtStartThenContentUpdated() {
        // Given: Empty document
        // When: Insert "Hello" at start
        sut.insert("Hello", at: sut.content.startIndex)

        // Then: Content should be "Hello"
        XCTAssertEqual(sut.content, "Hello")
    }

    func testInsertWhenTextInsertedAtEndThenContentUpdated() {
        // Given: Document with "Hello"
        sut.insert("Hello", at: sut.content.startIndex)

        // When: Insert " World" at end
        sut.insert(" World", at: sut.content.endIndex)

        // Then: Content should be "Hello World"
        XCTAssertEqual(sut.content, "Hello World")
    }

    func testInsertWhenTextInsertedInMiddleThenContentUpdated() {
        // Given: Document with "HelloWorld"
        sut.insert("HelloWorld", at: sut.content.startIndex)

        // When: Insert " " at index 5
        let insertIndex = sut.content.index(sut.content.startIndex, offsetBy: 5)
        sut.insert(" ", at: insertIndex)

        // Then: Content should be "Hello World"
        XCTAssertEqual(sut.content, "Hello World")
    }

    // MARK: - Delete Tests

    func testDeleteWhenRangeDeletedThenContentUpdated() {
        // Given: Document with "Hello World"
        sut.insert("Hello World", at: sut.content.startIndex)

        // When: Delete " World" (index 5 to end)
        let startIndex = sut.content.index(sut.content.startIndex, offsetBy: 5)
        let deletedText = sut.delete(range: startIndex..<sut.content.endIndex)

        // Then: Content should be "Hello" and deleted text returned
        XCTAssertEqual(sut.content, "Hello")
        XCTAssertEqual(deletedText, " World")
    }

    func testDeleteWhenEntireContentDeletedThenContentEmpty() {
        // Given: Document with "Hello"
        sut.insert("Hello", at: sut.content.startIndex)

        // When: Delete entire content
        let deletedText = sut.delete(range: sut.content.startIndex..<sut.content.endIndex)

        // Then: Content should be empty
        XCTAssertEqual(sut.content, "")
        XCTAssertEqual(deletedText, "Hello")
    }

    // MARK: - Replace Tests

    func testReplaceWhenTextReplacedThenContentUpdated() {
        // Given: Document with "Hello"
        sut.insert("Hello", at: sut.content.startIndex)

        // When: Replace "Hello" with "Hi"
        let oldText = sut.replace(range: sut.content.startIndex..<sut.content.endIndex, with: "Hi")

        // Then: Content should be "Hi" and old text returned
        XCTAssertEqual(sut.content, "Hi")
        XCTAssertEqual(oldText, "Hello")
    }

    func testReplaceWhenPartialTextReplacedThenContentUpdated() {
        // Given: Document with "Hello World"
        sut.insert("Hello World", at: sut.content.startIndex)

        // When: Replace "World" with "Swift"
        let startIndex = sut.content.index(sut.content.startIndex, offsetBy: 6)
        let oldText = sut.replace(range: startIndex..<sut.content.endIndex, with: "Swift")

        // Then: Content should be "Hello Swift"
        XCTAssertEqual(sut.content, "Hello Swift")
        XCTAssertEqual(oldText, "World")
    }

    // MARK: - Integration Tests with CommandHistory

    func testUndoRedoFlowWhenInsertUndoRedoThenStateCorrect() {
        // Given: Document and history
        let history = CommandHistory()

        // When: Insert and undo
        let insertCommand = InsertTextCommand(document: sut, text: "Hello", at: sut.content.startIndex)
        history.execute(insertCommand)
        XCTAssertEqual(sut.content, "Hello")

        history.undo()
        XCTAssertEqual(sut.content, "")

        history.redo()
        XCTAssertEqual(sut.content, "Hello")
    }

    func testUndoRedoFlowWhenMultipleInsertsUndoThenStateCorrect() {
        // Given: Document and history
        let history = CommandHistory()

        // When: Two inserts
        let insert1 = InsertTextCommand(document: sut, text: "Hello", at: sut.content.startIndex)
        history.execute(insert1)

        let insert2 = InsertTextCommand(document: sut, text: " World", at: sut.content.endIndex)
        history.execute(insert2)

        XCTAssertEqual(sut.content, "Hello World")

        // Undo second insert
        history.undo()
        XCTAssertEqual(sut.content, "Hello")

        // Undo first insert
        history.undo()
        XCTAssertEqual(sut.content, "")
    }

    func testUndoRedoFlowWhenDeleteUndoThenStateRestored() {
        // Given: Document with content
        sut.insert("Hello World", at: sut.content.startIndex)
        let history = CommandHistory()

        // When: Delete and undo
        let startIndex = sut.content.index(sut.content.startIndex, offsetBy: 5)
        let deleteCommand = DeleteTextCommand(document: sut, range: startIndex..<sut.content.endIndex)
        history.execute(deleteCommand)

        XCTAssertEqual(sut.content, "Hello")

        history.undo()
        XCTAssertEqual(sut.content, "Hello World")
    }

    func testUndoRedoFlowWhenReplaceUndoThenStateRestored() {
        // Given: Document with content
        sut.insert("Hello", at: sut.content.startIndex)
        let history = CommandHistory()

        // When: Replace and undo
        let replaceCommand = ReplaceTextCommand(
            document: sut,
            range: sut.content.startIndex..<sut.content.endIndex,
            newText: "Hi"
        )
        history.execute(replaceCommand)

        XCTAssertEqual(sut.content, "Hi")

        history.undo()
        XCTAssertEqual(sut.content, "Hello")
    }
}

import XCTest
import Combine
@testable import UndoRedoSystem

final class TextEditorViewModelTests: XCTestCase {
    // MARK: - Properties

    private var sut: TextEditorViewModel!
    private var cancellables: Set<AnyCancellable>!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        sut = TextEditorViewModel()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitWhenCreatedThenTextIsEmpty() {
        // Given & When
        let viewModel = TextEditorViewModel()

        // Then
        XCTAssertEqual(viewModel.text, "")
    }

    func testInitWhenCreatedThenCannotUndoOrRedo() {
        // Given & When
        let viewModel = TextEditorViewModel()

        // Then
        XCTAssertFalse(viewModel.canUndo)
        XCTAssertFalse(viewModel.canRedo)
    }

    // MARK: - Insert Tests

    func testInsertWhenInsertTextThenTextIsUpdated() {
        // Given
        let expectation = expectation(description: "Text published")
        var publishedValues: [String] = []

        sut.$text
            .dropFirst() // Skip initial value
            .sink { value in
                publishedValues.append(value)
                if publishedValues.count == 1 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        sut.insert("Hello", at: 0)

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.text, "Hello")
        XCTAssertEqual(publishedValues, ["Hello"])
    }

    func testInsertWhenInsertMultipleTimesThenAllChangesApplied() {
        // Given & When
        sut.insert("Hello", at: 0)
        sut.insert(" ", at: 5)
        sut.insert("World", at: 6)

        // Then
        XCTAssertEqual(sut.text, "Hello World")
    }

    func testInsertWhenInsertThenCanUndo() {
        // Given
        let expectation = expectation(description: "CanUndo published")

        sut.$canUndo
            .dropFirst() // Skip initial value
            .sink { value in
                if value {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        sut.insert("Hello", at: 0)

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(sut.canUndo)
    }

    // MARK: - Delete Tests

    func testDeleteWhenDeleteTextThenTextIsUpdated() {
        // Given
        sut.insert("Hello World", at: 0)

        let expectation = expectation(description: "Text published")
        var publishedValues: [String] = []

        sut.$text
            .dropFirst() // Skip current value
            .sink { value in
                publishedValues.append(value)
                if publishedValues.count == 1 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        sut.delete(in: NSRange(location: 0, length: 6))

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.text, "World")
        XCTAssertEqual(publishedValues, ["World"])
    }

    func testDeleteWhenDeleteThenCanUndo() {
        // Given
        sut.insert("Hello World", at: 0)

        // When
        sut.delete(in: NSRange(location: 0, length: 6))

        // Then
        XCTAssertTrue(sut.canUndo)
    }

    // MARK: - Replace Tests

    func testReplaceWhenReplaceTextThenTextIsUpdated() {
        // Given
        sut.insert("Hello World", at: 0)

        let expectation = expectation(description: "Text published")
        var publishedValues: [String] = []

        sut.$text
            .dropFirst() // Skip current value
            .sink { value in
                publishedValues.append(value)
                if publishedValues.count == 1 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        sut.replace(in: NSRange(location: 6, length: 5), with: "Swift")

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.text, "Hello Swift")
        XCTAssertEqual(publishedValues, ["Hello Swift"])
    }

    func testReplaceWhenReplaceThenCanUndo() {
        // Given
        sut.insert("Hello World", at: 0)

        // When
        sut.replace(in: NSRange(location: 6, length: 5), with: "Swift")

        // Then
        XCTAssertTrue(sut.canUndo)
    }

    // MARK: - Undo Tests

    func testUndoWhenAfterInsertThenTextIsReverted() {
        // Given
        sut.insert("Hello", at: 0)
        XCTAssertEqual(sut.text, "Hello")

        let expectation = expectation(description: "Text published")
        var publishedValues: [String] = []

        sut.$text
            .dropFirst() // Skip current value
            .sink { value in
                publishedValues.append(value)
                if publishedValues.count == 1 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        sut.undo()

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.text, "")
        XCTAssertEqual(publishedValues, [""])
    }

    func testUndoWhenAfterMultipleOperationsThenUndoesLastOperation() {
        // Given
        sut.insert("A", at: 0)
        sut.insert("B", at: 1)
        sut.insert("C", at: 2)
        XCTAssertEqual(sut.text, "ABC")

        // When
        sut.undo()

        // Then
        XCTAssertEqual(sut.text, "AB")
    }

    func testUndoWhenUndoAllThenTextIsEmpty() {
        // Given
        sut.insert("Hello", at: 0)
        sut.insert(" World", at: 5)

        // When
        sut.undo()
        sut.undo()

        // Then
        XCTAssertEqual(sut.text, "")
        XCTAssertFalse(sut.canUndo)
    }

    func testUndoWhenAfterUndoThenCanRedo() {
        // Given
        sut.insert("Hello", at: 0)

        let expectation = expectation(description: "CanRedo published")

        sut.$canRedo
            .dropFirst() // Skip initial value
            .sink { value in
                if value {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        sut.undo()

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(sut.canRedo)
    }

    func testUndoWhenNoOperationsThenNoChange() {
        // Given & When
        sut.undo()

        // Then
        XCTAssertEqual(sut.text, "")
        XCTAssertFalse(sut.canUndo)
    }

    // MARK: - Redo Tests

    func testRedoWhenAfterUndoThenTextIsRestored() {
        // Given
        sut.insert("Hello", at: 0)
        sut.undo()
        XCTAssertEqual(sut.text, "")

        let expectation = expectation(description: "Text published")
        var publishedValues: [String] = []

        sut.$text
            .dropFirst() // Skip current value
            .sink { value in
                publishedValues.append(value)
                if publishedValues.count == 1 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        sut.redo()

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.text, "Hello")
        XCTAssertEqual(publishedValues, ["Hello"])
    }

    func testRedoWhenRedoMultipleTimesThenAllOperationsRestored() {
        // Given
        sut.insert("A", at: 0)
        sut.insert("B", at: 1)
        sut.undo()
        sut.undo()
        XCTAssertEqual(sut.text, "")

        // When
        sut.redo()
        sut.redo()

        // Then
        XCTAssertEqual(sut.text, "AB")
        XCTAssertFalse(sut.canRedo)
    }

    func testRedoWhenNoUndoThenNoChange() {
        // Given
        sut.insert("Hello", at: 0)

        // When
        sut.redo()

        // Then
        XCTAssertEqual(sut.text, "Hello")
        XCTAssertFalse(sut.canRedo)
    }

    func testRedoWhenAfterRedoThenCanUndo() {
        // Given
        sut.insert("Hello", at: 0)
        sut.undo()

        // When
        sut.redo()

        // Then
        XCTAssertTrue(sut.canUndo)
    }

    // MARK: - Redo History Clear Tests

    func testInsertWhenAfterUndoThenRedoHistoryIsCleared() {
        // Given
        sut.insert("Hello", at: 0)
        sut.undo()
        XCTAssertTrue(sut.canRedo)

        // When
        sut.insert("World", at: 0)

        // Then
        XCTAssertFalse(sut.canRedo)
        XCTAssertEqual(sut.text, "World")
    }

    func testDeleteWhenAfterUndoThenRedoHistoryIsCleared() {
        // Given
        sut.insert("Hello", at: 0)
        sut.undo()
        XCTAssertTrue(sut.canRedo)

        // When
        sut.insert("Hello World", at: 0)
        sut.delete(in: NSRange(location: 0, length: 6))

        // Then
        XCTAssertFalse(sut.canRedo)
    }

    // MARK: - Publisher Tests

    func testPublishersWhenOperationsPerformedThenAllValuesPublished() {
        // Given
        var textValues: [String] = []
        var canUndoValues: [Bool] = []
        var canRedoValues: [Bool] = []

        sut.$text
            .sink { textValues.append($0) }
            .store(in: &cancellables)

        sut.$canUndo
            .sink { canUndoValues.append($0) }
            .store(in: &cancellables)

        sut.$canRedo
            .sink { canRedoValues.append($0) }
            .store(in: &cancellables)

        // When
        sut.insert("Hello", at: 0)
        sut.undo()
        sut.redo()

        // Then
        XCTAssertEqual(textValues, ["", "Hello", "", "Hello"])
        XCTAssertEqual(canUndoValues, [false, true, false, true])
        XCTAssertEqual(canRedoValues, [false, false, true, false])
    }

    // MARK: - Integration Tests

    func testComplexWorkflowWhenMultipleOperationsThenBehavesCorrectly() {
        // Given & When
        sut.insert("Hello", at: 0)          // "Hello"
        sut.insert(" ", at: 5)              // "Hello "
        sut.insert("World", at: 6)          // "Hello World"
        XCTAssertEqual(sut.text, "Hello World")

        sut.undo()                          // "Hello "
        XCTAssertEqual(sut.text, "Hello ")

        sut.delete(in: NSRange(location: 5, length: 1))  // "Hello"
        XCTAssertEqual(sut.text, "Hello")
        XCTAssertFalse(sut.canRedo) // New operation clears redo

        sut.replace(in: NSRange(location: 0, length: 5), with: "Hi")  // "Hi"
        XCTAssertEqual(sut.text, "Hi")

        sut.undo()                          // "Hello"
        XCTAssertEqual(sut.text, "Hello")

        sut.undo()                          // "Hello "
        XCTAssertEqual(sut.text, "Hello ")

        sut.redo()                          // "Hello"
        XCTAssertEqual(sut.text, "Hello")

        sut.redo()                          // "Hi"
        XCTAssertEqual(sut.text, "Hi")

        // Then
        XCTAssertTrue(sut.canUndo)
        XCTAssertFalse(sut.canRedo)
    }
}

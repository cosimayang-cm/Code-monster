import XCTest
@testable import CodeMonster

final class ApplyStyleCommandTests: XCTestCase {

    var document: TextDocument!
    var history: CommandHistory!

    override func setUp() {
        super.setUp()
        document = TextDocument(content: "Hello World")
        history = CommandHistory()
    }

    override func tearDown() {
        document = nil
        history = nil
        super.tearDown()
    }

    // MARK: - TextStyle Tests

    func testTextStyleWhenBoldThenRawValueCorrect() {
        XCTAssertEqual(TextStyle.bold.rawValue, 1)
    }

    func testTextStyleWhenItalicThenRawValueCorrect() {
        XCTAssertEqual(TextStyle.italic.rawValue, 2)
    }

    func testTextStyleWhenUnderlineThenRawValueCorrect() {
        XCTAssertEqual(TextStyle.underline.rawValue, 4)
    }

    func testTextStyleWhenCombinedThenContainsBoth() {
        let combined: TextStyle = [.bold, .italic]
        XCTAssertTrue(combined.contains(.bold))
        XCTAssertTrue(combined.contains(.italic))
        XCTAssertFalse(combined.contains(.underline))
    }

    // MARK: - ApplyStyleCommand Execute Tests

    func testApplyStyleWhenExecutedThenStyleApplied() {
        let range = document.content.startIndex..<document.content.index(document.content.startIndex, offsetBy: 5)
        let command = ApplyStyleCommand(document: document, range: range, style: .bold)

        history.execute(command)

        let styles = document.stylesIn(range: range)
        XCTAssertEqual(styles.count, 1)
        XCTAssertEqual(styles.first?.style, .bold)
    }

    func testApplyStyleWhenMultipleStylesThenAllApplied() {
        let range = document.content.startIndex..<document.content.index(document.content.startIndex, offsetBy: 5)

        history.execute(ApplyStyleCommand(document: document, range: range, style: .bold))
        history.execute(ApplyStyleCommand(document: document, range: range, style: .italic))

        let styles = document.stylesIn(range: range)
        XCTAssertEqual(styles.count, 2)
    }

    // MARK: - ApplyStyleCommand Undo Tests

    func testApplyStyleWhenUndoThenStyleRemoved() {
        let range = document.content.startIndex..<document.content.index(document.content.startIndex, offsetBy: 5)
        let command = ApplyStyleCommand(document: document, range: range, style: .bold)

        history.execute(command)
        history.undo()

        let styles = document.stylesIn(range: range)
        XCTAssertTrue(styles.isEmpty)
    }

    func testApplyStyleWhenUndoMultipleThenAllRemoved() {
        let range = document.content.startIndex..<document.content.index(document.content.startIndex, offsetBy: 5)

        history.execute(ApplyStyleCommand(document: document, range: range, style: .bold))
        history.execute(ApplyStyleCommand(document: document, range: range, style: .italic))

        history.undo()
        var styles = document.stylesIn(range: range)
        XCTAssertEqual(styles.count, 1)
        XCTAssertEqual(styles.first?.style, .bold)

        history.undo()
        styles = document.stylesIn(range: range)
        XCTAssertTrue(styles.isEmpty)
    }

    // MARK: - ApplyStyleCommand Redo Tests

    func testApplyStyleWhenRedoThenStyleReapplied() {
        let range = document.content.startIndex..<document.content.index(document.content.startIndex, offsetBy: 5)
        let command = ApplyStyleCommand(document: document, range: range, style: .bold)

        history.execute(command)
        history.undo()
        history.redo()

        let styles = document.stylesIn(range: range)
        XCTAssertEqual(styles.count, 1)
        XCTAssertEqual(styles.first?.style, .bold)
    }

    // MARK: - Description Tests

    func testApplyStyleDescriptionWhenBoldThenCorrect() {
        let range = document.content.startIndex..<document.content.endIndex
        let command = ApplyStyleCommand(document: document, range: range, style: .bold)
        XCTAssertEqual(command.description, "套用粗體")
    }

    func testApplyStyleDescriptionWhenItalicThenCorrect() {
        let range = document.content.startIndex..<document.content.endIndex
        let command = ApplyStyleCommand(document: document, range: range, style: .italic)
        XCTAssertEqual(command.description, "套用斜體")
    }

    func testApplyStyleDescriptionWhenUnderlineThenCorrect() {
        let range = document.content.startIndex..<document.content.endIndex
        let command = ApplyStyleCommand(document: document, range: range, style: .underline)
        XCTAssertEqual(command.description, "套用底線")
    }

    func testApplyStyleDescriptionWhenCombinedThenCorrect() {
        let range = document.content.startIndex..<document.content.endIndex
        let command = ApplyStyleCommand(document: document, range: range, style: [.bold, .italic])
        XCTAssertEqual(command.description, "套用粗體、斜體")
    }
}

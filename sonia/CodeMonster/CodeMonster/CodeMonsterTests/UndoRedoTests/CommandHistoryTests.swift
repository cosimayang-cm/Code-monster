//
//  CommandHistoryTests.swift
//  CodeMonsterTests
//
//  Created by Claude on 2026/1/23.
//

import XCTest
@testable import CodeMonster

/// Test suite for CommandHistory - Undo/Redo system
/// Tests cover FR-001 through FR-006 from specification
final class CommandHistoryTests: XCTestCase {

    var sut: CommandHistory!

    override func setUp() {
        super.setUp()
        sut = CommandHistory()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - FR-002: Initial State Tests

    /// Test: T006-001 - CommandHistory initializes with empty stacks
    func testInitWhenCreatedThenStacksAreEmpty() {
        // Given: Fresh CommandHistory instance (created in setUp)

        // When: Check initial state

        // Then: Both stacks should be empty
        XCTAssertFalse(sut.canUndo, "canUndo should be false initially")
        XCTAssertFalse(sut.canRedo, "canRedo should be false initially")
    }

    /// Test: T006-002 - Initial state has no descriptions
    func testInitWhenCreatedThenDescriptionsAreNil() {
        // Given: Fresh CommandHistory instance

        // When: Check descriptions

        // Then: Descriptions should be nil
        XCTAssertNil(sut.undoDescription, "undoDescription should be nil initially")
        XCTAssertNil(sut.redoDescription, "redoDescription should be nil initially")
    }

    // MARK: - FR-003: Execute Command Tests

    /// Test: T006-003 - Execute command enables undo
    func testExecuteWhenCommandExecutedThenCanUndo() {
        // Given: A mock command
        let command = MockCommand(description: "Test Command")

        // When: Execute the command
        sut.execute(command)

        // Then: canUndo should be true
        XCTAssertTrue(sut.canUndo, "canUndo should be true after executing a command")
        XCTAssertFalse(sut.canRedo, "canRedo should remain false")
    }

    /// Test: T006-004 - Execute command updates undo description
    func testExecuteWhenCommandExecutedThenUndoDescriptionSet() {
        // Given: A command with specific description
        let command = MockCommand(description: "Add Circle")

        // When: Execute the command
        sut.execute(command)

        // Then: undoDescription should match command description
        XCTAssertEqual(sut.undoDescription, "Add Circle", "undoDescription should match executed command")
        XCTAssertNil(sut.redoDescription, "redoDescription should still be nil")
    }

    /// Test: T006-005 - Execute command calls command's execute method
    func testExecuteWhenCommandExecutedThenCommandExecuteIsCalled() {
        // Given: A mock command that tracks execution
        let command = MockCommand(description: "Test")

        // When: Execute the command
        sut.execute(command)

        // Then: Command's execute should have been called
        XCTAssertTrue(command.executeWasCalled, "Command's execute() should be called")
        XCTAssertFalse(command.undoWasCalled, "Command's undo() should not be called")
    }

    // MARK: - FR-003, FR-004: Undo Tests

    /// Test: T006-006 - Undo restores previous state
    func testUndoWhenCommandUndone​ThenStateRestored() {
        // Given: An executed command
        let command = MockCommand(description: "Change Color")
        sut.execute(command)

        // When: Undo the command
        sut.undo()

        // Then: Command's undo should be called
        XCTAssertTrue(command.undoWasCalled, "Command's undo() should be called")
        XCTAssertFalse(sut.canUndo, "canUndo should be false after undoing last command")
        XCTAssertTrue(sut.canRedo, "canRedo should be true after undo")
    }

    /// Test: T006-007 - Undo updates descriptions
    func testUndoWhenCommandUndone​ThenDescriptionsUpdated() {
        // Given: An executed command
        let command = MockCommand(description: "Delete Shape")
        sut.execute(command)

        // When: Undo the command
        sut.undo()

        // Then: Descriptions should be updated
        XCTAssertNil(sut.undoDescription, "undoDescription should be nil after undoing last command")
        XCTAssertEqual(sut.redoDescription, "Delete Shape", "redoDescription should match undone command")
    }

    /// Test: T006-008 - Multiple undo operations work correctly
    func testUndoWhenMultipleCommandsUndone​ThenStackMaintained() {
        // Given: Multiple executed commands
        let command1 = MockCommand(description: "Command 1")
        let command2 = MockCommand(description: "Command 2")
        let command3 = MockCommand(description: "Command 3")

        sut.execute(command1)
        sut.execute(command2)
        sut.execute(command3)

        // When: Undo twice
        sut.undo()

        // Then: Should be able to undo again
        XCTAssertTrue(sut.canUndo, "Should still be able to undo")
        XCTAssertEqual(sut.undoDescription, "Command 2", "undoDescription should be Command 2")
        XCTAssertEqual(sut.redoDescription, "Command 3", "redoDescription should be Command 3")

        sut.undo()

        XCTAssertTrue(sut.canUndo, "Should still be able to undo")
        XCTAssertEqual(sut.undoDescription, "Command 1", "undoDescription should be Command 1")
        XCTAssertEqual(sut.redoDescription, "Command 2", "redoDescription should be Command 2")
    }

    // MARK: - FR-003, FR-004: Redo Tests

    /// Test: T006-009 - Redo restores undone state
    func testRedoWhenCommandRedone​ThenStateRestored() {
        // Given: An executed and undone command
        let command = MockCommand(description: "Resize")
        sut.execute(command)
        sut.undo()

        // Reset the flag to test redo
        command.executeWasCalled = false

        // When: Redo the command
        sut.redo()

        // Then: Command should be re-executed
        XCTAssertTrue(command.executeWasCalled, "Command's execute() should be called on redo")
        XCTAssertTrue(sut.canUndo, "canUndo should be true after redo")
        XCTAssertFalse(sut.canRedo, "canRedo should be false after redoing last undone command")
    }

    /// Test: T006-010 - Redo updates descriptions
    func testRedoWhenCommandRedone​ThenDescriptionsUpdated() {
        // Given: An executed and undone command
        let command = MockCommand(description: "Move")
        sut.execute(command)
        sut.undo()

        // When: Redo the command
        sut.redo()

        // Then: Descriptions should be updated
        XCTAssertEqual(sut.undoDescription, "Move", "undoDescription should match redone command")
        XCTAssertNil(sut.redoDescription, "redoDescription should be nil after redoing last command")
    }

    /// Test: T006-011 - Multiple redo operations work correctly
    func testRedoWhenMultipleCommandsRedone​ThenStackMaintained() {
        // Given: Multiple commands that were undone
        let command1 = MockCommand(description: "Command 1")
        let command2 = MockCommand(description: "Command 2")

        sut.execute(command1)
        sut.execute(command2)
        sut.undo()
        sut.undo()

        // When: Redo once
        sut.redo()

        // Then: Should be able to redo again
        XCTAssertTrue(sut.canRedo, "Should still be able to redo")
        XCTAssertEqual(sut.undoDescription, "Command 1", "undoDescription should be Command 1")
        XCTAssertEqual(sut.redoDescription, "Command 2", "redoDescription should be Command 2")

        sut.redo()

        XCTAssertFalse(sut.canRedo, "Should not be able to redo anymore")
        XCTAssertEqual(sut.undoDescription, "Command 2", "undoDescription should be Command 2")
        XCTAssertNil(sut.redoDescription, "redoDescription should be nil")
    }

    // MARK: - FR-006: Execute Clears Redo Stack

    /// Test: T007-001 - Execute new command clears redo stack
    func testExecuteWhenNewCommandExecutedAfterUndoThenRedoStackCleared() {
        // Given: Commands that were undone
        let command1 = MockCommand(description: "Original")
        let command2 = MockCommand(description: "Undone")

        sut.execute(command1)
        sut.execute(command2)
        sut.undo()

        XCTAssertTrue(sut.canRedo, "canRedo should be true before new execute")

        // When: Execute a new command
        let newCommand = MockCommand(description: "New Command")
        sut.execute(newCommand)

        // Then: Redo stack should be cleared
        XCTAssertFalse(sut.canRedo, "canRedo should be false after executing new command")
        XCTAssertNil(sut.redoDescription, "redoDescription should be nil")
        XCTAssertEqual(sut.undoDescription, "New Command", "undoDescription should be the new command")
    }

    /// Test: T007-002 - Execute after multiple undos clears entire redo stack
    func testExecuteWhenNewCommandExecutedAfterMultipleUndosThenEntireRedoStackCleared() {
        // Given: Multiple commands that were undone
        let command1 = MockCommand(description: "Command 1")
        let command2 = MockCommand(description: "Command 2")
        let command3 = MockCommand(description: "Command 3")

        sut.execute(command1)
        sut.execute(command2)
        sut.execute(command3)
        sut.undo()
        sut.undo()

        // When: Execute a new command
        let newCommand = MockCommand(description: "Branching Command")
        sut.execute(newCommand)

        // Then: Cannot redo any of the undone commands
        XCTAssertFalse(sut.canRedo, "canRedo should be false")
        XCTAssertNil(sut.redoDescription, "redoDescription should be nil")

        // And: Can still undo to previous state
        XCTAssertTrue(sut.canUndo, "canUndo should be true")
        XCTAssertEqual(sut.undoDescription, "Branching Command", "undoDescription should be the new command")
    }

    // MARK: - Edge Cases

    /// Test: Edge case - Undo when nothing to undo
    func testUndoWhenNothingToUndoThenNoAction() {
        // Given: Empty command history

        // When: Try to undo
        sut.undo()

        // Then: Should handle gracefully
        XCTAssertFalse(sut.canUndo, "canUndo should remain false")
        XCTAssertFalse(sut.canRedo, "canRedo should remain false")
    }

    /// Test: Edge case - Redo when nothing to redo
    func testRedoWhenNothingToRedoThenNoAction() {
        // Given: Command history with no redo available
        let command = MockCommand(description: "Test")
        sut.execute(command)

        // When: Try to redo
        sut.redo()

        // Then: Should handle gracefully
        XCTAssertTrue(sut.canUndo, "canUndo should remain true")
        XCTAssertFalse(sut.canRedo, "canRedo should remain false")
    }

    /// Test: Stress test - Large number of operations
    func testExecuteWhenManyCommandsExecutedThenAllTracked() {
        // Given: Many commands
        var commands: [MockCommand] = []
        for i in 1...100 {
            let command = MockCommand(description: "Command \(i)")
            commands.append(command)
            sut.execute(command)
        }

        // When: Check final state

        // Then: Should track the latest command
        XCTAssertTrue(sut.canUndo, "canUndo should be true")
        XCTAssertEqual(sut.undoDescription, "Command 100", "undoDescription should be the last command")

        // And: Can undo all commands
        for i in (1...100).reversed() {
            XCTAssertTrue(sut.canUndo, "Should be able to undo command \(i)")
            XCTAssertEqual(sut.undoDescription, "Command \(i)", "undoDescription should match")
            sut.undo()
        }

        XCTAssertFalse(sut.canUndo, "canUndo should be false after all undos")
        XCTAssertTrue(sut.canRedo, "canRedo should be true")
    }
}

// MARK: - Mock Command

/// Mock implementation of Command protocol for testing
class MockCommand: Command {
    let commandDescription: String
    var executeWasCalled = false
    var undoWasCalled = false

    init(description: String) {
        self.commandDescription = description
    }

    func execute() {
        executeWasCalled = true
    }

    func undo() {
        undoWasCalled = true
    }

    var description: String {
        return commandDescription
    }
}

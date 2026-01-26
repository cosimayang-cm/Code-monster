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

    /// Test: Stress test - Random interleaved undo/redo operations
    func testRandomUndoRedoWhenInterleavedThenStateConsistent() {
        // Given: Execute some initial commands
        var expectedUndoCount = 0

        for i in 1...20 {
            let command = MockCommand(description: "Initial \(i)")
            sut.execute(command)
            expectedUndoCount += 1
        }

        // When: Random interleaved operations (deterministic seed for reproducibility)
        //
        // srand48(42) 說明：
        // - srand48 = Seed Random 48-bit，設定 48 位元隨機數產生器的種子
        // - 42 是種子值（任意數字皆可，42 是程式界的梗：生命、宇宙及萬事萬物的終極答案）
        // - drand48() 會產生 0.0 ~ 1.0 之間的隨機小數
        //
        // 為什麼要用固定種子？
        // - 相同種子 = 相同的「隨機」序列，每次測試都會產生一模一樣的操作順序
        // - 好處：測試結果可重現，如果失敗可以 debug，避免「有時過有時不過」的不穩定測試
        //
        // 範例：
        //   srand48(42)
        //   drand48() → 0.374540...（每次執行都一樣）
        //   drand48() → 0.950714...（每次執行都一樣）
        //
        srand48(42)

        for _ in 1...100 {
            let action = Int(drand48() * 3)  // 0, 1, or 2

            switch action {
            case 0:  // Execute new command
                let command = MockCommand(description: "Random")
                sut.execute(command)
                expectedUndoCount += 1

            case 1:  // Undo if possible
                if sut.canUndo {
                    sut.undo()
                    expectedUndoCount -= 1
                }

            case 2:  // Redo if possible
                if sut.canRedo {
                    sut.redo()
                    expectedUndoCount += 1
                }

            default:
                break
            }

            // Invariant checks after each operation
            XCTAssertEqual(sut.canUndo, expectedUndoCount > 0,
                           "canUndo should match expected state")

            if sut.canUndo {
                XCTAssertNotNil(sut.undoDescription,
                               "undoDescription should exist when canUndo is true")
            }
        }
    }

    /// Test: Stress test - Rapid undo/redo cycling
    func testRapidUndoRedoCycleWhenRepeatedThenStateCorrect() {
        // Given: A set of commands
        for i in 1...10 {
            sut.execute(MockCommand(description: "Command \(i)"))
        }

        // When: Rapidly cycle undo/redo multiple times
        for cycle in 1...5 {
            // Undo all
            while sut.canUndo {
                sut.undo()
            }
            XCTAssertFalse(sut.canUndo, "Cycle \(cycle): Should not be able to undo")
            XCTAssertTrue(sut.canRedo, "Cycle \(cycle): Should be able to redo")
            XCTAssertEqual(sut.redoDescription, "Command 1",
                          "Cycle \(cycle): First command should be next redo")

            // Redo all
            while sut.canRedo {
                sut.redo()
            }
            XCTAssertTrue(sut.canUndo, "Cycle \(cycle): Should be able to undo")
            XCTAssertFalse(sut.canRedo, "Cycle \(cycle): Should not be able to redo")
            XCTAssertEqual(sut.undoDescription, "Command 10",
                          "Cycle \(cycle): Last command should be next undo")
        }
    }

    /// Test: Edge case - Execute interrupts undo/redo sequence
    func testExecuteDuringUndoRedoWhenNewCommandThenRedoCleared() {
        // Given: Commands with partial undo
        for i in 1...5 {
            sut.execute(MockCommand(description: "Original \(i)"))
        }

        sut.undo()  // undo Original 5
        sut.undo()  // undo Original 4
        sut.undo()  // undo Original 3

        XCTAssertEqual(sut.undoDescription, "Original 2")
        XCTAssertEqual(sut.redoDescription, "Original 3")

        // When: Execute new command mid-sequence
        sut.execute(MockCommand(description: "Interrupt"))

        // Then: Redo stack cleared, can only undo
        XCTAssertFalse(sut.canRedo, "Redo should be cleared after new execute")
        XCTAssertEqual(sut.undoDescription, "Interrupt")

        // Undo the interrupt
        sut.undo()
        XCTAssertEqual(sut.undoDescription, "Original 2")

        // Original 3, 4, 5 are gone forever
        sut.redo()
        XCTAssertEqual(sut.undoDescription, "Interrupt")
        XCTAssertFalse(sut.canRedo)
    }

    // MARK: - FR-020: CompositeCommand Tests

    /// Test: T078-001 - CompositeCommand executes all sub-commands sequentially
    func testCompositeCommandWhenExecutedThenAllSubCommandsExecuted() {
        // Given: A composite command with multiple sub-commands
        let command1 = MockCommand(description: "Sub 1")
        let command2 = MockCommand(description: "Sub 2")
        let command3 = MockCommand(description: "Sub 3")

        let composite = CompositeCommand(
            commands: [command1, command2, command3],
            description: "複合操作"
        )

        // When: Execute the composite command
        sut.execute(composite)

        // Then: All sub-commands should be executed
        XCTAssertTrue(command1.executeWasCalled, "Sub-command 1 should be executed")
        XCTAssertTrue(command2.executeWasCalled, "Sub-command 2 should be executed")
        XCTAssertTrue(command3.executeWasCalled, "Sub-command 3 should be executed")
    }

    /// Test: T079-001 - CompositeCommand undoes all sub-commands in reverse order
    func testCompositeCommandWhenUndoThenAllSubCommandsUndoneInReverse() {
        // Given: A composite command that was executed
        let command1 = OrderTrackingMockCommand(description: "Sub 1")
        let command2 = OrderTrackingMockCommand(description: "Sub 2")
        let command3 = OrderTrackingMockCommand(description: "Sub 3")

        OrderTrackingMockCommand.undoOrder = []

        let composite = CompositeCommand(
            commands: [command1, command2, command3],
            description: "複合操作"
        )

        sut.execute(composite)

        // When: Undo the composite command
        sut.undo()

        // Then: All sub-commands should be undone in reverse order
        XCTAssertTrue(command1.undoWasCalled, "Sub-command 1 should be undone")
        XCTAssertTrue(command2.undoWasCalled, "Sub-command 2 should be undone")
        XCTAssertTrue(command3.undoWasCalled, "Sub-command 3 should be undone")

        // Verify reverse order: 3, 2, 1
        XCTAssertEqual(OrderTrackingMockCommand.undoOrder, ["Sub 3", "Sub 2", "Sub 1"],
                       "Sub-commands should be undone in reverse order")
    }

    /// Test: T080-001 - CompositeCommand description is correct
    func testCompositeCommandWhenCreatedThenDescriptionCorrect() {
        // Given: A composite command
        let composite = CompositeCommand(description: "批次操作")

        // Then: Description should match
        XCTAssertEqual(composite.description, "批次操作")
    }

    /// Test: T081-001 - CompositeCommand can add commands dynamically
    func testCompositeCommandWhenAddCommandThenCountIncreases() {
        // Given: An empty composite command
        let composite = CompositeCommand(description: "Dynamic")

        // When: Add commands
        composite.add(MockCommand(description: "Cmd 1"))
        composite.add(MockCommand(description: "Cmd 2"))

        // Then: Count should be correct
        XCTAssertEqual(composite.count, 2)
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

/// Mock command that tracks undo order for testing CompositeCommand
class OrderTrackingMockCommand: Command {
    static var undoOrder: [String] = []

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
        OrderTrackingMockCommand.undoOrder.append(commandDescription)
    }

    var description: String {
        return commandDescription
    }
}

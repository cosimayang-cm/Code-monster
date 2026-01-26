//
//  CommandHistoryObserverTests.swift
//  CodeMonsterTests
//
//  Created by Claude on 2026/1/23.
//

import XCTest
@testable import CodeMonster

/// Test suite for CommandHistory Observer Pattern
/// Tests cover FR-025 through FR-027 from UI Layer specification
final class CommandHistoryObserverTests: XCTestCase {

    var sut: CommandHistory!

    override func setUp() {
        super.setUp()
        sut = CommandHistory()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - FR-025: CommandHistoryObserver Protocol Tests

    /// Test: T091-001 - Observer receives notification after execute
    func testExecuteWhenCommandExecutedThenObserverNotified() {
        // Given: An observer registered with CommandHistory
        let observer = MockCommandHistoryObserver()
        sut.addObserver(observer)

        // When: Execute a command
        let command = MockCommand(description: "Test")
        sut.execute(command)

        // Then: Observer should be notified
        XCTAssertTrue(observer.didReceiveNotification, "Observer should be notified after execute")
        XCTAssertEqual(observer.notificationCount, 1, "Observer should be notified exactly once")
        XCTAssertTrue(observer.lastHistoryCanUndo ?? false, "canUndo should be true in notification")
    }

    /// Test: T091-002 - Observer receives notification after undo
    func testUndoWhenCommandUndone​ThenObserverNotified() {
        // Given: An observer and an executed command
        let observer = MockCommandHistoryObserver()
        let command = MockCommand(description: "Test")
        sut.execute(command)

        sut.addObserver(observer)

        // When: Undo the command
        sut.undo()

        // Then: Observer should be notified
        XCTAssertTrue(observer.didReceiveNotification, "Observer should be notified after undo")
        XCTAssertEqual(observer.notificationCount, 1, "Observer should be notified exactly once")
        XCTAssertFalse(observer.lastHistoryCanUndo ?? true, "canUndo should be false in notification")
        XCTAssertTrue(observer.lastHistoryCanRedo ?? false, "canRedo should be true in notification")
    }

    /// Test: T091-003 - Observer receives notification after redo
    func testRedoWhenCommandRedone​ThenObserverNotified() {
        // Given: An observer and an undone command
        let observer = MockCommandHistoryObserver()
        let command = MockCommand(description: "Test")
        sut.execute(command)
        sut.undo()

        sut.addObserver(observer)

        // When: Redo the command
        sut.redo()

        // Then: Observer should be notified
        XCTAssertTrue(observer.didReceiveNotification, "Observer should be notified after redo")
        XCTAssertTrue(observer.lastHistoryCanUndo ?? false, "canUndo should be true in notification")
        XCTAssertFalse(observer.lastHistoryCanRedo ?? true, "canRedo should be false in notification")
    }

    // MARK: - FR-026: Observer Management Tests

    /// Test: T091-004 - Can add multiple observers
    func testAddObserverWhenMultipleObserversAddedThenAllNotified() {
        // Given: Multiple observers
        let observer1 = MockCommandHistoryObserver()
        let observer2 = MockCommandHistoryObserver()
        let observer3 = MockCommandHistoryObserver()

        sut.addObserver(observer1)
        sut.addObserver(observer2)
        sut.addObserver(observer3)

        // When: Execute a command
        sut.execute(MockCommand(description: "Test"))

        // Then: All observers should be notified
        XCTAssertTrue(observer1.didReceiveNotification, "Observer 1 should be notified")
        XCTAssertTrue(observer2.didReceiveNotification, "Observer 2 should be notified")
        XCTAssertTrue(observer3.didReceiveNotification, "Observer 3 should be notified")
    }

    /// Test: T091-005 - Can remove observer
    func testRemoveObserverWhenObserverRemovedThenNoLongerNotified() {
        // Given: An observer that was added and then removed
        let observer = MockCommandHistoryObserver()
        sut.addObserver(observer)
        sut.removeObserver(observer)

        // When: Execute a command
        sut.execute(MockCommand(description: "Test"))

        // Then: Observer should NOT be notified
        XCTAssertFalse(observer.didReceiveNotification, "Removed observer should not be notified")
    }

    /// Test: T091-006 - Remove specific observer leaves others
    func testRemoveObserverWhenOneRemovedThenOthersStillNotified() {
        // Given: Multiple observers, one is removed
        let observer1 = MockCommandHistoryObserver()
        let observer2 = MockCommandHistoryObserver()

        sut.addObserver(observer1)
        sut.addObserver(observer2)
        sut.removeObserver(observer1)

        // When: Execute a command
        sut.execute(MockCommand(description: "Test"))

        // Then: Only observer2 should be notified
        XCTAssertFalse(observer1.didReceiveNotification, "Removed observer should not be notified")
        XCTAssertTrue(observer2.didReceiveNotification, "Remaining observer should be notified")
    }

    // MARK: - FR-027: Weak Reference Tests

    /// Test: T091-007 - Observer is held weakly (no retain cycle)
    func testObserverWhenDeallocatedThenNoNotificationSent() {
        // Given: A weak observer that gets deallocated
        var observer: MockCommandHistoryObserver? = MockCommandHistoryObserver()
        weak var weakObserver = observer

        sut.addObserver(observer!)

        // When: Observer is deallocated
        observer = nil

        // Then: WeakObserver reference should be nil (no retain cycle)
        XCTAssertNil(weakObserver, "Observer should be deallocated (weak reference)")

        // And: Execute should not crash
        sut.execute(MockCommand(description: "Test"))
        // No crash means weak reference works correctly
    }

    /// Test: T091-008 - Multiple operations notify correctly
    func testNotificationsWhenMultipleOperationsThenCorrectCountReceived() {
        // Given: An observer
        let observer = MockCommandHistoryObserver()
        sut.addObserver(observer)

        // When: Perform multiple operations
        sut.execute(MockCommand(description: "Cmd 1"))
        sut.execute(MockCommand(description: "Cmd 2"))
        sut.undo()
        sut.redo()
        sut.undo()

        // Then: Observer should receive 5 notifications
        XCTAssertEqual(observer.notificationCount, 5, "Should receive 5 notifications")
    }

    // MARK: - Integration Tests (T099)

    /// Test: T099-001 - Observer notification flow integration
    func testIntegrationWhenFullWorkflowThenObserverStatesCorrect() {
        // Given: An observer tracking all state changes
        let observer = MockCommandHistoryObserver()
        sut.addObserver(observer)

        // Initial state
        XCTAssertFalse(sut.canUndo)
        XCTAssertFalse(sut.canRedo)

        // When: Execute first command
        sut.execute(MockCommand(description: "Insert Text"))

        // Then: Observer should see canUndo = true, canRedo = false
        XCTAssertTrue(observer.lastHistoryCanUndo ?? false)
        XCTAssertFalse(observer.lastHistoryCanRedo ?? true)

        // When: Execute second command
        sut.execute(MockCommand(description: "Delete Text"))

        // Then: Observer should still see canUndo = true, canRedo = false
        XCTAssertTrue(observer.lastHistoryCanUndo ?? false)
        XCTAssertFalse(observer.lastHistoryCanRedo ?? true)

        // When: Undo
        sut.undo()

        // Then: Observer should see canUndo = true, canRedo = true
        XCTAssertTrue(observer.lastHistoryCanUndo ?? false)
        XCTAssertTrue(observer.lastHistoryCanRedo ?? false)

        // When: Undo again (last command)
        sut.undo()

        // Then: Observer should see canUndo = false, canRedo = true
        XCTAssertFalse(observer.lastHistoryCanUndo ?? true)
        XCTAssertTrue(observer.lastHistoryCanRedo ?? false)

        // When: Redo
        sut.redo()

        // Then: Observer should see canUndo = true, canRedo = true
        XCTAssertTrue(observer.lastHistoryCanUndo ?? false)
        XCTAssertTrue(observer.lastHistoryCanRedo ?? false)

        // When: Execute new command (clears redo stack)
        sut.execute(MockCommand(description: "New Action"))

        // Then: Observer should see canUndo = true, canRedo = false
        XCTAssertTrue(observer.lastHistoryCanUndo ?? false)
        XCTAssertFalse(observer.lastHistoryCanRedo ?? true)
    }

    /// Test: T099-002 - Observer UI button state simulation
    func testUIButtonStateSimulationWhenOperationsThenStatesMatch() {
        // Given: An observer simulating UI button states
        let uiObserver = UIButtonStateObserver()
        sut.addObserver(uiObserver)

        // Initial: Both buttons disabled
        XCTAssertFalse(uiObserver.undoButtonEnabled)
        XCTAssertFalse(uiObserver.redoButtonEnabled)

        // Execute command: Undo enabled, Redo disabled
        sut.execute(MockCommand(description: "Action"))
        XCTAssertTrue(uiObserver.undoButtonEnabled)
        XCTAssertFalse(uiObserver.redoButtonEnabled)

        // Undo: Undo disabled, Redo enabled
        sut.undo()
        XCTAssertFalse(uiObserver.undoButtonEnabled)
        XCTAssertTrue(uiObserver.redoButtonEnabled)

        // Redo: Undo enabled, Redo disabled
        sut.redo()
        XCTAssertTrue(uiObserver.undoButtonEnabled)
        XCTAssertFalse(uiObserver.redoButtonEnabled)
    }
}

// MARK: - Mock Observer

/// Mock implementation of CommandHistoryObserver for testing
final class MockCommandHistoryObserver: CommandHistoryObserver {
    var didReceiveNotification = false
    var notificationCount = 0
    var lastHistoryCanUndo: Bool?
    var lastHistoryCanRedo: Bool?

    func commandHistoryDidChange(_ history: CommandHistory) {
        didReceiveNotification = true
        notificationCount += 1
        lastHistoryCanUndo = history.canUndo
        lastHistoryCanRedo = history.canRedo
    }
}

/// Mock observer simulating UI button state management
final class UIButtonStateObserver: CommandHistoryObserver {
    var undoButtonEnabled = false
    var redoButtonEnabled = false

    func commandHistoryDidChange(_ history: CommandHistory) {
        undoButtonEnabled = history.canUndo
        redoButtonEnabled = history.canRedo
    }
}

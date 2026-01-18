# Implementation Tasks: 彈窗連鎖顯示機制 (Popup Response Chain)

**Feature**: Popup Response Chain using Chain of Responsibility Pattern
**Architecture**: Simplified Design (9 files, focusing on core Chain logic)
**Created**: 2025-01-18
**Pattern**: Chain of Responsibility

---

## Overview

This task list implements a simplified Popup Response Chain system with 5 popup handlers. The implementation focuses on the Chain of Responsibility pattern without UI complexity, using `print()` to simulate popup displays.

**Key Simplifications**:
- Total: 9 files (vs. original 22 classes)
- No UI ViewControllers (using console output)
- No UserStateManager (direct UserDefaults usage)
- No PopupPresenter (focusing on chain logic)
- External handler injection in Manager (decoupled design)

---

## Implementation Strategy

### MVP Scope
**Phase 1-3**: Core chain functionality with all 5 handlers
- Delivers working Chain of Responsibility pattern
- Console-based popup simulation
- Complete handler chain with proper sequencing

### Incremental Delivery
1. **Phase 1**: Project setup and structure
2. **Phase 2**: Core protocol and base handler (foundation for all handlers)
3. **Phase 3**: Individual handlers (parallelizable)
4. **Phase 4**: Chain manager with external injection
5. **Phase 5**: Testing and validation

---

## Task Breakdown

### Phase 1: Project Setup

**Goal**: Initialize Swift package structure and create directory layout

**Tasks**:
- [X] T001 Create Package.swift with Swift 5.9+ configuration in yuta/monster2/
- [X] T002 Create directory structure: Sources/{Protocols,Handlers,Models}
- [X] T003 Create directory structure: Tests/HandlerTests
- [X] T004 Create .gitignore with Swift/Xcode patterns in yuta/monster2/

**Completion Criteria**:
- ✅ Package.swift compiles successfully
- ✅ Directory structure matches plan.md specification
- ✅ `swift build` runs without errors

---

### Phase 2: Foundational Components

**Goal**: Implement core protocol, base handler, and data model (blocking prerequisites)

**Tasks**:
- [X] T005 Implement PopupHandling protocol in Sources/Protocols/PopupHandling.swift
- [X] T006 Implement BasePopupHandler with chain logic in Sources/Handlers/BasePopupHandler.swift
- [X] T007 Implement UserContext struct in Sources/Models/UserContext.swift

**Completion Criteria**:
- ✅ PopupHandling protocol defines next, shouldHandle, handle methods
- ✅ BasePopupHandler implements default chain traversal logic
- ✅ UserContext contains all 5 boolean flags
- ✅ Code compiles with `swift build`

**Implementation Notes**:
- PopupHandling: Include setNext() extension for fluent API
- BasePopupHandler: Use weak reference for next property
- BasePopupHandler: Implement passToNext() as private helper
- UserContext: All properties mutable for testing

---

### Phase 3: Handler Implementations

**Goal**: Implement all 5 concrete handlers (independently testable)

**User Story**: FR-1 through FR-9 - Core popup chain functionality

**Tasks**:
- [X] T008 [P] Implement TutorialHandler in Sources/Handlers/TutorialHandler.swift
- [X] T009 [P] Implement InterstitialAdHandler in Sources/Handlers/InterstitialAdHandler.swift
- [X] T010 [P] Implement NewFeatureHandler in Sources/Handlers/NewFeatureHandler.swift
- [X] T011 [P] Implement DailyCheckInHandler in Sources/Handlers/DailyCheckInHandler.swift
- [X] T012 [P] Implement PredictionResultHandler in Sources/Handlers/PredictionResultHandler.swift

**Completion Criteria**:
- ✅ Each handler overrides shouldHandle() with correct logic
- ✅ Each handler overrides showPopup() with print() simulation
- ✅ TutorialHandler checks !context.hasSeenTutorial
- ✅ InterstitialAdHandler checks !context.hasSeenInterstitialAd
- ✅ NewFeatureHandler checks !context.hasSeenNewFeature
- ✅ DailyCheckInHandler checks !context.hasCheckedInToday
- ✅ PredictionResultHandler checks context.hasPredictionResult
- ✅ All handlers compile independently

**Implementation Notes**:
- Each handler prints: "[彈窗] {Name}" when displayed
- TutorialHandler: Updates UserDefaults.standard "hasSeenTutorial"
- InterstitialAdHandler: Updates UserDefaults.standard "hasSeenInterstitialAd"
- NewFeatureHandler: Updates UserDefaults.standard "hasSeenNewFeature"
- DailyCheckInHandler: Updates UserDefaults.standard "lastCheckInDate" with Date()
- PredictionResultHandler: No state update (read-only)

---

### Phase 4: Chain Manager

**Goal**: Implement manager with external handler injection

**User Story**: FR-13, FR-14 - Manager responsibilities

**Tasks**:
- [X] T013 Implement PopupChainManager with external injection in Sources/PopupChainManager.swift
- [X] T014 Add init(handlers:) to assemble chain from array
- [X] T015 Add startChain(with:completion:) method

**Completion Criteria**:
- ✅ Manager accepts [PopupHandling] array in initializer
- ✅ Manager chains handlers using setNext() in sequence
- ✅ Manager stores first handler reference
- ✅ startChain() delegates to first handler or calls completion
- ✅ Empty handler array handled gracefully
- ✅ Full integration compiles with `swift build`

**Implementation Notes**:
- Use guard statement for empty array check
- Loop through handlers[0..<count-1] to chain
- Store firstHandler as optional PopupHandling?
- No knowledge of concrete handler types

---

### Phase 5: Unit Tests

**Goal**: Test each handler and chain integration

**User Story**: FR-11 - Handler independent testing

**Tasks**:
- [X] T016 [P] Write test: testShouldHandleWhenTutorialNotSeenThenReturnsTrue in Tests/HandlerTests/TutorialHandlerTests.swift
- [X] T017 [P] Write test: testShouldHandleWhenTutorialSeenThenReturnsFalse in Tests/HandlerTests/TutorialHandlerTests.swift
- [X] T018 [P] Write test: testShouldHandleWhenInterstitialNotSeenThenReturnsTrue in Tests/HandlerTests/InterstitialAdHandlerTests.swift
- [X] T019 [P] Write test: testShouldHandleWhenInterstitialSeenThenReturnsFalse in Tests/HandlerTests/InterstitialAdHandlerTests.swift
- [X] T020 [P] Write test: testShouldHandleWhenNewFeatureNotSeenThenReturnsTrue in Tests/HandlerTests/NewFeatureHandlerTests.swift
- [X] T021 [P] Write test: testShouldHandleWhenNewFeatureSeenThenReturnsFalse in Tests/HandlerTests/NewFeatureHandlerTests.swift
- [X] T022 [P] Write test: testShouldHandleWhenNotCheckedInTodayThenReturnsTrue in Tests/HandlerTests/DailyCheckInHandlerTests.swift
- [X] T023 [P] Write test: testShouldHandleWhenCheckedInTodayThenReturnsFalse in Tests/HandlerTests/DailyCheckInHandlerTests.swift
- [X] T024 [P] Write test: testShouldHandleWhenHasPredictionResultThenReturnsTrue in Tests/HandlerTests/PredictionResultHandlerTests.swift
- [X] T025 [P] Write test: testShouldHandleWhenNoPredictionResultThenReturnsFalse in Tests/HandlerTests/PredictionResultHandlerTests.swift

**Completion Criteria**:
- ✅ Each handler has 2 tests (condition met / not met)
- ✅ Tests use Given-When-Then structure
- ✅ All tests pass with `swift test`
- ✅ Tests verify shouldHandle() logic only (no UI)

**Test Structure**:
```swift
func testShouldHandleWhenTutorialNotSeenThenReturnsTrue() {
    // Given
    let context = UserContext(hasSeenTutorial: false, ...)

    // When
    let result = sut.shouldHandle(context)

    // Then
    XCTAssertTrue(result)
}
```

---

### Phase 6: Integration Tests

**Goal**: Validate complete chain behavior

**User Story**: FR-1 through FR-5 - Chain sequencing

**Tasks**:
- [X] T026 Write test: testStartChainWhenAllConditionsMetThenShowsAllPopups in Tests/ChainIntegrationTests.swift
- [X] T027 Write test: testStartChainWhenNoConditionsMetThenCompletesImmediately in Tests/ChainIntegrationTests.swift
- [X] T028 Write test: testStartChainWhenOnlyMiddleConditionMetThenShowsOnlyThatPopup in Tests/ChainIntegrationTests.swift
- [X] T029 Write test: testStartChainWithEmptyHandlersThenCompletesImmediately in Tests/ChainIntegrationTests.swift
- [X] T030 Write test: testStartChainWhenFirstHandlerOnlyThenShowsFirstOnly in Tests/ChainIntegrationTests.swift

**Completion Criteria**:
- ✅ Chain executes handlers in correct order (1→2→3→4→5)
- ✅ Handlers skip when condition not met
- ✅ All handlers execute when all conditions met
- ✅ Empty chain completes without errors
- ✅ Partial conditions show only relevant popups
- ✅ All integration tests pass

**Test Setup**:
```swift
let handlers: [PopupHandling] = [
    TutorialHandler(),
    InterstitialAdHandler(),
    NewFeatureHandler(),
    DailyCheckInHandler(),
    PredictionResultHandler()
]
manager = PopupChainManager(handlers: handlers)
```

---

### Phase 7: Usage Documentation

**Goal**: Document usage and provide examples

**Tasks**:
- [X] T031 Update README.md with usage examples
- [X] T032 Add example code for handler assembly in README.md
- [X] T033 Add console output examples in README.md
- [X] T034 Document extensibility pattern (adding 6th handler) in README.md

**Completion Criteria**:
- ✅ README shows complete usage example
- ✅ README demonstrates handler injection pattern
- ✅ README includes expected console output
- ✅ README explains how to add new handlers

**Usage Example**:
```swift
// 1. Assemble handlers
let handlers: [PopupHandling] = [
    TutorialHandler(),
    InterstitialAdHandler(),
    NewFeatureHandler(),
    DailyCheckInHandler(),
    PredictionResultHandler()
]

// 2. Create manager
let manager = PopupChainManager(handlers: handlers)

// 3. Create context
let context = UserContext(
    hasSeenTutorial: false,
    hasSeenInterstitialAd: false,
    hasSeenNewFeature: false,
    hasCheckedInToday: false,
    hasPredictionResult: true
)

// 4. Start chain
manager.startChain(with: context) {
    print("✅ 彈窗檢查完成")
}
```

---

### Phase 8: Extensibility Validation

**Goal**: Verify system can be extended without modifying existing code

**User Story**: FR-10 - Extensibility requirement

**Tasks**:
- [X] T035 Create example RatingPromptHandler in Tests/ExtensibilityTests.swift
- [X] T036 Write test: testAddingSixthHandlerDoesNotModifyExistingHandlers in Tests/ExtensibilityTests.swift
- [X] T037 Write test: testChainWithSixHandlersExecutesInOrder in Tests/ExtensibilityTests.swift

**Completion Criteria**:
- ✅ New handler added without modifying existing handlers
- ✅ New handler integrated by appending to array
- ✅ Chain executes all 6 handlers correctly
- ✅ Demonstrates Open-Closed Principle

**Extensibility Example**:
```swift
class RatingPromptHandler: BasePopupHandler {
    override func shouldHandle(_ context: UserContext) -> Bool {
        return context.shouldShowRating
    }

    override func showPopup(completion: @escaping () -> Void) {
        print("[彈窗] 評分提示")
        completion()
    }
}

// Usage: Just add to array
let handlers: [PopupHandling] = [
    TutorialHandler(),
    InterstitialAdHandler(),
    NewFeatureHandler(),
    DailyCheckInHandler(),
    PredictionResultHandler(),
    RatingPromptHandler()  // New handler
]
```

---

### Phase 9: Final Validation

**Goal**: Verify complete system meets all requirements

**Tasks**:
- [X] T038 Run all tests with `swift test` and verify 100% pass rate
- [X] T039 Verify all handlers print correct popup names
- [X] T040 Verify handler order matches specification (1→2→3→4→5)
- [X] T041 Verify empty chain completes gracefully
- [X] T042 Verify Manager knows no concrete handler types (check imports)
- [X] T043 Update plan.md checklist with completion status

**Completion Criteria**:
- ✅ All unit tests pass (10 tests)
- ✅ All integration tests pass (5 tests)
- ✅ All extensibility tests pass (2 tests)
- ✅ Console output matches expected format
- ✅ Manager has no dependencies on concrete handlers
- ✅ Code compiles with zero warnings

---

## Dependencies & Execution Order

### Critical Path
```
Phase 1 (Setup)
    ↓
Phase 2 (Foundation) - BLOCKING
    ↓
Phase 3 (Handlers) - All parallelizable after Phase 2
    ↓
Phase 4 (Manager) - Depends on Phase 2 & 3
    ↓
Phase 5 (Unit Tests) - Depends on Phase 3
    ↓
Phase 6 (Integration) - Depends on Phase 4
    ↓
Phase 7 (Documentation)
    ↓
Phase 8 (Extensibility)
    ↓
Phase 9 (Validation)
```

### Parallel Execution Opportunities

**Phase 3 - All 5 Handlers (T008-T012)**:
```bash
# Can implement simultaneously (different files, no dependencies)
- TutorialHandler.swift
- InterstitialAdHandler.swift
- NewFeatureHandler.swift
- DailyCheckInHandler.swift
- PredictionResultHandler.swift
```

**Phase 5 - All Handler Tests (T016-T025)**:
```bash
# Can write simultaneously (independent test suites)
- TutorialHandlerTests.swift
- InterstitialAdHandlerTests.swift
- NewFeatureHandlerTests.swift
- DailyCheckInHandlerTests.swift
- PredictionResultHandlerTests.swift
```

---

## Success Metrics

| Metric | Target | Validation |
|--------|--------|------------|
| Total Files | 9 source files | File count in Sources/ |
| Handler Count | 5 handlers | All implement PopupHandling |
| Test Coverage | 17+ tests | Unit + Integration + Extensibility |
| Console Output | Correct order | Manual verification of print() |
| Extensibility | Add 6th handler without edits | ExtensibilityTests pass |
| Manager Decoupling | Zero concrete imports | Check PopupChainManager imports |
| Build Success | Zero warnings | `swift build` output |
| Test Success | 100% pass rate | `swift test` output |

---

## File Checklist

### Source Files (9 total)
- [X] Sources/Protocols/PopupHandling.swift
- [X] Sources/Handlers/BasePopupHandler.swift
- [X] Sources/Handlers/TutorialHandler.swift
- [X] Sources/Handlers/InterstitialAdHandler.swift
- [X] Sources/Handlers/NewFeatureHandler.swift
- [X] Sources/Handlers/DailyCheckInHandler.swift
- [X] Sources/Handlers/PredictionResultHandler.swift
- [X] Sources/Models/UserContext.swift
- [X] Sources/PopupChainManager.swift

### Test Files
- [X] Tests/HandlerTests/TutorialHandlerTests.swift
- [X] Tests/HandlerTests/InterstitialAdHandlerTests.swift
- [X] Tests/HandlerTests/NewFeatureHandlerTests.swift
- [X] Tests/HandlerTests/DailyCheckInHandlerTests.swift
- [X] Tests/HandlerTests/PredictionResultHandlerTests.swift
- [X] Tests/IntegrationTests/ChainIntegrationTests.swift
- [X] Tests/ExtensibilityTests/ExtensibilityTests.swift

### Configuration
- [X] Package.swift
- [X] .gitignore
- [X] README.md (updated)

---

## Task Summary

**Total Tasks**: 43
- **Setup**: 4 tasks (T001-T004)
- **Foundation**: 3 tasks (T005-T007)
- **Handlers**: 5 tasks (T008-T012) - All parallelizable
- **Manager**: 3 tasks (T013-T015)
- **Unit Tests**: 10 tasks (T016-T025) - All parallelizable
- **Integration Tests**: 5 tasks (T026-T030)
- **Documentation**: 4 tasks (T031-T034)
- **Extensibility**: 3 tasks (T035-T037)
- **Validation**: 6 tasks (T038-T043)

**Parallel Opportunities**: 15 tasks marked [P]
- 5 handler implementations (Phase 3)
- 10 handler unit tests (Phase 5)

**Estimated Completion Time**:
- **Sequential**: ~4-5 hours
- **With Parallelization**: ~2-3 hours

---

## Notes

### Design Decisions Reflected in Tasks
1. **External Injection**: Manager receives handlers array (T013-T014)
2. **No UI**: All handlers use print() simulation (T008-T012)
3. **Decoupled**: Manager imports only protocol, not concrete handlers (T042)
4. **Testable**: Each handler independently testable (T016-T025)
5. **Extensible**: Adding handlers requires no existing code changes (T035-T037)

### Learning Objectives Covered
- ✅ Chain of Responsibility pattern implementation
- ✅ Protocol-oriented programming
- ✅ Dependency injection
- ✅ Open-Closed Principle
- ✅ Single Responsibility Principle
- ✅ Unit testing strategies
- ✅ Integration testing

### Simplifications from Original Plan
- ❌ No UserStateManager (using UserDefaults directly)
- ❌ No PopupPresenter (focusing on chain logic)
- ❌ No UIViewControllers (using print() simulation)
- ❌ No UserContextBuilder (simple struct initialization)
- ❌ No error handling enums (keeping it simple)

This simplified approach reduces complexity by 60% (22 → 9 files) while maintaining full Chain of Responsibility pattern learning value.

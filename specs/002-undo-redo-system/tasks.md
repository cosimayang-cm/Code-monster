# Tasks: Undo/Redo 編輯系統

**Input**: Design documents from `/specs/002-undo-redo-system/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Tests**: TDD approach explicitly required - tests MUST be written first and FAIL before implementation.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Source**: `sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/`
- **Tests**: `sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Create Undo-Redo folder structure in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/
- [x] T002 [P] Create sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/ directory
- [x] T003 [P] Create sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/TextEditor/ directory
- [x] T004 [P] Create sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/CanvasEditor/ directory
- [x] T005 [P] Create sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/ directory with TextEditor/ and CanvasEditor/ subdirectories

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core Command infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Tests for Foundational (TDD - Write First) ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [x] T006 [P] Write Command protocol tests (verify interface) in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/CommandHistoryTests.swift
- [x] T007 [P] Write CommandHistory tests for initial state in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/CommandHistoryTests.swift

### Implementation for Foundational

- [x] T008 Define Command protocol with execute(), undo(), description in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/Command.swift
- [x] T009 Implement CommandHistory class with undoStack, redoStack in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/CommandHistory.swift
- [x] T010 Implement CommandHistory.execute() method in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/CommandHistory.swift
- [x] T011 Implement CommandHistory.undo() method in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/CommandHistory.swift
- [x] T012 Implement CommandHistory.redo() method in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/CommandHistory.swift
- [x] T013 Implement canUndo, canRedo computed properties in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/CommandHistory.swift
- [x] T014 Implement undoDescription, redoDescription computed properties in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/CommandHistory.swift

**Checkpoint**: Command infrastructure ready - user story implementation can now begin

---

## Phase 3: User Story 1 - 文章編輯器基本編輯與撤銷 (Priority: P1) 🎯 MVP

**Goal**: 使用者在文章編輯器中進行文字編輯操作（插入、刪除、取代文字），並能夠撤銷和重做這些操作

**Independent Test**: 建立 TextDocument、執行插入/刪除操作、呼叫 undo/redo，驗證文件內容是否正確還原

### Tests for User Story 1 (TDD - Write First) ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [x] T015 [P] [US1] Write TextDocument tests for content management in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/TextEditor/TextDocumentTests.swift
- [x] T016 [P] [US1] Write InsertTextCommand tests for execute/undo in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/TextEditor/InsertTextCommandTests.swift
- [x] T017 [P] [US1] Write DeleteTextCommand tests for execute/undo in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/TextEditor/DeleteTextCommandTests.swift
- [x] T018 [P] [US1] Write ReplaceTextCommand tests for execute/undo in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/TextEditor/ReplaceTextCommandTests.swift

### Implementation for User Story 1

- [x] T019 [US1] Create TextDocument class with content property in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/TextEditor/TextDocument.swift
- [x] T020 [US1] Implement TextDocument.insert() method in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/TextEditor/TextDocument.swift
- [x] T021 [US1] Implement TextDocument.delete() method in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/TextEditor/TextDocument.swift
- [x] T022 [US1] Implement TextDocument.replace() method in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/TextEditor/TextDocument.swift
- [x] T023 [US1] Implement InsertTextCommand with execute/undo in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/TextEditor/InsertTextCommand.swift
- [x] T024 [US1] Implement DeleteTextCommand with execute/undo in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/TextEditor/DeleteTextCommand.swift
- [x] T025 [US1] Implement ReplaceTextCommand with execute/undo in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/TextEditor/ReplaceTextCommand.swift
- [x] T026 [US1] Write integration tests for TextEditor undo/redo flow in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/TextEditor/TextDocumentTests.swift

**Checkpoint**: User Story 1 (文章編輯器基本編輯) should be fully functional and testable independently

---

## Phase 4: User Story 2 - 畫布編輯器圖形操作與撤銷 (Priority: P1)

**Goal**: 使用者在畫布編輯器中進行圖形操作（新增、刪除、移動、縮放、變更顏色），並能夠撤銷和重做這些操作

**Independent Test**: 建立 Canvas、執行圖形操作、呼叫 undo/redo，驗證畫布狀態是否正確還原

### Tests for User Story 2 (TDD - Write First) ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [x] T027 [P] [US2] Write Color struct tests in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/CanvasEditor/CanvasTests.swift
- [x] T028 [P] [US2] Write Point, Size struct tests in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/CanvasEditor/CanvasTests.swift
- [x] T029 [P] [US2] Write Shape protocol and concrete types tests in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/CanvasEditor/CanvasTests.swift
- [x] T030 [P] [US2] Write Canvas tests for shape management in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/CanvasEditor/CanvasTests.swift
- [x] T031 [P] [US2] Write AddShapeCommand tests in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/CanvasEditor/CanvasTests.swift
- [x] T032 [P] [US2] Write RemoveShapeCommand tests in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/CanvasEditor/CanvasTests.swift
- [x] T033 [P] [US2] Write MoveShapeCommand tests in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/CanvasEditor/CanvasTests.swift
- [x] T034 [P] [US2] Write ResizeShapeCommand tests in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/CanvasEditor/CanvasTests.swift
- [x] T035 [P] [US2] Write ChangeColorCommand tests in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/CanvasEditor/CanvasTests.swift

### Implementation for User Story 2

- [x] T036 [P] [US2] Create Color struct with RGBA properties in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/CanvasEditor/Color.swift
- [x] T037 [P] [US2] Create Point and Size structs in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/CanvasEditor/Shape.swift
- [x] T038 [US2] Define Shape protocol with id, position, fillColor, strokeColor in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/CanvasEditor/Shape.swift
- [x] T039 [US2] Implement Rectangle struct conforming to Shape in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/CanvasEditor/Shape.swift
- [x] T040 [US2] Implement Circle struct conforming to Shape in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/CanvasEditor/Shape.swift
- [x] T041 [US2] Implement Line struct conforming to Shape in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/CanvasEditor/Shape.swift
- [x] T042 [US2] Create Canvas class with shapes array in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/CanvasEditor/Canvas.swift
- [x] T043 [US2] Implement Canvas.add(), remove(), shape(withId:) methods in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/CanvasEditor/Canvas.swift
- [x] T044 [US2] Implement Canvas.updateShape() method in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/CanvasEditor/Canvas.swift
- [x] T045 [US2] Implement AddShapeCommand with execute/undo in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/CanvasEditor/AddShapeCommand.swift
- [x] T046 [US2] Implement RemoveShapeCommand with execute/undo in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/CanvasEditor/RemoveShapeCommand.swift
- [x] T047 [US2] Implement MoveShapeCommand with execute/undo in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/CanvasEditor/MoveShapeCommand.swift
- [x] T048 [US2] Implement ResizeShapeCommand with execute/undo in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/CanvasEditor/ResizeShapeCommand.swift
- [x] T049 [US2] Implement ChangeColorCommand with execute/undo in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/CanvasEditor/ChangeColorCommand.swift
- [x] T050 [US2] Write integration tests for Canvas undo/redo flow in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/CanvasEditor/CanvasTests.swift

**Checkpoint**: User Stories 1 AND 2 should both work independently - Core MVP complete

---

## Phase 5: User Story 3 - 文字樣式套用與撤銷 (Priority: P2)

**Goal**: 使用者對文字編輯器中的指定範圍套用樣式（粗體、斜體、底線），並能夠撤銷和重做樣式變更

**Independent Test**: 對文字範圍套用樣式、執行 undo/redo，驗證樣式是否正確套用/移除

### Tests for User Story 3 (TDD - Write First) ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T051 [P] [US3] Write TextStyle tests for OptionSet behavior in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/TextEditor/ApplyStyleCommandTests.swift
- [ ] T052 [P] [US3] Write TextStyleRange tests in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/TextEditor/ApplyStyleCommandTests.swift
- [ ] T053 [P] [US3] Write ApplyStyleCommand tests for execute/undo in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/TextEditor/ApplyStyleCommandTests.swift

### Implementation for User Story 3

- [ ] T054 [US3] Create TextStyle OptionSet with bold, italic, underline in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/TextEditor/TextStyle.swift
- [ ] T055 [US3] Create TextStyleRange struct in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/TextEditor/TextStyle.swift
- [ ] T056 [US3] Add styles property to TextDocument in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/TextEditor/TextDocument.swift
- [ ] T057 [US3] Implement TextDocument.applyStyle() method in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/TextEditor/TextDocument.swift
- [ ] T058 [US3] Implement TextDocument.removeStyle() method in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/TextEditor/TextDocument.swift
- [ ] T059 [US3] Implement ApplyStyleCommand with execute/undo in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/TextEditor/ApplyStyleCommand.swift
- [ ] T060 [US3] Write integration tests for style undo/redo flow in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/TextEditor/ApplyStyleCommandTests.swift

**Checkpoint**: User Story 3 should work independently

---

## Phase 6: User Story 4 - Undo/Redo 狀態顯示 (Priority: P2)

**Goal**: 系統能夠正確顯示目前是否可以執行 Undo/Redo，以及下一個將被撤銷/重做的操作描述

**Independent Test**: 檢查 canUndo/canRedo 屬性和 undoDescription/redoDescription 是否正確反映狀態

### Tests for User Story 4 (TDD - Write First) ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T061 [P] [US4] Write tests for canUndo/canRedo edge cases in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/CommandHistoryTests.swift
- [ ] T062 [P] [US4] Write tests for undoDescription/redoDescription accuracy in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/CommandHistoryTests.swift
- [ ] T063 [P] [US4] Write tests for redo stack clearing on new execute in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/CommandHistoryTests.swift

### Implementation for User Story 4

- [ ] T064 [US4] Add description property to InsertTextCommand in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/TextEditor/InsertTextCommand.swift
- [ ] T065 [US4] Add description property to DeleteTextCommand in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/TextEditor/DeleteTextCommand.swift
- [ ] T066 [US4] Add description property to ReplaceTextCommand in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/TextEditor/ReplaceTextCommand.swift
- [ ] T067 [US4] Add description property to ApplyStyleCommand in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/TextEditor/ApplyStyleCommand.swift
- [ ] T068 [P] [US4] Add description property to all Canvas commands in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/CanvasEditor/*.swift
- [ ] T069 [US4] Write integration tests for state display accuracy in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/CommandHistoryTests.swift

**Checkpoint**: User Story 4 should work independently - UI can now display undo/redo state

---

## Phase 7: User Story 5 - 命令合併 (Priority: P3)

**Goal**: 連續的同類型操作能夠合併為一個命令，讓 Undo 時能一次撤銷整批操作

**Independent Test**: 連續輸入字元後執行一次 Undo，驗證是否一次撤銷所有連續輸入

### Tests for User Story 5 (TDD - Write First) ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T070 [P] [US5] Write CoalescibleCommand protocol tests in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/CommandHistoryTests.swift
- [ ] T071 [P] [US5] Write tests for consecutive InsertTextCommand coalescing in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/TextEditor/InsertTextCommandTests.swift
- [ ] T072 [P] [US5] Write tests for consecutive MoveShapeCommand coalescing in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/CanvasEditor/MoveShapeCommandTests.swift

### Implementation for User Story 5

- [ ] T073 [US5] Define CoalescibleCommand protocol in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/Command.swift
- [ ] T074 [US5] Implement coalescing logic in CommandHistory.execute() in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/CommandHistory.swift
- [ ] T075 [US5] Make InsertTextCommand conform to CoalescibleCommand in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/TextEditor/InsertTextCommand.swift
- [ ] T076 [US5] Make MoveShapeCommand conform to CoalescibleCommand in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/CanvasEditor/MoveShapeCommand.swift
- [ ] T077 [US5] Write integration tests for coalescing flow in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/CommandHistoryTests.swift

**Checkpoint**: User Story 5 should work independently

---

## Phase 8: User Story 6 - 命令群組 (Priority: P3)

**Goal**: 多個命令可以組合成一個原子操作，執行時依序執行，撤銷時反序撤銷

**Independent Test**: 建立 CompositeCommand、執行、然後 Undo，驗證所有子命令是否被正確撤銷

### Tests for User Story 6 (TDD - Write First) ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T078 [P] [US6] Write CompositeCommand tests for sequential execute in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/CommandHistoryTests.swift
- [ ] T079 [P] [US6] Write CompositeCommand tests for reverse undo in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/CommandHistoryTests.swift

### Implementation for User Story 6

- [ ] T080 [US6] Implement CompositeCommand class in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/CompositeCommand.swift
- [ ] T081 [US6] Implement CompositeCommand.execute() with sequential execution in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/CompositeCommand.swift
- [ ] T082 [US6] Implement CompositeCommand.undo() with reverse order in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/CompositeCommand.swift
- [ ] T083 [US6] Write integration tests for composite command flow in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/CommandHistoryTests.swift

**Checkpoint**: All user stories should now be independently functional

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T084 [P] Add edge case handling for empty undo/redo stack operations in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/CommandHistory.swift
- [ ] T085 [P] Add edge case handling for invalid text ranges in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/TextEditor/TextDocument.swift
- [ ] T086 [P] Add edge case handling for non-existent shape operations in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/CanvasEditor/Canvas.swift
- [ ] T087 [P] Write edge case tests for all error scenarios in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/
- [ ] T088 Run quickstart.md validation - verify all examples work correctly
- [ ] T089 Code review for Foundation-only imports (no UIKit in Model layer)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-8)**: All depend on Foundational phase completion
  - US1 (P1) and US2 (P1) can proceed in parallel after Foundational
  - US3 (P2) and US4 (P2) can proceed after Foundational (or after US1 for better context)
  - US5 (P3) and US6 (P3) can proceed after Foundational
- **Polish (Phase 9)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 3 (P2)**: Can start after Foundational (Phase 2) - Builds on US1's TextDocument
- **User Story 4 (P2)**: Can start after Foundational (Phase 2) - Uses commands from US1/US2
- **User Story 5 (P3)**: Can start after Foundational (Phase 2) - Extends US1/US2 commands
- **User Story 6 (P3)**: Can start after Foundational (Phase 2) - Independent of other stories

### Within Each User Story

- Tests MUST be written FIRST and FAIL before implementation (TDD)
- Models/Receivers before Commands
- Core implementation before integration tests
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All test tasks within a story marked [P] can run in parallel
- US1 and US2 can run in parallel after Foundational phase
- US3, US4, US5, US6 can run in parallel after Foundational phase
- Within US2: Color, Point/Size structs can be created in parallel (T036, T037)
- Within US2: All command tests (T031-T035) can be written in parallel

---

## Parallel Example: User Story 2

```bash
# Launch all tests for User Story 2 together:
Task: "Write Color struct tests" (T027)
Task: "Write Point, Size struct tests" (T028)
Task: "Write Shape protocol tests" (T029)
Task: "Write Canvas tests" (T030)
Task: "Write AddShapeCommand tests" (T031)
Task: "Write RemoveShapeCommand tests" (T032)
Task: "Write MoveShapeCommand tests" (T033)
Task: "Write ResizeShapeCommand tests" (T034)
Task: "Write ChangeColorCommand tests" (T035)

# Launch foundation types in parallel:
Task: "Create Color struct" (T036)
Task: "Create Point and Size structs" (T037)
```

---

## Implementation Strategy

### MVP First (User Stories 1 + 2 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1 (文章編輯器基本編輯)
4. Complete Phase 4: User Story 2 (畫布編輯器圖形操作)
5. **STOP and VALIDATE**: Test both stories independently
6. Deploy/demo if ready - Core undo/redo functionality complete

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Demo (Basic text editor)
3. Add User Story 2 → Test independently → Demo (Basic canvas editor)
4. Add User Story 3 → Test independently → Demo (Text styles)
5. Add User Story 4 → Test independently → Demo (State display)
6. Add User Story 5 → Test independently → Demo (Command coalescing)
7. Add User Story 6 → Test independently → Demo (Command groups)
8. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1 (Text Editor)
   - Developer B: User Story 2 (Canvas Editor)
3. After US1/US2 complete:
   - Developer A: User Story 3 (Text Styles)
   - Developer B: User Story 4 (State Display)
4. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- **TDD is mandatory**: Verify tests FAIL before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- All Model layer code MUST only import Foundation (no UIKit)
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence

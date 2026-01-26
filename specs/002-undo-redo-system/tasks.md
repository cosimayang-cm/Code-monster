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

# Part A: Model Layer (已完成 ✅)

## Phase 1: Setup (Shared Infrastructure) ✅

**Purpose**: Project initialization and basic structure

- [x] T001 Create Undo-Redo folder structure in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/
- [x] T002 [P] Create sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/ directory
- [x] T003 [P] Create sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/TextEditor/ directory
- [x] T004 [P] Create sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/CanvasEditor/ directory
- [x] T005 [P] Create sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/ directory with TextEditor/ and CanvasEditor/ subdirectories

---

## Phase 2: Foundational (Blocking Prerequisites) ✅

**Purpose**: Core Command infrastructure that MUST be complete before ANY user story can be implemented

- [x] T006 [P] Write Command protocol tests (verify interface) in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/CommandHistoryTests.swift
- [x] T007 [P] Write CommandHistory tests for initial state in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/CommandHistoryTests.swift
- [x] T008 Define Command protocol with execute(), undo(), description in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/Command.swift
- [x] T009 Implement CommandHistory class with undoStack, redoStack in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/CommandHistory.swift
- [x] T010 Implement CommandHistory.execute() method in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/CommandHistory.swift
- [x] T011 Implement CommandHistory.undo() method in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/CommandHistory.swift
- [x] T012 Implement CommandHistory.redo() method in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/CommandHistory.swift
- [x] T013 Implement canUndo, canRedo computed properties in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/CommandHistory.swift
- [x] T014 Implement undoDescription, redoDescription computed properties in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/CommandHistory.swift

---

## Phase 3-9: Model Layer User Stories (US1-US6) ✅

> All Model layer tasks (T015-T089) completed. See git history for details.

**Checkpoint**: Model layer complete - all unit tests passing

---

# Part B: UI Layer (新增)

## Phase 10: UI Setup (Shared UI Infrastructure)

**Purpose**: Create UI folder structure and Observer Pattern foundation

### Foundational - Observer Pattern (FR-025 ~ FR-027)

- [x] T090 [P] Create sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/ directory structure per plan.md
- [x] T091 [P] Write CommandHistoryObserver tests in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/CommandHistoryObserverTests.swift
- [x] T092 Create CommandHistoryObserver protocol in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/CommandHistoryObserver.swift
- [x] T093 Add WeakCommandHistoryObserver struct in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/CommandHistoryObserver.swift
- [x] T094 Add observers array to CommandHistory in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/CommandHistory.swift
- [x] T095 Implement addObserver() method in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/CommandHistory.swift
- [x] T096 Implement removeObserver() method in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/CommandHistory.swift
- [x] T097 Implement private notifyObservers() method in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/CommandHistory.swift
- [x] T098 Call notifyObservers() at end of execute(), undo(), redo() in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/CommandHistory.swift
- [x] T099 Write integration tests for Observer notification flow in sonia/CodeMonster/CodeMonster/CodeMonsterTests/UndoRedoTests/CommandHistoryObserverTests.swift

**Checkpoint**: Observer Pattern ready - UI can subscribe to CommandHistory changes

---

## Phase 11: Core UI Components (FR-037)

**Purpose**: Build reusable UI components

- [x] T100 [P] Create Color+UIKit.swift extension with uiColor computed property in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/Extensions/Color+UIKit.swift
- [x] T101 Create UndoRedoToolbarView with Undo/Redo buttons in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/Components/UndoRedoToolbarView.swift
- [x] T102 Add onUndo and onRedo closures to UndoRedoToolbarView in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/Components/UndoRedoToolbarView.swift
- [x] T103 Implement updateState(canUndo:canRedo:) method in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/Components/UndoRedoToolbarView.swift

**Checkpoint**: Core UI components ready for use in ViewControllers

---

## Phase 12: User Story 7 - Demo Hub 導覽頁面 (Priority: P1) 🎯 UI MVP

**Goal**: 使用者啟動 App 後看到 Demo Hub 頁面，可以選擇進入「文字編輯器」或「畫布編輯器」

**Independent Test**: 啟動 App 並點擊按鈕測試導覽功能

### Implementation for User Story 7 (FR-028 ~ FR-029)

- [x] T104 [US7] Create UndoRedoDemoViewController with title "Undo/Redo 系統展示" in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/UndoRedoDemoViewController.swift
- [x] T105 [US7] Add "文字編輯器" button with navigation action in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/UndoRedoDemoViewController.swift
- [x] T106 [US7] Add "畫布編輯器" button with navigation action in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/UndoRedoDemoViewController.swift
- [x] T107 [US7] Update SceneDelegate to use UndoRedoDemoViewController as root in sonia/CodeMonster/CodeMonster/CodeMonster/SceneDelegate.swift

**Checkpoint**: Demo Hub functional - can navigate to placeholder editors

---

## Phase 13: User Story 8 - 文字編輯器 UI 操作 (Priority: P1)

**Goal**: 使用者在文字編輯器頁面可以執行各種文字操作，並透過 Navigation Bar 右上角的 Undo/Redo 按鈕撤銷或重做操作

**Independent Test**: 操作編輯器介面並點擊 Undo/Redo 按鈕測試

### Implementation for User Story 8 (FR-030 ~ FR-032)

- [x] T108 [US8] Create TextEditorViewController skeleton in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/TextEditor/TextEditorViewController.swift
- [x] T109 [US8] Add UITextView for text display in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/TextEditor/TextEditorViewController.swift
- [x] T110 [US8] Add TextDocument and CommandHistory properties in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/TextEditor/TextEditorViewController.swift
- [x] T111 [US8] Conform to CommandHistoryObserver protocol in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/TextEditor/TextEditorViewController.swift
- [x] T112 [US8] Add Navigation Bar Undo/Redo buttons (right bar button items) in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/TextEditor/TextEditorViewController.swift
- [x] T113 [US8] Implement undoTapped() and redoTapped() actions in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/TextEditor/TextEditorViewController.swift
- [x] T114 [US8] Implement commandHistoryDidChange() to update button states in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/TextEditor/TextEditorViewController.swift
- [x] T115 [US8] Add bottom toolbar with Insert button in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/TextEditor/TextEditorViewController.swift
- [x] T116 [US8] Add bottom toolbar Delete button in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/TextEditor/TextEditorViewController.swift
- [x] T117 [US8] Add bottom toolbar Replace button in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/TextEditor/TextEditorViewController.swift
- [x] T118 [US8] Add bottom toolbar Style buttons (Bold, Italic, Underline) in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/TextEditor/TextEditorViewController.swift
- [x] T119 [US8] Implement insertButtonTapped() with InsertTextCommand in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/TextEditor/TextEditorViewController.swift
- [x] T120 [US8] Implement deleteButtonTapped() with DeleteTextCommand in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/TextEditor/TextEditorViewController.swift
- [x] T121 [US8] Implement replaceButtonTapped() with ReplaceTextCommand in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/TextEditor/TextEditorViewController.swift
- [x] T122 [US8] Implement styleButtonTapped() with ApplyStyleCommand in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/TextEditor/TextEditorViewController.swift
- [x] T123 [US8] Implement refreshTextView() to sync UITextView with TextDocument in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/TextEditor/TextEditorViewController.swift
- [x] T124 [US8] Connect Demo Hub navigation to TextEditorViewController in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/UndoRedoDemoViewController.swift

**Checkpoint**: Text Editor UI functional - Undo/Redo works with button state updates

---

## Phase 14: User Story 9 - 畫布編輯器 UI 操作 (Priority: P1)

**Goal**: 使用者在畫布編輯器頁面可以新增、移動圖形，並透過 Navigation Bar 右上角的 Undo/Redo 按鈕撤銷或重做操作

**Independent Test**: 操作畫布介面並點擊 Undo/Redo 按鈕測試

### Implementation for User Story 9 (FR-033 ~ FR-036)

#### ShapeView Component

- [x] T125 [P] [US9] Create ShapeView class skeleton in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/Views/ShapeView.swift
- [x] T126 [P] [US9] Add shapeId and shape properties to ShapeView in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/Views/ShapeView.swift
- [x] T127 [US9] Implement draw(_:) for Rectangle rendering in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/Views/ShapeView.swift
- [x] T128 [US9] Implement draw(_:) for Circle rendering in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/Views/ShapeView.swift
- [x] T129 [US9] Implement draw(_:) for Line rendering in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/Views/ShapeView.swift
- [x] T130 [US9] Add ShapeViewDelegate protocol for drag events in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/Views/ShapeView.swift
- [x] T131 [US9] Add UIPanGestureRecognizer for shape dragging in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/Views/ShapeView.swift
- [x] T132 [US9] Implement handlePan() gesture handler in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/Views/ShapeView.swift

#### CanvasView Container

- [x] T133 [US9] Create CanvasView class skeleton in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/Views/CanvasView.swift
- [x] T134 [US9] Add shapeViews dictionary [UUID: ShapeView] in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/Views/CanvasView.swift
- [x] T135 [US9] Add CanvasViewDelegate protocol for shape events in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/Views/CanvasView.swift
- [x] T136 [US9] Implement sync(with canvas:) method in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/Views/CanvasView.swift
- [x] T137 [US9] Implement addShapeView() helper in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/Views/CanvasView.swift
- [x] T138 [US9] Implement removeShapeView() helper in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/Views/CanvasView.swift
- [x] T139 [US9] Implement updateShapeView() helper in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/Views/CanvasView.swift

#### CanvasEditorViewController

- [x] T140 [US9] Create CanvasEditorViewController skeleton in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/CanvasEditorViewController.swift
- [x] T141 [US9] Add Canvas and CommandHistory properties in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/CanvasEditorViewController.swift
- [x] T142 [US9] Add CanvasView subview in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/CanvasEditorViewController.swift
- [x] T143 [US9] Conform to CommandHistoryObserver protocol in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/CanvasEditorViewController.swift
- [x] T144 [US9] Add Navigation Bar Undo/Redo buttons in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/CanvasEditorViewController.swift
- [x] T145 [US9] Implement undoTapped() and redoTapped() actions in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/CanvasEditorViewController.swift
- [x] T146 [US9] Implement commandHistoryDidChange() to update button states in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/CanvasEditorViewController.swift
- [x] T147 [US9] Add bottom toolbar with Add Rectangle button in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/CanvasEditorViewController.swift
- [x] T148 [US9] Add bottom toolbar Add Circle button in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/CanvasEditorViewController.swift
- [x] T149 [US9] Add bottom toolbar Add Line button in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/CanvasEditorViewController.swift
- [x] T150 [US9] Add bottom toolbar Delete button in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/CanvasEditorViewController.swift
- [x] T151 [US9] Add bottom toolbar Color picker button in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/CanvasEditorViewController.swift
- [x] T152 [US9] Implement addRectangleTapped() with AddShapeCommand in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/CanvasEditorViewController.swift
- [x] T153 [US9] Implement addCircleTapped() with AddShapeCommand in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/CanvasEditorViewController.swift
- [x] T154 [US9] Implement addLineTapped() with AddShapeCommand in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/CanvasEditorViewController.swift
- [x] T155 [US9] Implement deleteSelectedTapped() with RemoveShapeCommand in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/CanvasEditorViewController.swift
- [x] T156 [US9] Implement changeColorTapped() with ChangeColorCommand in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/CanvasEditorViewController.swift
- [x] T157 [US9] Conform to CanvasViewDelegate for shape move events in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/CanvasEditorViewController.swift
- [x] T158 [US9] Implement canvasView(_:didMoveShape:by:) with MoveShapeCommand in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/CanvasEditorViewController.swift
- [x] T159 [US9] Implement refreshCanvasView() to sync CanvasView with Canvas in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/CanvasEditorViewController.swift
- [x] T160 [US9] Connect Demo Hub navigation to CanvasEditorViewController in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/UndoRedoDemoViewController.swift

**Checkpoint**: Canvas Editor UI functional - All shape operations with Undo/Redo working

---

## Phase 15: User Story 10 - UI 與 Model 層即時同步 (Priority: P2)

**Goal**: 當 Model 層的 CommandHistory 狀態變化時，UI 層即時更新

**Independent Test**: 透過 Observer Pattern 驗證 UI 收到通知並更新

### Implementation for User Story 10

- [x] T161 [US10] Verify Observer registration in TextEditorViewController viewDidLoad in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/TextEditor/TextEditorViewController.swift
- [x] T162 [US10] Verify Observer registration in CanvasEditorViewController viewDidLoad in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/CanvasEditorViewController.swift
- [x] T163 [US10] Verify Observer removal in TextEditorViewController deinit in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/TextEditor/TextEditorViewController.swift
- [x] T164 [US10] Verify Observer removal in CanvasEditorViewController deinit in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/UI/CanvasEditor/CanvasEditorViewController.swift
- [x] T165 [US10] Ensure UI updates on main thread in notifyObservers() in sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/Command/CommandHistory.swift

**Checkpoint**: UI syncs in real-time with Model layer changes

---

## Phase 16: Integration & Polish

**Purpose**: Final integration and validation

- [x] T166 [P] Verify Demo Hub navigation to both editors works correctly
- [x] T167 [P] Verify Text Editor Undo/Redo button states update correctly
- [x] T168 [P] Verify Canvas Editor Undo/Redo button states update correctly
- [x] T169 [P] Verify shape dragging creates MoveShapeCommand correctly
- [x] T170 Test consecutive Undo operations in Text Editor
- [x] T171 Test consecutive Undo operations in Canvas Editor
- [x] T172 Test Redo after multiple Undo operations
- [x] T173 Test new operation clears Redo stack
- [x] T174 Verify no memory leaks with Observer weak references
- [x] T175 Run full manual test: Demo Hub → Text Editor → operations → Undo/Redo → back
- [x] T176 Run full manual test: Demo Hub → Canvas Editor → operations → Undo/Redo → back
- [x] T177 Code review for UIKit-only imports in UI layer files

**Checkpoint**: UI Layer complete - All acceptance scenarios verified

---

## Dependencies & Execution Order

### Phase Dependencies

```
Phase 10 (UI Setup) ──► Phase 11 (Core UI Components)
                   │
                   └──► Phase 12 (Demo Hub - US7)

Phase 11 ──┬──► Phase 13 (Text Editor - US8)
           │
           └──► Phase 14 (Canvas Editor - US9)

Phase 13 + Phase 14 ──► Phase 15 (UI Sync - US10)

Phase 12 + Phase 13 + Phase 14 + Phase 15 ──► Phase 16 (Integration)
```

### User Story Dependencies (UI Layer)

- **User Story 7 (Demo Hub)**: Can start after Phase 10 (UI Setup)
- **User Story 8 (Text Editor UI)**: Can start after Phase 11 (Core UI Components)
- **User Story 9 (Canvas Editor UI)**: Can start after Phase 11 (Core UI Components)
- **User Story 10 (UI Sync)**: Can start after US8 and US9 have Observer integration

### Parallel Opportunities

- T090 (UI folder) and T091 (Observer tests) can run in parallel
- T100 (Color+UIKit) and T101 (UndoRedoToolbarView) can run in parallel
- Phase 13 (Text Editor) and Phase 14 (Canvas Editor) can run in parallel
- Within Phase 14: T125-T126 (ShapeView skeleton) can run in parallel with T133 (CanvasView skeleton)

---

## Parallel Example: Phase 14 (Canvas Editor)

```bash
# Launch ShapeView and CanvasView in parallel:
Task: "Create ShapeView class skeleton" (T125)
Task: "Create CanvasView class skeleton" (T133)

# After skeletons are ready, implementation can proceed
```

---

## Implementation Strategy

### UI MVP First (US7 + US8 Only)

1. Complete Phase 10: UI Setup + Observer Pattern
2. Complete Phase 11: Core UI Components
3. Complete Phase 12: Demo Hub (US7)
4. Complete Phase 13: Text Editor UI (US8)
5. **STOP and VALIDATE**: Test text editing with Undo/Redo
6. Demo if ready - Text Editor UI functional

### Full UI Implementation

1. Complete Phase 10-13 (MVP)
2. Add Phase 14: Canvas Editor UI (US9)
3. Add Phase 15: UI Sync verification (US10)
4. Complete Phase 16: Integration & Polish
5. **FULL DEMO**: Both editors with complete Undo/Redo functionality

### Parallel Team Strategy

With two developers:

1. Both complete Phase 10-11 together
2. Developer A: Phase 12 (Demo Hub) → Phase 13 (Text Editor)
3. Developer B: Phase 14 (Canvas Editor)
4. Both: Phase 15-16 (Integration)

---

## Summary

### Total Tasks

| Part | Phases | Task Count | Status |
|------|--------|------------|--------|
| Model Layer | 1-9 | T001-T089 (89 tasks) | ✅ 完成 |
| UI Layer | 10-16 | T090-T177 (88 tasks) | ⏳ 待實作 |
| **Total** | **1-16** | **177 tasks** | |

### Tasks per UI User Story

| User Story | Phase | Task IDs | Count |
|------------|-------|----------|-------|
| US7 (Demo Hub) | 12 | T104-T107 | 4 |
| US8 (Text Editor UI) | 13 | T108-T124 | 17 |
| US9 (Canvas Editor UI) | 14 | T125-T160 | 36 |
| US10 (UI Sync) | 15 | T161-T165 | 5 |
| Setup & Integration | 10, 11, 16 | T090-T103, T166-T177 | 26 |

### Suggested MVP Scope

**UI MVP**: Phase 10 + 11 + 12 + 13 (T090-T124, 35 tasks)
- Observer Pattern 支援
- Core UI 元件
- Demo Hub
- 文字編輯器 UI

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- UI layer files MUST only import UIKit and Foundation
- Model layer files remain Foundation-only (no UIKit)
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence

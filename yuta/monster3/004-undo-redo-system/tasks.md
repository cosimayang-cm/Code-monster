# Tasks: Undo/Redo System

**Input**: Design documents from `/specs/004-undo-redo-system/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Tests**: Tests are OPTIONAL per PAGEs Framework - only included if explicitly requested. Given-When-Then structure with camelCase naming: `testMethodNameWhenConditionThenExpectedResult`

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

This project uses the following structure:
- **Models**: `Sources/Models/` (Foundation only)
- **ViewModels**: `Sources/ViewModels/` (Foundation + Combine)
- **Views**: `Sources/Views/` (UIKit + Combine)
- **Tests**: `Tests/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure per plan.md

- [ ] T001 Create project directory structure: Sources/Models/{Command,Entities,Protocols,Receivers,Memento}, Sources/ViewModels, Sources/Views/Extensions, Tests/{Mocks,CommandTests,ReceiverTests,ViewModelTests}
- [ ] T002 [P] Initialize Swift package with Foundation and Combine dependencies
- [ ] T003 [P] Configure SwiftLint rules aligned with PAGEs code quality standards

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core Command Pattern and Memento infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T004 [P] Create Command protocol in Sources/Models/Command/Command.swift
- [ ] T005 [P] Create CommandHistoryProtocol in Sources/Models/Protocols/CommandHistoryProtocol.swift
- [ ] T006 [P] Create Memento protocol in Sources/Models/Memento/Memento.swift
- [ ] T007 Implement CommandHistory class in Sources/Models/Command/CommandHistory.swift implementing CommandHistoryProtocol
- [ ] T008 [P] Create Foundation-only Color struct in Sources/Models/Entities/Color.swift
- [ ] T009 [P] Create Foundation-only Point struct in Sources/Models/Entities/Point.swift
- [ ] T010 [P] Create Foundation-only Size struct in Sources/Models/Entities/Size.swift

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - 文章編輯器基本操作 (Priority: P1) 🎯 MVP

**Goal**: 實作文章編輯器的插入、刪除、取代文字操作，並支援 Undo/Redo

**Independent Test**: 可透過執行插入、刪除、取代文字操作，然後使用 Undo/Redo 驗證每個操作都能正確復原與重做

### Implementation for User Story 1

- [ ] T011 [P] [US1] Create TextStyle struct in Sources/Models/Entities/TextStyle.swift
- [ ] T012 [P] [US1] Create TextDocumentProtocol in Sources/Models/Protocols/TextDocumentProtocol.swift
- [ ] T013 [US1] Create TextDocument class implementing TextDocumentProtocol in Sources/Models/Receivers/TextDocument.swift
- [ ] T014 [P] [US1] Implement InsertTextCommand in Sources/Models/Command/TextCommands/InsertTextCommand.swift
- [ ] T015 [P] [US1] Implement DeleteTextCommand in Sources/Models/Command/TextCommands/DeleteTextCommand.swift
- [ ] T016 [P] [US1] Implement ReplaceTextCommand in Sources/Models/Command/TextCommands/ReplaceTextCommand.swift
- [ ] T017 [US1] Create TextDocumentMemento in Sources/Models/Memento/TextDocumentMemento.swift
- [ ] T018 [US1] Add createMemento and restore methods to TextDocument for Memento support
- [ ] T019 [US1] Create TextEditorViewModel with @Published properties in Sources/ViewModels/TextEditorViewModel.swift using TextDocumentProtocol and CommandHistoryProtocol
- [ ] T020 [US1] Run xcodegen generate in project directory
- [ ] T021 [US1] Verify project integrity: plutil -lint *.xcodeproj/project.pbxproj
- [ ] T022 [US1] Verify build: xcodebuild build -workspace *.xcworkspace -scheme *

**Checkpoint**: At this point, User Story 1 should be fully functional - text insertion, deletion, replacement all support Undo/Redo

---

## Phase 4: User Story 2 - 文章編輯器樣式設定 (Priority: P2)

**Goal**: 實作文字樣式（粗體、斜體、底線）套用功能，並支援 Undo/Redo

**Independent Test**: 可透過對文字範圍套用各種樣式，然後使用 Undo/Redo 驗證樣式變更可正確復原

### Implementation for User Story 2

- [ ] T023 [US2] Implement ApplyStyleCommand in Sources/Models/Command/TextCommands/ApplyStyleCommand.swift
- [ ] T024 [US2] Add applyStyle and removeStyle methods to TextDocument with style range management
- [ ] T025 [US2] Add style-related actions to TextEditorViewModel (applyBold, applyItalic, applyUnderline)
- [ ] T026 [US2] Run xcodegen generate in project directory
- [ ] T027 [US2] Verify build: xcodebuild build -workspace *.xcworkspace -scheme *

**Checkpoint**: Text styling now works with Undo/Redo - User Stories 1 AND 2 are both independently functional

---

## Phase 5: User Story 3 - 畫布編輯器圖形操作 (Priority: P1)

**Goal**: 實作畫布編輯器的新增、刪除、移動圖形操作，並支援 Undo/Redo

**Independent Test**: 可透過建立和操作圖形，並驗證所有操作都能正確 Undo/Redo

### Implementation for User Story 3

- [ ] T028 [P] [US3] Create Shape protocol in Sources/Models/Entities/Shape.swift using Foundation-only Color, Point
- [ ] T029 [P] [US3] Create Rectangle class implementing Shape in Sources/Models/Entities/Rectangle.swift
- [ ] T030 [P] [US3] Create Circle class implementing Shape in Sources/Models/Entities/Circle.swift
- [ ] T031 [P] [US3] Create Line class implementing Shape in Sources/Models/Entities/Line.swift
- [ ] T032 [P] [US3] Create CanvasProtocol in Sources/Models/Protocols/CanvasProtocol.swift
- [ ] T033 [US3] Create Canvas class implementing CanvasProtocol in Sources/Models/Receivers/Canvas.swift
- [ ] T034 [P] [US3] Implement AddShapeCommand in Sources/Models/Command/CanvasCommands/AddShapeCommand.swift
- [ ] T035 [P] [US3] Implement RemoveShapeCommand in Sources/Models/Command/CanvasCommands/RemoveShapeCommand.swift
- [ ] T036 [P] [US3] Implement MoveShapeCommand in Sources/Models/Command/CanvasCommands/MoveShapeCommand.swift
- [ ] T037 [US3] Create CanvasMemento in Sources/Models/Memento/CanvasMemento.swift
- [ ] T038 [US3] Add createMemento and restore methods to Canvas with deep copy for shapes
- [ ] T039 [US3] Create CanvasEditorViewModel with @Published properties in Sources/ViewModels/CanvasEditorViewModel.swift using CanvasProtocol and CommandHistoryProtocol
- [ ] T040 [US3] Run xcodegen generate in project directory
- [ ] T041 [US3] Verify project integrity: plutil -lint *.xcodeproj/project.pbxproj
- [ ] T042 [US3] Verify build: xcodebuild build -workspace *.xcworkspace -scheme *

**Checkpoint**: Canvas basic operations (add, remove, move) now work with Undo/Redo

---

## Phase 6: User Story 4 - 畫布編輯器圖形外觀調整 (Priority: P2)

**Goal**: 實作圖形大小和顏色調整功能，並支援 Undo/Redo

**Independent Test**: 可透過修改圖形大小和顏色，然後驗證這些變更可 Undo/Redo

### Implementation for User Story 4

- [ ] T043 [P] [US4] Implement ResizeShapeCommand in Sources/Models/Command/CanvasCommands/ResizeShapeCommand.swift
- [ ] T044 [P] [US4] Implement ChangeColorCommand in Sources/Models/Command/CanvasCommands/ChangeColorCommand.swift
- [ ] T045 [US4] Add resize and changeColor methods to Canvas
- [ ] T046 [US4] Add resize and changeColor actions to CanvasEditorViewModel
- [ ] T047 [US4] Run xcodegen generate in project directory
- [ ] T048 [US4] Verify build: xcodebuild build -workspace *.xcworkspace -scheme *

**Checkpoint**: Canvas appearance adjustments work with Undo/Redo - User Stories 3 AND 4 are both independently functional

---

## Phase 7: User Story 5 - UI 顯示 Undo/Redo 狀態 (Priority: P3)

**Goal**: 實作 UI 層的 Undo/Redo 按鈕狀態和描述顯示

**Independent Test**: 可透過執行操作並檢查 UI 按鈕狀態和描述是否正確更新

### Implementation for User Story 5

- [ ] T049 [P] [US5] Create Color+UIKit extension in Sources/Views/Extensions/Color+UIKit.swift for UIColor conversion
- [ ] T050 [P] [US5] Create Point+CoreGraphics extension in Sources/Views/Extensions/Point+CoreGraphics.swift for CGPoint conversion
- [ ] T051 [P] [US5] Create Size+CoreGraphics extension in Sources/Views/Extensions/Size+CoreGraphics.swift for CGSize conversion
- [ ] T052 [US5] Create TextEditorViewController in Sources/Views/TextEditorViewController.swift with Combine bindings to TextEditorViewModel
- [ ] T053 [US5] Create CanvasEditorViewController in Sources/Views/CanvasEditorViewController.swift with Combine bindings to CanvasEditorViewModel
- [ ] T054 [US5] Implement setupBindings in TextEditorViewController subscribing to @Published properties (content, canUndo, canRedo, undoButtonTitle, redoButtonTitle)
- [ ] T055 [US5] Implement setupBindings in CanvasEditorViewController subscribing to @Published properties
- [ ] T056 [US5] Implement IBAction methods for undo/redo buttons in both ViewControllers
- [ ] T057 [US5] Run xcodegen generate in project directory
- [ ] T058 [US5] Verify project integrity: plutil -lint *.xcodeproj/project.pbxproj
- [ ] T059 [US5] Verify build: xcodebuild build -workspace *.xcworkspace -scheme *

**Checkpoint**: UI layer complete - all user stories are now fully functional with UI feedback

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Code quality validation and compliance checks per PAGEs standards

- [ ] T060 [P] Run SwiftLint validation on all Swift files
- [ ] T061 Verify Foundation-only constraint: grep -r "import UIKit" Sources/Models/ should return empty
- [ ] T062 Verify Foundation-only constraint: grep -r "import CoreGraphics" Sources/Models/Entities/ should return empty (except internal type definitions)
- [ ] T063 Verify Protocol usage: All Commands use TextDocumentProtocol and CanvasProtocol instead of concrete types
- [ ] T064 Verify weak references: All Commands use weak var for Receiver references to avoid retain cycles
- [ ] T065 Verify Combine integration: All ViewModels use @Published properties and ViewControllers use AnyCancellable
- [ ] T066 [P] Code review: Verify SOLID principles compliance per plan.md checklist
- [ ] T067 Run quickstart.md validation: Execute all code examples to ensure they work
- [ ] T068 Final build verification: xcodebuild build -workspace *.xcworkspace -scheme *

**Checkpoint**: 核心實作完成 - 所有設計模式已實作並驗證，可在 Unit Test 或 Playground 中測試所有功能

---

## Phase 9: SwiftUI UI 實作（可選 - 有餘裕時實作）

**Purpose**: 提供視覺化介面，可在模擬器上實際操作編輯器

**⚠️ 前置條件**: Phase 1-8 必須完成並通過驗證

**📝 注意**: 此階段為**可選項目**，優先完成核心習題程式碼，有餘裕才實作 UI

### App 基礎架構

- [ ] T069 [P] Create App.swift with @main entry point in App/App.swift
- [ ] T070 [P] Create Info.plist with basic app configuration in App/Info.plist
- [ ] T071 [P] Create Assets.xcassets for app resources in App/Assets.xcassets

### 主畫面實作

- [ ] T072 Create ContentView.swift with TabView structure in App/Views/ContentView.swift
- [ ] T073 Configure TabView with text editor and canvas editor tabs
- [ ] T074 Add tab icons using SF Symbols (doc.text, paintbrush)

### 文字編輯器 UI

- [ ] T075 Create TextEditorView.swift with @StateObject ViewModel in App/Views/TextEditorView.swift
- [ ] T076 Implement text editing UI with TextEditor component
- [ ] T077 Add Undo/Redo buttons with disabled state binding
- [ ] T078 Implement text synchronization between UI and ViewModel using @Published
- [ ] T079 Add style buttons (Bold, Italic, Underline) for US2 features
- [ ] T080 Implement onChange and onReceive for bidirectional binding

### 畫布編輯器 UI

- [ ] T081 Create CanvasEditorView.swift with @StateObject ViewModel in App/Views/CanvasEditorView.swift
- [ ] T082 Create CanvasDrawingView subview for canvas rendering
- [ ] T083 Implement shape tool picker (Rectangle, Circle, Line)
- [ ] T084 Add ColorPicker for shape color selection
- [ ] T085 Implement drag gesture for shape creation
- [ ] T086 Implement shape drawing logic using SwiftUI Canvas
- [ ] T087 Add shape conversion from Model types to SwiftUI drawing

### ViewModel 補充方法

- [ ] T088 Add convenience methods to CanvasEditorViewModel: addRectangle, addCircle, addLine
- [ ] T089 Add shapes computed property to CanvasEditorViewModel for UI access
- [ ] T090 Ensure all @Published properties are correctly exposed

### 整合測試

- [ ] T091 Run app on iPhone 16 Pro simulator
- [ ] T092 Test text editor: type text, undo, redo, apply styles
- [ ] T093 Test canvas editor: draw shapes, undo, redo, change colors
- [ ] T094 Verify all operations correctly trigger ViewModel methods
- [ ] T095 Verify UI updates automatically via @Published properties

**Checkpoint**: SwiftUI UI 完成 - 可在模擬器上實際操作文字編輯器和畫布編輯器，驗證所有 Undo/Redo 功能

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phases 3-7)**: All depend on Foundational phase completion
  - User stories can proceed in parallel (if staffed) or sequentially in priority order
  - Priority order: US1 (P1) → US3 (P1) → US2 (P2) → US4 (P2) → US5 (P3)
- **Polish (Phase 8)**: Depends on all desired user stories being complete
- **SwiftUI UI (Phase 9)**: **OPTIONAL** - Depends on Phase 1-8 completion and validation
  - Only implement if there is spare capacity after core exercises are complete
  - Provides visual interface for actual simulator testing

### User Story Dependencies

- **User Story 1 (P1) - 文章編輯器基本操作**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2) - 文章編輯器樣式設定**: Depends on US1 completion (builds on TextDocument)
- **User Story 3 (P1) - 畫布編輯器圖形操作**: Can start after Foundational (Phase 2) - No dependencies on other stories (independent of text editor)
- **User Story 4 (P2) - 畫布編輯器圖形外觀調整**: Depends on US3 completion (builds on Canvas)
- **User Story 5 (P3) - UI 顯示 Undo/Redo 狀態**: Depends on US1 and US3 completion (needs ViewModels from both editors)

### Within Each User Story

- Protocol definitions before implementations
- Models/Entities before Receivers
- Receivers before Commands
- Commands before ViewModels
- ViewModels before ViewControllers
- xcodegen tasks after any Swift file additions
- Build verification after xcodegen

### Parallel Opportunities

- **Phase 1 Setup**: T002 and T003 can run in parallel
- **Phase 2 Foundational**: T004, T005, T006 can run in parallel; T008, T009, T010 can run in parallel
- **Phase 3 (US1)**: T011 and T012 can run in parallel; T014, T015, T016 can run in parallel
- **Phase 5 (US3)**: T028, T029, T030, T031 can run in parallel; T034, T035, T036 can run in parallel
- **Phase 6 (US4)**: T043 and T044 can run in parallel
- **Phase 7 (US5)**: T049, T050, T051 can run in parallel
- **Phase 8 Polish**: T060 and T066 can run in parallel
- **Phase 9 SwiftUI (OPTIONAL)**: T069, T070, T071 can run in parallel; T075-T087 mostly parallelizable
- **User Story level**: US1 and US3 can be developed in parallel (independent text and canvas editors)

---

## Parallel Example: Foundational Phase

```bash
# Launch all protocol definitions together:
Task: "Create Command protocol in Sources/Models/Command/Command.swift"
Task: "Create CommandHistoryProtocol in Sources/Models/Protocols/CommandHistoryProtocol.swift"
Task: "Create Memento protocol in Sources/Models/Memento/Memento.swift"

# Launch all Foundation-only type definitions together:
Task: "Create Foundation-only Color struct in Sources/Models/Entities/Color.swift"
Task: "Create Foundation-only Point struct in Sources/Models/Entities/Point.swift"
Task: "Create Foundation-only Size struct in Sources/Models/Entities/Size.swift"
```

## Parallel Example: User Story 3

```bash
# Launch all Shape implementations together:
Task: "Create Rectangle class implementing Shape in Sources/Models/Entities/Rectangle.swift"
Task: "Create Circle class implementing Shape in Sources/Models/Entities/Circle.swift"
Task: "Create Line class implementing Shape in Sources/Models/Entities/Line.swift"

# Launch all Canvas Commands together:
Task: "Implement AddShapeCommand in Sources/Models/Command/CanvasCommands/AddShapeCommand.swift"
Task: "Implement RemoveShapeCommand in Sources/Models/Command/CanvasCommands/RemoveShapeCommand.swift"
Task: "Implement MoveShapeCommand in Sources/Models/Command/CanvasCommands/MoveShapeCommand.swift"
```

---

## Implementation Strategy

### 🎯 核心優先策略（推薦）

**目標**：優先完成設計模式學習的核心程式碼，有餘裕才考慮 UI

#### Stage 1: 核心實作（必須完成）

1. **Phase 1-2**: Setup + Foundational (T001-T010)
   - 建立專案結構和核心 Protocol
   - 建立 Foundation-only 型別

2. **Phase 3-7**: 實作所有 User Stories (T011-T059)
   - US1: 文章編輯器基本操作
   - US3: 畫布編輯器圖形操作
   - US2: 文章樣式
   - US4: 圖形外觀
   - US5: ViewModel 準備

3. **Phase 8**: Polish & Validation (T060-T068)
   - 程式碼品質驗證
   - Foundation-only 檢查
   - Protocol 使用檢查

**驗證方式**：
- 在 Unit Test 中驗證所有功能
- 在 Playground 中互動測試
- 確認所有設計模式正確實作

**Checkpoint**: 核心完成後，所有設計模式學習目標已達成 ✅

---

#### Stage 2: UI 實作（可選，有餘裕時）

**前置條件**：Stage 1 必須完成並驗證通過

4. **Phase 9**: SwiftUI UI (T069-T095) - **OPTIONAL**
   - App 基礎架構
   - 文字編輯器 UI
   - 畫布編輯器 UI
   - 模擬器測試

**驗證方式**：
- 在 iPhone 模擬器上實際操作
- 輸入文字、繪製圖形
- 驗證 Undo/Redo 視覺效果

**Checkpoint**: UI 完成後，可視覺化體驗所有功能 🎨

---

### MVP First (核心程式碼優先)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1 (文章編輯器基本操作)
4. Complete Phase 5: User Story 3 (畫布編輯器圖形操作)
5. **STOP and VALIDATE**: Test in Unit Tests or Playground
6. **Core MVP Complete**: Command Pattern + Memento Pattern implemented ✅
7. **OPTIONAL**: Proceed to Phase 9 for UI if time permits

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test in Playground (文章編輯器基本操作)
3. Add User Story 3 → Test in Playground (畫布編輯器圖形操作) → **Core MVP!**
4. Add User Story 2 → Test independently (文章樣式)
5. Add User Story 4 → Test independently (圖形外觀)
6. Add Phase 8 Polish → Validate code quality
7. **OPTIONAL**: Add Phase 9 SwiftUI → Visual testing in simulator

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1 (文章編輯器) → User Story 2 (樣式)
   - Developer B: User Story 3 (畫布編輯器) → User Story 4 (外觀)
   - Developer C: Phase 8 (Polish) after core stories
3. **OPTIONAL**: One developer adds Phase 9 (SwiftUI) if team has capacity

---

## Notes

- **[P] tasks**: Different files, no dependencies - can run in parallel
- **[Story] label**: Maps task to specific user story for traceability
- **Each user story**: Should be independently completable and testable
- **Foundation-only constraint**: Model layer must not import UIKit/CoreGraphics (except for type definitions)
- **Protocol abstraction**: All Commands use Protocol types (TextDocumentProtocol, CanvasProtocol, CommandHistoryProtocol)
- **Weak references**: Commands must use weak var for Receivers to avoid retain cycles
- **Combine reactive**: ViewModels use @Published, ViewControllers use Combine subscriptions with AnyCancellable
- **xcodegen**: Required after any Swift file additions to update Xcode project
- **PAGEs compliance**: Follow architecture (ViewModel → Protocol → Receiver), code quality (weak self, Logger.log), testing standards (Given-When-Then, camelCase)
- **Commit strategy**: Commit after each task or logical group
- **Checkpoints**: Stop at any checkpoint to validate story independently
- **Avoid**: Vague tasks, same file conflicts, cross-story dependencies that break independence

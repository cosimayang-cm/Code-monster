# Implementation Plan: Undo/Redo 系統 UI 層

**Branch**: `002-undo-redo-system` | **Date**: 2026-01-23 | **Spec**: [spec.md](./spec.md)
**Input**: UI Layer Requirements from spec.md (FR-025 ~ FR-037)

## Summary

為已完成的 Undo/Redo Model 層建立 UIKit UI，包含：
1. Observer Pattern 增強 - 讓 UI 能響應 CommandHistory 狀態變化
2. Demo Hub - 展示入口頁面
3. 文字編輯器 UI - 展示文字操作的 Undo/Redo
4. 畫布編輯器 UI - 展示圖形操作的 Undo/Redo

## Technical Context

**Language/Version**: Swift 5.9+
**Primary Dependencies**: UIKit, Foundation (Model 層已完成)
**Storage**: N/A（記憶體內操作）
**Testing**: XCTest (Observer Pattern 單元測試)
**Target Platform**: iOS 15+
**Project Type**: Mobile iOS App
**Performance Goals**: 60 fps UI 渲染、即時響應
**Constraints**: 無外部依賴，純 iOS SDK 實作
**Scale/Scope**: 2 個編輯器頁面、1 個 Hub 頁面

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Gate | Status | Notes |
|------|--------|-------|
| Model 層完成 | ✅ PASS | CommandHistory, TextDocument, Canvas 等已實作並測試通過 |
| 架構分層 | ✅ PASS | Model (Foundation only) / UI (UIKit) 分離 |
| 測試策略 | ✅ PASS | Observer Pattern 可透過單元測試驗證 |

## Project Structure

### Documentation (this feature)

```text
specs/002-undo-redo-system/
├── spec.md              # 功能規格（已更新 UI Layer Requirements）
├── plan.md              # 本檔案
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output (已存在，補充 UI 部分)
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output
```

### Source Code (repository root)

```text
sonia/CodeMonster/CodeMonster/CodeMonster/Undo-Redo/
├── Command/
│   ├── Command.swift              # ✅ 已存在
│   ├── CommandHistory.swift       # 🔧 修改：加入 Observer 支援
│   ├── CommandHistoryObserver.swift # 🆕 新增：觀察者協議
│   └── CompositeCommand.swift     # ✅ 已存在
├── TextEditor/
│   ├── TextDocument.swift         # ✅ 已存在
│   ├── TextStyle.swift            # ✅ 已存在
│   ├── InsertTextCommand.swift    # ✅ 已存在
│   ├── DeleteTextCommand.swift    # ✅ 已存在
│   ├── ReplaceTextCommand.swift   # ✅ 已存在
│   └── ApplyStyleCommand.swift    # ✅ 已存在
├── CanvasEditor/
│   ├── Canvas.swift               # ✅ 已存在
│   ├── Shape.swift                # ✅ 已存在
│   ├── Color.swift                # ✅ 已存在
│   ├── AddShapeCommand.swift      # ✅ 已存在
│   ├── RemoveShapeCommand.swift   # ✅ 已存在
│   ├── MoveShapeCommand.swift     # ✅ 已存在
│   ├── ResizeShapeCommand.swift   # ✅ 已存在
│   └── ChangeColorCommand.swift   # ✅ 已存在
└── UI/                            # 🆕 新增：UI 層
    ├── UndoRedoDemoViewController.swift  # Demo Hub
    ├── Components/
    │   └── UndoRedoToolbarView.swift     # 可重用工具列
    ├── Extensions/
    │   └── Color+UIKit.swift             # Color → UIColor
    ├── TextEditor/
    │   └── TextEditorViewController.swift
    └── CanvasEditor/
        ├── CanvasEditorViewController.swift
        └── Views/
            ├── CanvasView.swift
            └── ShapeView.swift
```

**Structure Decision**: 沿用現有 Undo-Redo 目錄結構，在其下新增 UI/ 子目錄存放所有 UI 相關程式碼。

## Complexity Tracking

> 無違規事項，不需要額外追蹤

## Implementation Phases

### Phase 1: Observer Pattern 增強 (FR-025 ~ FR-027)

**目標**: 讓 UI 能訂閱 CommandHistory 狀態變化

**修改檔案**:
1. `Command/CommandHistoryObserver.swift` (新增)
   - 定義 `CommandHistoryObserver` 協議
   - 包含 `commandHistoryDidChange(_ history: CommandHistory)` 方法

2. `Command/CommandHistory.swift` (修改)
   - 新增 `WeakObserver` 結構（弱引用包裝）
   - 新增 `observers` 陣列
   - 新增 `addObserver()`, `removeObserver()` 方法
   - 在 `execute()`, `undo()`, `redo()` 結尾呼叫 `notifyObservers()`

### Phase 2: 核心 UI 元件 (FR-037)

**目標**: 建立可重用的 UI 元件

**新增檔案**:
1. `UI/Extensions/Color+UIKit.swift`
   - Model Color → UIColor 轉換擴展

2. `UI/Components/UndoRedoToolbarView.swift`
   - Undo/Redo 按鈕的可重用視圖
   - `updateState(canUndo:canRedo:)` 方法
   - `onUndo`, `onRedo` 回調

### Phase 3: Demo Hub (FR-028 ~ FR-029)

**目標**: 建立展示入口頁面

**新增檔案**:
1. `UI/UndoRedoDemoViewController.swift`
   - 標題：「Undo/Redo 系統展示」
   - 兩個按鈕導覽至文字/畫布編輯器

### Phase 4: 文字編輯器 UI (FR-030 ~ FR-032)

**目標**: 建立文字編輯器介面

**新增檔案**:
1. `UI/TextEditor/TextEditorViewController.swift`
   - Navigation Bar 右上角 Undo/Redo 按鈕
   - UITextView 顯示文字
   - 底部工具列：插入、刪除、取代、樣式
   - 實作 `CommandHistoryObserver`

### Phase 5: 畫布編輯器 UI (FR-033 ~ FR-036)

**目標**: 建立畫布編輯器介面

**新增檔案**:
1. `UI/CanvasEditor/Views/ShapeView.swift`
   - 繪製單一圖形的 UIView
   - 支援 Rectangle, Circle, Line

2. `UI/CanvasEditor/Views/CanvasView.swift`
   - 管理多個 ShapeView 的容器
   - `sync(with canvas: Canvas)` 方法

3. `UI/CanvasEditor/CanvasEditorViewController.swift`
   - Navigation Bar 右上角 Undo/Redo 按鈕
   - 底部工具列：新增矩形、圓形、線條、刪除、顏色
   - Pan gesture 拖曳移動圖形
   - 實作 `CommandHistoryObserver`

### Phase 6: 整合與測試

**目標**: 整合所有元件並驗證

**修改檔案**:
1. `SceneDelegate.swift`
   - 設定 Demo Hub 為 root view controller

**測試項目**:
- Observer 通知機制單元測試
- 手動測試兩個編輯器的 Undo/Redo 流程
- 驗證按鈕狀態正確啟用/停用

## Dependencies

```
Phase 1 (Observer) ──┬──> Phase 2 (UI Components)
                     │
                     └──> Phase 3 (Demo Hub)

Phase 2 ──┬──> Phase 4 (Text Editor)
          │
          └──> Phase 5 (Canvas Editor)

Phase 3 + Phase 4 + Phase 5 ──> Phase 6 (Integration)
```

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Observer 記憶體洩漏 | 中 | 高 | 使用弱引用 WeakObserver |
| UI 更新不及時 | 低 | 中 | 在主執行緒呼叫 notifyObservers |
| 圖形繪製效能 | 低 | 低 | 使用 setNeedsDisplay 而非即時重繪 |

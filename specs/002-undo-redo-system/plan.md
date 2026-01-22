# Implementation Plan: Undo/Redo 編輯系統

**Branch**: `002-undo-redo-system` | **Date**: 2026-01-22 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-undo-redo-system/spec.md`

## Summary

實作支援 Undo/Redo 的編輯系統，包含文章編輯器和畫布編輯器。使用 Command Pattern 封裝操作，CommandHistory 管理撤銷/重做堆疊。採用 TDD 開發，Model 層只依賴 Foundation，確保可獨立測試。

## Technical Context

**Language/Version**: Swift 5.9+
**Primary Dependencies**: Foundation (Model 層)、UIKit (UI 層)
**Storage**: N/A（記憶體內操作）
**Testing**: XCTest
**Target Platform**: iOS 15+
**Project Type**: mobile (練習專案)
**Performance Goals**: N/A（練習專案無特殊效能要求）
**Constraints**: Model 層只 import Foundation，不依賴 UIKit
**Scale/Scope**: 練習專案，兩個編輯器（文字、畫布）

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Constitution 尚未設定專案特定規則，採用預設原則：
- [x] TDD：已在規格中明確要求
- [x] 簡單架構：只有兩層（Model + UI）
- [x] 可測試性：Model 層不依賴 UIKit

**狀態**: PASS

## Project Structure

### Documentation (this feature)

```text
specs/002-undo-redo-system/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit.tasks)
```

### Source Code (repository root)

```text
Sources/
├── UndoRedo/
│   ├── Command/
│   │   ├── Command.swift              # Command protocol
│   │   └── CommandHistory.swift       # 管理 undo/redo 堆疊
│   ├── TextEditor/
│   │   ├── TextDocument.swift         # Receiver
│   │   ├── TextStyle.swift            # 樣式定義
│   │   ├── InsertTextCommand.swift
│   │   ├── DeleteTextCommand.swift
│   │   ├── ReplaceTextCommand.swift
│   │   └── ApplyStyleCommand.swift
│   └── CanvasEditor/
│       ├── Canvas.swift               # Receiver
│       ├── Shape.swift                # 圖形基底
│       ├── Color.swift                # UIKit-independent 顏色
│       ├── AddShapeCommand.swift
│       ├── RemoveShapeCommand.swift
│       ├── MoveShapeCommand.swift
│       ├── ResizeShapeCommand.swift
│       └── ChangeColorCommand.swift

Tests/
├── UndoRedoTests/
│   ├── CommandHistoryTests.swift
│   ├── TextEditor/
│   │   ├── TextDocumentTests.swift
│   │   ├── InsertTextCommandTests.swift
│   │   ├── DeleteTextCommandTests.swift
│   │   ├── ReplaceTextCommandTests.swift
│   │   └── ApplyStyleCommandTests.swift
│   └── CanvasEditor/
│       ├── CanvasTests.swift
│       ├── AddShapeCommandTests.swift
│       ├── RemoveShapeCommandTests.swift
│       ├── MoveShapeCommandTests.swift
│       ├── ResizeShapeCommandTests.swift
│       └── ChangeColorCommandTests.swift
```

**Structure Decision**: 採用簡單的 Sources/Tests 結構，按功能模組分組（Command、TextEditor、CanvasEditor）。

## Complexity Tracking

無違規需要說明。架構保持簡單，只有兩層。

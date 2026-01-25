# Undo/Redo 系統 - 實作計畫

## 目錄結構

```
CarSystem/
├── UndoRedo/
│   ├── Core/                           # Foundation Only Layer
│   │   ├── Protocols/
│   │   │   ├── Command.swift           # Command Protocol
│   │   │   └── CoalescibleCommand.swift # 進階：可合併命令協議
│   │   ├── History/
│   │   │   └── CommandHistory.swift    # 命令歷史管理器
│   │   └── Commands/
│   │       └── CompositeCommand.swift  # 進階：組合命令
│   │
│   ├── TextEditor/                     # 文章編輯器
│   │   ├── Models/
│   │   │   ├── TextDocument.swift      # Receiver：文件模型
│   │   │   ├── TextStyle.swift         # 文字樣式定義
│   │   │   └── TextDocumentMemento.swift # Memento：文件快照
│   │   ├── Commands/
│   │   │   ├── InsertTextCommand.swift
│   │   │   ├── DeleteTextCommand.swift
│   │   │   ├── ReplaceTextCommand.swift
│   │   │   └── ApplyStyleCommand.swift
│   │   └── ViewModels/
│   │       └── TextEditorViewModel.swift
│   │
│   ├── CanvasEditor/                   # 畫布編輯器
│   │   ├── Models/
│   │   │   ├── Canvas.swift            # Receiver：畫布模型
│   │   │   ├── Shape.swift             # 圖形定義
│   │   │   └── CanvasMemento.swift     # Memento：畫布快照
│   │   ├── Commands/
│   │   │   ├── AddShapeCommand.swift
│   │   │   ├── RemoveShapeCommand.swift
│   │   │   ├── MoveShapeCommand.swift
│   │   │   ├── ResizeShapeCommand.swift
│   │   │   └── ChangeColorCommand.swift
│   │   └── ViewModels/
│   │       └── CanvasEditorViewModel.swift
│   │
│   └── Views/                          # UI Layer
│       ├── TextEditorViewController.swift
│       └── CanvasEditorViewController.swift
│
CarSystemTests/
└── UndoRedoTests/
    ├── CommandHistoryTests.swift
    ├── TextEditorTests/
    │   ├── TextDocumentTests.swift
    │   └── TextCommandTests.swift
    └── CanvasEditorTests/
        ├── CanvasTests.swift
        └── CanvasCommandTests.swift
```

---

## 實作階段

### Phase 1：Core 核心層 ⏳
**目標**：建立 Command Pattern 基礎設施

| # | 檔案 | 說明 | 狀態 |
|---|------|------|------|
| 1 | `Command.swift` | Command Protocol 定義 | ⬜ |
| 2 | `CommandHistory.swift` | 命令歷史管理器 | ⬜ |
| 3 | `CommandHistoryTests.swift` | 核心功能測試 | ⬜ |

**驗收標準**：
- [ ] `CommandHistory` 可獨立執行 undo/redo
- [ ] 執行新命令後 redo stack 清空
- [ ] 單元測試全部通過

---

### Phase 2：文章編輯器 ⏳
**目標**：實作文字編輯的所有命令

| # | 檔案 | 說明 | 狀態 |
|---|------|------|------|
| 4 | `TextStyle.swift` | 文字樣式（粗體/斜體/底線） | ⬜ |
| 5 | `TextDocument.swift` | 文件模型（Receiver） | ⬜ |
| 6 | `TextDocumentMemento.swift` | 文件快照結構 | ⬜ |
| 7 | `InsertTextCommand.swift` | 插入文字命令 | ⬜ |
| 8 | `DeleteTextCommand.swift` | 刪除文字命令 | ⬜ |
| 9 | `ReplaceTextCommand.swift` | 取代文字命令 | ⬜ |
| 10 | `ApplyStyleCommand.swift` | 套用樣式命令 | ⬜ |
| 11 | `TextDocumentTests.swift` | 文件模型測試 | ⬜ |
| 12 | `TextCommandTests.swift` | 文字命令測試 | ⬜ |

**驗收標準**：
- [ ] 插入、刪除、取代、套用樣式皆可 undo/redo
- [ ] 所有類別只 import Foundation
- [ ] 單元測試全部通過

---

### Phase 3：畫布編輯器 ⏳
**目標**：實作畫布編輯的所有命令

| # | 檔案 | 說明 | 狀態 |
|---|------|------|------|
| 13 | `Shape.swift` | 圖形定義（矩形/圓形/線條） | ⬜ |
| 14 | `Canvas.swift` | 畫布模型（Receiver） | ⬜ |
| 15 | `CanvasMemento.swift` | 畫布快照結構 | ⬜ |
| 16 | `AddShapeCommand.swift` | 新增圖形命令 | ⬜ |
| 17 | `RemoveShapeCommand.swift` | 刪除圖形命令 | ⬜ |
| 18 | `MoveShapeCommand.swift` | 移動圖形命令 | ⬜ |
| 19 | `ResizeShapeCommand.swift` | 縮放圖形命令 | ⬜ |
| 20 | `ChangeColorCommand.swift` | 變更顏色命令 | ⬜ |
| 21 | `CanvasTests.swift` | 畫布模型測試 | ⬜ |
| 22 | `CanvasCommandTests.swift` | 畫布命令測試 | ⬜ |

**驗收標準**：
- [ ] 新增、刪除、移動、縮放、變更顏色皆可 undo/redo
- [ ] 所有類別只 import Foundation
- [ ] 單元測試全部通過

---

### Phase 4：ViewModel 層 ⏳
**目標**：封裝業務邏輯，提供 UI 綁定介面

| # | 檔案 | 說明 | 狀態 |
|---|------|------|------|
| 23 | `TextEditorViewModel.swift` | 文字編輯器 ViewModel | ⬜ |
| 24 | `CanvasEditorViewModel.swift` | 畫布編輯器 ViewModel | ⬜ |

**驗收標準**：
- [ ] ViewModel 正確封裝 CommandHistory
- [ ] 提供 canUndo/canRedo 綁定
- [ ] 提供 undoDescription/redoDescription 綁定

---

### Phase 5：UI 層 ⏳
**目標**：實作使用者介面

| # | 檔案 | 說明 | 狀態 |
|---|------|------|------|
| 25 | `TextEditorViewController.swift` | 文字編輯器 UI | ⬜ |
| 26 | `CanvasEditorViewController.swift` | 畫布編輯器 UI | ⬜ |

**驗收標準**：
- [ ] Undo/Redo 按鈕狀態正確
- [ ] 按鈕顯示操作描述
- [ ] UI 即時反映編輯結果

---

### Phase 6：進階功能（選做）⏳
**目標**：實作進階命令功能

| # | 檔案 | 說明 | 狀態 |
|---|------|------|------|
| 27 | `CoalescibleCommand.swift` | 可合併命令協議 | ⬜ |
| 28 | `CompositeCommand.swift` | 組合命令類別 | ⬜ |
| 29 | `CommandHistory` 擴充 | 歷史數量限制 | ⬜ |

**驗收標準**：
- [ ] 連續輸入可合併為單一命令
- [ ] 多命令可組合為原子操作
- [ ] 歷史記錄數量有上限

---

## 時間估計

| Phase | 預估時間 | 說明 |
|-------|---------|------|
| Phase 1 | 30 分鐘 | 核心基礎設施 |
| Phase 2 | 1 小時 | 文章編輯器完整功能 |
| Phase 3 | 1 小時 | 畫布編輯器完整功能 |
| Phase 4 | 30 分鐘 | ViewModel 封裝 |
| Phase 5 | 1 小時 | UI 實作 |
| Phase 6 | 30 分鐘 | 進階功能（選做） |

**總計**：約 4-5 小時

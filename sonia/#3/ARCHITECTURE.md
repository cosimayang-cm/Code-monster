# Undo/Redo 系統架構文件

## 概述

本系統採用 **Command Pattern** 實作 Undo/Redo 功能，支援文字編輯器和畫布編輯器兩種應用場景。

## 架構圖

```
┌─────────────────────────────────────────────────────────────┐
│                        UI Layer                              │
│  TextEditorViewController / CanvasEditorViewController       │
└─────────────────────┬───────────────────────────────────────┘
                      │ 建立並執行 Command
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                   CommandHistory                             │
│  ┌──────────────┐              ┌──────────────┐             │
│  │  undoStack   │              │  redoStack   │             │
│  │  [Command]   │◄────────────►│  [Command]   │             │
│  └──────────────┘    undo/redo └──────────────┘             │
└─────────────────────┬───────────────────────────────────────┘
                      │ execute() / undo()
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                    Commands                                  │
│  InsertTextCommand │ DeleteTextCommand │ ReplaceTextCommand │
│  ApplyStyleCommand │ RemoveStyleCommand │ AddShapeCommand   │
└─────────────────────┬───────────────────────────────────────┘
                      │ 操作 Receiver
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                 Receivers (Model)                            │
│         TextDocument          │         Canvas               │
└─────────────────────────────────────────────────────────────┘
```

## 主要組件

| 組件 | 職責 |
|------|------|
| **Command (Protocol)** | 定義 `execute()` / `undo()` / `description` |
| **CommandHistory** | 管理 undo/redo stack，協調命令執行 |
| **TextDocument / Canvas** | Receiver，實際執行資料操作 |
| **ViewController** | 建立 Command 並交給 History 執行 |

## 目錄結構

```
Undo-Redo/
├── Command/                    # 核心命令框架
│   ├── Command.swift           # Command Protocol 定義
│   ├── CommandHistory.swift    # 歷史管理器
│   ├── CommandHistoryObserver.swift  # 觀察者協議
│   └── CompositeCommand.swift  # 複合命令
│
├── TextEditor/                 # 文字編輯器 Model
│   ├── TextDocument.swift      # 文字文件 (Receiver)
│   ├── TextStyle.swift         # 文字樣式定義
│   ├── InsertTextCommand.swift # 插入文字命令
│   ├── DeleteTextCommand.swift # 刪除文字命令
│   ├── ReplaceTextCommand.swift# 取代文字命令
│   ├── ApplyStyleCommand.swift # 套用樣式命令
│   └── RemoveStyleCommand.swift# 移除樣式命令
│
├── CanvasEditor/               # 畫布編輯器 Model
│   ├── Canvas.swift            # 畫布 (Receiver)
│   ├── Shape.swift             # 圖形定義
│   ├── Color.swift             # 顏色定義
│   ├── AddShapeCommand.swift   # 新增圖形命令
│   ├── RemoveShapeCommand.swift# 移除圖形命令
│   ├── MoveShapeCommand.swift  # 移動圖形命令
│   ├── ResizeShapeCommand.swift# 縮放圖形命令
│   └── ChangeColorCommand.swift# 變更顏色命令
│
└── UI/                         # UI Layer
    ├── TextEditor/
    │   └── TextEditorViewController.swift
    ├── CanvasEditor/
    │   ├── CanvasEditorViewController.swift
    │   └── Views/
    │       ├── CanvasView.swift
    │       └── ShapeView.swift
    ├── Components/
    │   └── UndoRedoToolbarView.swift
    ├── Extensions/
    │   └── Color+UIKit.swift
    └── UndoRedoDemoViewController.swift
```

## 進階功能

### 1. 命令合併 (Coalescing)

連續的相同類型操作（如連續輸入）會自動合併為單一命令，減少歷史記錄數量。

```swift
protocol CoalescibleCommand: Command {
    var coalescingTimeout: TimeInterval { get }
    var lastExecutionTime: Date { get set }
    func coalesce(with other: Command) -> Bool
}
```

### 2. 觀察者模式

UI 透過 `CommandHistoryObserver` 監聽歷史變化，自動更新 Undo/Redo 按鈕狀態。

```swift
protocol CommandHistoryObserver: AnyObject {
    func commandHistoryDidChange(_ history: CommandHistory)
}
```

### 3. 弱引用包裝

使用 `WeakCommandHistoryObserver` 避免 ViewController 與 CommandHistory 之間的循環引用。

## Undo/Redo 流程

### 執行新命令
```
1. ViewController 建立 Command
2. 呼叫 history.execute(command)
3. Command.execute() 修改 Receiver
4. Command 加入 undoStack
5. redoStack 清空
6. 通知 Observer 更新 UI
```

### Undo
```
1. 從 undoStack pop 最後一個 Command
2. 呼叫 Command.undo() 還原 Receiver
3. Command 加入 redoStack
4. 通知 Observer 更新 UI
```

### Redo
```
1. 從 redoStack pop 最後一個 Command
2. 呼叫 Command.execute() 重新執行
3. Command 加入 undoStack
4. 通知 Observer 更新 UI
```

## 評價

### 優點

| 項目 | 說明 |
|------|------|
| **架構清晰** | Command Pattern 實作標準，職責分離明確 |
| **可擴展性高** | 新增操作只需建立新 Command，不影響既有程式碼 |
| **支援合併** | CoalescibleCommand 處理連續輸入，避免歷史爆炸 |
| **記憶體安全** | Observer 使用弱引用，避免 retain cycle |
| **雙向復原** | 每個 Command 都實作 undo，支援完整的來回操作 |

### 可改進之處

| 項目 | 現況 | 建議 |
|------|------|------|
| **歷史上限** | undoStack 無限增長 | 加入 `maxHistoryCount` 限制 |
| **持久化** | 關閉 App 歷史消失 | 可序列化 Command 存入本地 |
| **群組命令** | 有 CompositeCommand 但未廣泛使用 | 更多場景應用複合命令 |
| **樣式模型** | 每個樣式獨立儲存 | 可改用合併後的單一 TextStyleRange |
| **選取範圍同步** | undo 後選取範圍不會還原 | 可在 Command 中記錄 selection state |

### 整體評分：⭐⭐⭐⭐ (4/5)

這是一個**教科書級的 Command Pattern 實作**，架構乾淨、易於理解和維護。對於展示 Undo/Redo 概念非常適合。若要用於生產環境，建議補上歷史上限和群組命令功能。

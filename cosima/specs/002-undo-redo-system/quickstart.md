# Undo/Redo 系統 - 快速開始

## 概念說明

### Command Pattern（命令模式）
將「操作」封裝成物件，讓你可以：
- 記錄操作歷史
- 撤銷（Undo）已執行的操作
- 重做（Redo）已撤銷的操作

```
┌─────────────────┐     execute()    ┌─────────────────┐
│   Invoker       │ ───────────────► │   Command       │
│ (CommandHistory)│                  │ (InsertText...) │
└─────────────────┘     undo()       └────────┬────────┘
                    ◄───────────────           │
                                               │ 操作
                                               ▼
                                      ┌─────────────────┐
                                      │   Receiver      │
                                      │ (TextDocument)  │
                                      └─────────────────┘
```

### Memento Pattern（備忘錄模式）
保存物件的完整狀態快照，讓你可以：
- 在任意時間點建立快照
- 還原到之前的狀態

---

## 使用範例

### 文章編輯器
```swift
// 1. 建立文件和歷史管理器
let document = TextDocument()
let history = CommandHistory()

// 2. 插入文字 "Hello"
let insertHello = InsertTextCommand(document: document, text: "Hello", position: 0)
history.execute(insertHello)
// document.content == "Hello"

// 3. 插入文字 " World"
let insertWorld = InsertTextCommand(document: document, text: " World", position: 5)
history.execute(insertWorld)
// document.content == "Hello World"

// 4. Undo - 撤銷插入 " World"
history.undo()
// document.content == "Hello"

// 5. Redo - 重做插入 " World"
history.redo()
// document.content == "Hello World"
```

### 畫布編輯器
```swift
// 1. 建立畫布和歷史管理器
let canvas = Canvas()
let history = CommandHistory()

// 2. 新增圓形
let circle = Circle(position: Point(x: 100, y: 100), radius: 50)
let addCircle = AddShapeCommand(canvas: canvas, shape: circle)
history.execute(addCircle)
// canvas.shapes.count == 1

// 3. 移動圓形
let moveCircle = MoveShapeCommand(canvas: canvas, shapeId: circle.id, offset: Point(x: 20, y: 30))
history.execute(moveCircle)
// circle.position == Point(x: 120, y: 130)

// 4. Undo - 撤銷移動
history.undo()
// circle.position == Point(x: 100, y: 100)

// 5. Undo - 撤銷新增
history.undo()
// canvas.shapes.count == 0
```

---

## 關鍵概念

### Command 必須保存足夠資訊
```swift
class DeleteTextCommand: Command {
    private let document: TextDocument
    private let range: Range<Int>
    private var deletedText: String?  // ⬅️ 必須記住被刪除的內容！
    
    func execute() {
        deletedText = document.delete(range: range)  // 保存被刪除的文字
    }
    
    func undo() {
        guard let text = deletedText else { return }
        document.insert(text, at: range.lowerBound)  // 還原文字
    }
}
```

### Redo Stack 在新命令執行後清空
```swift
// history: [A, B, C]
history.undo()  // 撤銷 C
history.undo()  // 撤銷 B
// undoStack: [A], redoStack: [B, C]

history.execute(D)  // 執行新命令 D
// undoStack: [A, D], redoStack: []  ⬅️ redo stack 被清空！
```

### 使用 Reference Type 要小心
```swift
// ❌ 錯誤：Shape 是 reference type，直接保存會被修改
class RemoveShapeCommand: Command {
    var removedShape: Shape?  // 這是一個參考！
    
    func execute() {
        removedShape = canvas.remove(shapeId: id)
        // 如果之後 shape 被修改，removedShape 也會跟著變
    }
}

// ✅ 正確：保存 Shape 的快照或複製
class RemoveShapeCommand: Command {
    var shapeSnapshot: ShapeSnapshot?  // 保存值類型的快照
    
    func execute() {
        if let shape = canvas.remove(shapeId: id) {
            shapeSnapshot = shape.snapshot()  // 建立快照
        }
    }
}
```

---

## 架構限制提醒

| 層級 | 允許 import | 檔案 |
|------|-------------|------|
| Foundation Only | `Foundation` | Command, CommandHistory, TextDocument, Canvas, 所有 Commands |
| ViewModel | `Foundation`, `UIKit`(可選) | TextEditorViewModel, CanvasEditorViewModel |
| ViewController | `Foundation`, `UIKit` | TextEditorViewController, CanvasEditorViewController |

**為什麼要這樣限制？**
- 純邏輯層可以獨立測試，不需要 UI 環境
- 邏輯與 UI 解耦，方便重用
- 測試執行速度快

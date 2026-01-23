# Data Model: Undo/Redo 編輯系統

**Date**: 2026-01-22
**Feature**: 002-undo-redo-system

## Core Entities

### Command (Protocol)

```swift
protocol Command {
    func execute()
    func undo()
    var description: String { get }
}
```

| Property | Type | Description |
|----------|------|-------------|
| description | String | 命令描述，用於 UI 顯示 |

| Method | Description |
|--------|-------------|
| execute() | 執行命令 |
| undo() | 撤銷命令 |

---

### CommandHistory

```swift
class CommandHistory {
    private var undoStack: [Command] = []
    private var redoStack: [Command] = []

    var canUndo: Bool
    var canRedo: Bool
    var undoDescription: String?
    var redoDescription: String?

    func execute(_ command: Command)
    func undo()
    func redo()
}
```

| Property | Type | Description |
|----------|------|-------------|
| undoStack | [Command] | 可撤銷的命令堆疊 |
| redoStack | [Command] | 可重做的命令堆疊 |
| canUndo | Bool | 是否可撤銷 |
| canRedo | Bool | 是否可重做 |
| undoDescription | String? | 下一個撤銷命令的描述 |
| redoDescription | String? | 下一個重做命令的描述 |

**Behavior**:
- `execute()`: 執行命令 → push to undoStack → clear redoStack
- `undo()`: pop from undoStack → undo → push to redoStack
- `redo()`: pop from redoStack → execute → push to undoStack

---

## Text Editor Entities

### TextDocument (Receiver)

```swift
class TextDocument {
    private(set) var content: String = ""
    private(set) var styles: [TextStyleRange] = []

    func insert(_ text: String, at index: String.Index)
    func delete(range: Range<String.Index>) -> String
    func replace(range: Range<String.Index>, with text: String) -> String
    func applyStyle(_ style: TextStyle, to range: Range<String.Index>)
    func removeStyle(_ style: TextStyle, from range: Range<String.Index>)
}
```

| Property | Type | Description |
|----------|------|-------------|
| content | String | 文件文字內容 |
| styles | [TextStyleRange] | 樣式範圍列表 |

---

### TextStyle

```swift
struct TextStyle: OptionSet {
    static let bold = TextStyle(rawValue: 1 << 0)
    static let italic = TextStyle(rawValue: 1 << 1)
    static let underline = TextStyle(rawValue: 1 << 2)
}
```

---

### TextStyleRange

```swift
struct TextStyleRange {
    let range: Range<String.Index>
    let style: TextStyle
}
```

---

### Text Commands

| Command | Properties | Description |
|---------|------------|-------------|
| InsertTextCommand | document, text, index | 在指定位置插入文字 |
| DeleteTextCommand | document, range, deletedText | 刪除指定範圍文字 |
| ReplaceTextCommand | document, range, newText, oldText | 取代指定範圍文字 |
| ApplyStyleCommand | document, range, style, previousStyles | 套用樣式 |

---

## Canvas Editor Entities

### Color

```swift
struct Color: Equatable {
    let red: Double    // 0.0 - 1.0
    let green: Double  // 0.0 - 1.0
    let blue: Double   // 0.0 - 1.0
    let alpha: Double  // 0.0 - 1.0

    static let black = Color(red: 0, green: 0, blue: 0, alpha: 1)
    static let white = Color(red: 1, green: 1, blue: 1, alpha: 1)
    static let red = Color(red: 1, green: 0, blue: 0, alpha: 1)
    static let blue = Color(red: 0, green: 0, blue: 1, alpha: 1)
}
```

---

### Point

```swift
struct Point: Equatable {
    var x: Double
    var y: Double
}
```

---

### Size

```swift
struct Size: Equatable {
    var width: Double
    var height: Double
}
```

---

### Shape (Protocol)

```swift
protocol Shape {
    var id: UUID { get }
    var position: Point { get set }
    var fillColor: Color { get set }
    var strokeColor: Color { get set }
}
```

---

### Rectangle

```swift
struct Rectangle: Shape {
    let id: UUID
    var position: Point
    var size: Size
    var fillColor: Color
    var strokeColor: Color
}
```

---

### Circle

```swift
struct Circle: Shape {
    let id: UUID
    var position: Point  // center
    var radius: Double
    var fillColor: Color
    var strokeColor: Color
}
```

---

### Line

```swift
struct Line: Shape {
    let id: UUID
    var position: Point  // start point
    var endPoint: Point
    var strokeColor: Color
    var fillColor: Color { get { .clear } set { } }  // Lines don't have fill
}
```

---

### Canvas (Receiver)

```swift
class Canvas {
    private(set) var shapes: [any Shape] = []

    func add(_ shape: any Shape)
    func remove(id: UUID) -> (any Shape)?
    func shape(withId id: UUID) -> (any Shape)?
    func updateShape(id: UUID, update: (inout any Shape) -> Void)
}
```

| Property | Type | Description |
|----------|------|-------------|
| shapes | [any Shape] | 畫布上的所有圖形 |

---

### Canvas Commands

| Command | Properties | Description |
|---------|------------|-------------|
| AddShapeCommand | canvas, shape | 新增圖形 |
| RemoveShapeCommand | canvas, shapeId, removedShape | 移除圖形 |
| MoveShapeCommand | canvas, shapeId, offset, previousPosition | 移動圖形 |
| ResizeShapeCommand | canvas, shapeId, newSize, previousSize | 縮放圖形 |
| ChangeColorCommand | canvas, shapeId, newFill, newStroke, previousFill, previousStroke | 變更顏色 |

---

## Entity Relationships

```
CommandHistory
    └── [Command]
            ├── InsertTextCommand ──► TextDocument
            ├── DeleteTextCommand ──► TextDocument
            ├── ReplaceTextCommand ──► TextDocument
            ├── ApplyStyleCommand ──► TextDocument
            ├── AddShapeCommand ──► Canvas
            ├── RemoveShapeCommand ──► Canvas
            ├── MoveShapeCommand ──► Canvas
            ├── ResizeShapeCommand ──► Canvas
            └── ChangeColorCommand ──► Canvas

TextDocument
    └── [TextStyleRange]
            └── TextStyle

Canvas
    └── [Shape]
            ├── Rectangle
            ├── Circle
            └── Line
```

---

## State Transitions

### CommandHistory States

```
[Empty] ──execute──► [HasUndo]
[HasUndo] ──undo──► [HasRedo]
[HasRedo] ──redo──► [HasUndo]
[HasRedo] ──execute──► [HasUndo, NoRedo]
```

### Shape Lifecycle

```
[Created] ──add──► [InCanvas] ──remove──► [Removed]
                       │
                       ├──move──► [InCanvas]
                       ├──resize──► [InCanvas]
                       └──changeColor──► [InCanvas]
```

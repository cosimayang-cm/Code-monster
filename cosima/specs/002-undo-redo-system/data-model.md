# Undo/Redo 系統 - 資料模型

## 核心模型

### Command Protocol
```swift
/// Foundation Only
protocol Command {
    var description: String { get }
    func execute()
    func undo()
}
```

### CommandHistory
```swift
/// Foundation Only
class CommandHistory {
    private var undoStack: [Command] = []
    private var redoStack: [Command] = []
    
    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }
    var undoDescription: String? { undoStack.last?.description }
    var redoDescription: String? { redoStack.last?.description }
}
```

---

## 文章編輯器模型

### TextStyle
```swift
/// 文字樣式 - 使用 OptionSet 支援多重樣式
struct TextStyle: OptionSet {
    let rawValue: Int
    
    static let bold      = TextStyle(rawValue: 1 << 0)  // 粗體
    static let italic    = TextStyle(rawValue: 1 << 1)  // 斜體
    static let underline = TextStyle(rawValue: 1 << 2)  // 底線
}
```

### TextDocument (Receiver)
```swift
/// 文件模型 - 命令的接收者
/// Foundation Only
class TextDocument {
    private(set) var content: String = ""
    private(set) var styles: [Range<Int>: TextStyle] = [:]
    
    // 基本操作
    func insert(_ text: String, at position: Int)
    func delete(range: Range<Int>) -> String
    func replace(range: Range<Int>, with text: String) -> String
    func applyStyle(_ style: TextStyle, to range: Range<Int>)
    func removeStyle(_ style: TextStyle, from range: Range<Int>)
}
```

### TextDocumentMemento
```swift
/// 文件快照
struct TextDocumentMemento {
    let content: String
    let styles: [Range<Int>: TextStyle]
    let timestamp: Date
}
```

---

## 畫布編輯器模型

### Point & Size
```swift
struct Point: Equatable {
    var x: Double
    var y: Double
}

struct Size: Equatable {
    var width: Double
    var height: Double
}
```

### Color
```swift
struct Color: Equatable {
    var red: Double    // 0.0 ~ 1.0
    var green: Double
    var blue: Double
    var alpha: Double
    
    static let black = Color(red: 0, green: 0, blue: 0, alpha: 1)
    static let white = Color(red: 1, green: 1, blue: 1, alpha: 1)
    static let red = Color(red: 1, green: 0, blue: 0, alpha: 1)
    static let clear = Color(red: 0, green: 0, blue: 0, alpha: 0)
}
```

### Shape
```swift
/// 圖形基礎協議
protocol Shape: AnyObject {
    var id: UUID { get }
    var position: Point { get set }
    var fillColor: Color { get set }
    var strokeColor: Color { get set }
}

/// 矩形
class Rectangle: Shape {
    let id: UUID
    var position: Point
    var size: Size
    var fillColor: Color
    var strokeColor: Color
}

/// 圓形
class Circle: Shape {
    let id: UUID
    var position: Point  // 圓心
    var radius: Double
    var fillColor: Color
    var strokeColor: Color
}

/// 線條
class Line: Shape {
    let id: UUID
    var position: Point  // 起點
    var endPoint: Point
    var fillColor: Color   // 未使用
    var strokeColor: Color
}
```

### Canvas (Receiver)
```swift
/// 畫布模型 - 命令的接收者
/// Foundation Only
class Canvas {
    private(set) var shapes: [Shape] = []
    private(set) var selectedShapeId: UUID?
    
    // 基本操作
    func add(_ shape: Shape)
    func remove(shapeId: UUID) -> Shape?
    func shape(withId id: UUID) -> Shape?
    func select(shapeId: UUID?)
}
```

### CanvasMemento
```swift
/// 畫布快照
struct CanvasMemento {
    let shapes: [ShapeSnapshot]  // 圖形快照陣列
    let selectedShapeId: UUID?
    let timestamp: Date
}

/// 圖形快照（用於 Memento，避免 reference type 問題）
enum ShapeSnapshot {
    case rectangle(id: UUID, position: Point, size: Size, fill: Color, stroke: Color)
    case circle(id: UUID, position: Point, radius: Double, fill: Color, stroke: Color)
    case line(id: UUID, start: Point, end: Point, stroke: Color)
}
```

---

## Command 類別

### 文章編輯器 Commands

```swift
class InsertTextCommand: Command {
    private let document: TextDocument
    private let text: String
    private let position: Int
    
    var description: String { "插入文字" }
}

class DeleteTextCommand: Command {
    private let document: TextDocument
    private let range: Range<Int>
    private var deletedText: String?  // undo 時需要
    
    var description: String { "刪除文字" }
}

class ReplaceTextCommand: Command {
    private let document: TextDocument
    private let range: Range<Int>
    private let newText: String
    private var oldText: String?  // undo 時需要
    
    var description: String { "取代文字" }
}

class ApplyStyleCommand: Command {
    private let document: TextDocument
    private let style: TextStyle
    private let range: Range<Int>
    private var previousStyles: [Range<Int>: TextStyle]?
    
    var description: String { "套用樣式" }
}
```

### 畫布編輯器 Commands

```swift
class AddShapeCommand: Command {
    private let canvas: Canvas
    private let shape: Shape
    
    var description: String { "新增圖形" }
}

class RemoveShapeCommand: Command {
    private let canvas: Canvas
    private let shapeId: UUID
    private var removedShape: Shape?
    
    var description: String { "刪除圖形" }
}

class MoveShapeCommand: Command {
    private let canvas: Canvas
    private let shapeId: UUID
    private let offset: Point
    private var originalPosition: Point?
    
    var description: String { "移動圖形" }
}

class ResizeShapeCommand: Command {
    private let canvas: Canvas
    private let shapeId: UUID
    private let newSize: Size  // 或 newRadius for Circle
    private var originalSize: Size?
    
    var description: String { "縮放圖形" }
}

class ChangeColorCommand: Command {
    private let canvas: Canvas
    private let shapeId: UUID
    private let newFillColor: Color?
    private let newStrokeColor: Color?
    private var originalFillColor: Color?
    private var originalStrokeColor: Color?
    
    var description: String { "變更顏色" }
}
```

---

## 進階模型

### CoalescibleCommand
```swift
protocol CoalescibleCommand: Command {
    /// 嘗試將另一個命令合併到自己
    func coalesce(with command: Command) -> Bool
}
```

### CompositeCommand
```swift
class CompositeCommand: Command {
    private var commands: [Command] = []
    let description: String
    
    init(description: String)
    func add(_ command: Command)
}
```

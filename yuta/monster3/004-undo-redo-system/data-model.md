# Data Model: Undo/Redo System

**Feature**: 004-undo-redo-system
**Date**: 2026-01-25
**Purpose**: 定義所有資料模型、Protocol 和實體（Foundation only - Clean Architecture）

## 架構概覽

```
┌─────────────────────────────────────────────────────────────────┐
│                     Foundation Only Layer                        │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────────┐       ┌──────────────────────────────┐    │
│  │  CommandHistory  │◄──────│  <<protocol>> Command        │    │
│  ├──────────────────┤       ├──────────────────────────────┤    │
│  │ - undoStack      │       │ + execute()                  │    │
│  │ - redoStack      │       │ + undo()                     │    │
│  ├──────────────────┤       │ + description: String        │    │
│  │ + execute()      │       └──────────────┬───────────────┘    │
│  │ + undo()         │                      │                    │
│  │ + redo()         │         ┌────────────┴────────────┐       │
│  └──────────────────┘         ▼                         ▼       │
│                     ┌──────────────────┐      ┌──────────────────┐
│                     │ Text Commands    │      │ Canvas Commands  │
│                     │ - Insert         │      │ - AddShape       │
│                     │ - Delete         │      │ - RemoveShape    │
│                     │ - Replace        │      │ - MoveShape      │
│                     │ - ApplyStyle     │      │ - ResizeShape    │
│                     └────────┬─────────┘      │ - ChangeColor    │
│                              │                └────────┬─────────┘
│                              ▼                         ▼         │
│                     ┌──────────────────┐      ┌──────────────────┐
│                     │  TextDocument    │      │     Canvas       │
│                     │  (Receiver)      │      │   (Receiver)     │
│                     └──────────────────┘      └──────────────────┘
└─────────────────────────────────────────────────────────────────┘
```

## 1. Core Protocols

### 1.1 Command Protocol

**檔案**: `Sources/Models/Command/Command.swift`

```swift
import Foundation

/// Command Pattern 的核心介面
/// 定義可執行和可撤銷的命令操作
public protocol Command: AnyObject {
    /// 執行命令，修改 Receiver 的狀態
    func execute()

    /// 撤銷命令，還原 Receiver 到執行前的狀態
    func undo()

    /// 命令的人類可讀描述，用於 UI 顯示
    /// 例如："插入文字 'Hello'"、"移動圖形"
    var description: String { get }
}
```

**設計說明**:
- 使用 `AnyObject` 限制為 class（reference type）
- `execute()` 和 `undo()` 必須是對稱操作
- `description` 用於 UI 顯示「復原 xxx」

### 1.2 Memento Protocol

**檔案**: `Sources/Models/Memento/Memento.swift`

```swift
import Foundation

/// Memento Pattern 的核心介面
/// 用於保存和還原物件的完整狀態
public protocol Memento {
    /// 關聯的狀態類型
    associatedtype State

    /// 保存的狀態
    var state: State { get }

    /// 從狀態建立 Memento
    init(state: State)
}
```

## 2. Command History

### 2.1 CommandHistory Class

**檔案**: `Sources/Models/Command/CommandHistory.swift`

```swift
import Foundation

/// 管理命令執行歷史，支援 Undo/Redo 操作
public final class CommandHistory {
    // MARK: - Properties

    /// Undo 堆疊：已執行的命令（LIFO）
    private var undoStack: [Command] = []

    /// Redo 堆疊：被撤銷的命令（LIFO）
    private var redoStack: [Command] = []

    /// 最大歷史記錄數量（0 表示無限制）
    public var maxHistorySize: Int = 0

    // MARK: - Initialization

    public init() {}

    // MARK: - Public Methods

    /// 執行命令並加入歷史記錄
    /// - Parameter command: 要執行的命令
    public func execute(_ command: Command) {
        command.execute()
        undoStack.append(command)
        redoStack.removeAll()

        // 限制歷史大小
        if maxHistorySize > 0 && undoStack.count > maxHistorySize {
            undoStack.removeFirst()
        }
    }

    /// 撤銷最近一次命令
    public func undo() {
        guard let command = undoStack.popLast() else { return }
        command.undo()
        redoStack.append(command)
    }

    /// 重做最近撤銷的命令
    public func redo() {
        guard let command = redoStack.popLast() else { return }
        command.execute()
        undoStack.append(command)
    }

    /// 清除所有歷史記錄
    public func clear() {
        undoStack.removeAll()
        redoStack.removeAll()
    }

    // MARK: - Query Methods

    /// 是否可以執行 Undo
    public var canUndo: Bool {
        !undoStack.isEmpty
    }

    /// 是否可以執行 Redo
    public var canRedo: Bool {
        !redoStack.isEmpty
    }

    /// 下一個要 Undo 的命令描述
    public var undoDescription: String? {
        undoStack.last?.description
    }

    /// 下一個要 Redo 的命令描述
    public var redoDescription: String? {
        redoStack.last?.description
    }

    /// 當前 Undo 堆疊大小
    public var undoCount: Int {
        undoStack.count
    }

    /// 當前 Redo 堆疊大小
    public var redoCount: Int {
        redoStack.count
    }
}
```

## 3. Receivers (資料模型)

### 3.1 TextDocument

**檔案**: `Sources/Models/Receivers/TextDocument.swift`

```swift
import Foundation

/// 文字文件模型（Receiver）
/// 支援文字內容編輯和樣式管理
public final class TextDocument {
    // MARK: - Types

    /// 文字範圍
    public struct TextRange: Hashable {
        public let start: Int
        public let end: Int

        public init(start: Int, end: Int) {
            self.start = start
            self.end = end
        }

        public var range: Range<Int> {
            start..<end
        }
    }

    // MARK: - Properties

    /// 文件內容
    private(set) public var content: String

    /// 樣式映射（範圍 -> 樣式）
    private(set) public var styles: [TextRange: TextStyle]

    /// 游標位置
    public var cursorPosition: Int

    // MARK: - Initialization

    public init(content: String = "") {
        self.content = content
        self.styles = [:]
        self.cursorPosition = 0
    }

    // MARK: - Text Operations

    /// 在指定位置插入文字
    /// - Parameters:
    ///   - text: 要插入的文字
    ///   - position: 插入位置
    public func insert(text: String, at position: Int) {
        guard position >= 0 && position <= content.count else { return }

        let index = content.index(content.startIndex, offsetBy: position)
        content.insert(contentsOf: text, at: index)

        // 更新後面範圍的樣式位置
        updateStylesAfterInsert(at: position, length: text.count)
    }

    /// 刪除指定範圍的文字
    /// - Parameter range: 要刪除的範圍
    /// - Returns: 被刪除的文字
    @discardableResult
    public func delete(range: Range<Int>) -> String {
        guard range.lowerBound >= 0 && range.upperBound <= content.count else {
            return ""
        }

        let startIndex = content.index(content.startIndex, offsetBy: range.lowerBound)
        let endIndex = content.index(content.startIndex, offsetBy: range.upperBound)
        let deletedText = String(content[startIndex..<endIndex])

        content.removeSubrange(startIndex..<endIndex)

        // 更新範圍樣式
        updateStylesAfterDelete(range: range)

        return deletedText
    }

    /// 取代指定範圍的文字
    /// - Parameters:
    ///   - range: 要取代的範圍
    ///   - text: 新文字
    /// - Returns: 被取代的文字
    @discardableResult
    public func replace(range: Range<Int>, with text: String) -> String {
        let deleted = delete(range: range)
        insert(text: text, at: range.lowerBound)
        return deleted
    }

    // MARK: - Style Operations

    /// 對指定範圍套用樣式
    /// - Parameters:
    ///   - style: 要套用的樣式
    ///   - range: 目標範圍
    public func applyStyle(_ style: TextStyle, to range: Range<Int>) {
        let textRange = TextRange(start: range.lowerBound, end: range.upperBound)
        styles[textRange] = style
    }

    /// 移除指定範圍的樣式
    /// - Parameter range: 目標範圍
    /// - Returns: 被移除的樣式（如果存在）
    @discardableResult
    public func removeStyle(from range: Range<Int>) -> TextStyle? {
        let textRange = TextRange(start: range.lowerBound, end: range.upperBound)
        return styles.removeValue(forKey: textRange)
    }

    // MARK: - Memento Support

    /// 建立當前狀態的快照
    public func createMemento() -> TextDocumentMemento {
        TextDocumentMemento(
            content: content,
            styles: styles,
            cursorPosition: cursorPosition
        )
    }

    /// 從快照還原狀態
    public func restore(from memento: TextDocumentMemento) {
        self.content = memento.content
        self.styles = memento.styles
        self.cursorPosition = memento.cursorPosition
    }

    // MARK: - Private Helpers

    private func updateStylesAfterInsert(at position: Int, length: Int) {
        // 實作：調整插入點之後的樣式範圍
        // 簡化版，實際可能需要處理樣式分割等複雜情況
    }

    private func updateStylesAfterDelete(range: Range<Int>) {
        // 實作：調整刪除範圍之後的樣式範圍
    }
}
```

### 3.2 Canvas

**檔案**: `Sources/Models/Receivers/Canvas.swift`

```swift
import Foundation

/// 畫布模型（Receiver）
/// 管理圖形的集合和操作
public final class Canvas {
    // MARK: - Properties

    /// 畫布上的所有圖形
    private(set) public var shapes: [Shape] = []

    /// 目前選取的圖形 ID
    public var selectedShapeId: UUID?

    // MARK: - Initialization

    public init() {}

    // MARK: - Shape Operations

    /// 新增圖形到畫布
    /// - Parameter shape: 要新增的圖形
    public func add(shape: Shape) {
        shapes.append(shape)
    }

    /// 從畫布移除圖形
    /// - Parameter shape: 要移除的圖形
    /// - Returns: 圖形在陣列中的索引（供 undo 使用）
    @discardableResult
    public func remove(shape: Shape) -> Int? {
        guard let index = shapes.firstIndex(where: { $0.id == shape.id }) else {
            return nil
        }
        shapes.remove(at: index)
        return index
    }

    /// 移動圖形
    /// - Parameters:
    ///   - shape: 要移動的圖形
    ///   - offset: 位移量
    public func move(shape: Shape, by offset: Point) {
        shape.position.x += offset.x
        shape.position.y += offset.y
    }

    /// 縮放圖形
    /// - Parameters:
    ///   - shape: 要縮放的圖形
    ///   - size: 新的大小
    public func resize(shape: Shape, to size: Size) {
        if let rectangle = shape as? Rectangle {
            rectangle.size = size
        } else if let circle = shape as? Circle {
            circle.radius = size.width / 2  // 使用寬度的一半作為半徑
        }
    }

    /// 變更圖形顏色
    /// - Parameters:
    ///   - shape: 要變更的圖形
    ///   - fillColor: 填充顏色（nil 表示不變）
    ///   - strokeColor: 邊框顏色（nil 表示不變）
    public func changeColor(
        shape: Shape,
        fillColor: Color? = nil,
        strokeColor: Color? = nil
    ) {
        if let fill = fillColor {
            shape.fillColor = fill
        }
        if let stroke = strokeColor {
            shape.strokeColor = stroke
        }
    }

    /// 根據 ID 尋找圖形
    /// - Parameter id: 圖形 ID
    /// - Returns: 找到的圖形，不存在則為 nil
    public func findShape(by id: UUID) -> Shape? {
        shapes.first { $0.id == id }
    }

    // MARK: - Memento Support

    /// 建立當前狀態的快照
    public func createMemento() -> CanvasMemento {
        // Deep copy shapes
        let shapesCopy = shapes.map { $0.copy() }
        return CanvasMemento(
            shapes: shapesCopy,
            selectedShapeId: selectedShapeId
        )
    }

    /// 從快照還原狀態
    public func restore(from memento: CanvasMemento) {
        self.shapes = memento.shapes.map { $0.copy() }
        self.selectedShapeId = memento.selectedShapeId
    }
}
```

## 4. Entities

### 4.1 Shape Protocol

**檔案**: `Sources/Models/Entities/Shape.swift`

```swift
import Foundation

/// 圖形基礎 protocol
public protocol Shape: AnyObject {
    /// 唯一識別碼
    var id: UUID { get }

    /// 位置
    var position: Point { get set }

    /// 填充顏色
    var fillColor: Color? { get set }

    /// 邊框顏色
    var strokeColor: Color? { get set }

    /// 深拷貝
    func copy() -> Shape
}
```

### 4.2 Rectangle

**檔案**: `Sources/Models/Entities/Rectangle.swift`

```swift
import Foundation

/// 矩形圖形
public final class Rectangle: Shape {
    public let id: UUID
    public var position: Point
    public var size: Size
    public var fillColor: Color?
    public var strokeColor: Color?

    public init(
        position: Point,
        size: Size,
        fillColor: Color? = nil,
        strokeColor: Color? = nil
    ) {
        self.id = UUID()
        self.position = position
        self.size = size
        self.fillColor = fillColor
        self.strokeColor = strokeColor
    }

    public func copy() -> Shape {
        let copy = Rectangle(
            position: position,
            size: size,
            fillColor: fillColor,
            strokeColor: strokeColor
        )
        return copy
    }
}
```

### 4.3 Circle

**檔案**: `Sources/Models/Entities/Circle.swift`

```swift
import Foundation

/// 圓形圖形
public final class Circle: Shape {
    public let id: UUID
    public var position: Point  // 圓心
    public var radius: Double
    public var fillColor: Color?
    public var strokeColor: Color?

    public init(
        position: Point,
        radius: Double,
        fillColor: Color? = nil,
        strokeColor: Color? = nil
    ) {
        self.id = UUID()
        self.position = position
        self.radius = radius
        self.fillColor = fillColor
        self.strokeColor = strokeColor
    }

    public func copy() -> Shape {
        let copy = Circle(
            position: position,
            radius: radius,
            fillColor: fillColor,
            strokeColor: strokeColor
        )
        return copy
    }
}
```

### 4.4 Line

**檔案**: `Sources/Models/Entities/Line.swift`

```swift
import Foundation

/// 線條圖形
public final class Line: Shape {
    public let id: UUID
    public var position: Point  // 起點
    public var endPoint: Point   // 終點
    public var fillColor: Color? // 線條不使用填充色
    public var strokeColor: Color?

    public init(
        position: Point,
        endPoint: Point,
        strokeColor: Color? = nil
    ) {
        self.id = UUID()
        self.position = position
        self.endPoint = endPoint
        self.fillColor = nil
        self.strokeColor = strokeColor
    }

    public func copy() -> Shape {
        let copy = Line(
            position: position,
            endPoint: endPoint,
            strokeColor: strokeColor
        )
        return copy
    }
}
```

### 4.5 TextStyle

**檔案**: `Sources/Models/Entities/TextStyle.swift`

```swift
import Foundation

/// 文字樣式
public struct TextStyle: Equatable, Hashable {
    public let isBold: Bool
    public let isItalic: Bool
    public let isUnderlined: Bool

    public init(
        isBold: Bool = false,
        isItalic: Bool = false,
        isUnderlined: Bool = false
    ) {
        self.isBold = isBold
        self.isItalic = isItalic
        self.isUnderlined = isUnderlined
    }

    /// 預設樣式（無任何格式）
    public static let plain = TextStyle()

    /// 粗體
    public static let bold = TextStyle(isBold: true)

    /// 斜體
    public static let italic = TextStyle(isItalic: true)

    /// 底線
    public static let underline = TextStyle(isUnderlined: true)
}
```

## 5. Memento Implementations

### 5.1 TextDocumentMemento

**檔案**: `Sources/Models/Memento/TextDocumentMemento.swift`

```swift
import Foundation

/// 文字文件的狀態快照
public struct TextDocumentMemento {
    public let content: String
    public let styles: [TextDocument.TextRange: TextStyle]
    public let cursorPosition: Int

    public init(
        content: String,
        styles: [TextDocument.TextRange: TextStyle],
        cursorPosition: Int
    ) {
        self.content = content
        self.styles = styles
        self.cursorPosition = cursorPosition
    }
}
```

### 5.2 CanvasMemento

**檔案**: `Sources/Models/Memento/CanvasMemento.swift`

```swift
import Foundation

/// 畫布的狀態快照
public struct CanvasMemento {
    public let shapes: [Shape]
    public let selectedShapeId: UUID?

    public init(
        shapes: [Shape],
        selectedShapeId: UUID?
    ) {
        self.shapes = shapes
        self.selectedShapeId = selectedShapeId
    }
}
```

## 6. Commands Summary

所有 Command 實作將在 `Sources/Models/Command/` 下的子目錄中：

### 6.1 Text Commands
- `InsertTextCommand.swift` - 插入文字
- `DeleteTextCommand.swift` - 刪除文字
- `ReplaceTextCommand.swift` - 取代文字
- `ApplyStyleCommand.swift` - 套用樣式

### 6.2 Canvas Commands
- `AddShapeCommand.swift` - 新增圖形
- `RemoveShapeCommand.swift` - 移除圖形
- `MoveShapeCommand.swift` - 移動圖形
- `ResizeShapeCommand.swift` - 縮放圖形
- `ChangeColorCommand.swift` - 變更顏色

## 7. 資料流程

### 7.1 執行命令

```
User Action (UI)
      ↓
ViewModel.executeCommand()
      ↓
CommandHistory.execute(command)
      ↓
Command.execute()
      ↓
Receiver (TextDocument/Canvas) 狀態改變
      ↓
UI 更新
```

### 7.2 Undo/Redo

```
User clicks Undo
      ↓
ViewModel.undo()
      ↓
CommandHistory.undo()
      ↓
Command.undo()
      ↓
Receiver 狀態還原
      ↓
UI 更新
```

## 8. 驗證規則

### Foundation Only 檢查

所有以下檔案**只能 import Foundation**:
- ✅ Command.swift
- ✅ CommandHistory.swift
- ✅ 所有 Command 實作
- ✅ TextDocument.swift
- ✅ Canvas.swift
- ✅ 所有 Entity (Shape, Rectangle, Circle, Line, TextStyle)
- ✅ 所有 Memento

### Reference Type 檢查

必須使用 **class** (reference type):
- ✅ Command 實作
- ✅ TextDocument
- ✅ Canvas
- ✅ Shape 實作 (Rectangle, Circle, Line)
- ✅ CommandHistory

必須使用 **struct** (value type):
- ✅ Memento 實作
- ✅ TextStyle
- ✅ TextRange

## 9. 測試覆蓋

每個模型都需要對應的測試：
- `CommandHistoryTests.swift` - 測試歷史管理
- `TextDocumentTests.swift` - 測試文字操作
- `CanvasTests.swift` - 測試畫布操作
- `TextCommandsTests.swift` - 測試所有文字命令
- `CanvasCommandsTests.swift` - 測試所有畫布命令
- `MementoTests.swift` - 測試快照功能

所有測試都必須：
- 只 import Foundation 和 XCTest
- 不依賴 UIKit
- 可獨立執行

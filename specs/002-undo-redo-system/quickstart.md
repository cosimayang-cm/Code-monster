# Quickstart: Undo/Redo 編輯系統

## 開發環境

- **Xcode**: 15.0+
- **Swift**: 5.9+
- **iOS Deployment Target**: 15.0+

## 專案設定

本專案使用 Swift Package Manager 結構：

```
Package.swift
Sources/
Tests/
```

## 快速開始範例

### 文章編輯器

```swift
import Foundation

// 1. 建立文件和歷史管理器
let document = TextDocument()
let history = CommandHistory()

// 2. 插入文字
let insertHello = InsertTextCommand(
    document: document,
    text: "Hello",
    at: document.content.startIndex
)
history.execute(insertHello)
// document.content == "Hello"

// 3. 插入更多文字
let insertWorld = InsertTextCommand(
    document: document,
    text: " World",
    at: document.content.endIndex
)
history.execute(insertWorld)
// document.content == "Hello World"

// 4. Undo
history.undo()
// document.content == "Hello"

// 5. Redo
history.redo()
// document.content == "Hello World"
```

### 畫布編輯器

```swift
import Foundation

// 1. 建立畫布和歷史管理器
let canvas = Canvas()
let history = CommandHistory()

// 2. 新增圓形
let circle = Circle(
    id: UUID(),
    position: Point(x: 100, y: 100),
    radius: 50,
    fillColor: .blue,
    strokeColor: .black
)
let addCircle = AddShapeCommand(canvas: canvas, shape: circle)
history.execute(addCircle)

// 3. 移動圓形
let moveCircle = MoveShapeCommand(
    canvas: canvas,
    shapeId: circle.id,
    offset: Point(x: 20, y: 30)
)
history.execute(moveCircle)
// circle position == (120, 130)

// 4. Undo 移動
history.undo()
// circle position == (100, 100)

// 5. Undo 新增
history.undo()
// canvas.shapes.isEmpty == true
```

## TDD 開發流程

### 1. 先寫測試

```swift
import XCTest
@testable import UndoRedo

final class CommandHistoryTests: XCTestCase {
    func test_initialState_cannotUndo() {
        let history = CommandHistory()
        XCTAssertFalse(history.canUndo)
    }

    func test_afterExecute_canUndo() {
        let history = CommandHistory()
        let document = TextDocument()
        let command = InsertTextCommand(
            document: document,
            text: "Hello",
            at: document.content.startIndex
        )

        history.execute(command)

        XCTAssertTrue(history.canUndo)
    }
}
```

### 2. 執行測試（應該失敗）

```bash
swift test
```

### 3. 實作最小程式碼使測試通過

### 4. 重構（保持測試通過）

## 常用指令

```bash
# 執行所有測試
swift test

# 只執行特定測試
swift test --filter CommandHistoryTests

# 建置專案
swift build
```

## 架構概覽

```
┌─────────────────────────────────────┐
│           UI Layer (UIKit)          │  ← 最後實作
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────┐  ┌──────────────┐  │
│  │CommandHistory│  │   Commands   │  │
│  └─────────────┘  └──────────────┘  │
│          │              │           │
│          ▼              ▼           │
│  ┌─────────────┐  ┌──────────────┐  │
│  │TextDocument │  │   Canvas     │  │  ← Model Layer
│  └─────────────┘  └──────────────┘  │    (Foundation only)
│                                     │
└─────────────────────────────────────┘
```

## 檔案對照表

| 規格中的類別 | 檔案位置 |
|-------------|----------|
| Command | Sources/UndoRedo/Command/Command.swift |
| CommandHistory | Sources/UndoRedo/Command/CommandHistory.swift |
| TextDocument | Sources/UndoRedo/TextEditor/TextDocument.swift |
| Canvas | Sources/UndoRedo/CanvasEditor/Canvas.swift |
| Shape | Sources/UndoRedo/CanvasEditor/Shape.swift |

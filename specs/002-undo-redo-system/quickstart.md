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

### Model Layer

| 規格中的類別 | 檔案位置 |
|-------------|----------|
| Command | Undo-Redo/Command/Command.swift |
| CommandHistory | Undo-Redo/Command/CommandHistory.swift |
| TextDocument | Undo-Redo/TextEditor/TextDocument.swift |
| Canvas | Undo-Redo/CanvasEditor/Canvas.swift |
| Shape | Undo-Redo/CanvasEditor/Shape.swift |

### UI Layer (2026-01-23 新增)

| 規格中的類別 | 檔案位置 |
|-------------|----------|
| CommandHistoryObserver | Undo-Redo/Command/CommandHistoryObserver.swift |
| Color+UIKit | Undo-Redo/UI/Extensions/Color+UIKit.swift |
| UndoRedoToolbarView | Undo-Redo/UI/Components/UndoRedoToolbarView.swift |
| UndoRedoDemoViewController | Undo-Redo/UI/UndoRedoDemoViewController.swift |
| TextEditorViewController | Undo-Redo/UI/TextEditor/TextEditorViewController.swift |
| CanvasEditorViewController | Undo-Redo/UI/CanvasEditor/CanvasEditorViewController.swift |
| CanvasView | Undo-Redo/UI/CanvasEditor/Views/CanvasView.swift |
| ShapeView | Undo-Redo/UI/CanvasEditor/Views/ShapeView.swift |

---

# UI Layer Quickstart (2026-01-23)

## Observer Pattern 使用

```swift
// 1. 讓 ViewController 實作 Observer
class TextEditorViewController: UIViewController, CommandHistoryObserver {

    private let history = CommandHistory()

    override func viewDidLoad() {
        super.viewDidLoad()
        history.addObserver(self)
    }

    deinit {
        history.removeObserver(self)
    }

    // 2. 實作 Observer 方法
    func commandHistoryDidChange(_ history: CommandHistory) {
        // 更新 UI
        undoButton.isEnabled = history.canUndo
        redoButton.isEnabled = history.canRedo
    }
}
```

## 文字編輯器 UI 範例

```swift
class TextEditorViewController: UIViewController, CommandHistoryObserver {

    private let document = TextDocument()
    private let history = CommandHistory()
    private let textView = UITextView()

    // 插入文字按鈕動作
    @objc func insertButtonTapped() {
        let command = InsertTextCommand(
            document: document,
            text: "Sample Text",
            at: document.content.endIndex
        )
        history.execute(command)
        refreshTextView()
    }

    // Undo 按鈕動作
    @objc func undoTapped() {
        history.undo()
        refreshTextView()
    }

    // Redo 按鈕動作
    @objc func redoTapped() {
        history.redo()
        refreshTextView()
    }

    // 更新文字顯示
    private func refreshTextView() {
        textView.text = document.content
    }

    // Observer callback
    func commandHistoryDidChange(_ history: CommandHistory) {
        navigationItem.rightBarButtonItems?.forEach { item in
            // 更新 Undo/Redo 按鈕狀態
        }
    }
}
```

## 畫布編輯器 UI 範例

```swift
class CanvasEditorViewController: UIViewController, CommandHistoryObserver, CanvasViewDelegate {

    private let canvas = Canvas()
    private let history = CommandHistory()
    private let canvasView = CanvasView()

    // 新增矩形按鈕動作
    @objc func addRectangleTapped() {
        let rect = Rectangle(
            id: UUID(),
            position: Point(x: 50, y: 50),
            size: Size(width: 100, height: 100),
            fillColor: .blue,
            strokeColor: .black
        )
        let command = AddShapeCommand(canvas: canvas, shape: rect)
        history.execute(command)
        canvasView.sync(with: canvas)
    }

    // CanvasViewDelegate - 處理圖形移動
    func canvasView(_ view: CanvasView, didMoveShape id: UUID, by offset: Point) {
        let command = MoveShapeCommand(
            canvas: canvas,
            shapeId: id,
            offset: offset
        )
        history.execute(command)
    }

    // Observer callback
    func commandHistoryDidChange(_ history: CommandHistory) {
        // 更新 Undo/Redo 按鈕狀態
    }
}
```

## Color 轉換

```swift
import UIKit

// 在 UI 層使用 Model 的 Color
let modelColor = Color.blue
let uiColor = modelColor.uiColor  // UIColor

// 應用到 View
shapeView.backgroundColor = canvas.shapes[0].fillColor.uiColor
```

## 架構概覽（含 UI 層）

```
┌─────────────────────────────────────────────────────────────┐
│                      UI Layer (UIKit)                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────┐    ┌──────────────────────────┐   │
│  │UndoRedoDemoViewController│    UndoRedoToolbarView     │   │
│  └──────────────────────┘    └──────────────────────────┘   │
│           │                                                  │
│     ┌─────┴─────┐                                            │
│     ▼           ▼                                            │
│  ┌──────────────────┐    ┌──────────────────────────────┐   │
│  │TextEditorVC      │    │CanvasEditorVC                │   │
│  │  ├─ UITextView   │    │  ├─ CanvasView               │   │
│  │  └─ Toolbar      │    │  │    └─ [ShapeView]         │   │
│  └──────────────────┘    │  └─ Toolbar                  │   │
│           │              └──────────────────────────────┘   │
│           │                         │                        │
│           │    CommandHistoryObserver                        │
│           │              │                                   │
├───────────┴──────────────┴───────────────────────────────────┤
│                                                              │
│  ┌─────────────┐  ┌──────────────┐                          │
│  │CommandHistory│  │   Commands   │                          │
│  │ + Observer   │  └──────────────┘                          │
│  └─────────────┘         │                                   │
│          │               ▼                                   │
│  ┌─────────────┐  ┌──────────────┐                          │
│  │TextDocument │  │   Canvas     │   ← Model Layer           │
│  └─────────────┘  └──────────────┘     (Foundation only)     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

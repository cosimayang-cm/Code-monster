# Quick Start: Undo/Redo 系統

**Feature**: Undo/Redo 系統
**Date**: 2026-01-24
**Purpose**: 快速開始指南

## 概覽

本指南提供 Undo/Redo 系統的快速入門，包含文章編輯器和畫布編輯器的基本使用範例。

## 1. 文章編輯器範例

### 1.1 基本設置

```swift
import Foundation

// 建立文字文件和命令歷史
let document = TextDocument()
let history = CommandHistory()
```

### 1.2 插入文字

```swift
// 在位置 0 插入 "Hello"
let insertHello = InsertTextCommand(
    document: document,
    text: "Hello",
    position: 0
)
history.execute(insertHello)

print(document.content)  // "Hello"
print(history.undoDescription)  // Optional("插入文字 \"Hello\"")
```

### 1.3 繼續編輯

```swift
// 在位置 5 插入 " World"
let insertWorld = InsertTextCommand(
    document: document,
    text: " World",
    position: 5
)
history.execute(insertWorld)

print(document.content)  // "Hello World"
```

### 1.4 Undo 操作

```swift
// 撤銷最後一次插入
history.undo()
print(document.content)  // "Hello"

// 再撤銷一次
history.undo()
print(document.content)  // ""
```

### 1.5 Redo 操作

```swift
// 重做第一次插入
history.redo()
print(document.content)  // "Hello"

// 重做第二次插入
history.redo()
print(document.content)  // "Hello World"
```

### 1.6 檢查狀態

```swift
// 檢查是否可以 undo/redo
if history.canUndo {
    print("可以 Undo: \(history.undoDescription!)")
}

if history.canRedo {
    print("可以 Redo: \(history.redoDescription!)")
}
```

## 2. 文字樣式範例

### 2.1 套用粗體

```swift
let document = TextDocument(content: "Hello World")
let history = CommandHistory()

// 對 "Hello" 套用粗體（位置 0-5）
let applyBold = ApplyStyleCommand(
    document: document,
    style: .bold,
    range: 0..<5
)
history.execute(applyBold)

// 檢查樣式
let range = TextDocument.TextRange(start: 0, end: 5)
print(document.styles[range]?.isBold)  // Optional(true)
```

### 2.2 Undo 樣式

```swift
// 撤銷樣式
history.undo()

// 樣式已移除
print(document.styles[range])  // nil
```

## 3. 畫布編輯器範例

### 3.1 基本設置

```swift
import Foundation

// 建立畫布和命令歷史
let canvas = Canvas()
let history = CommandHistory()
```

### 3.2 新增圖形

```swift
// 建立圓形
let circle = Circle(
    position: Point(x: 100, y: 100),
    radius: 50,
    fillColor: Color(red: 1.0, green: 0, blue: 0, alpha: 1.0)  // 紅色
)

// 新增到畫布
let addCircle = AddShapeCommand(
    canvas: canvas,
    shape: circle
)
history.execute(addCircle)

print(canvas.shapes.count)  // 1
```

### 3.3 移動圖形

```swift
// 移動圓形
let moveCircle = MoveShapeCommand(
    canvas: canvas,
    shape: circle,
    offset: Point(x: 20, y: 30)
)
history.execute(moveCircle)

print(circle.position)  // Point(x: 120, y: 130)
```

### 3.4 Undo 操作

```swift
// 撤銷移動
history.undo()
print(circle.position)  // Point(x: 100, y: 100)

// 撤銷新增
history.undo()
print(canvas.shapes.count)  // 0
```

### 3.5 Redo 操作

```swift
// 重做新增
history.redo()
print(canvas.shapes.count)  // 1

// 重做移動
history.redo()
print(circle.position)  // Point(x: 120, y: 130)
```

## 4. 複雜操作範例

### 4.1 多步驟編輯

```swift
let document = TextDocument()
let history = CommandHistory()

// 步驟 1: 插入 "Hello"
history.execute(InsertTextCommand(
    document: document,
    text: "Hello",
    position: 0
))

// 步驟 2: 插入 " "
history.execute(InsertTextCommand(
    document: document,
    text: " ",
    position: 5
))

// 步驟 3: 插入 "World"
history.execute(InsertTextCommand(
    document: document,
    text: "World",
    position: 6
))

// 步驟 4: 對 "Hello" 套用粗體
history.execute(ApplyStyleCommand(
    document: document,
    style: .bold,
    range: 0..<5
))

print(document.content)  // "Hello World"
print(history.undoCount)  // 4

// 全部 Undo
while history.canUndo {
    history.undo()
}

print(document.content)  // ""
print(history.redoCount)  // 4
```

### 4.2 新命令清空 Redo

```swift
let document = TextDocument()
let history = CommandHistory()

// 執行兩個命令
history.execute(InsertTextCommand(document: document, text: "A", position: 0))
history.execute(InsertTextCommand(document: document, text: "B", position: 1))

// Undo 一次
history.undo()
print(history.canRedo)  // true

// 執行新命令
history.execute(InsertTextCommand(document: document, text: "C", position: 1))

// Redo 堆疊被清空
print(history.canRedo)  // false
```

## 5. 使用 Memento 的範例

### 5.1 建立快照

```swift
let document = TextDocument(content: "Hello World")

// 套用一些樣式
document.applyStyle(.bold, to: 0..<5)
document.applyStyle(.italic, to: 6..<11)

// 建立快照
let memento = document.createMemento()

// 繼續編輯
document.insert(text: "!!!", at: 11)

print(document.content)  // "Hello World!!!"
```

### 5.2 還原快照

```swift
// 從快照還原
document.restore(from: memento)

print(document.content)  // "Hello World"
// 樣式也被還原
```

### 5.3 使用 Memento 的 Command

```swift
class BatchEditCommand: Command {
    private weak var document: TextDocument?
    private var beforeMemento: TextDocumentMemento?
    private let operations: () -> Void

    init(document: TextDocument, operations: @escaping () -> Void) {
        self.document = document
        self.operations = operations
    }

    func execute() {
        beforeMemento = document?.createMemento()
        operations()
    }

    func undo() {
        guard let memento = beforeMemento else { return }
        document?.restore(from: memento)
    }

    var description: String {
        "批次編輯"
    }
}

// 使用
let document = TextDocument()
let history = CommandHistory()

let batchEdit = BatchEditCommand(document: document) {
    document.insert(text: "Line 1\n", at: 0)
    document.insert(text: "Line 2\n", at: 7)
    document.insert(text: "Line 3\n", at: 14)
    document.applyStyle(.bold, to: 0..<6)
}

history.execute(batchEdit)

// 一次 undo 就能復原所有操作
history.undo()
print(document.content)  // ""
```

## 6. UI 整合範例（ViewModel 層）

### 6.1 TextEditorViewModel

```swift
import Foundation

class TextEditorViewModel {
    // Model
    private let document: TextDocument
    private let history: CommandHistory

    init() {
        self.document = TextDocument()
        self.history = CommandHistory()
    }

    // 插入文字
    func insertText(_ text: String, at position: Int) {
        let command = InsertTextCommand(
            document: document,
            text: text,
            position: position
        )
        history.execute(command)
    }

    // 刪除文字
    func deleteText(in range: Range<Int>) {
        let command = DeleteTextCommand(
            document: document,
            range: range
        )
        history.execute(command)
    }

    // Undo
    func undo() {
        history.undo()
    }

    // Redo
    func redo() {
        history.redo()
    }

    // Query
    var content: String {
        document.content
    }

    var canUndo: Bool {
        history.canUndo
    }

    var canRedo: Bool {
        history.canRedo
    }

    var undoButtonTitle: String {
        if let desc = history.undoDescription {
            return "復原 \(desc)"
        } else {
            return "復原"
        }
    }

    var redoButtonTitle: String {
        if let desc = history.redoDescription {
            return "重做 \(desc)"
        } else {
            return "重做"
        }
    }
}
```

### 6.2 ViewController 使用

```swift
import UIKit

class TextEditorViewController: UIViewController {
    private let viewModel = TextEditorViewModel()

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!

    // 使用者輸入文字
    func textViewDidChange(_ textView: UITextView) {
        // 實際應用中可能需要更複雜的邏輯來決定何時建立命令
        // 這裡簡化為每次變更都建立命令
    }

    // Undo 按鈕
    @IBAction func undoButtonTapped() {
        viewModel.undo()
        updateUI()
    }

    // Redo 按鈕
    @IBAction func redoButtonTapped() {
        viewModel.redo()
        updateUI()
    }

    // 更新 UI
    private func updateUI() {
        textView.text = viewModel.content
        undoButton.isEnabled = viewModel.canUndo
        redoButton.isEnabled = viewModel.canRedo
        undoButton.setTitle(viewModel.undoButtonTitle, for: .normal)
        redoButton.setTitle(viewModel.redoButtonTitle, for: .normal)
    }
}
```

## 7. 測試範例

### 7.1 基本測試

```swift
import XCTest

class CommandHistoryTests: XCTestCase {
    func testExecuteAndUndo() {
        // Given
        let document = TextDocument()
        let history = CommandHistory()
        let command = InsertTextCommand(document: document, text: "Test", position: 0)

        // When
        history.execute(command)

        // Then
        XCTAssertEqual(document.content, "Test")
        XCTAssertTrue(history.canUndo)

        // When
        history.undo()

        // Then
        XCTAssertEqual(document.content, "")
        XCTAssertFalse(history.canUndo)
        XCTAssertTrue(history.canRedo)
    }
}
```

## 8. 進階功能範例（選做）

### 8.1 命令合併

```swift
class InsertTextCommand: CoalescibleCommand {
    private weak var document: TextDocument?
    private var text: String
    private let position: Int
    private let timestamp: Date

    init(document: TextDocument, text: String, position: Int) {
        self.document = document
        self.text = text
        self.position = position
        self.timestamp = Date()
    }

    func execute() {
        document?.insert(text: text, at: position)
    }

    func undo() {
        document?.delete(range: position..<(position + text.count))
    }

    var description: String {
        "插入文字 \"\(text)\""
    }

    // 嘗試合併
    func coalesce(with command: Command) -> Bool {
        guard let other = command as? InsertTextCommand,
              other.position == self.position + self.text.count,
              abs(other.timestamp.timeIntervalSince(self.timestamp)) < 1.0 else {
            return false
        }

        // 合併文字
        self.text += other.text
        return true
    }
}
```

### 8.2 歷史限制

```swift
let history = CommandHistory()
history.maxHistorySize = 100  // 最多保存 100 個命令

// 超過 100 個命令時，最舊的命令會被自動移除
```

## 9. 常見問題

### Q: 為什麼 Command 要持有 weak reference?

A: 避免循環參照。Command 持有 Receiver，CommandHistory 持有 Command，如果 Receiver 也持有 CommandHistory，就形成循環參照。

### Q: 什麼時候使用 Memento 而非 Command?

A: 當操作難以反向時（複雜批次操作）、需要保存快照、或效能考量時使用 Memento。

### Q: 如何處理 Redo 堆疊清空?

A: 這是標準行為。執行新命令後，無法 redo 被 undo 的操作，因為新操作改變了歷史分支。

### Q: 可以限制歷史大小嗎?

A: 可以。設定 `CommandHistory.maxHistorySize` 即可限制最大歷史記錄數量。

## 10. SwiftUI UI 實作（可選）

### 10.1 簡單的文字編輯器 UI

```swift
import SwiftUI

struct TextEditorView: View {
    @StateObject private var viewModel = TextEditorViewModel(
        document: TextDocument(),
        history: CommandHistory()
    )

    @State private var text: String = ""

    var body: some View {
        VStack {
            // 工具列
            HStack {
                Button(viewModel.undoButtonTitle) {
                    viewModel.undo()
                }
                .disabled(!viewModel.canUndo)

                Button(viewModel.redoButtonTitle) {
                    viewModel.redo()
                }
                .disabled(!viewModel.canRedo)
            }
            .padding()

            // 文字編輯區
            TextEditor(text: $text)
                .onChange(of: text) { newValue in
                    // 同步到 ViewModel
                    if newValue != viewModel.content {
                        let position = viewModel.content.count
                        let insertedText = String(newValue.suffix(newValue.count - viewModel.content.count))
                        viewModel.insertText(insertedText, at: position)
                    }
                }
                .onReceive(viewModel.$content) { newContent in
                    // 從 ViewModel 同步回來
                    if text != newContent {
                        text = newContent
                    }
                }
        }
    }
}
```

### 10.2 簡單的畫布編輯器 UI

```swift
import SwiftUI

struct CanvasEditorView: View {
    @StateObject private var viewModel = CanvasEditorViewModel(
        canvas: Canvas(),
        history: CommandHistory()
    )

    var body: some View {
        VStack {
            // 工具列
            HStack {
                Button(viewModel.undoButtonTitle) {
                    viewModel.undo()
                }
                .disabled(!viewModel.canUndo)

                Button(viewModel.redoButtonTitle) {
                    viewModel.redo()
                }
                .disabled(!viewModel.canRedo)
            }
            .padding()

            // 畫布
            Canvas { context, size in
                for shape in viewModel.shapes {
                    // 繪製圖形
                    if let rect = shape as? Rectangle {
                        let path = Path(
                            CGRect(
                                origin: rect.position.cgPoint,
                                size: rect.size.cgSize
                            )
                        )
                        context.fill(
                            path,
                            with: .color(Color(rect.fillColor?.uiColor ?? .clear))
                        )
                    }
                }
            }
        }
    }
}
```

### 10.3 App 入口點

```swift
import SwiftUI

@main
struct UndoRedoApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                TextEditorView()
                    .tabItem {
                        Label("文字編輯器", systemImage: "doc.text")
                    }

                CanvasEditorView()
                    .tabItem {
                        Label("畫布編輯器", systemImage: "paintbrush")
                    }
            }
        }
    }
}
```

**注意**：
- SwiftUI UI 為**可選功能**，僅在核心實作完成且有餘裕時執行
- 詳細實作請參考 plan.md Phase 7 和 tasks.md Phase 9
- 優先專注於設計模式學習，UI 為錦上添花

---

## 11. 下一步

### 核心實作（必須完成）

- 查看 [data-model.md](data-model.md) 了解完整的資料模型
- 查看 [contracts/](contracts/) 目錄了解所有 protocol 定義
- 開始實作各個 Command（參考 plan.md 的架構）
- 在 Playground 或 Unit Test 中驗證功能

### UI 實作（有餘裕時）

- 參考 plan.md Phase 7 的詳細 SwiftUI 實作
- 參考 tasks.md Phase 9 的任務清單
- 在模擬器上測試視覺化效果

# Research: Undo/Redo System

**Feature**: 004-undo-redo-system
**Date**: 2026-01-25
**Status**: Completed

## Overview

本研究文件記錄 Undo/Redo 系統的技術決策、設計模式選擇與實作策略。

## Design Pattern Research

### Decision 1: Command Pattern for Undo/Redo

**Decision**: 使用 Command Pattern 封裝所有可撤銷的操作

**Rationale**:
- Command Pattern 將操作封裝為物件，自然支援 Undo/Redo
- 每個 Command 知道如何執行 (execute) 和撤銷 (undo) 自己
- 符合 Single Responsibility Principle - 每個 Command 只負責一種操作
- 符合 Open/Closed Principle - 新增操作不需修改現有代碼
- 易於測試 - 每個 Command 可獨立測試

**Alternatives Considered**:
1. **直接在 ViewController 記錄狀態變化**
   - ❌ 違反 Single Responsibility - ViewController 職責過多
   - ❌ 難以測試 - 需要啟動完整 UI
   - ❌ 耦合度高 - 業務邏輯與 UI 混合

2. **使用閉包 (Closure) 記錄操作**
   - ❌ 缺乏結構化 - 難以管理複雜操作
   - ❌ 難以調試 - 無法查看命令歷史
   - ❌ 無法提供操作描述 - 影響 UI 顯示

---

### Decision 2: Memento Pattern for State Snapshots

**Decision**: 使用 Memento Pattern 保存複雜操作的狀態快照

**Rationale**:
- 某些操作難以反向執行（如批次編輯、複雜變換）
- Memento 提供狀態快照機制，可直接還原
- 保護物件封裝性 - 外部無法直接修改狀態
- 符合 Single Responsibility - Originator 負責建立/還原，Memento 只存狀態

**Alternatives Considered**:
1. **深拷貝 (Deep Copy) 整個物件**
   - ❌ 效能問題 - 大型文件/畫布會消耗大量記憶體
   - ❌ 缺乏選擇性 - 無法只保存需要的狀態

2. **事件溯源 (Event Sourcing)**
   - ❌ 過度設計 - 教育專案不需要完整事件歷史
   - ❌ 實作複雜度高

---

### Decision 3: Protocol-Based Abstraction (Dependency Inversion)

**Decision**: 所有核心組件（TextDocument, Canvas, CommandHistory）使用 Protocol 抽象

**Rationale**:
- 符合 SOLID-D (Dependency Inversion Principle)
- 高層模組 (ViewModel, Command) 依賴抽象而非具體實作
- 提升可測試性 - 可注入 Mock 實作
- 提升靈活性 - 可輕易替換實作

**Alternatives Considered**:
1. **直接使用具體類別**
   - ❌ 違反 DIP - 高層依賴低層
   - ❌ 難以測試 - 無法注入 Mock
   - ❌ 耦合度高 - 難以替換實作

---

## Architecture Research

### Decision 4: Foundation-Only Model Layer

**Decision**: Model 層（Command, Receiver, Memento）只使用 Foundation，不依賴 UIKit

**Rationale**:
- 清晰的層級分離 - 業務邏輯與 UI 完全解耦
- 提升可測試性 - 測試不需啟動 UI framework
- 符合 Clean Architecture - 核心業務邏輯不依賴外層
- 可重用性 - 核心邏輯可用於其他平台（macOS, watchOS）

**Implementation Strategy**:
1. 定義自訂型別取代 UIKit 型別：
   - `Color` (取代 `UIColor`)
   - `Point` (取代 `CGPoint`)
   - `Size` (取代 `CGSize`)

2. View 層使用 Extension 進行轉換

**Alternatives Considered**:
1. **直接使用 UIKit 型別**
   - ❌ 違反 Clean Architecture - Model 依賴 UI framework
   - ❌ 難以測試 - 需要 UIKit 環境
   - ❌ 平台限制 - 無法跨平台重用

---

### Decision 5: Combine Framework for Reactive Architecture

**Decision**: 使用 Combine Framework (@Published) 實現 ViewModel-ViewController 響應式綁定

**Rationale**:
- 現代 Swift 標準 - Apple 官方推薦的響應式框架
- 自動化資料流 - @Published 自動通知訂閱者
- 解耦 ViewModel-ViewController - 單向資料流
- 型別安全 - 編譯時檢查
- 生命週期管理 - AnyCancellable 自動取消訂閱

**Alternatives Considered**:
1. **Delegate Pattern**
   - ❌ 樣板代碼多 - 需要定義 protocol + delegate 方法
   - ❌ 難以管理多個訂閱 - 需要多個 delegate
   - ❌ 不夠現代 - Combine 提供更好的解決方案

2. **Notification Center**
   - ❌ 型別不安全 - 使用字串識別
   - ❌ 難以追蹤 - 訂閱關係不明確
   - ❌ 生命週期管理困難

---

### Decision 6: TDD with Given-When-Then Structure

**Decision**: 採用 Test-Driven Development，所有測試使用 Given-When-Then 結構

**Rationale**:
- 符合 PAGEs Testing Standards
- 清晰的測試結構 - 前置條件、操作、驗證分離
- 易讀性高 - 中文註解說明意圖
- 符合 BDD 精神 - 測試即文檔

**Test Naming Convention**:
- Format: `testMethodNameWhenConditionThenExpectedResult`
- Style: camelCase
- Language: English (方法名) + Traditional Chinese (註解)

---

### Decision 7: Unlimited Undo/Redo History (Educational Scope)

**Decision**: 不限制 Undo/Redo 歷史記錄數量

**Rationale**:
- 教育專案 - 專注於設計模式學習
- 簡化實作 - 避免過早優化
- 實際使用場景小 - 不會產生效能問題

**Future Optimization**: 可在 CommandHistory 中加入 maxHistorySize 限制（選做）

---

### Decision 8: Weak References in Commands

**Decision**: Command 對 Receiver 使用 weak reference

**Rationale**:
- 避免 retain cycle - CommandHistory 持有 Command，Command 持有 Receiver
- 符合 PAGEs Code Quality Standards
- 安全性 - Receiver 被釋放時，Command 自動失效

---

## Summary

| Decision | Pattern/Technology | Rationale |
|----------|-------------------|-----------|
| Undo/Redo 機制 | Command Pattern | 封裝操作，自然支援撤銷/重做 |
| 狀態快照 | Memento Pattern | 保存複雜狀態，直接還原 |
| 抽象層 | Protocol-based | 符合 DIP，提升可測試性 |
| Model 層 | Foundation only | Clean Architecture，解耦 UI |
| 響應式架構 | Combine (@Published) | 現代化，解耦 ViewModel-ViewController |
| 測試策略 | TDD + Given-When-Then | 符合 PAGEs Standards |
| 記憶體管理 | Weak references | 避免 retain cycle |
| 歷史限制 | Unlimited (教育) | 簡化實作，專注學習 |

**Next Steps**:
- Phase 1: Generate data-model.md (定義實體與關係)
- Phase 1: Generate contracts (定義 Protocol 介面)
- Phase 1: Generate quickstart.md (開發指南)

---

## 1. Command Pattern 深入理解

### 1.1 Pattern 概述

**定義**: Command Pattern 將請求封裝成物件，讓你可以用不同的請求將客戶參數化，並支援 undo/redo 操作。

**核心角色**:
- **Command**: 定義 execute() 和 undo() 介面
- **ConcreteCommand**: 實作具體命令，持有 Receiver 參考
- **Receiver**: 真正執行操作的物件（TextDocument, Canvas）
- **Invoker**: 要求命令執行操作（CommandHistory）

### 1.2 Command Protocol 設計

```swift
// 基礎 Command protocol
protocol Command {
    /// 執行命令
    func execute()

    /// 撤銷命令
    func undo()

    /// 命令描述（用於 UI 顯示）
    var description: String { get }
}
```

**設計考量**:
1. **execute() 方法**: 執行實際操作，修改 Receiver 狀態
2. **undo() 方法**: 反轉 execute() 的效果，必須保存足夠資訊以還原
3. **description 屬性**: 提供人類可讀的描述，用於 UI 顯示「復原插入文字」等

### 1.3 CommandHistory 實作策略

```swift
class CommandHistory {
    private var undoStack: [Command] = []
    private var redoStack: [Command] = []

    func execute(_ command: Command) {
        command.execute()
        undoStack.append(command)
        redoStack.removeAll()  // 重要：新命令清空 redo 堆疊
    }

    func undo() {
        guard let command = undoStack.popLast() else { return }
        command.undo()
        redoStack.append(command)
    }

    func redo() {
        guard let command = redoStack.popLast() else { return }
        command.execute()
        undoStack.append(command)
    }

    var canUndo: Bool {
        !undoStack.isEmpty
    }

    var canRedo: Bool {
        !redoStack.isEmpty
    }

    var undoDescription: String? {
        undoStack.last?.description
    }

    var redoDescription: String? {
        redoStack.last?.description
    }
}
```

**關鍵設計決策**:
- **使用兩個堆疊**: undoStack 保存已執行的命令，redoStack 保存被撤銷的命令
- **execute 時清空 redo**: 執行新命令時必須清空 redoStack，這是 undo/redo 的標準行為
- **LIFO 順序**: 後進先出（Last In, First Out），最近的命令最先被撤銷

### 1.4 Concrete Command 範例

#### InsertTextCommand

```swift
class InsertTextCommand: Command {
    private weak var document: TextDocument?
    private let text: String
    private let position: Int

    init(document: TextDocument, text: String, position: Int) {
        self.document = document
        self.text = text
        self.position = position
    }

    func execute() {
        document?.insert(text: text, at: position)
    }

    func undo() {
        let range = position..<(position + text.count)
        _ = document?.delete(range: range)
    }

    var description: String {
        "插入文字 \"\(text)\""
    }
}
```

**重點**:
- **weak reference to Receiver**: 避免循環參照
- **保存 undo 所需資訊**: position 和 text，以便 undo 時刪除正確範圍
- **對稱性**: execute 插入文字，undo 刪除相同文字

#### DeleteTextCommand

```swift
class DeleteTextCommand: Command {
    private weak var document: TextDocument?
    private let range: Range<Int>
    private var deletedText: String = ""  // 保存被刪除的文字以供 undo

    init(document: TextDocument, range: Range<Int>) {
        self.document = document
        self.range = range
    }

    func execute() {
        deletedText = document?.delete(range: range) ?? ""
    }

    func undo() {
        document?.insert(text: deletedText, at: range.lowerBound)
    }

    var description: String {
        "刪除文字"
    }
}
```

**重點**:
- **保存被刪除的內容**: deletedText 在 execute 時記錄，undo 時還原
- **範圍資訊**: 保存 range 以知道插入位置

## 2. Memento Pattern 應用時機

### 2.1 Pattern 概述

**定義**: Memento Pattern 在不違反封裝的前提下，捕獲並外部化一個物件的內部狀態，讓該物件可以稍後恢復到此狀態。

**何時使用 Memento 而非 Command**:
1. **Command 無法輕易反向操作**: 例如複雜的批次操作，難以實作 undo()
2. **需要保存快照供跳轉**: 例如跳到特定歷史版本
3. **效能考量**: 當重新執行所有命令太慢時，保存中間狀態

### 2.2 Memento 結構設計

```swift
// Memento Protocol
protocol Memento {
    associatedtype State
    var state: State { get }
    init(state: State)
}

// TextDocument 的 Memento
struct TextDocumentMemento: Memento {
    let content: String
    let styles: [TextRange: TextStyle]
    let cursorPosition: Int

    init(state: (content: String, styles: [TextRange: TextStyle], cursor: Int)) {
        self.content = state.content
        self.styles = state.styles
        self.cursorPosition = state.cursor
    }

    var state: (content: String, styles: [TextRange: TextStyle], cursor: Int) {
        (content, styles, cursorPosition)
    }
}

// Canvas 的 Memento
struct CanvasMemento: Memento {
    let shapes: [Shape]  // Deep copy of shapes
    let selectedShapeId: UUID?

    init(state: (shapes: [Shape], selected: UUID?)) {
        // Deep copy shapes to avoid reference issues
        self.shapes = state.shapes.map { $ }
        self.selectedShapeId = state.selected
    }

    var state: (shapes: [Shape], selected: UUID?) {
        (shapes, selectedShapeId)
    }
}
```

### 2.3 Memento + Command 混合使用

```swift
// 使用 Memento 的 Command
class BatchEditCommand: Command {
    private weak var document: TextDocument?
    private var beforeMemento: TextDocumentMemento?
    private var afterMemento: TextDocumentMemento?
    private let operations: () -> Void

    init(document: TextDocument, operations: @escaping () -> Void) {
        self.document = document
        self.operations = operations
    }

    func execute() {
        // 保存執行前的狀態
        beforeMemento = document?.createMemento()

        // 執行批次操作
        operations()

        // 保存執行後的狀態（可選）
        afterMemento = document?.createMemento()
    }

    func undo() {
        guard let memento = beforeMemento else { return }
        document?.restore(from: memento)
    }

    var description: String {
        "批次編輯"
    }
}
```

**適用場景**:
- 多個小操作組合成的複雜操作
- 狀態變化複雜，難以逐步反轉
- 需要快速還原到先前狀態

## 3. Swift 實作注意事項

### 3.1 Value Type vs Reference Type

**Receiver 應使用 Reference Type (class)**:
```swift
// ✅ 正確：使用 class
class TextDocument {
    private(set) var content: String = ""

    func insert(text: String, at position: Int) {
        // 修改 content
    }
}

// ❌ 錯誤：使用 struct 會導致複製問題
struct TextDocument {  // 不建議
    var content: String = ""
}
```

**原因**:
- Command 需要持有 Receiver 的參考
- struct 是 value type，會被複製，導致 Command 操作的是副本
- class 是 reference type，多個 Command 可以共享同一個 Receiver

**Memento 應使用 Value Type (struct)**:
```swift
// ✅ 正確：使用 struct
struct TextDocumentMemento: Memento {
    let content: String
    let styles: [TextRange: TextStyle]
}
```

**原因**:
- Memento 應該是不可變的快照
- struct 提供值語意，自動深拷貝
- 避免意外修改歷史狀態

### 3.2 Protocol Extension 應用

```swift
// 提供預設實作
extension Command {
    var description: String {
        String(describing: type(of: self))
    }
}

// 特定功能的 extension
extension CommandHistory {
    func executeAll(_ commands: [Command]) {
        commands.forEach { execute($0) }
    }

    func undoAll() {
        while canUndo {
            undo()
        }
    }
}
```

### 3.3 泛型設計

```swift
// 泛型 Command 基類（可選）
class GenericCommand<Receiver: AnyObject>: Command {
    weak var receiver: Receiver?

    init(receiver: Receiver) {
        self.receiver = receiver
    }

    func execute() {
        fatalError("Subclasses must implement execute()")
    }

    func undo() {
        fatalError("Subclasses must implement undo()")
    }

    var description: String {
        String(describing: type(of: self))
    }
}

// 使用泛型基類
class InsertTextCommand: GenericCommand<TextDocument> {
    private let text: String
    private let position: Int

    init(document: TextDocument, text: String, position: Int) {
        self.text = text
        self.position = position
        super.init(receiver: document)
    }

    override func execute() {
        receiver?.insert(text: text, at: position)
    }

    override func undo() {
        let range = position..<(position + text.count)
        _ = receiver?.delete(range: range)
    }
}
```

## 4. 測試策略

### 4.1 單元測試（Foundation only）

**測試 Command 的 execute/undo**:
```swift
class InsertTextCommandTests: XCTestCase {
    func testExecuteInsertsText() {
        // Given
        let document = TextDocument()
        let command = InsertTextCommand(document: document, text: "Hello", position: 0)

        // When
        command.execute()

        // Then
        XCTAssertEqual(document.content, "Hello")
    }

    func testUndoRemovesInsertedText() {
        // Given
        let document = TextDocument()
        let command = InsertTextCommand(document: document, text: "Hello", position: 0)
        command.execute()

        // When
        command.undo()

        // Then
        XCTAssertEqual(document.content, "")
    }

    func testExecuteUndoExecute() {
        // Given
        let document = TextDocument()
        let command = InsertTextCommand(document: document, text: "Hello", position: 0)

        // When
        command.execute()
        command.undo()
        command.execute()  // 重新執行應該產生相同結果

        // Then
        XCTAssertEqual(document.content, "Hello")
    }
}
```

**測試 CommandHistory**:
```swift
class CommandHistoryTests: XCTestCase {
    func testExecuteAddsToUndoStack() {
        let history = CommandHistory()
        let document = TextDocument()
        let command = InsertTextCommand(document: document, text: "Test", position: 0)

        history.execute(command)

        XCTAssertTrue(history.canUndo)
        XCTAssertFalse(history.canRedo)
    }

    func testUndoMovesCommandToRedoStack() {
        let history = CommandHistory()
        let document = TextDocument()
        let command = InsertTextCommand(document: document, text: "Test", position: 0)

        history.execute(command)
        history.undo()

        XCTAssertFalse(history.canUndo)
        XCTAssertTrue(history.canRedo)
    }

    func testNewCommandClearsRedoStack() {
        let history = CommandHistory()
        let document = TextDocument()
        let command1 = InsertTextCommand(document: document, text: "First", position: 0)
        let command2 = InsertTextCommand(document: document, text: "Second", position: 5)

        history.execute(command1)
        history.undo()
        XCTAssertTrue(history.canRedo)

        history.execute(command2)
        XCTAssertFalse(history.canRedo)  // Redo 堆疊應被清空
    }
}
```

### 4.2 驗證 Receiver 狀態變化

```swift
class TextDocumentTests: XCTestCase {
    func testInsertAtPosition() {
        let document = TextDocument()
        document.insert(text: "World", at: 0)
        document.insert(text: "Hello ", at: 0)

        XCTAssertEqual(document.content, "Hello World")
    }

    func testDeleteRange() {
        let document = TextDocument()
        document.insert(text: "Hello World", at: 0)

        let deleted = document.delete(range: 0..<6)

        XCTAssertEqual(deleted, "Hello ")
        XCTAssertEqual(document.content, "World")
    }
}
```

### 4.3 整合測試策略

```swift
class IntegrationTests: XCTestCase {
    func testCompleteUndoRedoWorkflow() {
        // Given: 文件和歷史
        let document = TextDocument()
        let history = CommandHistory()

        // When: 執行多個操作
        let cmd1 = InsertTextCommand(document: document, text: "Hello", position: 0)
        let cmd2 = InsertTextCommand(document: document, text: " World", position: 5)
        let cmd3 = DeleteTextCommand(document: document, range: 0..<6)

        history.execute(cmd1)  // "Hello"
        history.execute(cmd2)  // "Hello World"
        history.execute(cmd3)  // "World"

        // Then: 驗證狀態
        XCTAssertEqual(document.content, "World")

        // When: 全部 undo
        history.undo()  // 復原刪除 -> "Hello World"
        history.undo()  // 復原第二次插入 -> "Hello"
        history.undo()  // 復原第一次插入 -> ""

        // Then: 回到初始狀態
        XCTAssertEqual(document.content, "")

        // When: 全部 redo
        history.redo()  // -> "Hello"
        history.redo()  // -> "Hello World"
        history.redo()  // -> "World"

        // Then: 回到最終狀態
        XCTAssertEqual(document.content, "World")
    }
}
```

## 研究結論

### 決策摘要

1. **Command Pattern**:
   - 使用 protocol 定義統一介面
   - Receiver 使用 class (reference type)
   - Command 持有 weak reference 避免循環參照
   - CommandHistory 使用雙堆疊管理 undo/redo

2. **Memento Pattern**:
   - 用於複雜操作或批次操作
   - Memento 使用 struct (value type) 確保不可變性
   - 可與 Command Pattern 混合使用

3. **Swift 最佳實踐**:
   - Receiver 用 class，Memento 用 struct
   - 善用 Protocol Extension 提供預設實作
   - 考慮泛型設計減少重複程式碼

4. **測試策略**:
   - 單元測試不依賴 UIKit（Foundation only）
   - 測試每個 Command 的 execute/undo
   - 測試 CommandHistory 的堆疊管理
   - 整合測試驗證完整工作流程

### 後續步驟

- [ ] 實作 data-model.md（詳細資料模型）
- [ ] 建立 contracts/ 目錄並定義 protocol
- [ ] 撰寫 quickstart.md（使用範例）
- [ ] 開始實作（Phase 2）

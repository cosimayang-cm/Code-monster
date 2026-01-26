# Undo/Redo 系統 - 研究筆記

## 設計模式研究

### Command Pattern

**GoF 定義**：
> 將請求封裝成物件，讓你可以用不同的請求、佇列或日誌來參數化客戶端，並支援可撤銷的操作。

**四個角色**：
1. **Command**（命令）：宣告執行操作的介面
2. **ConcreteCommand**（具體命令）：實作 execute()，綁定 Receiver
3. **Invoker**（調用者）：要求命令執行請求
4. **Receiver**（接收者）：知道如何執行操作

**在本專案中的對應**：
| 角色 | 對應類別 |
|------|---------|
| Command | `Command` protocol |
| ConcreteCommand | `InsertTextCommand`, `AddShapeCommand`, ... |
| Invoker | `CommandHistory` |
| Receiver | `TextDocument`, `Canvas` |

---

### Memento Pattern

**GoF 定義**：
> 在不違反封裝的前提下，捕獲物件的內部狀態，並在外部保存，以便日後還原。

**三個角色**：
1. **Originator**（發起者）：需要保存狀態的物件
2. **Memento**（備忘錄）：保存 Originator 的狀態快照
3. **Caretaker**（管理者）：負責保管 Memento

**在本專案中的對應**：
| 角色 | 對應類別 |
|------|---------|
| Originator | `TextDocument`, `Canvas` |
| Memento | `TextDocumentMemento`, `CanvasMemento` |
| Caretaker | `CommandHistory` 或獨立的 HistoryManager |

---

## Command vs Memento：何時用哪個？

| 情境 | 建議使用 | 原因 |
|------|---------|------|
| 單一、可逆的操作 | Command | 記錄操作本身，undo 就是反向操作 |
| 複雜的批次操作 | Memento | 難以逐一反向，直接還原快照更簡單 |
| 需要跳轉到任意歷史點 | Memento | 快照可以直接還原，不需重新執行所有命令 |
| 記憶體有限 | Command | 只記錄操作，不保存完整狀態 |
| 狀態很小 | Memento | 保存完整狀態也不佔太多記憶體 |

**本專案策略**：
- 基本操作使用 **Command Pattern**
- 複雜批次操作或快照需求使用 **Memento Pattern**

---

## Swift 實作考量

### Value Type vs Reference Type

**問題**：Swift 的 `struct` 是值類型，`class` 是參考類型

```swift
// ❌ 問題：保存 reference，狀態會被共享修改
class MoveShapeCommand {
    var originalPosition: Point?  // Point 如果是 struct 沒問題
    var shape: Shape?  // Shape 如果是 class 就有問題！
}

// ✅ 解法 1：使用 struct 保存快照
struct ShapeSnapshot { ... }  // 值類型

// ✅ 解法 2：深拷貝
let shapeCopy = shape.copy()
```

### Protocol Extension 活用

```swift
protocol Command {
    var description: String { get }
    func execute()
    func undo()
}

// 提供預設實作
extension Command {
    var description: String { 
        return String(describing: type(of: self)) 
    }
}
```

### Combine 整合（可選）

```swift
class CommandHistory: ObservableObject {
    @Published private(set) var canUndo: Bool = false
    @Published private(set) var canRedo: Bool = false
    
    // UI 可以直接綁定這些 Published 屬性
}
```

---

## 參考資料

1. **Design Patterns: Elements of Reusable Object-Oriented Software** - GoF
2. **Head First Design Patterns** - Chapter 6: Command Pattern
3. **Swift Design Patterns** - Paul Hudson
4. **Apple Documentation**: 
   - [NSUndoManager](https://developer.apple.com/documentation/foundation/nsundomanager)
   - [Undo Architecture](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/UndoArchitecture/)

---

## 業界實作參考

### NSUndoManager (Apple)
- 使用 `registerUndo(withTarget:selector:object:)` 註冊反向操作
- 支援 grouping（多個操作合併）
- 支援 runloop integration

### VS Code
- 使用 Command Pattern
- 每個編輯操作都是一個 Command
- 支援 multi-cursor 編輯的合併

### Photoshop
- 使用 Memento Pattern 保存圖層狀態
- History Panel 顯示所有操作
- 支援跳轉到任意歷史點

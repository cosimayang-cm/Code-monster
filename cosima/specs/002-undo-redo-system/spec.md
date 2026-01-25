# Undo/Redo 系統規格書

## 功能概述
實作支援 Undo/Redo 的編輯系統，透過 **Command Pattern** 與 **Memento Pattern** 學習：
- Command Pattern 如何封裝操作
- Memento Pattern 如何保存與還原狀態
- 關注點分離，讓 Undo/Redo 邏輯與 UI 解耦

---

## 編輯器規格

### 編輯器 1：文章編輯器 (Text Editor)

| 操作 | 說明 | Command 名稱 |
|------|------|--------------|
| 插入文字 | 在指定位置插入文字 | `InsertTextCommand` |
| 刪除文字 | 刪除指定範圍的文字 | `DeleteTextCommand` |
| 取代文字 | 將指定範圍的文字替換成新文字 | `ReplaceTextCommand` |
| 套用樣式 | 對指定範圍套用粗體/斜體/底線 | `ApplyStyleCommand` |

### 編輯器 2：畫布編輯器 (Canvas Editor)

| 操作 | 說明 | Command 名稱 |
|------|------|--------------|
| 新增圖形 | 在畫布上新增矩形/圓形/線條 | `AddShapeCommand` |
| 刪除圖形 | 移除指定圖形 | `RemoveShapeCommand` |
| 移動圖形 | 改變圖形位置 | `MoveShapeCommand` |
| 縮放圖形 | 改變圖形大小 | `ResizeShapeCommand` |
| 變更顏色 | 改變圖形填充/邊框顏色 | `ChangeColorCommand` |

---

## 核心介面設計

### Command Protocol
```swift
/// 命令協議 - 定義可執行、可撤銷的命令介面
/// Foundation Only
protocol Command {
    /// 命令描述，用於顯示在 UI 上（如「Undo 插入文字」）
    var description: String { get }
    
    /// 執行命令
    func execute()
    
    /// 撤銷命令
    func undo()
}
```

### CommandHistory
```swift
/// 命令歷史管理器 - 管理 Undo/Redo 堆疊
/// Foundation Only
class CommandHistory {
    /// 是否可以 Undo
    var canUndo: Bool { get }
    
    /// 是否可以 Redo
    var canRedo: Bool { get }
    
    /// 下一個要 Undo 的命令描述
    var undoDescription: String? { get }
    
    /// 下一個要 Redo 的命令描述
    var redoDescription: String? { get }
    
    /// 執行命令並加入歷史
    func execute(_ command: Command)
    
    /// 撤銷最近一次命令
    func undo()
    
    /// 重做最近撤銷的命令
    func redo()
}
```

---

## Memento Pattern 應用

### 使用時機
1. Command 無法輕易反向操作時（如複雜批次操作）
2. 需要保存快照供跳轉時（如跳到特定歷史版本）
3. 效能考量：當重新執行所有命令太慢時

### Memento 結構

#### TextDocumentMemento
```swift
struct TextDocumentMemento {
    let content: String
    let cursorPosition: Int
    let styles: [Range<Int>: TextStyle]
}
```

#### CanvasMemento
```swift
struct CanvasMemento {
    let shapes: [Shape]
    let selectedShapeId: UUID?
}
```

---

## 進階功能（選做）

### 1. 命令合併 (Command Coalescing)
```swift
protocol CoalescibleCommand: Command {
    /// 嘗試將另一個命令合併到自己
    /// - Returns: 是否成功合併
    func coalesce(with command: Command) -> Bool
}
```

### 2. 命令群組 (Composite Command)
```swift
class CompositeCommand: Command {
    private var commands: [Command] = []
    
    func add(_ command: Command)
    func execute()  // 依序執行所有子命令
    func undo()     // 反序撤銷所有子命令
}
```

### 3. 歷史限制
```swift
class CommandHistory {
    var maxHistoryCount: Int = 100  // 限制歷史數量
}
```

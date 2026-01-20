# Code Monster #3: Undo/Redo 系統

## 學習目標

透過設計一個支援 Undo/Redo 的編輯系統，學習 **Command Pattern** 與 **Memento Pattern**：
- 理解 Command Pattern 如何封裝操作
- 理解 Memento Pattern 如何保存與還原狀態
- 實作關注點分離，讓 Undo/Redo 邏輯與 UI 解耦

---

## 設計限制

### 架構層級限制

| 層級 | 允許的 import | 說明 |
|------|---------------|------|
| Model / Command / History | `Foundation` only | 純邏輯層，不可依賴 UI 框架 |
| ViewModel | `Foundation`, `UIKit` (可選) | 可做資料轉換 |
| ViewController | `Foundation`, `UIKit` | UI 層 |

**重要**：處理 Undo/Redo 的核心物件（如 `CommandHistory`、各種 `Command`）**只能 import Foundation**，確保邏輯層可獨立測試且不耦合 UI。

---

## 需求規格

請實作**兩種編輯器**，各自支援 Undo/Redo 功能：

### 編輯器 1：文章編輯器 (Text Editor)

支援以下操作，每個操作都可 Undo/Redo：

| 操作 | 說明 | Command 名稱建議 |
|------|------|------------------|
| 插入文字 | 在指定位置插入文字 | `InsertTextCommand` |
| 刪除文字 | 刪除指定範圍的文字 | `DeleteTextCommand` |
| 取代文字 | 將指定範圍的文字替換成新文字 | `ReplaceTextCommand` |
| 套用樣式 | 對指定範圍套用粗體/斜體/底線 | `ApplyStyleCommand` |

### 編輯器 2：畫布編輯器 (Canvas Editor)

支援以下操作，每個操作都可 Undo/Redo：

| 操作 | 說明 | Command 名稱建議 |
|------|------|------------------|
| 新增圖形 | 在畫布上新增矩形/圓形/線條 | `AddShapeCommand` |
| 刪除圖形 | 移除指定圖形 | `RemoveShapeCommand` |
| 移動圖形 | 改變圖形位置 | `MoveShapeCommand` |
| 縮放圖形 | 改變圖形大小 | `ResizeShapeCommand` |
| 變更顏色 | 改變圖形填充/邊框顏色 | `ChangeColorCommand` |

---

## 核心設計

### Command Protocol

設計一個 `Command` protocol，定義可執行、可撤銷的命令介面，需包含：

- **execute()** 方法：執行命令
- **undo()** 方法：撤銷命令
- **description** 屬性：命令描述，用於顯示在 UI 上（如「Undo 插入文字」）

### CommandHistory

設計一個 `CommandHistory` 類別來管理命令歷史，支援 Undo/Redo，需提供：

- **execute(_ command:)** 方法：執行命令並加入歷史
- **undo()** 方法：撤銷最近一次命令
- **redo()** 方法：重做最近撤銷的命令
- **canUndo** 屬性：是否可以 Undo
- **canRedo** 屬性：是否可以 Redo
- **undoDescription** 屬性：下一個要 Undo 的命令描述（用於 UI 顯示）
- **redoDescription** 屬性：下一個要 Redo 的命令描述（用於 UI 顯示）

**注意**：此類別只能 import Foundation。

---

## Memento Pattern 應用

除了使用 Command Pattern 記錄操作外，某些情境下需要使用 **Memento Pattern** 保存完整狀態。

### 使用時機

1. **Command 無法輕易反向操作時**：例如複雜的批次操作
2. **需要保存快照供跳轉時**：例如跳到特定歷史版本
3. **效能考量**：當重新執行所有命令太慢時，可保存中間狀態

### Memento 結構建議

為各編輯器設計狀態快照結構：

- **文字編輯器 Memento**：保存文字內容、游標位置、各區段樣式
- **畫布編輯器 Memento**：保存所有圖形、目前選取的圖形 ID

---

## 類別架構圖

```
┌─────────────────────────────────────────────────────────────────┐
│                        ViewController                            │
│                    (import UIKit allowed)                        │
└─────────────────────────────────┬───────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                          ViewModel                               │
│                  (import UIKit optional)                         │
└─────────────────────────────────┬───────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Foundation Only Layer                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
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
│                     │ InsertTextCommand│      │ AddShapeCommand  │
│                     │ DeleteTextCommand│      │ MoveShapeCommand │
│                     │ ReplaceTextCmd   │      │ ResizeShapeCmd   │
│                     │ ApplyStyleCommand│      │ ChangeColorCmd   │
│                     └────────┬─────────┘      └────────┬─────────┘
│                              │                         │         │
│                              ▼                         ▼         │
│                     ┌──────────────────┐      ┌──────────────────┐
│                     │   TextDocument   │      │     Canvas       │
│                     │   (Receiver)     │      │   (Receiver)     │
│                     └──────────────────┘      └──────────────────┘
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 進階需求（選做）

### 1. 命令合併 (Command Coalescing)

連續的同類型操作可合併為一個命令：
- 連續輸入的字元合併為一次「插入文字」
- 連續的小幅移動合併為一次「移動圖形」

設計一個 `CoalescibleCommand` protocol 繼承 `Command`，新增方法讓命令可嘗試將另一個命令合併到自己。

### 2. 命令群組 (Composite Command)

將多個命令組合成一個原子操作。設計一個 `CompositeCommand` 類別，可加入多個子命令，執行時依序執行所有子命令，撤銷時反序撤銷所有子命令。

### 3. 歷史限制

限制歷史記錄數量，避免記憶體無限增長。在 `CommandHistory` 中加入最大歷史數量的設定。

---

## 驗收標準

### 基本功能

- [ ] 文章編輯器支援插入、刪除、取代、套用樣式，皆可 Undo/Redo
- [ ] 畫布編輯器支援新增、刪除、移動、縮放、變更顏色，皆可 Undo/Redo
- [ ] Undo 後可以 Redo
- [ ] 執行新命令後，Redo 堆疊清空
- [ ] UI 正確顯示 Undo/Redo 按鈕的啟用狀態

### 架構要求

- [ ] `Command` protocol 定義在 Foundation only 層
- [ ] `CommandHistory` 類別只 import Foundation
- [ ] 所有具體 Command 類別只 import Foundation
- [ ] Receiver（TextDocument、Canvas）只 import Foundation
- [ ] ViewController 負責 UI 渲染與使用者互動
- [ ] 可撰寫不依賴 UIKit 的單元測試

### 進階功能（選做）

- [ ] 實作命令合併
- [ ] 實作命令群組
- [ ] 實作歷史數量限制

---

## 使用範例

```swift
// 文章編輯器範例
let document = TextDocument()
let history = CommandHistory()

// 插入文字
let insertCmd = InsertTextCommand(document: document, text: "Hello", position: 0)
history.execute(insertCmd)
// document.content == "Hello"

// 再插入文字
let insertCmd2 = InsertTextCommand(document: document, text: " World", position: 5)
history.execute(insertCmd2)
// document.content == "Hello World"

// Undo
history.undo()
// document.content == "Hello"

// Redo
history.redo()
// document.content == "Hello World"
```

```swift
// 畫布編輯器範例
let canvas = Canvas()
let history = CommandHistory()

// 新增圓形
let circle = Circle(center: Point(x: 100, y: 100), radius: 50)
let addCmd = AddShapeCommand(canvas: canvas, shape: circle)
history.execute(addCmd)

// 移動圓形
let moveCmd = MoveShapeCommand(canvas: canvas, shapeId: circle.id, delta: Point(x: 20, y: 30))
history.execute(moveCmd)

// Undo 移動
history.undo()
// circle 回到原位 (100, 100)

// Undo 新增
history.undo()
// canvas 上沒有圓形了
```

---

## 提示

1. **Command 需持有 Receiver 的參考**：Command 需要知道要操作哪個物件
2. **Undo 需保存足夠資訊**：例如 `DeleteTextCommand` 需記住被刪除的文字內容
3. **考慮 Value Type vs Reference Type**：Swift 的 struct 是值類型，注意複製語意
4. **善用 Protocol Extension**：可在 extension 提供預設實作

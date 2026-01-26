# Undo/Redo 系統 UI 層實作計畫

## 目標
為已完成的 Model 層建立 UIKit UI，展示 Undo/Redo 功能。

## 確認需求
- **編輯器範圍**：兩個都要（文字編輯器 + 畫布編輯器）
- **按鈕位置**：Navigation Bar 右上角

---

## 架構設計

### 新增 Observer Pattern
在 `CommandHistory` 加入觀察者模式，讓 UI 能響應狀態變化：

```swift
protocol CommandHistoryObserver: AnyObject {
    func commandHistoryDidChange(_ history: CommandHistory)
}
```

### 檔案結構

```
Undo-Redo/
├── Command/
│   ├── CommandHistory.swift        # 修改：加入 observer 支援
│   └── CommandHistoryObserver.swift # 新增：觀察者協議
└── UI/                              # 新增：UI 層
    ├── UndoRedoDemoViewController.swift  # Hub 選單
    ├── Components/
    │   └── UndoRedoToolbarView.swift     # 可重用工具列
    ├── Extensions/
    │   └── Color+UIKit.swift             # Color → UIColor
    ├── TextEditor/
    │   └── TextEditorViewController.swift
    └── CanvasEditor/
        ├── CanvasEditorViewController.swift
        └── Views/
            ├── CanvasView.swift
            └── ShapeView.swift
```

---

## 實作階段

### Phase 1: Model 層增強 (Observer Pattern)
- 建立 `CommandHistoryObserver` 協議
- 修改 `CommandHistory`：加入 `addObserver()`, `removeObserver()`, `notifyObservers()`
- 在 `execute()`, `undo()`, `redo()` 結尾呼叫 `notifyObservers()`

### Phase 2: 核心 UI 元件
- `Color+UIKit.swift`：Model Color → UIColor 轉換
- `UndoRedoToolbarView`：Undo/Redo 按鈕，根據 canUndo/canRedo 啟用/停用

### Phase 3: Demo Hub
- `UndoRedoDemoViewController`：展示入口
  - 標題：「Undo/Redo 系統展示」
  - 兩個按鈕：「文字編輯器」、「畫布編輯器」

### Phase 4: 文字編輯器
- `TextEditorViewController`
  - UITextView 顯示文字內容
  - Navigation bar 放 Undo/Redo 按鈕
  - 底部工具列：插入、刪除、取代、樣式按鈕
  - 實作 `CommandHistoryObserver` 更新 UI

### Phase 5: 畫布編輯器
- `ShapeView`：繪製單一圖形的 UIView
- `CanvasView`：管理多個 ShapeView 的容器
- `CanvasEditorViewController`
  - Navigation bar 放 Undo/Redo 按鈕
  - 底部工具列：新增矩形、圓形、線條、刪除、顏色
  - Pan gesture 移動圖形
  - 實作 `CommandHistoryObserver` 更新 UI

### Phase 6: 整合與測試
- 更新 SceneDelegate 設定 Demo Hub 為 root
- 完整測試兩個編輯器的 Undo/Redo 流程

---

## 關鍵檔案

| 檔案 | 操作 | 說明 |
|------|------|------|
| `Command/CommandHistory.swift` | 修改 | 加入 observer 支援 |
| `Command/CommandHistoryObserver.swift` | 新增 | 觀察者協議 |
| `UI/UndoRedoDemoViewController.swift` | 新增 | Demo Hub |
| `UI/Components/UndoRedoToolbarView.swift` | 新增 | 可重用工具列 |
| `UI/Extensions/Color+UIKit.swift` | 新增 | 顏色轉換 |
| `UI/TextEditor/TextEditorViewController.swift` | 新增 | 文字編輯器 |
| `UI/CanvasEditor/CanvasEditorViewController.swift` | 新增 | 畫布編輯器 |
| `UI/CanvasEditor/Views/CanvasView.swift` | 新增 | 畫布視圖 |
| `UI/CanvasEditor/Views/ShapeView.swift` | 新增 | 圖形視圖 |

---

## 驗證方式

1. **單元測試**：Observer 通知機制
2. **手動測試**：
   - 啟動 App → 進入 Demo Hub
   - 進入文字編輯器 → 插入文字 → Undo → Redo
   - 進入畫布編輯器 → 新增圖形 → 移動 → Undo → Redo
3. **驗證項目**：
   - Undo/Redo 按鈕正確啟用/停用
   - 操作後狀態正確還原
   - 連續多次 Undo/Redo 狀態一致

---

## 技術細節

### Observer Pattern 實作

```swift
// CommandHistoryObserver.swift
protocol CommandHistoryObserver: AnyObject {
    func commandHistoryDidChange(_ history: CommandHistory)
}

// CommandHistory.swift 新增
private var observers: [WeakObserver] = []

struct WeakObserver {
    weak var observer: CommandHistoryObserver?
}

func addObserver(_ observer: CommandHistoryObserver) {
    observers.append(WeakObserver(observer: observer))
}

func removeObserver(_ observer: CommandHistoryObserver) {
    observers.removeAll { $0.observer === observer }
}

private func notifyObservers() {
    observers.removeAll { $0.observer == nil }  // 清理已釋放的觀察者
    observers.forEach { $0.observer?.commandHistoryDidChange(self) }
}
```

### Color+UIKit 轉換

```swift
// Color+UIKit.swift
import UIKit

extension Color {
    var uiColor: UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
```

### UndoRedoToolbarView 設計

```swift
// UndoRedoToolbarView.swift
import UIKit

final class UndoRedoToolbarView: UIView {

    var onUndo: (() -> Void)?
    var onRedo: (() -> Void)?

    private let undoButton = UIButton(type: .system)
    private let redoButton = UIButton(type: .system)

    func updateState(canUndo: Bool, canRedo: Bool) {
        undoButton.isEnabled = canUndo
        redoButton.isEnabled = canRedo
    }
}
```

---

## 相依性

- **前置條件**：Model 層已完成（Command, CommandHistory, Canvas, Shape, TextDocument 等）
- **技術依賴**：UIKit, Foundation
- **無外部依賴**：純 iOS SDK 實作

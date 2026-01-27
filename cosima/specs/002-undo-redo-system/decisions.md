# Undo/Redo 系統 - 設計決策紀錄

## 決策日期：2026/01/25

---

## 1. Combine 整合
**決策**：✅ 使用 Combine

`CommandHistory` 使用 `@Published` + `ObservableObject`，讓 UI 可以直接綁定狀態。

```swift
class CommandHistory: ObservableObject {
    @Published private(set) var canUndo: Bool = false
    @Published private(set) var canRedo: Bool = false
    @Published private(set) var undoDescription: String?
    @Published private(set) var redoDescription: String?
}
```

**影響**：
- 需要 `import Combine`（但 Combine 屬於 Foundation 層級，不違反架構限制）
- UI 層可以直接使用 `$canUndo` 等綁定

---

## 2. Shape 資料類型
**決策**：✅ 使用 `class`（Reference Type）

**理由**：
- 方便直接修改屬性（如 `shape.position = newPosition`）
- 符合圖形物件的語意（圖形是有身份的實體）

**注意事項**：
- Undo 時必須保存屬性的「舊值」，而非參考
- 考慮使用 Snapshot 結構保存完整狀態

```swift
// Command 保存舊值，而非 Shape 參考
class MoveShapeCommand: Command {
    private let shape: Shape
    private let oldPosition: Point  // ⬅️ 保存值，不是參考
    private let newPosition: Point
}
```

---

## 3. 進階功能
**決策**：✅ 一起實作

將實作以下進階功能：
- **命令合併 (Command Coalescing)**：連續同類型操作合併
- **命令群組 (Composite Command)**：多命令組成原子操作
- **歷史限制**：限制 undo stack 大小，防止記憶體無限增長

---

## 4. UI 複雜度
**決策**：🔸 簡化版 UI

UI 只需展示 Undo/Redo 機制，不需完整編輯功能：
- 按鈕觸發預設操作（如「插入 Hello」、「新增圓形」）
- Undo/Redo 按鈕顯示狀態和描述
- 顯示當前文件/畫布狀態

**不實作**：
- 真正的文字輸入框編輯
- 拖曳移動圖形
- 觸控縮放

---

## 5. 測試策略
**決策**：🔸 先實作再補測試

開發順序：
1. 實作功能程式碼
2. 手動驗證基本行為
3. 補上單元測試

---

## 架構確認

```
┌─────────────────────────────────────────────────────────────────┐
│                        ViewController                            │
│                    (import UIKit)                                │
└─────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                          ViewModel                               │
│                  (import Foundation, Combine)                    │
└─────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                  Foundation + Combine Layer                      │
├─────────────────────────────────────────────────────────────────┤
│  CommandHistory (ObservableObject)                               │
│  Command Protocol                                                │
│  TextDocument, Canvas                                            │
│  All Command Classes                                             │
└─────────────────────────────────────────────────────────────────┘
```

**注意**：Combine 是 Foundation 層級框架，不違反「不依賴 UIKit」的限制。

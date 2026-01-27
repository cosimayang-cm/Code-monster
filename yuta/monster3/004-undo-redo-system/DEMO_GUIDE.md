# 🎮 Undo/Redo System Demo 使用指南

這個專案提供了完整可執行的 Demo，讓你可以實際測試 Undo/Redo 系統的所有功能。

## 📦 Demo 選項

### ✅ 選項 A: Xcode Playground（推薦 - 已建立）

**位置**: `UndoRedoDemo.playground`

**優點**:
- ✅ 立即可用 - 已建立完成
- ✅ 快速執行 - 不需要編譯整個專案
- ✅ 互動式 - 可以即時修改並看到結果
- ✅ 學習友善 - 有詳細註解和說明

**如何使用**:
```bash
# 方法 1: 直接打開
open UndoRedoDemo.playground

# 方法 2: 使用 Xcode 打開
# File > Open > 選擇 UndoRedoDemo.playground
```

**功能展示**:
- Section 1: 文字編輯器基本操作（插入、刪除、Undo/Redo）
- Section 2: 文字編輯器進階操作（刪除、取代）
- Section 3: 文字樣式設定（粗體、斜體、底線）
- Section 4: 畫布編輯器圖形操作（新增、移動圖形）
- Section 5: 畫布編輯器外觀調整（縮放、變更顏色）
- Section 6: Memento Pattern 應用（狀態快照和還原）
- Section 7: 複雜場景（混合多種操作）

### 🎨 選項 B: SwiftUI App（可選 - 視覺化介面）

**位置**: `Sources/UndoRedoDemo/`

**優點**:
- 📱 完整 UI - 可在模擬器上實際操作
- 🎨 視覺化 - 看到圖形和文字的實時變化
- 🖱️ 互動式 - 使用按鈕和手勢操作

**如何使用**:
```bash
# 使用 Swift Package Manager 執行
swift build
swift run UndoRedoDemo
```

**功能展示**:
- 文字編輯器 UI（輸入框、Undo/Redo 按鈕）
- 畫布編輯器 UI（繪圖工具、圖形操作）
- 即時狀態顯示（canUndo、canRedo、操作描述）

## 🚀 快速開始（Playground）

### 步驟 1: 打開 Playground

```bash
cd /Users/yutasm4macmini/Desktop/CMoney/CodeMonster/yuta/monster3/004-undo-redo-system/
open UndoRedoDemo.playground
```

### 步驟 2: 執行測試

在 Xcode 中：
1. 確認 Playground 已打開
2. 點擊左下角的 ▶️ **Execute Playground** 按鈕
3. 查看右側面板的輸出結果

### 步驟 3: 查看結果

你會看到類似以下的輸出：

```
=== Section 1: 文字編輯器基本操作 ===

📝 測試 1: 插入 'Hello' 在位置 0
   內容: "Hello"
   可以 Undo: true
   Undo 描述: Insert 'Hello' at position 0

📝 測試 2: 插入 ' World' 在位置 5
   內容: "Hello World"
   可以 Undo: true

⏪ 測試 3: 執行 Undo
   內容: "Hello"
   可以 Undo: true
   可以 Redo: true
   Redo 描述: Insert ' World' at position 5

✅ Section 1 完成
```

## 📚 Demo 內容詳解

### Section 1-2: 文字編輯器基本操作

**測試項目**:
- ✅ 插入文字到指定位置
- ✅ 刪除指定範圍的文字
- ✅ 取代文字
- ✅ Undo 操作
- ✅ Redo 操作
- ✅ 連續 Undo 回到初始狀態
- ✅ 新操作清空 Redo 堆疊

**對應 User Story**: User Story 1

### Section 3: 文字樣式設定

**測試項目**:
- ✅ 套用粗體樣式
- ✅ 套用斜體樣式
- ✅ 套用底線樣式
- ✅ Undo/Redo 樣式變更
- ✅ 檢視所有已套用的樣式

**對應 User Story**: User Story 2

### Section 4-5: 畫布編輯器

**測試項目**:
- ✅ 新增圓形、矩形到畫布
- ✅ 刪除圖形
- ✅ 移動圖形
- ✅ 縮放圖形
- ✅ 變更填充顏色
- ✅ 變更邊框顏色
- ✅ Undo/Redo 所有操作

**對應 User Story**: User Story 3 & 4

### Section 6: Memento Pattern

**測試項目**:
- ✅ 建立狀態快照
- ✅ 繼續編輯
- ✅ 從快照還原
- ✅ 驗證還原後的狀態

**學習重點**: Memento Pattern 應用

### Section 7: 複雜場景

**測試項目**:
- ✅ 混合多種圖形操作
- ✅ 連續執行多個命令
- ✅ 全部 Undo（清空畫布）
- ✅ 全部 Redo（恢復所有操作）

**學習重點**: 真實使用場景模擬

## 🎯 驗證的功能需求

### 文章編輯器需求
- ✅ FR-001 ~ FR-010: 所有文字和樣式操作
- ✅ 支援 Undo/Redo

### 畫布編輯器需求
- ✅ FR-011 ~ FR-020: 所有圖形操作
- ✅ 支援 Undo/Redo

### 核心 Undo/Redo 需求
- ✅ FR-021 ~ FR-030: CommandHistory 完整功能
- ✅ 堆疊管理正確

### 架構要求
- ✅ AR-001 ~ AR-009: Foundation-only 設計
- ✅ 可撰寫不依賴 UIKit 的測試

## 🧪 測試覆蓋率

| User Story | 測試場景 | 狀態 |
|-----------|---------|-----|
| User Story 1 | 文字編輯基本操作 | ✅ 29 個測試 |
| User Story 2 | 文字樣式設定 | ✅ 測試 12-16 |
| User Story 3 | 畫布圖形操作 | ✅ 測試 17-23 |
| User Story 4 | 圖形外觀調整 | ✅ 測試 24-29 |
| User Story 5 | UI 狀態顯示 | ✅ 所有 Section |

**總計**: 29 個獨立測試場景，涵蓋所有 User Stories

## 🔍 Edge Cases 驗證

Playground 驗證了以下邊界情況：

1. ✅ **無操作歷史時 Undo**
   - 測試 1 執行前檢查 canUndo
   - 結果：正確返回 false，不執行操作

2. ✅ **執行新操作後 Redo 堆疊清空**
   - Section 2 測試 11
   - 結果：新操作執行後 canRedo 變為 false

3. ✅ **全部 Undo 回到初始狀態**
   - Section 1 測試 5
   - Section 7 全部 Undo
   - 結果：內容回到空白狀態

4. ✅ **命令描述正確顯示**
   - 每個 Section 都檢查 undoDescription/redoDescription
   - 結果：描述正確反映操作內容

## 🛠️ 自訂測試

你可以修改 Playground 來測試自己的場景：

### 範例 1: 測試自訂文字操作

```swift
let doc = TextDocument()
let history = CommandHistory()

// 你的測試邏輯
history.execute(InsertTextCommand(document: doc, text: "Test", position: 0))
print(doc.getText()) // "Test"

history.undo()
print(doc.getText()) // ""
```

### 範例 2: 測試自訂圖形操作

```swift
let canvas = Canvas()
let history = CommandHistory()

// 建立並新增圖形
let shape = Circle(position: Point(x: 50, y: 50), radius: 25, fillColor: Color.blue)
history.execute(AddShapeCommand(canvas: canvas, shape: shape))

// 驗證
print(canvas.shapes.count) // 1
```

## 📊 效能測試

Playground 也可以用來測試效能：

```swift
import Foundation

let doc = TextDocument()
let history = CommandHistory()

// 測試 1000 次插入操作
let startTime = Date()
for i in 0..<1000 {
    history.execute(InsertTextCommand(document: doc, text: "a", position: i))
}
let endTime = Date()

print("執行 1000 次插入: \(endTime.timeIntervalSince(startTime)) 秒")

// 測試 1000 次 Undo
let undoStartTime = Date()
for _ in 0..<1000 {
    history.undo()
}
let undoEndTime = Date()

print("執行 1000 次 Undo: \(undoEndTime.timeIntervalSince(undoStartTime)) 秒")
```

## 🎓 學習路徑

### 階段 1: 理解基礎（建議順序）
1. ✅ 執行 Section 1 - 理解基本 Undo/Redo
2. ✅ 執行 Section 2 - 理解新操作清空 Redo
3. ✅ 閱讀 `Sources/UndoRedoSystem.swift` - 理解 Command Pattern

### 階段 2: 深入探索
4. ✅ 執行 Section 3 - 理解樣式操作
5. ✅ 執行 Section 4-5 - 理解畫布操作
6. ✅ 執行 Section 6 - 理解 Memento Pattern

### 階段 3: 實戰應用
7. ✅ 執行 Section 7 - 理解複雜場景
8. ✅ 修改測試場景 - 自訂操作序列
9. ✅ 建立 UI（可選）- 視覺化展示

## 💡 故障排除

### 問題 1: Playground 無法打開

**解決方法**:
```bash
# 確認 Xcode 已安裝
xcode-select --install

# 重新打開 Playground
open UndoRedoDemo.playground
```

### 問題 2: 編譯錯誤

**解決方法**:
1. 確認 Swift 版本（需要 5.9+）
2. 清理 Playground: Editor > Clear Console
3. 重新執行: Editor > Run Playground

### 問題 3: 輸出未顯示

**解決方法**:
1. 確認右側面板已開啟: View > Debug Area > Show Debug Area
2. 確認 Console 選項卡已選中
3. 重新執行 Playground

## 🎉 完成！

你現在有一個完整可執行的 Undo/Redo 系統 Demo！

**下一步建議**:
1. ✅ 執行所有 Section，觀察輸出結果
2. ✅ 修改測試場景，實驗不同操作
3. ✅ 閱讀源代碼，理解設計模式
4. ✅ 建立 UI（可選），視覺化展示
5. ✅ 查看單元測試（`Tests/` 目錄）

**參考文件**:
- `README.md` - Playground 使用說明
- `spec.md` - 功能規格
- `quickstart.md` - 快速開始指南
- `data-model.md` - 資料模型說明
- `plan.md` - 實作計畫

---

**感謝使用 Undo/Redo System Demo！** 🎊

如有問題或建議，歡迎回饋。

# Undo/Redo System Demo Playground

這是一個完整可執行的 Xcode Playground，展示了 Undo/Redo 系統的所有功能。

## 🚀 快速開始

1. **打開 Playground**
   ```bash
   open UndoRedoDemo.playground
   ```

2. **執行 Playground**
   - 在 Xcode 中打開 `UndoRedoDemo.playground`
   - 點擊左下角的 ▶️ 按鈕執行
   - 查看右側面板的輸出結果

3. **逐步執行**
   - 可以分別執行每個 Section
   - 每個 Section 都是獨立的測試場景

## 📚 Demo 內容

### Section 1: 文字編輯器 - 基本操作
- ✅ 插入文字
- ✅ Undo/Redo 基本操作
- ✅ 連續 Undo 回到初始狀態
- ✅ 連續 Redo 恢復所有操作

### Section 2: 文字編輯器 - 刪除和取代
- ✅ 刪除指定範圍的文字
- ✅ 取代文字
- ✅ 驗證新操作清空 Redo 堆疊

### Section 3: 文字編輯器 - 樣式設定
- ✅ 套用粗體樣式
- ✅ 套用斜體樣式
- ✅ Undo/Redo 樣式變更
- ✅ 檢視所有已套用的樣式

### Section 4: 畫布編輯器 - 圖形操作
- ✅ 新增圓形到畫布
- ✅ 移動圖形
- ✅ Undo/Redo 圖形操作
- ✅ 連續 Undo/Redo 驗證

### Section 5: 畫布編輯器 - 圖形外觀調整
- ✅ 縮放圖形
- ✅ 變更填充顏色
- ✅ 變更邊框顏色
- ✅ Undo/Redo 外觀變更

### Section 6: 進階功能 - Memento Pattern
- ✅ 建立狀態快照
- ✅ 從快照還原
- ✅ 驗證 Memento Pattern 的應用

### Section 7: 複雜場景 - 多種操作混合
- ✅ 模擬真實使用場景
- ✅ 混合多種圖形和操作
- ✅ 連續執行多個命令
- ✅ 全部 Undo 和全部 Redo

## 🎯 學習重點

### Command Pattern
- 所有操作都封裝為 Command
- 每個 Command 實作 `execute()` 和 `undo()` 方法
- CommandHistory 管理命令堆疊
- 新命令執行後自動清空 Redo 堆疊

### Memento Pattern
- TextDocument 和 Canvas 都支援建立快照
- Memento 是不可變的狀態快照
- 可以隨時從快照還原狀態
- 適用於複雜的批次操作

### 架構設計
- **Foundation-only**: Model 層完全不依賴 UIKit
- **Protocol 抽象**: 使用 Protocol 定義介面
- **Weak References**: Command 持有 weak reference 避免循環參照
- **關注點分離**: UI、邏輯、資料完全解耦

## 📝 測試覆蓋的 User Stories

### ✅ User Story 1: 文章編輯器基本操作
- 插入、刪除、取代文字
- 所有操作可 Undo/Redo

### ✅ User Story 2: 文章編輯器樣式設定
- 套用粗體、斜體、底線
- 樣式變更可 Undo/Redo

### ✅ User Story 3: 畫布編輯器圖形操作
- 新增、刪除、移動圖形
- 所有操作可 Undo/Redo

### ✅ User Story 4: 畫布編輯器圖形外觀調整
- 縮放圖形、變更顏色
- 外觀調整可 Undo/Redo

### ✅ User Story 5: UI 顯示 Undo/Redo 狀態
- canUndo/canRedo 狀態正確
- undoDescription/redoDescription 顯示操作描述

## 🔍 驗證點

### Edge Cases
- ✅ 無操作歷史時 Undo 不執行
- ✅ 執行新操作後 Redo 堆疊清空
- ✅ 全部 Undo 後回到初始狀態
- ✅ 命令描述正確顯示

### 設計模式實作
- ✅ Command Pattern 完整實作
- ✅ Memento Pattern 正確應用
- ✅ CommandHistory 正確管理命令堆疊
- ✅ Weak reference 避免記憶體洩漏

## 🛠️ 自訂測試

你可以修改 Playground 來測試自己的場景：

```swift
// 建立自己的測試場景
let myDocument = TextDocument()
let myHistory = CommandHistory()

// 執行自訂操作
myHistory.execute(InsertTextCommand(document: myDocument, text: "My Test", position: 0))

// 驗證結果
print(myDocument.getText()) // "My Test"
```

## 📊 輸出範例

執行 Playground 後，你會看到類似以下的輸出：

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

...
```

## 🎓 下一步

1. **執行所有測試** - 確認所有功能正常運作
2. **修改測試場景** - 嘗試不同的操作序列
3. **閱讀程式碼** - 理解 Command Pattern 和 Memento Pattern 的實作
4. **建立 UI** - 參考 quickstart.md 建立視覺化介面

## 💡 提示

- 每個 Section 都可以單獨執行
- 觀察每次操作後的狀態變化
- 注意 Undo/Redo 堆疊的行為
- 實驗不同的命令組合

## 🎉 完成！

這個 Playground 展示了完整的 Undo/Redo 系統實作。
所有 User Stories 都已實現並可以實際執行測試！

如果有任何問題，請參考：
- `spec.md` - 功能規格
- `quickstart.md` - 快速開始指南
- `data-model.md` - 資料模型說明

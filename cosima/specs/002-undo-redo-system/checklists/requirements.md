# Undo/Redo 系統 - 需求檢查清單

## 基本功能

### 文章編輯器
- [ ] 插入文字可 Undo/Redo
- [ ] 刪除文字可 Undo/Redo
- [ ] 取代文字可 Undo/Redo
- [ ] 套用樣式（粗體）可 Undo/Redo
- [ ] 套用樣式（斜體）可 Undo/Redo
- [ ] 套用樣式（底線）可 Undo/Redo

### 畫布編輯器
- [ ] 新增矩形可 Undo/Redo
- [ ] 新增圓形可 Undo/Redo
- [ ] 新增線條可 Undo/Redo
- [ ] 刪除圖形可 Undo/Redo
- [ ] 移動圖形可 Undo/Redo
- [ ] 縮放圖形可 Undo/Redo
- [ ] 變更填充顏色可 Undo/Redo
- [ ] 變更邊框顏色可 Undo/Redo

### 歷史管理
- [ ] Undo 後可以 Redo
- [ ] 執行新命令後，Redo 堆疊清空
- [ ] `canUndo` 屬性正確反映狀態
- [ ] `canRedo` 屬性正確反映狀態
- [ ] `undoDescription` 顯示正確的命令描述
- [ ] `redoDescription` 顯示正確的命令描述

---

## 架構要求

### Foundation Only 限制
- [ ] `Command` protocol 只 import Foundation
- [ ] `CommandHistory` 類別只 import Foundation
- [ ] `InsertTextCommand` 只 import Foundation
- [ ] `DeleteTextCommand` 只 import Foundation
- [ ] `ReplaceTextCommand` 只 import Foundation
- [ ] `ApplyStyleCommand` 只 import Foundation
- [ ] `AddShapeCommand` 只 import Foundation
- [ ] `RemoveShapeCommand` 只 import Foundation
- [ ] `MoveShapeCommand` 只 import Foundation
- [ ] `ResizeShapeCommand` 只 import Foundation
- [ ] `ChangeColorCommand` 只 import Foundation
- [ ] `TextDocument` 只 import Foundation
- [ ] `Canvas` 只 import Foundation

### 分層架構
- [ ] ViewController 只負責 UI 渲染與使用者互動
- [ ] ViewModel 負責資料轉換與業務邏輯封裝
- [ ] Model/Command/History 不依賴 UI 框架

### 測試
- [ ] 可撰寫不依賴 UIKit 的單元測試
- [ ] `CommandHistoryTests` 通過
- [ ] `TextDocumentTests` 通過
- [ ] `TextCommandTests` 通過
- [ ] `CanvasTests` 通過
- [ ] `CanvasCommandTests` 通過

---

## UI 要求

- [ ] Undo 按鈕在 `canUndo == false` 時 disabled
- [ ] Redo 按鈕在 `canRedo == false` 時 disabled
- [ ] Undo 按鈕顯示 `undoDescription`（如「Undo 插入文字」）
- [ ] Redo 按鈕顯示 `redoDescription`（如「Redo 插入文字」）
- [ ] 編輯操作後 UI 即時更新

---

## 進階功能（選做）

### 命令合併 (Command Coalescing)
- [ ] `CoalescibleCommand` protocol 定義完成
- [ ] 連續輸入的字元合併為一次「插入文字」
- [ ] 連續的小幅移動合併為一次「移動圖形」

### 命令群組 (Composite Command)
- [ ] `CompositeCommand` 類別實作完成
- [ ] 多命令可組合為原子操作
- [ ] 組合命令的 undo 反序撤銷所有子命令

### 歷史限制
- [ ] `CommandHistory` 支援 `maxHistoryCount` 設定
- [ ] 超過限制時自動移除最舊的命令

---

## 驗收測試場景

### 場景 1：文字編輯基本流程
```
1. 新建空文件
2. 插入 "Hello" → 內容為 "Hello"
3. 插入 " World" → 內容為 "Hello World"
4. Undo → 內容為 "Hello"
5. Undo → 內容為 ""
6. Redo → 內容為 "Hello"
7. Redo → 內容為 "Hello World"
```
- [ ] 通過

### 場景 2：新命令清除 Redo Stack
```
1. 新建空文件
2. 插入 "A" → 內容為 "A"
3. 插入 "B" → 內容為 "AB"
4. Undo → 內容為 "A"
5. 插入 "C" → 內容為 "AC"
6. Redo → 無效（canRedo == false）
```
- [ ] 通過

### 場景 3：畫布編輯基本流程
```
1. 新建空畫布
2. 新增圓形於 (100, 100)
3. 移動圓形 (+20, +30) → 位置為 (120, 130)
4. Undo → 位置回到 (100, 100)
5. Undo → 畫布為空
6. Redo → 圓形出現在 (100, 100)
```
- [ ] 通過

### 場景 4：樣式套用
```
1. 新建文件，內容為 "Hello World"
2. 對 "Hello" (0..<5) 套用粗體
3. 對 "World" (6..<11) 套用斜體
4. Undo → "World" 斜體移除
5. Undo → "Hello" 粗體移除
```
- [ ] 通過

---

## 簽核

| 階段 | 完成日期 | 簽核人 |
|------|---------|--------|
| Phase 1 完成 | | |
| Phase 2 完成 | | |
| Phase 3 完成 | | |
| Phase 4 完成 | | |
| Phase 5 完成 | | |
| Phase 6 完成 | | |
| 最終驗收 | | |

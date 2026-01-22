# Feature Specification: Undo/Redo 編輯系統

**Feature Branch**: `002-undo-redo-system`
**Created**: 2026-01-22
**Status**: Draft
**Input**: User description: "透過設計一個支援 Undo/Redo 的編輯系統，學習 Command Pattern 與 Memento Pattern"

## Clarifications

### Session 2026-01-22

- Q: 畫布上的圖形如何被唯一識別？ → A: 使用 UUID（每個 Shape 自動產生唯一識別碼）

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 文章編輯器基本編輯與撤銷 (Priority: P1)

使用者在文章編輯器中進行文字編輯操作（插入、刪除、取代文字），並能夠撤銷和重做這些操作。

**Why this priority**: 這是編輯系統的核心功能，沒有 Undo/Redo 的編輯器無法提供基本的使用者體驗。文字編輯是最常見的使用情境。

**Independent Test**: 可透過建立 TextDocument、執行插入/刪除操作、呼叫 undo/redo 來獨立測試，驗證文件內容是否正確還原。

**Acceptance Scenarios**:

1. **Given** 一個空的文字文件, **When** 使用者在位置 0 插入 "Hello", **Then** 文件內容變為 "Hello"
2. **Given** 文件內容為 "Hello", **When** 使用者在位置 5 插入 " World", **Then** 文件內容變為 "Hello World"
3. **Given** 文件內容為 "Hello World" 且執行過兩次插入, **When** 使用者執行 Undo, **Then** 文件內容回復為 "Hello"
4. **Given** 文件內容為 "Hello" 且剛執行過 Undo, **When** 使用者執行 Redo, **Then** 文件內容變為 "Hello World"
5. **Given** 文件內容為 "Hello World", **When** 使用者刪除位置 5-11 的文字, **Then** 文件內容變為 "Hello"
6. **Given** 文件內容為 "Hello", **When** 使用者將 "Hello" 取代為 "Hi", **Then** 文件內容變為 "Hi"

---

### User Story 2 - 畫布編輯器圖形操作與撤銷 (Priority: P1)

使用者在畫布編輯器中進行圖形操作（新增、刪除、移動、縮放、變更顏色），並能夠撤銷和重做這些操作。

**Why this priority**: 畫布編輯器與文章編輯器並列為核心功能，展示 Command Pattern 在不同領域的應用。

**Independent Test**: 可透過建立 Canvas、執行圖形操作、呼叫 undo/redo 來獨立測試，驗證畫布狀態是否正確還原。

**Acceptance Scenarios**:

1. **Given** 一個空的畫布, **When** 使用者新增一個圓心在 (100, 100)、半徑 50 的圓形, **Then** 畫布上出現該圓形
2. **Given** 畫布上有一個圓形在 (100, 100), **When** 使用者將圓形移動 (20, 30), **Then** 圓形位置變為 (120, 130)
3. **Given** 圓形位置為 (120, 130) 且執行過移動, **When** 使用者執行 Undo, **Then** 圓形回到原位 (100, 100)
4. **Given** 圓形在原位 (100, 100) 且剛執行過 Undo, **When** 再執行一次 Undo, **Then** 畫布上的圓形被移除
5. **Given** 畫布上有一個藍色矩形, **When** 使用者將填充顏色變更為紅色, **Then** 矩形變為紅色
6. **Given** 畫布上有一個 50x50 的矩形, **When** 使用者將矩形縮放為 100x100, **Then** 矩形大小變為 100x100

---

### User Story 3 - 文字樣式套用與撤銷 (Priority: P2)

使用者對文字編輯器中的指定範圍套用樣式（粗體、斜體、底線），並能夠撤銷和重做樣式變更。

**Why this priority**: 樣式功能增強編輯器的實用性，但不影響基本的文字編輯流程。

**Independent Test**: 可透過對文字範圍套用樣式、執行 undo/redo 來獨立測試，驗證樣式是否正確套用/移除。

**Acceptance Scenarios**:

1. **Given** 文件內容為 "Hello World", **When** 使用者對位置 0-5 的 "Hello" 套用粗體, **Then** "Hello" 顯示為粗體樣式
2. **Given** "Hello" 為粗體, **When** 使用者執行 Undo, **Then** "Hello" 回復為一般樣式
3. **Given** 文件內容為 "Hello World", **When** 使用者對 "World" 同時套用斜體和底線, **Then** "World" 顯示為斜體加底線

---

### User Story 4 - Undo/Redo 狀態顯示 (Priority: P2)

系統能夠正確顯示目前是否可以執行 Undo/Redo，以及下一個將被撤銷/重做的操作描述。

**Why this priority**: UI 狀態回饋是良好使用者體驗的重要組成，但不影響核心功能運作。

**Independent Test**: 可透過檢查 canUndo/canRedo 屬性和 undoDescription/redoDescription 來獨立測試。

**Acceptance Scenarios**:

1. **Given** 新建立的空歷史記錄, **When** 檢查 canUndo, **Then** 回傳 false
2. **Given** 執行過一次插入文字操作, **When** 檢查 canUndo, **Then** 回傳 true
3. **Given** 執行過一次插入文字操作, **When** 檢查 undoDescription, **Then** 回傳 "插入文字" 或類似描述
4. **Given** 執行 Undo 後, **When** 檢查 canRedo, **Then** 回傳 true
5. **Given** 執行 Undo 後再執行新命令, **When** 檢查 canRedo, **Then** 回傳 false（Redo 堆疊被清空）

---

### User Story 5 - 命令合併（進階功能）(Priority: P3)

連續的同類型操作能夠合併為一個命令，讓 Undo 時能一次撤銷整批操作。

**Why this priority**: 屬於進階功能，提升使用體驗但非必要功能。

**Independent Test**: 可透過連續輸入字元後執行一次 Undo，驗證是否一次撤銷所有連續輸入。

**Acceptance Scenarios**:

1. **Given** 使用者連續輸入 "abc" 三個字元（在短時間內）, **When** 使用者執行一次 Undo, **Then** 三個字元全部被撤銷
2. **Given** 使用者連續小幅移動圖形多次, **When** 使用者執行一次 Undo, **Then** 圖形回到連續移動前的位置

---

### User Story 6 - 命令群組（進階功能）(Priority: P3)

多個命令可以組合成一個原子操作，執行時依序執行，撤銷時反序撤銷。

**Why this priority**: 屬於進階功能，用於複雜的批次操作情境。

**Independent Test**: 可透過建立 CompositeCommand、執行、然後 Undo，驗證所有子命令是否被正確撤銷。

**Acceptance Scenarios**:

1. **Given** 一個包含「新增圖形」和「變更顏色」的命令群組, **When** 執行該群組命令, **Then** 依序新增圖形並變更其顏色
2. **Given** 命令群組已執行, **When** 執行 Undo, **Then** 先撤銷變更顏色、再撤銷新增圖形

---

### Edge Cases

- 當 undoStack 為空時執行 Undo，系統應安全處理（不執行任何操作）
- 當 redoStack 為空時執行 Redo，系統應安全處理（不執行任何操作）
- 刪除不存在的文字範圍時，系統應安全處理或拋出明確錯誤
- 移動或操作不存在的圖形時，系統應安全處理或拋出明確錯誤
- 歷史記錄達到最大限制時，最舊的命令應被移除（若實作歷史限制功能）

## Requirements *(mandatory)*

### Functional Requirements

#### 核心架構要求

- **FR-001**: 系統 MUST 定義 Command protocol，包含 execute()、undo() 方法和 description 屬性
- **FR-002**: 系統 MUST 實作 CommandHistory 類別，管理 undoStack 和 redoStack
- **FR-003**: CommandHistory MUST 提供 execute()、undo()、redo() 方法
- **FR-004**: CommandHistory MUST 提供 canUndo、canRedo 布林屬性
- **FR-005**: CommandHistory MUST 提供 undoDescription、redoDescription 字串屬性
- **FR-006**: 執行新命令時，redoStack MUST 被清空

#### 文章編輯器要求

- **FR-007**: 系統 MUST 實作 InsertTextCommand，支援在指定位置插入文字
- **FR-008**: 系統 MUST 實作 DeleteTextCommand，支援刪除指定範圍的文字
- **FR-009**: 系統 MUST 實作 ReplaceTextCommand，支援將指定範圍的文字替換成新文字
- **FR-010**: 系統 MUST 實作 ApplyStyleCommand，支援對指定範圍套用粗體/斜體/底線樣式
- **FR-011**: TextDocument MUST 作為文字編輯器的 Receiver，管理文字內容和樣式

#### 畫布編輯器要求

- **FR-012**: 系統 MUST 實作 AddShapeCommand，支援在畫布上新增矩形/圓形/線條
- **FR-013**: 系統 MUST 實作 RemoveShapeCommand，支援移除指定圖形
- **FR-014**: 系統 MUST 實作 MoveShapeCommand，支援改變圖形位置
- **FR-015**: 系統 MUST 實作 ResizeShapeCommand，支援改變圖形大小
- **FR-016**: 系統 MUST 實作 ChangeColorCommand，支援改變圖形填充/邊框顏色
- **FR-017**: Canvas MUST 作為畫布編輯器的 Receiver，管理所有圖形物件

#### 架構層級限制

- **FR-018**: Command protocol 和所有具體 Command 類別 MUST 只 import Foundation
- **FR-019**: CommandHistory 類別 MUST 只 import Foundation
- **FR-020**: TextDocument 和 Canvas（Receiver）MUST 只 import Foundation
- **FR-021**: 所有核心邏輯 MUST 可在不依賴 UIKit 的情況下進行單元測試

#### 進階功能要求（選做）

- **FR-022**: 系統 MAY 實作 CoalescibleCommand protocol，支援連續同類型操作的合併
- **FR-023**: 系統 MAY 實作 CompositeCommand 類別，支援命令群組
- **FR-024**: CommandHistory MAY 支援最大歷史數量限制

### Key Entities

- **Command**: 代表一個可執行、可撤銷的操作，包含 execute()、undo() 方法和描述
- **CommandHistory**: 管理命令歷史的協調者，維護 undoStack 和 redoStack
- **TextDocument**: 文字編輯器的接收者，儲存文字內容、游標位置和樣式資訊
- **Canvas**: 畫布編輯器的接收者，儲存所有圖形物件和選取狀態
- **Shape**: 代表畫布上的圖形（矩形、圓形、線條），以 UUID 唯一識別，包含位置、大小、顏色等屬性
- **TextStyle**: 代表文字樣式（粗體、斜體、底線）
- **Memento**: 狀態快照物件，用於保存和還原 Receiver 的完整狀態

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 所有基本編輯操作（插入、刪除、取代、樣式）都能成功執行 Undo/Redo
- **SC-002**: 所有圖形操作（新增、刪除、移動、縮放、變更顏色）都能成功執行 Undo/Redo
- **SC-003**: Undo 操作能將系統狀態精確還原到上一步的狀態
- **SC-004**: 連續執行多次 Undo 後，執行相同次數的 Redo 能還原到原始狀態
- **SC-005**: 執行新命令後，之前的 Redo 歷史被正確清除
- **SC-006**: canUndo/canRedo 狀態在任何時候都能正確反映實際可用性
- **SC-007**: 核心邏輯（Command、CommandHistory、Receiver）100% 可透過單元測試驗證
- **SC-008**: 所有單元測試不依賴 UIKit 或任何 UI 框架

## Development Approach

### TDD (測試驅動開發)

採用 TDD 開發流程：Red → Green → Refactor

### 簡單架構

只分兩層，保持好讀易懂：

| 層級 | 內容 | 規則 |
|------|------|------|
| **Model 層** | Command、CommandHistory、TextDocument、Canvas | 只 import Foundation，可獨立測試 |
| **UI 層** | ViewController | import UIKit，負責顯示 |

### 開發順序

1. **先做 Model 層**：寫測試 → 寫實作 → 測試通過
2. **最後做 UI 層**：所有單元測試通過後才做

## Assumptions

- 本規格假設使用 Swift 語言實作，遵循 Swift 5.9+ 標準
- 文字編輯器的文字內容使用 String 型別，位置以字元索引表示
- 圖形的位置和大小使用數值型別（如 Double 或 CGFloat）
- 顏色資訊以獨立於 UIKit 的方式表示（如 RGB 數值或自定義結構）
- 每個 Command 物件在建立時就需要持有足夠的資訊以支援 undo 操作
- 使用 Reference Type（class）實作 Receiver，以便 Command 能修改其狀態

# Feature Specification: Undo/Redo 系統

**Feature Branch**: `004-undo-redo-system`
**Created**: 2026-01-24
**Status**: Draft
**Input**: User description: "實作支援 Undo/Redo 的編輯系統，包含文章編輯器和畫布編輯器，學習 Command Pattern 和 Memento Pattern"

## 學習目標

透過設計一個支援 Undo/Redo 的編輯系統，學習 **Command Pattern** 與 **Memento Pattern**：
- 理解 Command Pattern 如何封裝操作
- 理解 Memento Pattern 如何保存與還原狀態
- 實作關注點分離，讓 Undo/Redo 邏輯與 UI 解耦

### 實作範圍

**核心範圍（必須完成）**：
- ✅ Model 層：Command Pattern、Memento Pattern 完整實作
- ✅ ViewModel 層：使用 Combine @Published 實現響應式架構
- ✅ Foundation-only 設計：Model 層完全不依賴 UIKit
- ✅ Protocol 抽象：解耦具體實作，提升可測試性

**驗證方式**：在 Unit Test 或 Playground 中測試所有功能

**UI 實作（可選）**：
- 🎨 SwiftUI 視覺化介面（Phase 9）
- 📱 可在模擬器上實際操作編輯器
- ⏰ 僅在核心實作完成且有餘裕時執行

**學習重點**：優先專注於設計模式本身，UI 為錦上添花

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 文章編輯器基本操作 (Priority: P1)

作為一位使用者，當我在編輯文章時，我需要能夠插入、刪除、取代文字，並且能夠對這些操作進行 Undo/Redo。

**Why this priority**: 這是文章編輯器的核心功能，必須優先實作。

**Independent Test**: 可透過執行插入、刪除、取代文字操作，然後使用 Undo/Redo 驗證每個操作都能正確復原與重做。

**Acceptance Scenarios**:

1. **Given** 空白文件, **When** 在位置 0 插入 "Hello", **Then** 文件內容為 "Hello"
2. **Given** 文件內容為 "Hello", **When** 在位置 5 插入 " World", **Then** 文件內容為 "Hello World"
3. **Given** 文件內容為 "Hello World", **When** 執行 undo, **Then** 文件內容回復為 "Hello"
4. **Given** 文件內容為 "Hello", **When** 執行 redo, **Then** 文件內容再次變為 "Hello World"
5. **Given** 文件內容為 "Hello", **When** 刪除指定範圍的文字後執行 undo, **Then** 被刪除的文字恢復
6. **Given** 文件內容為 "cat", **When** 將其取代為 "dog" 後執行 undo, **Then** 文字恢復為 "cat"

---

### User Story 2 - 文章編輯器樣式設定 (Priority: P2)

作為一位使用者，當我對文字套用格式（粗體、斜體、底線）時，我需要能夠對樣式變更進行 Undo/Redo。

**Why this priority**: 樣式是文章編輯的重要功能，但可在基本文字操作之後實作。

**Independent Test**: 可透過對文字範圍套用各種樣式，然後使用 Undo/Redo 驗證樣式變更可正確復原。

**Acceptance Scenarios**:

1. **Given** 文件內容為 "Hello World", **When** 對 "Hello" 套用粗體, **Then** "Hello" 顯示為粗體
2. **Given** "Hello" 為粗體, **When** 執行 undo, **Then** "Hello" 恢復為正常字重
3. **Given** 文件內容為 "Hello World", **When** 對 "World" 套用斜體後執行 undo, **Then** "World" 恢復正常
4. **Given** 文件內容為 "Hello", **When** 套用底線後執行 undo, **Then** 底線被移除

---

### User Story 3 - 畫布編輯器圖形操作 (Priority: P1)

作為一位使用者，當我在畫布上新增、刪除、移動圖形時，我需要能夠對這些操作進行 Undo/Redo。

**Why this priority**: 這是畫布編輯器的核心功能，必須優先實作。

**Independent Test**: 可透過建立和操作圖形，並驗證所有操作都能正確 Undo/Redo。

**Acceptance Scenarios**:

1. **Given** 空白畫布, **When** 新增圓心在 (100, 100)、半徑 50 的圓形, **Then** 圓形出現在畫布上
2. **Given** 畫布有一個圓形, **When** 執行 undo, **Then** 畫布上的圓形被移除
3. **Given** 畫布有圓形在 (100, 100), **When** 移動圓形 offset (20, 30) 至 (120, 130), **Then** 圓形位置更新
4. **Given** 圓形在 (120, 130), **When** 執行 undo, **Then** 圓形回到原位 (100, 100)
5. **Given** 圓形在 (120, 130), **When** 再執行一次 undo, **Then** 畫布上的圓形被移除
6. **Given** 空白畫布, **When** 執行兩次 redo, **Then** 圓形重新出現在 (120, 130)

---

### User Story 4 - 畫布編輯器圖形外觀調整 (Priority: P2)

作為一位使用者，當我調整圖形的大小和顏色時，我需要能夠對這些變更進行 Undo/Redo。

**Why this priority**: 視覺調整增強畫布編輯器功能，但可在基本操作之後實作。

**Independent Test**: 可透過修改圖形大小和顏色，然後驗證這些變更可 Undo/Redo。

**Acceptance Scenarios**:

1. **Given** 畫布上有矩形圖形, **When** 縮放圖形改變大小, **Then** 圖形顯示為新的大小
2. **Given** 圖形已縮放, **When** 執行 undo, **Then** 圖形恢復原始大小
3. **Given** 畫布上有圖形, **When** 變更填充顏色, **Then** 圖形顯示新顏色
4. **Given** 圖形顏色已變更, **When** 執行 undo, **Then** 圖形恢復原始顏色
5. **Given** 畫布上有圖形, **When** 變更邊框顏色後執行 undo, **Then** 邊框恢復原始顏色

---

### User Story 5 - UI 顯示 Undo/Redo 狀態 (Priority: P3)

作為一位使用者，我需要知道目前是否可以執行 Undo/Redo，以及下一個操作的描述。

**Why this priority**: UI 回饋提升使用者體驗，但不影響核心功能運作。

**Independent Test**: 可透過執行操作並檢查 UI 按鈕狀態和描述是否正確更新。

**Acceptance Scenarios**:

1. **Given** 尚未執行任何操作, **When** 查看編輯器, **Then** Undo 按鈕停用
2. **Given** 已執行一個操作, **When** 查看編輯器, **Then** Undo 按鈕啟用並顯示操作描述
3. **Given** 已執行 undo, **When** 查看編輯器, **Then** Redo 按鈕啟用並顯示操作描述
4. **Given** 執行 undo 後又執行新操作, **When** 查看編輯器, **Then** Redo 按鈕停用

---

### Edge Cases

- 當使用者嘗試在無操作歷史時執行 Undo 會發生什麼？系統應保持文件/畫布不變
- 當使用者在 Undo 後執行新操作會發生什麼？Redo 堆疊應清空
- 當使用者 Undo 所有操作會發生什麼？文件/畫布應回到初始空白狀態

## Requirements *(mandatory)*

### Functional Requirements

#### 文章編輯器需求

- **FR-001**: 系統必須支援在指定位置插入文字
- **FR-002**: 系統必須支援刪除指定範圍的文字
- **FR-003**: 系統必須支援將指定範圍的文字取代為新文字
- **FR-004**: 系統必須支援對指定範圍套用粗體樣式
- **FR-005**: 系統必須支援對指定範圍套用斜體樣式
- **FR-006**: 系統必須支援對指定範圍套用底線樣式
- **FR-007**: 所有文字操作必須可以 Undo
- **FR-008**: 所有文字操作必須可以 Redo
- **FR-009**: 所有樣式操作必須可以 Undo
- **FR-010**: 所有樣式操作必須可以 Redo

#### 畫布編輯器需求

- **FR-011**: 系統必須支援新增矩形圖形
- **FR-012**: 系統必須支援新增圓形圖形
- **FR-013**: 系統必須支援新增線條圖形
- **FR-014**: 系統必須支援刪除圖形
- **FR-015**: 系統必須支援移動圖形
- **FR-016**: 系統必須支援縮放圖形
- **FR-017**: 系統必須支援變更圖形填充顏色
- **FR-018**: 系統必須支援變更圖形邊框顏色
- **FR-019**: 所有圖形操作必須可以 Undo
- **FR-020**: 所有圖形操作必須可以 Redo

#### 核心 Undo/Redo 需求

- **FR-021**: CommandHistory 必須提供 execute(_ command:) 方法執行命令並加入歷史
- **FR-022**: CommandHistory 必須提供 undo() 方法撤銷最近一次命令
- **FR-023**: CommandHistory 必須提供 redo() 方法重做最近撤銷的命令
- **FR-024**: CommandHistory 必須提供 canUndo 屬性指示是否可以 Undo
- **FR-025**: CommandHistory 必須提供 canRedo 屬性指示是否可以 Redo
- **FR-026**: CommandHistory 必須提供 undoDescription 屬性顯示下一個要 Undo 的命令描述
- **FR-027**: CommandHistory 必須提供 redoDescription 屬性顯示下一個要 Redo 的命令描述
- **FR-028**: 執行新命令後，Redo 堆疊必須清空
- **FR-029**: Undo 操作必須以反向時序執行（最近的優先）
- **FR-030**: Redo 操作必須以正向時序執行（最近被撤銷的優先）

### 架構要求

- **AR-001**: Command protocol 必須定義在 Foundation only 層
- **AR-002**: Command protocol 必須包含 execute() 方法
- **AR-003**: Command protocol 必須包含 undo() 方法
- **AR-004**: Command protocol 必須包含 description 屬性
- **AR-005**: CommandHistory 類別只能 import Foundation
- **AR-006**: 所有具體 Command 類別只能 import Foundation
- **AR-007**: Receiver（TextDocument、Canvas）只能 import Foundation
- **AR-008**: ViewController 負責 UI 渲染與使用者互動
- **AR-009**: 核心邏輯必須可撰寫不依賴 UIKit 的單元測試

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 文章編輯器支援插入、刪除、取代、套用樣式，皆可 Undo/Redo
- **SC-002**: 畫布編輯器支援新增、刪除、移動、縮放、變更顏色，皆可 Undo/Redo
- **SC-003**: Undo 後可以 Redo
- **SC-004**: 執行新命令後，Redo 堆疊清空
- **SC-005**: UI 正確顯示 Undo/Redo 按鈕的啟用狀態
- **SC-006**: Command protocol 定義在 Foundation only 層
- **SC-007**: CommandHistory 類別只 import Foundation
- **SC-008**: 所有具體 Command 類別只 import Foundation
- **SC-009**: Receiver（TextDocument、Canvas）只 import Foundation
- **SC-010**: 可撰寫不依賴 UIKit 的單元測試

## 進階需求（選做）

### 命令合併 (Command Coalescing)

連續的同類型操作可合併為一個命令：
- 連續輸入的字元合併為一次「插入文字」
- 連續的小幅移動合併為一次「移動圖形」

設計一個 `CoalescibleCommand` protocol 繼承 `Command`，新增方法讓命令可嘗試將另一個命令合併到自己。

### 命令群組 (Composite Command)

將多個命令組合成一個原子操作。設計一個 `CompositeCommand` 類別，可加入多個子命令，執行時依序執行所有子命令，撤銷時反序撤銷所有子命令。

### 歷史限制

限制歷史記錄數量，避免記憶體無限增長。在 `CommandHistory` 中加入最大歷史數量的設定。

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

---
parent_branch: main
feature: "monster6-console-board-game"
status: In Progress
created_at: 2026-02-26T09:30:00+09:00
---

# Feature: Code Monster #6 — Console Board Game 棋盤遊戲引擎

## Overview

設計一個「VC 當搖桿、Console 當畫面」的回合制棋盤遊戲引擎，包含四款遊戲：Tic-Tac-Toe（井字棋）、Connect Four（四子棋）、Reversi（黑白棋）、2048。所有遊戲畫面透過 `print()` 輸出到 Xcode Console，UIKit ViewController 只負責接收使用者操作（按鈕點擊），不顯示任何遊戲畫面。

透過此功能學習：
- **Protocol-Oriented Programming**：四個遊戲共用框架，透過 Protocol 定義共通介面
- **State Machine**：遊戲狀態管理（等待 → 進行中 → 結束）
- **Clean Architecture**：Engine 層只用 Foundation、VC 層只用 UIKit，徹底分離

## Clarifications

### Session 2026-02-26

- Q: 遊戲結束後，VC 上應該提供什麼操作讓使用者繼續？ → A: 顯示「再玩一局」與「回選單」雙按鈕，使用者自行選擇
- Q: Reversi 遊戲結束時，如果黑白雙方棋子數量相同，如何判定結果？ → A: 判定平手（Draw），Console 顯示平手訊息

## User Scenarios & Testing

### User Story 1 — 遊戲選擇與啟動 (Priority: P0)

使用者開啟 App 後看到四款遊戲的選擇介面，點選任一遊戲即進入該遊戲的操作畫面（VC），同時 Console 印出初始棋盤狀態。

**Acceptance Scenarios**:

1. **Given** 使用者開啟 App，**When** 畫面載入完成，**Then** 顯示四款遊戲的選擇按鈕（Tic-Tac-Toe、Connect Four、Reversi、2048）
2. **Given** 使用者在選擇畫面，**When** 點選任一遊戲，**Then** 進入該遊戲的操作 VC，Console 印出初始棋盤
3. **Given** 使用者在遊戲中，**When** 遊戲結束後，**Then** VC 顯示「再玩一局」與「回選單」兩個按鈕
4. **Given** 遊戲結束且顯示雙按鈕，**When** 使用者點擊「再玩一局」，**Then** 重置棋盤並開始新局，Console 印出初始棋盤
5. **Given** 遊戲結束且顯示雙按鈕，**When** 使用者點擊「回選單」，**Then** 返回遊戲選擇畫面

---

### User Story 2 — Tic-Tac-Toe 井字棋 (Priority: P1)

使用者與 AI 進行井字棋對弈。VC 顯示 3x3 按鈕格，使用者點擊空格下子（❌），AI 自動回應（⭕）。每次操作後 Console 印出最新棋盤。AI 使用 Minimax 演算法，永不輸。

**Acceptance Scenarios**:

1. **Given** 進入 Tic-Tac-Toe，**When** 畫面載入，**Then** Console 印出空白 3x3 棋盤，顯示「Player ❌'s turn」
2. **Given** 輪到使用者，**When** 點擊空格按鈕，**Then** 該格落子 ❌，Console 印出更新棋盤，AI 自動回應 ⭕
3. **Given** 輪到使用者，**When** 點擊已有子的格子，**Then** 無反應，不產生任何效果
4. **Given** 任一方達成橫、直、斜三連線，**When** 判定勝負，**Then** Console 顯示勝利訊息並標示獲勝連線
5. **Given** 棋盤已滿且無三連線，**When** 判定勝負，**Then** Console 顯示平手訊息
6. **Given** AI 使用 Minimax 演算法，**When** 進行多局對弈，**Then** AI 先手或後手都不會輸

---

### User Story 3 — Connect Four 四子棋 (Priority: P1)

使用者與 AI 進行四子棋對弈。VC 顯示 7 個欄位按鈕，使用者點擊選擇投入欄位，棋子因重力掉落到該欄最底空位。AI 使用 Alpha-Beta Pruning 演算法。

**Acceptance Scenarios**:

1. **Given** 進入 Connect Four，**When** 畫面載入，**Then** Console 印出空白 7x6 棋盤（Row 1 在底部），顯示當前玩家
2. **Given** 輪到使用者，**When** 點擊某欄按鈕，**Then** 棋子掉落到該欄最底空位，Console 印出更新棋盤
3. **Given** 某欄已滿，**When** 使用者點擊該欄按鈕，**Then** 無反應，不產生任何效果
4. **Given** 任一方達成橫、直、斜四連線，**When** 判定勝負，**Then** Console 顯示勝利訊息
5. **Given** 棋盤已滿且無四連線，**When** 判定勝負，**Then** Console 顯示平手訊息
6. **Given** AI 面對即將四連線的局面，**When** AI 運算，**Then** AI 能擋住明顯的勝著

---

### User Story 4 — Reversi 黑白棋 (Priority: P2)

使用者與 AI 進行黑白棋對弈。VC 使用 8x8 的 UICollectionView，使用者點擊格子下子。棋子必須能翻轉至少 1 顆對手的子才能下。Console 用 `*` 標記可下位置並顯示翻轉數量。

**Acceptance Scenarios**:

1. **Given** 進入 Reversi，**When** 畫面載入，**Then** Console 印出 8x8 棋盤，中心 4 格交叉放置黑白各 2 子，標記可下位置
2. **Given** 輪到使用者，**When** 點擊標記 `*` 的可下位置，**Then** 該格落子並翻轉對手棋子（8 個方向檢查），Console 印出更新棋盤
3. **Given** 輪到使用者，**When** 點擊非合法位置，**Then** 無反應
4. **Given** 當前玩家無合法落子位置，**When** 判定回合，**Then** 自動跳過該回合，輪到對方
5. **Given** 雙方都無合法落子位置，**When** 判定遊戲狀態，**Then** 遊戲結束，棋子多的一方獲勝；棋子數相同則判定平手
6. **Given** Console 顯示棋盤，**When** 更新畫面，**Then** 顯示雙方棋子數量、可下位置標記 `*`、每個可下位置的翻轉數量
7. **Given** AI 有角落可下，**When** AI 運算，**Then** 優先選擇角落位置

---

### User Story 5 — 2048 (Priority: P2)

使用者進行單人 2048 遊戲。VC 顯示四個方向按鈕（上下左右），使用者點擊方向按鈕觸發滑動合併。每次有效滑動後隨機在空格生成新方塊。

**Acceptance Scenarios**:

1. **Given** 進入 2048，**When** 畫面載入，**Then** Console 印出 4x4 棋盤，隨機兩格有數字（2 或 4），顯示分數 0
2. **Given** 使用者點擊方向按鈕，**When** 該方向有方塊可移動或合併，**Then** 所有方塊往該方向滑動合併，隨機空格生成 2（90%）或 4（10%），Console 印出更新棋盤與分數
3. **Given** 使用者點擊方向按鈕，**When** 該方向無方塊可移動或合併，**Then** 無反應，不生成新方塊
4. **Given** 滑動合併時 `[2,2,2,2]`，**When** 合併邏輯執行，**Then** 結果為 `[4,4,0,0]`（每格每次只合併一次）
5. **Given** 任一格合成 2048，**When** 判定勝負，**Then** Console 顯示勝利訊息，使用者可選擇繼續玩
6. **Given** 棋盤滿且四個方向都無法合併，**When** 判定勝負，**Then** Console 顯示失敗訊息
7. **Given** 合併產生新數字，**When** 計算分數，**Then** 分數為所有合併產生的數字累加

---

### User Story 6 — Shared Game Framework 共用框架 (Priority: P0)

四個遊戲共用一套框架，定義棋盤、操作、判勝負、渲染等共通介面。新增第五款遊戲時，只需實作具體邏輯（conform protocols），不需重寫整個流程。

**Acceptance Scenarios**:

1. **Given** 共用框架已定義，**When** 實作新遊戲，**Then** 只需 conform 對應 Protocol，不需修改框架本身
2. **Given** Engine 層程式碼，**When** 檢查 import，**Then** 只允許 `Foundation`，不可 import `UIKit`
3. **Given** VC 層程式碼，**When** 檢查職責，**Then** VC 只負責接收使用者操作，不包含遊戲邏輯
4. **Given** Board / Move 型別，**When** 檢查型別定義，**Then** 使用 `struct`（值語義），方便 AI 遞迴時複製棋盤
5. **Given** 遊戲狀態機，**When** 任何時刻檢查狀態，**Then** 遊戲處於明確狀態（idle / playing / gameOver），不存在非法狀態轉換

## Functional Requirements

### FR-1: Shared Game Protocol Framework

- 定義共通 Protocol 介面涵蓋：棋盤狀態、合法操作查詢、操作執行、勝負判定、棋盤渲染
- Board 使用 struct（值語義），Move 使用 struct 並 conform `Hashable`
- 遊戲狀態機使用 enum 定義狀態（idle / playing / gameOver），非法轉換必須拋錯
- 渲染邏輯與遊戲邏輯完全分離

### FR-2: Tic-Tac-Toe Engine

- 3x3 棋盤，兩位玩家輪流下子（❌ vs ⭕）
- 只能在空格下子
- 勝負判定：橫（3 種）、直（3 種）、斜（2 種）三連線，或棋盤滿為平手
- AI 使用 Minimax 演算法（搜尋空間小，不需 pruning），先手後手都不會輸
- Console 渲染格式依照規格範例

### FR-3: Connect Four Engine

- 7 欄 x 6 列棋盤，兩位玩家輪流選擇欄位投入
- 重力掉落：棋子落到該欄最底部空位
- 欄滿時不可再投入
- 勝負判定：橫、直、斜四連線，或棋盤滿為平手
- AI 使用 Alpha-Beta Pruning，搜尋深度 6-8 層，評估函數考慮連線數量、中路優勢、潛在威脅
- Console 渲染格式依照規格範例（Row 1 在底部）

### FR-4: Reversi Engine

- 8x8 棋盤，初始中心 4 格交叉放置黑白各 2 子
- 下子時必須至少翻轉 1 顆對手的子（8 個方向皆檢查）
- 無合法落子位置時跳過該回合
- 雙方都無合法落子時遊戲結束，棋子多者獲勝；棋子數相同則判定平手（Draw）
- Console 顯示：用 `*` 標記可下位置，顯示每個可下位置的翻轉數量，顯示雙方棋子數
- AI 使用位置權重矩陣（角落最高分、角落旁最低分）+ Alpha-Beta Pruning（深度 4-6 層），優先搶角

### FR-5: 2048 Engine

- 4x4 棋盤，單人遊戲
- 四個方向滑動合併：移除空格壓縮 → 相鄰相同合併（每格每次只合併一次）→ 再壓縮補空格
- 無效滑動（方向無變化）不生成新方塊
- 每次有效滑動後隨機空格生成 2（90% 機率）或 4（10% 機率）
- 勝利：合成 2048（可選擇繼續玩）；失敗：棋盤滿且四方向都無法合併
- 分數：所有合併產生的數字累加
- Console 渲染：數字靠右對齊，格子寬度一致

### FR-6: VC 操作介面

- 遊戲選擇畫面：四款遊戲的選擇按鈕
- Tic-Tac-Toe VC：3x3 UIButton grid
- Connect Four VC：7 個 UIButton（每欄一個）
- Reversi VC：8x8 UICollectionView
- 2048 VC：4 個方向按鈕（⬆ ⬇ ⬅ ➡）
- 所有 VC 只負責接收使用者操作並轉發給 Engine，不顯示遊戲畫面
- 遊戲結束時，所有遊戲 VC 顯示「再玩一局」與「回選單」兩個按鈕

### FR-7: Clean Architecture 分層

- Engine 層（Board、Move、StateMachine、AI、Renderer）：只允許 import `Foundation`
- VC 層（ViewController）：允許 import `Foundation` 與 `UIKit`
- Engine 層可透過 delegate/protocol 通知 VC 層狀態變化
- Engine 層 100% 可用 XCTest 進行單元測試，不需要實例化任何 UIKit 元件

## Success Criteria

1. 四款遊戲均可透過 VC 操作、Console 顯示完整進行一局遊戲（開始 → 操作 → 結束）
2. Tic-Tac-Toe AI 模擬 50 局以上，先手後手都不會輸
3. Connect Four AI 面對即將四連線的局面，能正確防守
4. Reversi AI 有角落可下時優先選擇角落
5. 2048 滑動合併邏輯通過所有邊界測試（包含 `[2,2,2,2]` → `[4,4,0,0]`）
6. 新增第五款遊戲時，只需 conform Protocol 即可整合，不需修改框架核心程式碼
7. Engine 層所有程式碼只 import `Foundation`，無 UIKit 依賴
8. Engine 層單元測試覆蓋率達 90% 以上（Board、Move、AI、WinDetection、Renderer）

## Key Entities

| Entity | 類型 | 說明 |
|--------|------|------|
| GameBoard | Protocol | 棋盤共通介面：狀態查詢、合法操作、操作執行 |
| GameMove | Protocol | 操作共通介面：位置、值 |
| GameState | Enum | 遊戲狀態：idle / playing / gameOver |
| GameRenderer | Protocol | 渲染共通介面：將棋盤轉為 Console 字串 |
| GameAI | Protocol | AI 共通介面：根據棋盤狀態計算最佳操作 |
| TicTacToeBoard | Struct | 3x3 棋盤狀態 |
| ConnectFourBoard | Struct | 7x6 棋盤狀態（含重力邏輯） |
| ReversiBoard | Struct | 8x8 棋盤狀態（含翻轉邏輯） |
| Game2048Board | Struct | 4x4 棋盤狀態（含滑動合併邏輯） |

## Assumptions

1. 使用者操作一律透過 VC 上的按鈕，不支援鍵盤或手勢輸入
2. AI 運算在主執行緒同步完成（棋盤搜尋空間不大，不需背景執行緒）
3. 遊戲不需要儲存/讀取進度，每次重新開始
4. Console 輸出使用 `print()` 即可，不需要自定義 Logger
5. 不需要網路連線或多人線上對戰功能
6. 2048 初始生成兩個方塊，數值為 2
7. Tic-Tac-Toe 使用者為先手（❌），AI 為後手（⭕）
8. Connect Four 使用者為先手（🔴），AI 為後手（🟡）
9. Reversi 使用者為黑方（⚫），AI 為白方（⚪）

# Tasks: Console Board Game 棋盤遊戲引擎

**Branch**: `006-console-board-games` | **Date**: 2026-03-01

> 每個 Task 完成後需確認 Xcode Build 通過。

---

## Phase 0: Shared Framework

### T0-1: 建立 GameState State Machine
**檔案**: `BoardGames/Shared/Models/GameState.swift`
**描述**: 定義遊戲所有合法狀態
```swift
enum GameState: Equatable {
    case waiting
    case playing
    case won(Player)
    case draw
    case wonCanContinue   // 2048 達成目標可繼續
}
```
**驗收**: 可 compile，無 UIKit 依賴

---

### T0-2: 建立 Player Model
**檔案**: `BoardGames/Shared/Models/Player.swift`
**描述**: 玩家 enum，區分雙人對弈與 2048 單人
```swift
enum Player: Equatable {
    case human     // 使用者
    case ai        // AI 對手
    case none      // 空位（棋盤 cell 使用）
}
// 也可按需求設計為 first/second 或 black/white 等，由學員決定
```
**驗收**: 可 compile，無 UIKit 依賴

---

### T0-3: 建立 BoardGame 協議
**檔案**: `BoardGames/Shared/Protocols/BoardGame.swift`
**描述**: 四個遊戲共用的主協議
- `var state: GameState { get }`
- `var currentPlayer: Player { get }`
- `mutating func apply(move: Move) throws`
- `func validMoves() -> [Move]`
- `mutating func restart()`
**驗收**: 可 compile，associatedtype 設計合理

---

### T0-4: 建立 BoardRenderer 協議
**檔案**: `BoardGames/Shared/Protocols/BoardRenderer.swift`
**描述**: Console 渲染協議
- `func render() -> String` — 返回完整棋盤字串，由 VC 負責 print
**驗收**: 可 compile，無 UIKit 依賴

---

### T0-5: 建立 GameAI 協議
**檔案**: `BoardGames/Shared/Protocols/GameAI.swift`
**描述**: AI 協議，回傳最佳走步
- `func bestMove() -> Move?`
**驗收**: 可 compile，無 UIKit 依賴

---

## Phase 1: Menu & Navigation

### T1-1: 建立 MenuViewController
**檔案**: `BoardGames/Menu/MenuViewController.swift`
**描述**:
- UITableView 顯示四款遊戲清單（Tic-Tac-Toe / Connect Four / Reversi / 2048）
- 點擊後 push 對應 ViewController（用 placeholder VC 先接）
**驗收**: App 啟動後顯示清單，點擊可跳轉（即使跳轉的是空 VC）

---

### T1-2: 接入 App 導航
**描述**: 修改現有 SceneDelegate 或 ViewController，讓 BoardGames Menu 可從主畫面進入
**驗收**: 可從 App 主頁面導航至 BoardGames Menu

---

## Phase 2: Tic-Tac-Toe

### T2-1: TicTacToeBoard — 3×3 棋盤結構
**檔案**: `BoardGames/TicTacToe/Engine/TicTacToeBoard.swift`
**描述**:
- `struct TicTacToeBoard` — 9 個 cell 的 value type
- `subscript(row:col:)` 存取
- `isFull: Bool`
**驗收**: Unit test：初始棋盤空白、設值後可讀取、`isFull` 正確

---

### T2-2: TicTacToeMove — 走步結構
**檔案**: `BoardGames/TicTacToe/Engine/TicTacToeMove.swift`
**描述**:
- `struct TicTacToeMove: Equatable` — `row: Int, col: Int`
- `var description: String`（例：「A1」）
**驗收**: 可 compile

---

### T2-3: TicTacToeGame — 遊戲邏輯
**檔案**: `BoardGames/TicTacToe/Engine/TicTacToeGame.swift`
**描述**:
- conform to `BoardGame`
- `apply(move:)` — 驗證空格、下子、換手、判勝負
- `checkWinner() -> Player?` — 橫 3 種、直 3 種、斜 2 種
- `validMoves()` — 所有空格
- `restart()` — 重置
**驗收**:
- [ ] 橫直斜三連線正確判定
- [ ] 棋盤滿無三連線為平手
- [ ] 已有棋子的格子不可再下（throw error）

---

### T2-4: TicTacToeAI — Minimax
**檔案**: `BoardGames/TicTacToe/AI/TicTacToeAI.swift`
**描述**:
- Minimax 演算法，完美對弈
- 利用 BoardGame 值語義複製棋盤進行搜尋
**驗收**:
- [ ] 模擬 100 局（AI 先手 + AI 後手），AI 永不輸
- [ ] AI 擔任後手時看到對手即將獲勝可封堵

---

### T2-5: TicTacToeRenderer — Console 渲染
**檔案**: `BoardGames/TicTacToe/Renderer/TicTacToeRenderer.swift`
**描述**:
- `render() -> String` 輸出 spec 中的 console 格式（含標題、行列標籤、emoji 棋子）
**驗收**: Unit test：snapshot 比對空棋盤輸出字串、有棋子棋盤輸出字串

---

### T2-6: TicTacToeViewController — UIKit 輸入
**檔案**: `BoardGames/TicTacToe/UI/TicTacToeViewController.swift`
**描述**:
- 3×3 UIButton grid（programmatic layout）
- 點擊 → `game.apply(move:)` → `print(renderer.render())`
- AI 回合自動觸發
- 遊戲結束時顯示「New Game」按鈕
- 已佔位格子 button disabled
**驗收**:
- [ ] VC 不顯示任何棋盤資訊（只有按鈕）
- [ ] 每次操作後 Console 印出最新棋盤
- [ ] 遊戲結束後可重開

---

## Phase 3: Connect Four

### T3-1: ConnectFourBoard — 7×6 重力棋盤
**檔案**: `BoardGames/ConnectFour/Engine/ConnectFourBoard.swift`
**描述**:
- 7 欄 × 6 列 struct
- `dropColumn(_ col: Int, player: Player) -> Int?` — 返回落下的 row，欄滿返回 nil
- Row 1 = 底部（重力方向）
**驗收**: Unit test：棋子落到正確最底空位、欄滿返回 nil

---

### T3-2: ConnectFourMove — 欄位走步
**檔案**: `BoardGames/ConnectFour/Engine/ConnectFourMove.swift`
**描述**: `struct ConnectFourMove: Equatable { column: Int }` (1-7)
**驗收**: 可 compile

---

### T3-3: ConnectFourGame — 遊戲邏輯
**檔案**: `BoardGames/ConnectFour/Engine/ConnectFourGame.swift`
**描述**:
- `checkWinner()` — 橫、直、斜（兩方向）四連線
- `validMoves()` — 未滿的欄
**驗收**:
- [ ] 橫直斜四連線正確判定
- [ ] 棋盤滿無四連線為平手

---

### T3-4: ConnectFourAI — Alpha-Beta Pruning
**檔案**: `BoardGames/ConnectFour/AI/ConnectFourAI.swift`
**描述**:
- Alpha-Beta Pruning，搜尋深度 6-8 層
- 評估函數：連線數量、中路優勢、潛在威脅
**驗收**: AI 能擋明顯勝著（設定即將四連線的局面驗證）

---

### T3-5: ConnectFourRenderer
**檔案**: `BoardGames/ConnectFour/Renderer/ConnectFourRenderer.swift`
**描述**: 輸出 spec console 格式（Row 1 在底部）
**驗收**: Unit test snapshot

---

### T3-6: ConnectFourViewController
**檔案**: `BoardGames/ConnectFour/UI/ConnectFourViewController.swift`
**描述**: 7 個欄位 UIButton，欄滿時 disabled，遊戲結束顯示「New Game」
**驗收**: 符合 spec VC 限制

---

## Phase 4: Reversi

### T4-1: ReversiBoard — 8×8 翻轉棋盤
**檔案**: `BoardGames/Reversi/Engine/ReversiBoard.swift`
**描述**:
- 初始中心 4 子正確放置
- 8 方向查找函數 `canFlip(from:direction:player:) -> [Position]`
**驗收**: Unit test：初始盤面正確、各方向翻轉計算正確

---

### T4-2: ReversiMove
**檔案**: `BoardGames/Reversi/Engine/ReversiMove.swift`
**描述**: `struct ReversiMove: Equatable { row: Int, col: Int }`
**驗收**: 可 compile

---

### T4-3: ReversiGame — 翻轉邏輯
**檔案**: `BoardGames/Reversi/Engine/ReversiGame.swift`
**描述**:
- `validMoves()` — 至少能翻轉 1 顆才合法
- `flipPieces(at:)` — 執行翻轉
- `isPassRequired() -> Bool` — 當前玩家無子可下
- `isGameOver() -> Bool` — 雙方都無子可下
**驗收**:
- [ ] 8 方向翻轉邏輯正確
- [ ] `validMoves()` 初始盤面返回 4 個位置
- [ ] 跳過回合邏輯正確
- [ ] 遊戲結束判定正確

---

### T4-4: ReversiAI — 權重矩陣 + Alpha-Beta
**檔案**: `BoardGames/Reversi/AI/ReversiAI.swift`
**描述**:
- 8×8 位置權重矩陣（角落最高、角落相鄰最低）
- Alpha-Beta Pruning（深度 4-6）
- 角落策略：有角可下時必選角
**驗收**: 有角落可下時 AI 優先選角落（Unit test 驗證）

---

### T4-5: ReversiRenderer — 含 `*` 標記
**檔案**: `BoardGames/Reversi/Renderer/ReversiRenderer.swift`
**描述**: `*` 標記當前可下位置，顯示翻轉數量，顯示黑白子數
**驗收**: Unit test snapshot

---

### T4-6: ReversiViewController — UICollectionView + Pass 按鈕
**檔案**: `BoardGames/Reversi/UI/ReversiViewController.swift`
**描述**:
- UICollectionView 8×8，tap cell 送出 move
- Pass 按鈕：有子可下時 hidden，無子可下時顯示
- 遊戲結束顯示「New Game」
**驗收**:
- [ ] Pass 按鈕動態顯示/隱藏邏輯正確
- [ ] VC 不顯示棋盤資訊

---

## Phase 5: 2048

### T5-1: TwentyFortyEightBoard — 4×4 滑動棋盤
**檔案**: `BoardGames/TwentyFortyEight/Engine/TwentyFortyEightBoard.swift`
**描述**:
- `randomSpawn()` — 隨機空格生成 2（90%）或 4（10%）
- `isEmpty: Bool`
**驗收**: Unit test：spawn 後空格數減 1

---

### T5-2: TwentyFortyEightMove — 方向走步
**檔案**: `BoardGames/TwentyFortyEight/Engine/TwentyFortyEightMove.swift`
**描述**: `enum Direction: case up, down, left, right`
**驗收**: 可 compile

---

### T5-3: TwentyFortyEightGame — 滑動合併核心
**檔案**: `BoardGames/TwentyFortyEight/Engine/TwentyFortyEightGame.swift`
**描述**:
- `slideRow(_ row: [Int]) -> (result: [Int], score: Int)` — 核心合併演算法
- `apply(move: Direction)` — 4 方向轉換矩陣方向後套用 slideRow
- 無效滑動（棋盤無變化）不 spawn 不計分
- `isGameOver()` — 棋盤滿且 4 方向都無法合併
- State：`.wonCanContinue`（達成 2048）、`.won` 失敗後不繼續
**驗收**:
- [ ] `[2,2,2,2]` → `[4,4,0,0]`
- [ ] `[2,0,2,0]` → `[4,0,0,0]`
- [ ] `[4,4,4,4]` → `[8,8,0,0]`（不會變成 16）
- [ ] 無效滑動不 spawn

---

### T5-4: TwentyFortyEightRenderer
**檔案**: `BoardGames/TwentyFortyEight/Renderer/TwentyFortyEightRenderer.swift`
**描述**: 數字靠右對齊（6 字元寬），顯示分數
**驗收**: Unit test snapshot（空棋盤、有數字棋盤）

---

### T5-5: TwentyFortyEightViewController
**檔案**: `BoardGames/TwentyFortyEight/UI/TwentyFortyEightViewController.swift`
**描述**:
- 4 個方向 UIButton（⬆ ⬇ ⬅ ➡）
- 達成 2048：顯示「You Win! Continue?」按鈕
- 遊戲結束：顯示「New Game」按鈕
**驗收**: 符合 spec VC 限制

---

## Phase 6: 測試補強

### T6-1: Win Detection 全覆蓋測試
**描述**: 針對 spec「Win Detection 測試」章節，補齊所有情境
- Tic-Tac-Toe：橫 3 + 直 3 + 斜 2 + 平手 = 9 test cases
- Connect Four：橫、直、斜（左上→右下、右上→左下）、平手
- Reversi：雙方不能下時結束、計算子數多寡
- 2048：合成 2048 勝利、棋盤滿無法合併失敗

---

### T6-2: AI 行為測試
**描述**:
- Tic-Tac-Toe：模擬多局，AI 先手 + AI 後手永不輸
- Connect Four：設定即將四連線局面，AI 必封堵
- Reversi：設定有角落可下局面，AI 必選角落

---

### T6-3: Reversi 特有測試
**描述**:
- 翻轉計數：每個方向分別驗證
- 跳過回合：一方無子可下時自動跳過
- 遊戲結束：雙方都不能下

---

### T6-4: 2048 邊界測試
**描述**:
- `slideRow` 各種邊界：全 0、全相同、交錯值
- 特別驗證：每格每次只合併一次
- 無效滑動偵測：4 方向都無效時遊戲結束

---

### T6-5: 整合測試（完整遊戲流程）
**描述**:
- 每款遊戲：模擬「開始 → 多次操作 → 結束 → 重開」完整流程
- 驗證 GameState 轉換正確（`waiting → playing → won/draw/wonCanContinue`）

---

## Task 追蹤表

| Task | Phase | Status | 難度 |
|------|-------|--------|------|
| T0-1 GameState | 0 | ⬜ | Easy |
| T0-2 Player | 0 | ⬜ | Easy |
| T0-3 BoardGame protocol | 0 | ⬜ | Medium |
| T0-4 BoardRenderer protocol | 0 | ⬜ | Easy |
| T0-5 GameAI protocol | 0 | ⬜ | Easy |
| T1-1 MenuViewController | 1 | ⬜ | Easy |
| T1-2 App Navigation | 1 | ⬜ | Easy |
| T2-1 TicTacToeBoard | 2 | ⬜ | Easy |
| T2-2 TicTacToeMove | 2 | ⬜ | Easy |
| T2-3 TicTacToeGame | 2 | ⬜ | Medium |
| T2-4 TicTacToeAI (Minimax) | 2 | ⬜ | Hard |
| T2-5 TicTacToeRenderer | 2 | ⬜ | Medium |
| T2-6 TicTacToeViewController | 2 | ⬜ | Medium |
| T3-1 ConnectFourBoard | 3 | ⬜ | Medium |
| T3-2 ConnectFourMove | 3 | ⬜ | Easy |
| T3-3 ConnectFourGame | 3 | ⬜ | Medium |
| T3-4 ConnectFourAI (Alpha-Beta) | 3 | ⬜ | Hard |
| T3-5 ConnectFourRenderer | 3 | ⬜ | Easy |
| T3-6 ConnectFourViewController | 3 | ⬜ | Easy |
| T4-1 ReversiBoard | 4 | ⬜ | Hard |
| T4-2 ReversiMove | 4 | ⬜ | Easy |
| T4-3 ReversiGame | 4 | ⬜ | Hard |
| T4-4 ReversiAI | 4 | ⬜ | Hard |
| T4-5 ReversiRenderer | 4 | ⬜ | Medium |
| T4-6 ReversiViewController | 4 | ⬜ | Medium |
| T5-1 2048 Board | 5 | ⬜ | Easy |
| T5-2 2048 Move | 5 | ⬜ | Easy |
| T5-3 2048 Game (slideRow) | 5 | ⬜ | Hard |
| T5-4 2048 Renderer | 5 | ⬜ | Easy |
| T5-5 2048 ViewController | 5 | ⬜ | Easy |
| T6-1 Win Detection Tests | 6 | ⬜ | Medium |
| T6-2 AI Behavior Tests | 6 | ⬜ | Medium |
| T6-3 Reversi Special Tests | 6 | ⬜ | Medium |
| T6-4 2048 Edge Tests | 6 | ⬜ | Easy |
| T6-5 Integration Tests | 6 | ⬜ | Medium |

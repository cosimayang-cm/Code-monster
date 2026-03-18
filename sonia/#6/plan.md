# Implementation Plan: Console Board Game 棋盤遊戲引擎

**Branch**: `006-console-board-games` | **Date**: 2026-03-01 | **Spec**: [monster6.md](./monster6.md)
**Input**: Feature specification from `sonia/#6/monster6.md`

---

## Summary

建立四款回合制棋盤遊戲（Tic-Tac-Toe、Connect Four、Reversi、2048），使用：
- **Protocol-Oriented Programming** 抽象共用框架
- **Console Output** 透過 `print()` 顯示棋盤狀態
- **VC = Input Only**：UIKit ViewController 只負責按鈕輸入

**Spec 明確決策**：
| 項目 | 決策 |
|------|------|
| 導航 | MenuViewController 清單選擇四款遊戲 |
| Reversi Pass | 無子可下時顯示 Pass 按鈕，有子可下時隱藏 |
| 對戰模式 | Human vs AI Only（不支援 Human vs Human） |
| 專案位置 | 加入現有 `sonia/CodeMonster` 專案，新增 `BoardGames/` group |
| 遊戲重開 | 每款遊戲結束後顯示「New Game」按鈕 |
| Console 渲染 | Append 模式（每次操作 print 一次新棋盤） |
| 2048 繼續 | 達成 2048 → `.wonCanContinue` 狀態，直到棋盤滿無法移動 |

---

## Technical Context

**Language/Version**: Swift 5.9+
**Primary Dependencies**: UIKit（VC 層）、Foundation（Engine 層）
**Architecture**: Protocol-Oriented Programming + State Machine
**Storage**: None（記憶體內操作）
**Testing**: XCTest
**Target Platform**: iOS 16+
**Performance Goals**: 即時響應（AI 計算 < 200ms）
**Constraints**: Engine 層禁止 import UIKit；VC 層禁止 import 任何 game engine 具體型別（僅透過 protocol 溝通）
**Scale/Scope**: 4 款遊戲、1 個 Menu、1 個 Shared Framework

---

## Architecture Decision

### Protocol-Oriented Shared Framework

四個遊戲共用以下 Protocol（具體名稱為學員自行設計，此處為建議）：

```swift
// 核心遊戲協議（Engine 層，Foundation only）
protocol BoardGame {
    associatedtype Move
    var state: GameState { get }
    var currentPlayer: Player { get }
    mutating func apply(move: Move) throws
    func validMoves() -> [Move]
    func restart()
}

protocol BoardRenderer {
    func render() -> String  // 返回 console 畫面字串，由 VC 負責 print
}

protocol GameAI {
    associatedtype Move
    func bestMove(for game: some BoardGame) -> Move?
}

// 狀態機
enum GameState {
    case waiting           // 尚未開始
    case playing           // 進行中
    case won(Player)       // 勝利
    case draw              // 平手
    case wonCanContinue    // 2048 專用：達成目標可繼續
}
```

### VC 與 Engine 溝通模式

```
User Tap Button
     ↓
ViewController.buttonTapped(move:)
     ↓ (透過 protocol，不直接依賴具體 Engine 型別)
GameCoordinator.submitMove(move:)
     ↓
Engine.apply(move:)          ← Foundation only
     ↓
print(renderer.render())     ← ViewController 負責 print
     ↓ (如果是 AI 回合)
AI.bestMove(for: engine)
     ↓
Engine.apply(move:)
     ↓
print(renderer.render())
```

---

## Constitution Check

**Constitution Applicability**：此為 CodeMonster 學習專案，非 PAGEs Framework 生產專案。

| Constitutional Principle | Applicability | Status |
|--------------------------|---------------|--------|
| PAGEs 架構層（ViewModel/UseCase/Manager） | NOT applicable — 本專案使用 POP + State Machine | N/A — 合理 |
| Dependency injection (PAGEs DI) | NOT applicable — 本專案使用 Protocol + Init injection | N/A — 合理 |
| `[weak self]` 記憶體管理 | **APPLICABLE** — UIKit 閉包需要 | PASS |
| Logger.log() 使用 | NOT applicable — CodeMonster 使用 `print()` 顯示棋盤 | N/A — 合理 |
| XcodeGen workflow | NOT applicable — CodeMonster 使用標準 .xcodeproj | N/A |
| Test naming (camelCase) | **APPLICABLE** | PASS |
| Given-When-Then test structure | **APPLICABLE** | PASS |

---

## Project Structure

### Documentation

```text
sonia/#6/
├── monster6.md          # 功能規格（spec）
├── plan.md              # 本檔案
└── tasks.md             # Task 切分（Phase 2 output）
```

### Source Code

```text
sonia/CodeMonster/CodeMonster/CodeMonster/BoardGames/
├── Shared/
│   ├── Protocols/
│   │   ├── BoardGame.swift          # 主遊戲協議（associatedtype Move）
│   │   ├── BoardRenderer.swift      # 渲染協議（render() -> String）
│   │   └── GameAI.swift             # AI 協議（bestMove）
│   └── Models/
│       ├── GameState.swift          # State Machine enum
│       └── Player.swift             # 玩家 enum（player1/player2/human/ai）
├── TicTacToe/
│   ├── Engine/
│   │   ├── TicTacToeBoard.swift     # 3×3 board struct
│   │   ├── TicTacToeMove.swift      # Move: (row, col) struct
│   │   └── TicTacToeGame.swift      # 遊戲主邏輯，conformance to BoardGame
│   ├── AI/
│   │   └── TicTacToeAI.swift        # Minimax 演算法
│   ├── Renderer/
│   │   └── TicTacToeRenderer.swift  # Console 渲染
│   └── UI/
│       └── TicTacToeViewController.swift   # 3×3 UIButton grid
├── ConnectFour/
│   ├── Engine/
│   │   ├── ConnectFourBoard.swift   # 7×6 board struct
│   │   ├── ConnectFourMove.swift    # Move: column (Int)
│   │   └── ConnectFourGame.swift    # 重力掉落邏輯
│   ├── AI/
│   │   └── ConnectFourAI.swift      # Alpha-Beta Pruning + 評估函數
│   ├── Renderer/
│   │   └── ConnectFourRenderer.swift
│   └── UI/
│       └── ConnectFourViewController.swift  # 7 個欄位 UIButton
├── Reversi/
│   ├── Engine/
│   │   ├── ReversiBoard.swift       # 8×8 board struct
│   │   ├── ReversiMove.swift        # Move: (row, col)
│   │   └── ReversiGame.swift        # 翻轉邏輯、Pass 判斷
│   ├── AI/
│   │   └── ReversiAI.swift          # 權重矩陣 + Alpha-Beta
│   ├── Renderer/
│   │   └── ReversiRenderer.swift    # 含 * 標記可下位置
│   └── UI/
│       └── ReversiViewController.swift     # UICollectionView 8×8 + Pass 按鈕
├── TwentyFortyEight/
│   ├── Engine/
│   │   ├── TwentyFortyEightBoard.swift   # 4×4 board struct
│   │   ├── TwentyFortyEightMove.swift    # Move: Direction enum
│   │   └── TwentyFortyEightGame.swift    # 滑動合併邏輯
│   ├── Renderer/
│   │   └── TwentyFortyEightRenderer.swift
│   └── UI/
│       └── TwentyFortyEightViewController.swift  # 4 個方向 UIButton
└── Menu/
    └── MenuViewController.swift           # 遊戲清單選擇入口

sonia/CodeMonster/CodeMonsterTests/BoardGamesTests/
├── TicTacToeTests/
│   ├── TicTacToeBoardTests.swift
│   ├── TicTacToeGameTests.swift
│   ├── TicTacToeAITests.swift
│   └── TicTacToeRendererTests.swift
├── ConnectFourTests/
│   ├── ConnectFourBoardTests.swift
│   ├── ConnectFourGameTests.swift
│   └── ConnectFourAITests.swift
├── ReversiTests/
│   ├── ReversiBoardTests.swift
│   ├── ReversiGameTests.swift
│   └── ReversiAITests.swift
└── TwentyFortyEightTests/
    ├── TwentyFortyEightBoardTests.swift
    └── TwentyFortyEightGameTests.swift
```

---

## Implementation Phases

### Phase 0: Shared Framework（基礎協議與 State Machine）

**目標**：建立四個遊戲共用的 Protocol 與 Model

**新增檔案**：
1. `Shared/Protocols/BoardGame.swift` — 主遊戲協議
2. `Shared/Protocols/BoardRenderer.swift` — 渲染協議
3. `Shared/Protocols/GameAI.swift` — AI 協議
4. `Shared/Models/GameState.swift` — State Machine enum
5. `Shared/Models/Player.swift` — 玩家 enum

**驗收**：Protocols 可 compile、不依賴 UIKit

---

### Phase 1: Menu & Navigation

**目標**：建立導航入口，讓後續遊戲接入

**新增檔案**：
1. `Menu/MenuViewController.swift` — UITableView 清單，點擊進入各遊戲

**修改檔案**：
- `SceneDelegate.swift` 或現有入口：加入 BoardGames 入口（透過新 MenuVC）

**驗收**：App 可啟動，點擊任一遊戲跳轉（先用空 VC placeholder）

---

### Phase 2: Tic-Tac-Toe（最完整的 End-to-End 實作）

**目標**：建立第一款完整遊戲，確立 Engine ↔ VC 溝通模式

**新增檔案**：
1. `TicTacToe/Engine/TicTacToeBoard.swift` — 3×3 board，`getCell`, `setCell`, `isFull`
2. `TicTacToe/Engine/TicTacToeMove.swift` — `struct TicTacToeMove: Equatable { row, col }`
3. `TicTacToe/Engine/TicTacToeGame.swift` — `mutating func apply(move:)`, `checkWinner()`
4. `TicTacToe/AI/TicTacToeAI.swift` — Minimax（不需 alpha-beta pruning）
5. `TicTacToe/Renderer/TicTacToeRenderer.swift` — 輸出 spec 中的 console 格式
6. `TicTacToe/UI/TicTacToeViewController.swift` — 3×3 UIButton grid，`print(renderer.render())`

**驗收**：
- Minimax AI 永不輸（可透過跑 100 局模擬驗證）
- Console 輸出符合 spec 格式
- VC 只有 UIButton，不顯示棋盤

---

### Phase 3: Connect Four

**目標**：加入重力掉落機制與 Alpha-Beta Pruning AI

**新增檔案**：
1. `ConnectFour/Engine/ConnectFourBoard.swift` — 7×6，`dropPiece(column:)` 重力邏輯
2. `ConnectFour/Engine/ConnectFourMove.swift` — `struct ConnectFourMove { column: Int }`
3. `ConnectFour/Engine/ConnectFourGame.swift` — 四連線判定
4. `ConnectFour/AI/ConnectFourAI.swift` — Alpha-Beta Pruning（深度 6-8）＋評估函數
5. `ConnectFour/Renderer/ConnectFourRenderer.swift`
6. `ConnectFour/UI/ConnectFourViewController.swift` — 7 個欄位 UIButton

**驗收**：
- 棋子落到正確最底空位
- 欄滿時按鈕 disabled
- AI 能擋明顯勝著

---

### Phase 4: Reversi（最複雜的遊戲邏輯）

**目標**：8 方向翻轉、合法走步計算、Pass 按鈕

**新增檔案**：
1. `Reversi/Engine/ReversiBoard.swift` — 8×8，初始 4 子，8 方向掃描
2. `Reversi/Engine/ReversiMove.swift` — `struct ReversiMove { row, col }`
3. `Reversi/Engine/ReversiGame.swift` — `validMoves()`, `flipPieces()`, `isPassRequired()`, `isGameOver()`
4. `Reversi/AI/ReversiAI.swift` — 權重矩陣 + Alpha-Beta（深度 4-6）
5. `Reversi/Renderer/ReversiRenderer.swift` — `*` 標記可下位置，顯示翻轉數量
6. `Reversi/UI/ReversiViewController.swift` — UICollectionView 8×8 + Pass 按鈕（動態顯示/隱藏）

**驗收**：
- 8 方向翻轉邏輯正確
- 無子可下時 Pass 按鈕顯示，AI 自動跳過
- 雙方都不能下時結束遊戲

---

### Phase 5: 2048（單人，無 AI）

**目標**：滑動合併邏輯、分數計算、勝負判定

**新增檔案**：
1. `TwentyFortyEight/Engine/TwentyFortyEightBoard.swift` — 4×4，`randomSpawn()`（90%/10%）
2. `TwentyFortyEight/Engine/TwentyFortyEightMove.swift` — `enum Direction: case up, down, left, right`
3. `TwentyFortyEight/Engine/TwentyFortyEightGame.swift` — `slide(direction:)`, 分數計算, `isGameOver()`
4. `TwentyFortyEight/Renderer/TwentyFortyEightRenderer.swift` — 數字靠右對齊
5. `TwentyFortyEight/UI/TwentyFortyEightViewController.swift` — 4 個方向 UIButton

**驗收**：
- `[2,2,2,2]` → `[4,4,0,0]`（每格每次只合併一次）
- 無效滑動不生成新方塊
- 合成 2048 顯示「You Win! Continue?」按鈕
- 分數正確累加

---

### Phase 6: 測試補強

**目標**：補齊所有 spec 要求的測試案例

**新增測試**（依 spec 測試策略）：
- Renderer 測試：snapshot 比對 console 字串
- Move 驗證測試：valid/invalid move 全覆蓋
- Win Detection 測試：所有勝負情境
- AI 行為測試：Minimax 永不輸、角落策略
- 2048 特有：`[2,0,2,0]` → `[4,0,0,0]` 等邊界測試
- 整合測試：完整遊戲流程狀態轉換

---

## Dependencies Between Phases

```
Phase 0 (Shared Framework)
     ↓
Phase 1 (Menu)
     ↓
Phase 2 (Tic-Tac-Toe)       ← 確立 Engine ↔ VC pattern
     ↓
Phase 3 (Connect Four)
Phase 4 (Reversi)            ← 可平行進行
Phase 5 (2048)               ← 可平行進行
     ↓
Phase 6 (Tests)
```

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Minimax 對 Reversi 太慢 | 中 | 高 | 加入 Alpha-Beta pruning + 深度限制 |
| Console append 輸出難以追蹤 | 低 | 低 | 每次 print 前加 separator 分隔 |
| UICollectionView layout 複雜（Reversi） | 低 | 中 | 使用 UICollectionViewFlowLayout 固定 cell size |
| 2048 滑動方向邏輯對稱性 | 中 | 中 | 統一 `slideRow([Int]) -> [Int]` 函數，4 方向轉換矩陣方向再套用 |
| Xcode project 未加入新檔案 | 中 | 高 | 每個 Phase 結束後手動確認 .xcodeproj 中有新增 group/files |

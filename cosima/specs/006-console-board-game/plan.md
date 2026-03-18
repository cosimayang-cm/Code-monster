# Implementation Plan: Console Board Game 棋盤遊戲引擎

**Branch**: `feature/monster6-console-board-game` | **Date**: 2026-02-26 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/006-console-board-game/spec.md`

## Summary

實作一個「VC 當搖桿、Console 當畫面」的回合制棋盤遊戲引擎。採用 Protocol-Oriented Programming + Delegate Pattern 架構，Engine 層純 Foundation，VC 層純 UIKit。包含四款遊戲（Tic-Tac-Toe、Connect Four、Reversi、2048），共用一套 Protocol 框架。AI 使用泛型 Minimax Engine 搭配 Alpha-Beta Pruning。

## Technical Context

**Language/Version**: Swift 5.9+
**Primary Dependencies**: Foundation (Engine 層), UIKit (VC 層), XCTest (測試)
**Storage**: N/A（無持久化需求）
**Testing**: XCTest
**Target Platform**: iOS 15+ (iPhone Simulator)
**Project Type**: Mobile (existing Xcode project: CarSystem.xcodeproj)
**Performance Goals**: AI 回應 < 1 秒（同步主執行緒）
**Constraints**: Engine 層禁止 import UIKit；無第三方套件依賴
**Scale/Scope**: 4 款遊戲、約 30+ Swift 檔案、Engine 層 90%+ 測試覆蓋率

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Gate | Status | Notes |
|------|--------|-------|
| 分層限制：Model 層只允許 Foundation | PASS | Engine 層（Board/Move/AI/Renderer）只 import Foundation |
| 命名慣例：Protocol 用名詞/形容詞 | PASS | GameBoard, GameMove, GameRenderer, GameAI |
| 命名慣例：Struct 用名詞 | PASS | TicTacToeBoard, ConnectFourMove 等 |
| 測試規範：Foundation 層必須有單元測試 | PASS | 所有 Engine 層類別都有對應 XCTest |
| 測試檔案放在 CarSystemTests/ | PASS | CarSystemTests/Monster6/ 目錄 |

## Project Structure

### Documentation (this feature)

```text
specs/006-console-board-game/
├── spec.md              # 功能規格
├── plan.md              # 本檔案（實作計畫）
├── research.md          # 技術研究與決策
├── data-model.md        # 資料模型
├── checklists/
│   └── requirements.md  # 品質檢查清單
└── contracts/
```

### Source Code (repository root)

```text
CarSystem/Monster6/
├── Shared/                          # 共用 Protocol 框架（Foundation only）
│   ├── Protocols/
│   │   ├── GameBoard.swift          # GameBoard protocol (associatedtype Move)
│   │   ├── GameMove.swift           # GameMove protocol (Hashable)
│   │   ├── GameRenderer.swift       # GameRenderer protocol → String
│   │   └── GameAI.swift             # GameAI protocol
│   ├── Models/
│   │   ├── GameState.swift          # enum GameState { idle, playing, gameOver }
│   │   ├── GameResult.swift         # enum GameResult { win, draw, lose }
│   │   └── Player.swift             # enum Player { human, ai }
│   └── Engine/
│       ├── GameEngine.swift         # Generic GameEngine<Board> 遊戲流程控制
│       └── MinimaxEngine.swift      # Generic MinimaxEngine<Board> AI 搜尋
│
├── TicTacToe/                       # 井字棋（Foundation only）
│   ├── TicTacToeBoard.swift         # struct TicTacToeBoard: GameBoard
│   ├── TicTacToeMove.swift          # struct TicTacToeMove: GameMove
│   ├── TicTacToeRenderer.swift      # Console 渲染
│   └── TicTacToeAI.swift            # Minimax (depth=9, 不需 pruning)
│
├── ConnectFour/                     # 四子棋（Foundation only）
│   ├── ConnectFourBoard.swift       # struct ConnectFourBoard: GameBoard
│   ├── ConnectFourMove.swift        # struct ConnectFourMove: GameMove
│   ├── ConnectFourRenderer.swift    # Console 渲染
│   └── ConnectFourAI.swift          # Alpha-Beta Pruning (depth=6-8)
│
├── Reversi/                         # 黑白棋（Foundation only）
│   ├── ReversiBoard.swift           # struct ReversiBoard: GameBoard
│   ├── ReversiMove.swift            # struct ReversiMove: GameMove
│   ├── ReversiRenderer.swift        # Console 渲染
│   └── ReversiAI.swift              # Weight Matrix + Alpha-Beta (depth=4-6)
│
├── Game2048/                        # 2048（Foundation only）
│   ├── Game2048Board.swift          # struct Game2048Board: GameBoard
│   ├── Game2048Move.swift           # struct Game2048Move: GameMove
│   └── Game2048Renderer.swift       # Console 渲染（數字靠右對齊）
│
└── Views/                           # VC 層（UIKit）
    ├── GameMenuViewController.swift # 遊戲選單（4 個遊戲選擇）
    ├── TicTacToeViewController.swift    # 3x3 UIButton grid
    ├── ConnectFourViewController.swift  # 7 個 UIButton
    ├── ReversiViewController.swift      # 8x8 UICollectionView
    └── Game2048ViewController.swift     # 4 個方向按鈕

CarSystemTests/Monster6/
├── Shared/
│   ├── GameEngineTests.swift        # GameEngine 狀態轉換測試
│   └── MinimaxEngineTests.swift     # 泛型 AI 搜尋測試
├── TicTacToe/
│   ├── TicTacToeBoardTests.swift    # 棋盤邏輯測試
│   ├── TicTacToeRendererTests.swift # 渲染輸出測試
│   └── TicTacToeAITests.swift       # Minimax 永不輸測試
├── ConnectFour/
│   ├── ConnectFourBoardTests.swift  # 棋盤 + 重力掉落測試
│   ├── ConnectFourRendererTests.swift
│   └── ConnectFourAITests.swift     # 防守測試
├── Reversi/
│   ├── ReversiBoardTests.swift      # 翻轉邏輯 + 8 方向測試
│   ├── ReversiRendererTests.swift
│   └── ReversiAITests.swift         # 角落策略測試
└── Game2048/
    ├── Game2048BoardTests.swift     # 滑動合併 + 邊界測試
    └── Game2048RendererTests.swift
```

**Structure Decision**: 採用 Monster5 同等級的目錄結構 `CarSystem/Monster6/`，內部按遊戲分子目錄。共用框架放在 `Shared/`，每個遊戲的 Engine 層檔案直接放在遊戲目錄下（不另建 Engine/ 子目錄），VC 集中在 `Views/`。

## Implementation Phases

### Phase 1: Shared Protocol Framework + GameEngine

**目標**: 建立所有遊戲共用的 Protocol 定義與泛型 Engine。

**檔案**:
- `Shared/Protocols/GameBoard.swift` — GameBoard protocol with associatedtype
- `Shared/Protocols/GameMove.swift` — GameMove protocol conforming Hashable
- `Shared/Protocols/GameRenderer.swift` — GameRenderer protocol returning String
- `Shared/Protocols/GameAI.swift` — GameAI protocol
- `Shared/Models/GameState.swift` — enum GameState with transitions
- `Shared/Models/GameResult.swift` — enum GameResult
- `Shared/Models/Player.swift` — enum Player
- `Shared/Engine/GameEngine.swift` — Generic GameEngine managing state machine
- `Shared/Engine/MinimaxEngine.swift` — Generic Minimax with Alpha-Beta Pruning

**測試**:
- `CarSystemTests/Monster6/Shared/GameEngineTests.swift`
- `CarSystemTests/Monster6/Shared/MinimaxEngineTests.swift`

**關鍵設計**:

```swift
// GameBoard protocol（Foundation only）
protocol GameBoard {
    associatedtype Move: GameMove
    var currentPlayer: Player { get }
    var isTerminal: Bool { get }
    func legalMoves() -> [Move]
    func applying(_ move: Move) -> Self
    func winner() -> Player?
    func evaluate(for player: Player) -> Double
}

// GameState enum
enum GameState: Equatable {
    case idle
    case playing(currentPlayer: Player)
    case gameOver(result: GameResult)
}

// MinimaxEngine（泛型，支援 Alpha-Beta Pruning）
struct MinimaxEngine<Board: GameBoard> {
    func bestMove(board: Board, depth: Int, maximizing: Bool) -> Board.Move?
    // 內部使用 alpha-beta pruning
}

// GameEngine（泛型，管理遊戲流程）
protocol GameEngineDelegate: AnyObject {
    func gameEngineDidUpdateState(_ state: GameState)
    func gameEngineDidUpdateBoard(_ boardString: String)
}
```

### Phase 2: Tic-Tac-Toe（第一個遊戲，驗證框架）

**目標**: 實作最簡單的遊戲，驗證 Shared Framework 可用性。

**檔案**:
- `TicTacToe/TicTacToeBoard.swift` — 3x3 棋盤 struct
- `TicTacToe/TicTacToeMove.swift` — 位置 struct
- `TicTacToe/TicTacToeRenderer.swift` — Console 渲染
- `TicTacToe/TicTacToeAI.swift` — Minimax depth=9

**測試**:
- Board: 合法落子、非法落子、橫/直/斜 win detection、平手判定
- Renderer: 空棋盤渲染、中局渲染、勝利訊息
- AI: 模擬 50+ 局，先手後手都不輸

### Phase 3: Connect Four

**目標**: 加入重力掉落機制，驗證更大棋盤的 Alpha-Beta Pruning。

**檔案**:
- `ConnectFour/ConnectFourBoard.swift` — 7x6 棋盤（column-based storage）
- `ConnectFour/ConnectFourMove.swift` — 欄位 struct
- `ConnectFour/ConnectFourRenderer.swift` — Console 渲染（Row 1 在底部）
- `ConnectFour/ConnectFourAI.swift` — Alpha-Beta depth=6-8 + 評估函數

**測試**:
- Board: 重力掉落、欄滿、橫/直/斜 4 連線、平手
- Renderer: 渲染格式正確（底部 = Row 1）
- AI: 防守即將 4 連線的局面

### Phase 4: Reversi

**目標**: 實作最複雜的翻轉邏輯與 AI 策略。

**檔案**:
- `Reversi/ReversiBoard.swift` — 8x8 棋盤 + 8 方向翻轉
- `Reversi/ReversiMove.swift` — 位置 + 翻轉清單
- `Reversi/ReversiRenderer.swift` — Console 渲染（含 * 標記、翻轉數量）
- `Reversi/ReversiAI.swift` — Weight Matrix + Alpha-Beta depth=4-6

**測試**:
- Board: 8 方向翻轉正確、必須翻轉才能下、跳過回合、雙方都不能下、平手
- Renderer: 可下位置 `*` 標記、翻轉數量顯示
- AI: 有角落時優先選角落

### Phase 5: 2048

**目標**: 實作單人滑動合併遊戲（無 AI 對手）。

**檔案**:
- `Game2048/Game2048Board.swift` — 4x4 棋盤 + 滑動合併邏輯
- `Game2048/Game2048Move.swift` — 方向 struct
- `Game2048/Game2048Renderer.swift` — Console 渲染（數字靠右對齊）

**測試**:
- Board: `[2,2,2,2]→[4,4,0,0]`、`[2,0,2,0]→[4,0,0,0]`、無效滑動不變、分數計算
- Board: 新方塊生成（90% = 2, 10% = 4）、勝利（2048）、失敗（滿且不可合併）
- Renderer: 數字靠右對齊、格子寬度一致

### Phase 6: VC Layer + Integration

**目標**: 建立所有 UIKit VC，整合到 TabBar。

**檔案**:
- `Views/GameMenuViewController.swift` — 遊戲選單
- `Views/TicTacToeViewController.swift` — 3x3 UIButton grid + delegate
- `Views/ConnectFourViewController.swift` — 7 UIButton + delegate
- `Views/ReversiViewController.swift` — 8x8 UICollectionView + delegate
- `Views/Game2048ViewController.swift` — 4 方向按鈕 + delegate
- 修改 `AppDelegate.swift` / `SceneDelegate.swift` 新增 Monster6 Tab

**整合要點**:
- 每個 VC conform `GameEngineDelegate` 接收狀態變化
- 遊戲結束時顯示「再玩一局」與「回選單」按鈕
- Navigation: GameMenu push → Game VC, pop back to menu

## Dependency Graph

```
Phase 1 (Shared Framework)
    ↓
Phase 2 (Tic-Tac-Toe)  ← 驗證框架
    ↓
Phase 3 (Connect Four)  ← 可與 Phase 4 並行
Phase 4 (Reversi)       ← 可與 Phase 3 並行
    ↓
Phase 5 (2048)          ← 可與 Phase 3/4 並行
    ↓
Phase 6 (VC + Integration)  ← 依賴所有 Engine
```

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Connect Four AI 搜尋太慢（depth 6-8） | Medium | 先用 depth=6 測試，若 < 1s 再提高；加入 move ordering 優化 |
| Reversi 翻轉邏輯 bug（8 方向） | High | 每個方向獨立測試，coverage 確保所有方向都被測到 |
| 2048 合併邊界條件（每格只合併一次） | Medium | 完整列舉 edge case 測試：[2,2,2,2], [4,2,2,4], [0,0,2,2] 等 |
| Xcode project 檔案新增 | Low | 新增 Monster6 group 與所有 .swift 檔案到 CarSystem target |
| Protocol associated type 使用限制 | Medium | 使用 type erasure (AnyGameBoard) 如果需要異質集合，否則保持泛型 |

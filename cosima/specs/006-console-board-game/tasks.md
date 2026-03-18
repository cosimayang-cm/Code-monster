# Tasks: Console Board Game 棋盤遊戲引擎

**Branch**: `feature/monster6-console-board-game`
**Generated**: 2026-02-26
**Spec**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)

## Summary

- **Total Tasks**: 40
- **Phases**: 7 (Setup → Shared Framework → Tic-Tac-Toe → Connect Four → Reversi → 2048 → Integration)
- **Test Tasks**: 14（TDD — 測試先於實作）
- **Parallel Opportunities**: Phase 4/5/6 可並行

---

## Phase 1: Setup (專案初始化)

### T001 — 建立 Monster6 目錄結構

- [x] **[Setup]** Create directory structure
- **File**: `CarSystem/Monster6/` (directories only)
- **Action**: 建立以下目錄：
  ```
  CarSystem/Monster6/Shared/Protocols/
  CarSystem/Monster6/Shared/Models/
  CarSystem/Monster6/Shared/Engine/
  CarSystem/Monster6/TicTacToe/
  CarSystem/Monster6/ConnectFour/
  CarSystem/Monster6/Reversi/
  CarSystem/Monster6/Game2048/
  CarSystem/Monster6/Views/
  CarSystemTests/Monster6/Shared/
  CarSystemTests/Monster6/TicTacToe/
  CarSystemTests/Monster6/ConnectFour/
  CarSystemTests/Monster6/Reversi/
  CarSystemTests/Monster6/Game2048/
  ```
- **Done when**: All directories exist, Xcode project can reference them

---

## Phase 2: Shared Framework — US6 共用框架 (P0, Foundational)

> **Story Goal**: 定義所有遊戲共用的 Protocol 與 Engine，新增遊戲時只需 conform Protocol。
> **Independent Test**: Protocol 定義可編譯、GameEngine 狀態轉換正確、MinimaxEngine 在簡單棋盤上找到最佳步。

### T002 — Player enum + GameResult enum + GameState enum [P]

- [x] **[US6]** Implement shared model enums
- **Files**:
  - `CarSystem/Monster6/Shared/Models/Player.swift`
  - `CarSystem/Monster6/Shared/Models/GameResult.swift`
  - `CarSystem/Monster6/Shared/Models/GameState.swift`
- **Details**:
  - `Player`: `.human`, `.ai` — conform `Equatable`
  - `GameResult`: `.win(player:)`, `.draw`, `.lose` — conform `Equatable`
  - `GameState`: `.idle`, `.playing(currentPlayer:)`, `.gameOver(result:)` — conform `Equatable`
  - **Only import Foundation**
- **Done when**: Enums compile, all cases defined with associated values

### T003 — GameMove protocol [P]

- [x] **[US6]** Define GameMove protocol
- **File**: `CarSystem/Monster6/Shared/Protocols/GameMove.swift`
- **Details**:
  - Conform to `Hashable` and `CustomStringConvertible`
  - `var description: String { get }`
  - **Only import Foundation**
- **Done when**: Protocol compiles

### T004 — GameBoard protocol [P]

- [x] **[US6]** Define GameBoard protocol
- **File**: `CarSystem/Monster6/Shared/Protocols/GameBoard.swift`
- **Details**:
  - `associatedtype Move: GameMove`
  - `var currentPlayer: Player { get }`
  - `var isTerminal: Bool { get }`
  - `func legalMoves() -> [Move]`
  - `func applying(_ move: Move) -> Self`
  - `func winner() -> Player?`
  - `func evaluate(for player: Player) -> Double`
  - **Only import Foundation**
- **Done when**: Protocol compiles with all required members

### T005 — GameRenderer protocol [P]

- [x] **[US6]** Define GameRenderer protocol
- **File**: `CarSystem/Monster6/Shared/Protocols/GameRenderer.swift`
- **Details**:
  - `associatedtype Board: GameBoard`
  - `func render(board: Board, state: GameState) -> String`
  - Returns String (不直接 print)
  - **Only import Foundation**
- **Done when**: Protocol compiles

### T006 — GameAI protocol [P]

- [x] **[US6]** Define GameAI protocol
- **File**: `CarSystem/Monster6/Shared/Protocols/GameAI.swift`
- **Details**:
  - `associatedtype Board: GameBoard`
  - `func bestMove(for board: Board) -> Board.Move?`
  - **Only import Foundation**
- **Done when**: Protocol compiles

### T007 — GameEngine tests (TDD)

- [x] **[US6][Test]** Write GameEngine state machine tests
- **File**: `CarSystemTests/Monster6/Shared/GameEngineTests.swift`
- **Tests**:
  - `testInitialStateIsIdle` — 初始狀態為 .idle
  - `testStartGameTransitionsToPlaying` — idle → playing(.human)
  - `testApplyMoveTransitionsPlayer` — playing(.human) → playing(.ai)
  - `testWinTransitionsToGameOver` — playing → gameOver(.win)
  - `testDrawTransitionsToGameOver` — playing → gameOver(.draw)
  - `testResetTransitionsToIdle` — gameOver → idle
  - `testInvalidTransitionThrows` — gameOver 下不能 applyMove
  - `testDelegateCalledOnStateChange` — delegate 被呼叫
- **Done when**: Tests compile (may fail, awaiting implementation)

### T008 — GameEngine implementation

- [x] **[US6]** Implement generic GameEngine
- **File**: `CarSystem/Monster6/Shared/Engine/GameEngine.swift`
- **Details**:
  - `class GameEngine<Board: GameBoard, Renderer: GameRenderer, AI: GameAI>` where constraints match
  - Manages `GameState` transitions via enum switch
  - `weak var delegate: GameEngineDelegate?`
  - `func startGame()` — idle → playing
  - `func applyHumanMove(_ move: Board.Move) throws` — validate legal, apply, check terminal, trigger AI
  - `func reset()` — any state → idle
  - Invalid transitions throw `GameEngineError`
  - After each move: call `delegate?.gameEngineDidUpdateBoard(renderer.render(...))`
  - After state change: call `delegate?.gameEngineDidUpdateState(_:)`
  - **Only import Foundation**
- **Depends on**: T002, T003, T004, T005, T006
- **Done when**: T007 tests pass

### T009 — MinimaxEngine tests (TDD)

- [x] **[US6][Test]** Write MinimaxEngine tests
- **File**: `CarSystemTests/Monster6/Shared/MinimaxEngineTests.swift`
- **Tests**: Use a simple mock board (e.g., 2x2 or 1D board) to verify:
  - `testFindsWinningMove` — 1 步可贏時選贏
  - `testBlocksOpponentWin` — 對手 1 步可贏時選擋
  - `testReturnsNilForTerminalBoard` — 已結束棋盤回傳 nil
  - `testAlphaBetaPrunesCorrectly` — depth 限制生效
- **Done when**: Tests compile (may fail, awaiting implementation)

### T010 — MinimaxEngine implementation

- [x] **[US6]** Implement generic MinimaxEngine with Alpha-Beta Pruning
- **File**: `CarSystem/Monster6/Shared/Engine/MinimaxEngine.swift`
- **Details**:
  - `struct MinimaxEngine<Board: GameBoard>`
  - `func bestMove(board: Board, depth: Int, maximizing: Bool) -> Board.Move?`
  - Internal `minimax(board:depth:alpha:beta:maximizing:) -> Double`
  - Alpha-Beta pruning: `if beta <= alpha { break }`
  - Terminal check: `if depth == 0 || board.isTerminal { return board.evaluate(for:) }`
  - No force unwraps, return nil if no legal moves
  - **Only import Foundation**
- **Depends on**: T004
- **Done when**: T009 tests pass

**🔶 Checkpoint**: Shared Framework complete. All protocols defined, GameEngine + MinimaxEngine tested.

---

## Phase 3: Tic-Tac-Toe — US2 井字棋 (P1, validates framework)

> **Story Goal**: 使用者與 Minimax AI 對弈 3x3 井字棋，每步 Console 印出棋盤。
> **Independent Test**: Board 邏輯正確、Renderer 輸出正確、AI 50 局不輸。

### T011 — TicTacToeMove + TicTacToeBoard tests (TDD) [P]

- [x] **[US2][Test]** Write TicTacToe board logic tests
- **File**: `CarSystemTests/Monster6/TicTacToe/TicTacToeBoardTests.swift`
- **Tests**:
  - `testInitialBoardIsEmpty` — 9 格皆 .empty
  - `testLegalMovesOnEmptyBoard` — 回傳 9 個 moves
  - `testApplyMoveChangesCell` — 下子後 cell 變化
  - `testApplyMoveChangesPlayer` — 下子後切換玩家
  - `testOccupiedCellNotInLegalMoves` — 已有子的格子不在 legalMoves
  - `testHorizontalWin` — 橫三連線 (3 種)
  - `testVerticalWin` — 直三連線 (3 種)
  - `testDiagonalWin` — 斜三連線 (2 種)
  - `testDrawWhenBoardFull` — 棋盤滿且無三連線 = draw
  - `testIsTerminalOnWin` — 有人贏 → isTerminal = true
  - `testIsTerminalOnDraw` — 平手 → isTerminal = true
  - `testNotTerminalMidGame` — 未結束 → isTerminal = false
- **Done when**: Tests compile

### T012 — TicTacToeMove + TicTacToeBoard implementation

- [x] **[US2]** Implement TicTacToe board and move
- **Files**:
  - `CarSystem/Monster6/TicTacToe/TicTacToeMove.swift`
  - `CarSystem/Monster6/TicTacToe/TicTacToeBoard.swift`
- **Details**:
  - `TicTacToeMove`: struct with `position: Int` (0-8), conform `GameMove`
  - `TicTacToeBoard`: struct with `cells: [CellState]` (9 elements), `currentPlayer: Player`
  - `CellState`: enum `.empty`, `.x`, `.o`
  - `legalMoves()`: return positions where cell == .empty
  - `applying(_ move:)`: return new board with cell set and player switched
  - `winner()`: check 8 win patterns (3 rows + 3 cols + 2 diagonals)
  - `isTerminal`: winner != nil || legalMoves().isEmpty
  - `evaluate(for:)`: +1000 win, -1000 lose, 0 otherwise
  - **Only import Foundation**
- **Depends on**: T002, T003, T004
- **Done when**: T011 tests pass

### T013 — TicTacToeRenderer tests (TDD) [P]

- [x] **[US2][Test]** Write TicTacToe renderer tests
- **File**: `CarSystemTests/Monster6/TicTacToe/TicTacToeRendererTests.swift`
- **Tests**:
  - `testRenderEmptyBoard` — 空棋盤格式正確（含標題、座標、格線）
  - `testRenderMidGame` — 中局顯示 ❌ ⭕ 在正確位置
  - `testRenderWinMessage` — 勝利時顯示勝利訊息
  - `testRenderDrawMessage` — 平手時顯示平手訊息
  - `testRenderCurrentPlayerTurn` — 顯示當前玩家回合
- **Done when**: Tests compile

### T014 — TicTacToeRenderer implementation

- [x] **[US2]** Implement TicTacToe console renderer
- **File**: `CarSystem/Monster6/TicTacToe/TicTacToeRenderer.swift`
- **Details**:
  - Conform `GameRenderer` where Board == TicTacToeBoard
  - 渲染格式參照 spec 範例（含 emoji、座標 A/B/C、格線 ┌───┬───┐）
  - 顯示當前玩家 or 勝利/平手訊息
  - **Only import Foundation**
- **Depends on**: T005, T012
- **Done when**: T013 tests pass

### T015 — TicTacToeAI tests (TDD)

- [x] **[US2][Test]** Write TicTacToe AI tests
- **File**: `CarSystemTests/Monster6/TicTacToe/TicTacToeAITests.swift`
- **Tests**:
  - `testAITakesWinningMove` — AI 1 步可贏時選贏
  - `testAIBlocksHumanWin` — 人類 1 步可贏時 AI 擋住
  - `testAINeverLosesAsSecondPlayer` — 模擬 50+ 局，AI 後手不輸
  - `testAINeverLosesAsFirstPlayer` — 模擬 50+ 局，AI 先手不輸
- **Done when**: Tests compile

### T016 — TicTacToeAI implementation

- [x] **[US2]** Implement TicTacToe AI (Minimax)
- **File**: `CarSystem/Monster6/TicTacToe/TicTacToeAI.swift`
- **Details**:
  - Conform `GameAI` where Board == TicTacToeBoard
  - 內部使用 `MinimaxEngine<TicTacToeBoard>` with depth=9（完整搜尋）
  - `bestMove(for:)` 回傳最佳位置
  - 不需 Alpha-Beta pruning（搜尋空間小）
  - **Only import Foundation**
- **Depends on**: T010, T012
- **Done when**: T015 tests pass（50+ 局不輸）

**🔶 Checkpoint**: Tic-Tac-Toe Engine complete. Framework validated with first game.

---

## Phase 4: Connect Four — US3 四子棋 (P1) [P with Phase 5, 6]

> **Story Goal**: 使用者與 Alpha-Beta AI 對弈 7x6 四子棋，含重力掉落機制。
> **Independent Test**: 重力掉落正確、4 連線判定、AI 能擋勝著。

### T017 — ConnectFourBoard tests (TDD) [P]

- [x] **[US3][Test]** Write ConnectFour board logic tests
- **File**: `CarSystemTests/Monster6/ConnectFour/ConnectFourBoardTests.swift`
- **Tests**:
  - `testInitialBoardIsEmpty` — 7 欄皆空
  - `testGravityDrop` — 棋子落到最底空位
  - `testMultipleDropsSameColumn` — 同欄多次投入堆疊正確
  - `testFullColumnNotInLegalMoves` — 滿欄不在 legalMoves
  - `testHorizontalFourWin` — 橫四連線
  - `testVerticalFourWin` — 直四連線
  - `testDiagonalUpRightWin` — 斜四連線（左下→右上）
  - `testDiagonalDownRightWin` — 斜四連線（左上→右下）
  - `testDrawWhenBoardFull` — 棋盤滿無四連線 = 平手
- **Done when**: Tests compile

### T018 — ConnectFourMove + ConnectFourBoard implementation

- [x] **[US3]** Implement ConnectFour board and move
- **Files**:
  - `CarSystem/Monster6/ConnectFour/ConnectFourMove.swift`
  - `CarSystem/Monster6/ConnectFour/ConnectFourBoard.swift`
- **Details**:
  - `ConnectFourMove`: struct with `column: Int` (0-6), conform `GameMove`
  - `ConnectFourBoard`: struct with `columns: [[CellState]]` (7 arrays), `currentPlayer`
  - Column-based storage: `columns[col]` is array, index 0 = bottom, append = drop
  - `legalMoves()`: columns where count < 6
  - `applying(_ move:)`: append to column, switch player
  - `winner()`: scan all horizontal, vertical, diagonal 4-in-a-row patterns
  - `evaluate(for:)`: count 2/3/4-in-row, center column bonus
  - **Only import Foundation**
- **Depends on**: T002, T003, T004
- **Done when**: T017 tests pass

### T019 — ConnectFourRenderer tests (TDD) [P]

- [x] **[US3][Test]** Write ConnectFour renderer tests
- **File**: `CarSystemTests/Monster6/ConnectFour/ConnectFourRendererTests.swift`
- **Tests**:
  - `testRenderEmptyBoard` — 7x6 空棋盤格式正確
  - `testRenderWithPieces` — 棋子顯示在正確位置（Row 1 在底部）
  - `testRenderCurrentPlayer` — 顯示當前玩家
- **Done when**: Tests compile

### T020 — ConnectFourRenderer implementation

- [x] **[US3]** Implement ConnectFour console renderer
- **File**: `CarSystem/Monster6/ConnectFour/ConnectFourRenderer.swift`
- **Details**:
  - Row 1 在底部, Row 6 在頂部
  - 渲染格式參照 spec 範例（🔴 🟡 emoji）
  - **Only import Foundation**
- **Depends on**: T005, T018
- **Done when**: T019 tests pass

### T021 — ConnectFourAI tests (TDD)

- [x] **[US3][Test]** Write ConnectFour AI tests
- **File**: `CarSystemTests/Monster6/ConnectFour/ConnectFourAITests.swift`
- **Tests**:
  - `testAIBlocksHorizontalThreat` — 對手 3 連線時擋住
  - `testAIBlocksVerticalThreat` — 對手垂直 3 連線時擋住
  - `testAITakesWinningMove` — AI 自己 3 連線時贏下
  - `testAIPrefersCenter` — 初期偏好中路
- **Done when**: Tests compile

### T022 — ConnectFourAI implementation

- [x] **[US3]** Implement ConnectFour AI (Alpha-Beta Pruning)
- **File**: `CarSystem/Monster6/ConnectFour/ConnectFourAI.swift`
- **Details**:
  - Conform `GameAI` where Board == ConnectFourBoard
  - 使用 `MinimaxEngine<ConnectFourBoard>` with depth=6（可調至 8）
  - 評估函數：連線數量權重 + 中路優勢 + 潛在威脅偵測
  - Move ordering optimization: 中路欄位優先搜尋
  - **Only import Foundation**
- **Depends on**: T010, T018
- **Done when**: T021 tests pass

**🔶 Checkpoint**: Connect Four Engine complete.

---

## Phase 5: Reversi — US4 黑白棋 (P2) [P with Phase 4, 6]

> **Story Goal**: 使用者與權重矩陣 AI 對弈 8x8 黑白棋，含 8 方向翻轉與跳過回合。
> **Independent Test**: 翻轉邏輯正確、跳過回合、AI 搶角落。

### T023 — ReversiBoard tests (TDD) [P]

- [x] **[US4][Test]** Write Reversi board logic tests
- **File**: `CarSystemTests/Monster6/Reversi/ReversiBoardTests.swift`
- **Tests**:
  - `testInitialBoardHasFourPieces` — 中心 4 格正確放置
  - `testInitialLegalMoves` — 黑方初始有 4 個合法位置
  - `testFlipHorizontal` — 水平翻轉正確
  - `testFlipVertical` — 垂直翻轉正確
  - `testFlipDiagonal` — 斜向翻轉正確
  - `testFlipMultipleDirections` — 多方向同時翻轉
  - `testMustFlipToPlace` — 不能翻轉的位置不合法
  - `testSkipTurnWhenNoLegalMoves` — 無合法步時跳過
  - `testGameOverWhenBothCantMove` — 雙方都不能下時結束
  - `testWinnerByPieceCount` — 棋子多的獲勝
  - `testDrawWhenEqualPieces` — 棋子相同判平手
- **Done when**: Tests compile

### T024 — ReversiMove + ReversiBoard implementation

- [x] **[US4]** Implement Reversi board and move
- **Files**:
  - `CarSystem/Monster6/Reversi/ReversiMove.swift`
  - `CarSystem/Monster6/Reversi/ReversiBoard.swift`
- **Details**:
  - `ReversiMove`: struct with `row`, `col`, `flips: [(Int, Int)]`, conform `GameMove`
  - `ReversiBoard`: struct with `cells: [[CellState]]` (8x8), `currentPlayer`
  - `CellState`: `.empty`, `.black`, `.white`
  - Initial state: D4=white, E4=black, D5=black, E5=white (0-indexed: [3][3]=white, [3][4]=black, [4][3]=black, [4][4]=white)
  - `legalMoves()`: scan all empty cells, for each check 8 directions, include only if flips >= 1
  - `applying(_ move:)`: place piece, flip all pieces in `flips`, switch player (or stay if opponent has no moves)
  - `isTerminal`: both players have no legal moves
  - `winner()`: count pieces, more = win; equal = nil (draw)
  - `evaluate(for:)`: piece count difference + position weight matrix score
  - **Only import Foundation**
- **Depends on**: T002, T003, T004
- **Done when**: T023 tests pass

### T025 — ReversiRenderer tests (TDD) [P]

- [x] **[US4][Test]** Write Reversi renderer tests
- **File**: `CarSystemTests/Monster6/Reversi/ReversiRendererTests.swift`
- **Tests**:
  - `testRenderInitialBoard` — 8x8 初始棋盤格式正確
  - `testRenderValidMoveMarkers` — `*` 標記在可下位置
  - `testRenderFlipCounts` — 顯示每個可下位置的翻轉數量
  - `testRenderPieceCounts` — 顯示雙方棋子數
- **Done when**: Tests compile

### T026 — ReversiRenderer implementation

- [x] **[US4]** Implement Reversi console renderer
- **File**: `CarSystem/Monster6/Reversi/ReversiRenderer.swift`
- **Details**:
  - 渲染格式參照 spec 範例（⚫ ⚪ * emoji、座標 A-H / 1-8）
  - 標記合法位置 `*`，顯示翻轉數量
  - 顯示棋子數量統計
  - **Only import Foundation**
- **Depends on**: T005, T024
- **Done when**: T025 tests pass

### T027 — ReversiAI tests (TDD)

- [x] **[US4][Test]** Write Reversi AI tests
- **File**: `CarSystemTests/Monster6/Reversi/ReversiAITests.swift`
- **Tests**:
  - `testAIPrefersCorner` — 有角落可下時優先選角落
  - `testAIAvoidsCornerAdjacent` — 避開角落旁 (C-square, X-square)
  - `testAIReturnsNilWhenNoMoves` — 無合法步時回傳 nil
- **Done when**: Tests compile

### T028 — ReversiAI implementation

- [x] **[US4]** Implement Reversi AI (Weight Matrix + Alpha-Beta)
- **File**: `CarSystem/Monster6/Reversi/ReversiAI.swift`
- **Details**:
  - Conform `GameAI` where Board == ReversiBoard
  - 使用 `MinimaxEngine<ReversiBoard>` with depth=4（可調至 6）
  - 評估函數結合：位置權重矩陣 + 棋子數差 + mobility（可下步數差）
  - 權重矩陣：角落 100、角旁 -20/-50、邊 10、中心 0-1
  - **Only import Foundation**
- **Depends on**: T010, T024
- **Done when**: T027 tests pass

**🔶 Checkpoint**: Reversi Engine complete.

---

## Phase 6: 2048 — US5 (P2) [P with Phase 4, 5]

> **Story Goal**: 使用者進行單人 2048 滑動合併遊戲。
> **Independent Test**: 滑動合併邏輯 100% 正確、分數計算、勝敗判定。

### T029 — Game2048Board tests (TDD) [P]

- [x] **[US5][Test]** Write 2048 board logic tests
- **File**: `CarSystemTests/Monster6/Game2048/Game2048BoardTests.swift`
- **Tests**:
  - `testSlideLeft_2222` — `[2,2,2,2]` → `[4,4,0,0]`, score += 8
  - `testSlideLeft_2020` — `[2,0,2,0]` → `[4,0,0,0]`, score += 4
  - `testSlideLeft_4224` — `[4,2,2,4]` → `[4,4,4,0]`, score += 4
  - `testSlideRight` — 反方向合併正確
  - `testSlideUp` — 垂直方向合併正確
  - `testSlideDown` — 垂直方向合併正確
  - `testNoOpSlideDoesNothing` — 無變化時棋盤不變
  - `testNewTileGeneratedAfterValidSlide` — 有效滑動後生成新方塊
  - `testNoNewTileAfterInvalidSlide` — 無效滑動不生成新方塊
  - `testWinCondition` — 合成 2048 → hasWon = true
  - `testLoseCondition` — 棋盤滿且無可合併 → isTerminal
  - `testScoreAccumulates` — 分數為所有合併數字累加
  - `testInitialBoardHasTwoTiles` — 初始有 2 個方塊
- **Done when**: Tests compile

### T030 — Game2048Move + Game2048Board implementation

- [x] **[US5]** Implement 2048 board and move
- **Files**:
  - `CarSystem/Monster6/Game2048/Game2048Move.swift`
  - `CarSystem/Monster6/Game2048/Game2048Board.swift`
- **Details**:
  - `Game2048Move`: struct with `direction: Direction`, conform `GameMove`
  - `Direction`: enum `.up`, `.down`, `.left`, `.right`
  - `Game2048Board`: struct with `cells: [[Int]]` (4x4), `score: Int`, `hasWon: Bool`
  - Core algorithm: `slideLine(_ line: [Int]) -> ([Int], Int)` — 壓縮→合併→壓縮，回傳 (new line, merge score)
  - `applying(_ move:)`: extract rows/cols → slideLine → reassemble → generate new tile if changed
  - `legalMoves()`: return directions where applying would change the board
  - `isTerminal`: no legal moves (board full AND no adjacent equal)
  - `winner()`: nil (single player) — use `hasWon` for 2048 achievement
  - New tile: 90% chance 2, 10% chance 4, random empty cell
  - **Only import Foundation**
- **Depends on**: T002, T003, T004
- **Done when**: T029 tests pass

### T031 — Game2048Renderer tests (TDD) [P]

- [x] **[US5][Test]** Write 2048 renderer tests
- **File**: `CarSystemTests/Monster6/Game2048/Game2048RendererTests.swift`
- **Tests**:
  - `testRenderEmptyBoard` — 空棋盤格式正確
  - `testRenderNumbersRightAligned` — 數字靠右對齊
  - `testRenderConsistentCellWidth` — 格子寬度一致
  - `testRenderScore` — 顯示分數
  - `testRenderWinMessage` — 2048 勝利訊息
  - `testRenderLoseMessage` — 失敗訊息
- **Done when**: Tests compile

### T032 — Game2048Renderer implementation

- [x] **[US5]** Implement 2048 console renderer
- **File**: `CarSystem/Monster6/Game2048/Game2048Renderer.swift`
- **Details**:
  - 數字靠右對齊（String padding with width 4-6）
  - 格子寬度一致，0 顯示為空白
  - 顯示 Score、Win/Lose message
  - 渲染格式參照 spec 範例
  - **Only import Foundation**
- **Depends on**: T005, T030
- **Done when**: T031 tests pass

**🔶 Checkpoint**: 2048 Engine complete. All 4 game engines done.

---

## Phase 7: VC Layer + Integration — US1 遊戲選擇與啟動 (P0)

> **Story Goal**: 使用者可選擇遊戲、透過 VC 操作、Console 顯示，遊戲結束可重玩或回選單。
> **Independent Test**: App 開啟 → 選遊戲 → 操作 → Console 印出 → 結束 → 重玩/回選單。

### T033 — GameMenuViewController

- [x] **[US1]** Implement game menu screen
- **File**: `CarSystem/Monster6/Views/GameMenuViewController.swift`
- **Details**:
  - UIViewController with 4 UIButtons (Tic-Tac-Toe, Connect Four, Reversi, 2048)
  - 使用 UIStackView 排列按鈕
  - 點擊按鈕 → push 對應遊戲 VC via UINavigationController
  - Title: "🎮 Board Games"
  - **import UIKit**
- **Done when**: 4 個按鈕顯示且可點擊

### T034 — TicTacToeViewController [P]

- [x] **[US2]** Implement Tic-Tac-Toe VC
- **File**: `CarSystem/Monster6/Views/TicTacToeViewController.swift`
- **Details**:
  - 3x3 UIButton grid（使用 UIStackView 排列）
  - 按鈕只顯示位置（如 "A1"），不顯示棋子
  - 點擊 → `engine.applyHumanMove(TicTacToeMove(position:))`
  - Conform `GameEngineDelegate`: 收到 boardString → print to console
  - 遊戲結束時：隱藏 grid，顯示「再玩一局」+「回選單」按鈕
  - 「再玩一局」→ engine.reset() + 重新顯示 grid
  - 「回選單」→ navigationController?.popViewController
  - **import UIKit**
- **Depends on**: T012, T014, T016, T008
- **Done when**: 可完整操作一局 Tic-Tac-Toe

### T035 — ConnectFourViewController [P]

- [x] **[US3]** Implement Connect Four VC
- **File**: `CarSystem/Monster6/Views/ConnectFourViewController.swift`
- **Details**:
  - 7 個 UIButton，每個代表一欄（顯示 "Col 1" ~ "Col 7"）
  - 使用 horizontal UIStackView
  - 點擊 → `engine.applyHumanMove(ConnectFourMove(column:))`
  - Conform `GameEngineDelegate`
  - 遊戲結束：「再玩一局」+「回選單」
  - **import UIKit**
- **Depends on**: T018, T020, T022, T008
- **Done when**: 可完整操作一局 Connect Four

### T036 — ReversiViewController [P]

- [x] **[US4]** Implement Reversi VC
- **File**: `CarSystem/Monster6/Views/ReversiViewController.swift`
- **Details**:
  - 8x8 UICollectionView (UICollectionViewFlowLayout, 固定 cell size)
  - Cell 只顯示位置座標（如 "A1"），不顯示棋子
  - 點擊 cell → `engine.applyHumanMove(ReversiMove(row:col:flips:))`
  - Conform `GameEngineDelegate`
  - 遊戲結束：「再玩一局」+「回選單」
  - **import UIKit**
- **Depends on**: T024, T026, T028, T008
- **Done when**: 可完整操作一局 Reversi

### T037 — Game2048ViewController [P]

- [x] **[US5]** Implement 2048 VC
- **File**: `CarSystem/Monster6/Views/Game2048ViewController.swift`
- **Details**:
  - 4 個方向 UIButton（⬆ ⬇ ⬅ ➡）
  - 使用 UIStackView（center 2x2 grid 或 cross layout）
  - 點擊 → `engine.applyHumanMove(Game2048Move(direction:))`
  - Conform `GameEngineDelegate`
  - 遊戲結束：「再玩一局」+「回選單」
  - **import UIKit**
- **Depends on**: T030, T032, T008
- **Done when**: 可完整操作一局 2048

### T038 — TabBar Integration

- [x] **[US1]** Add Monster6 tab to AppDelegate/SceneDelegate
- **Files**:
  - `CarSystem/AppDelegate.swift` (modify)
  - `CarSystem/SceneDelegate.swift` (modify)
- **Details**:
  - 新增 Tab 5: Monster6
  - 建立 UINavigationController with GameMenuViewController as root
  - TabBarItem: title "遊戲", image "gamecontroller", selectedImage "gamecontroller.fill"
  - 兩個檔案都要更新（AppDelegate + SceneDelegate）
- **Depends on**: T033
- **Done when**: App 開啟後 Tab Bar 出現「遊戲」tab

### T039 — Xcode Project File Update

- [x] **[Setup]** Add all Monster6 files to Xcode project
- **File**: `CarSystem.xcodeproj/project.pbxproj` (modify)
- **Details**:
  - 新增 Monster6 group 到 CarSystem target
  - 新增所有 .swift source files 到 compile sources
  - 新增所有 test files 到 CarSystemTests target
  - 確保 build succeeds
- **Depends on**: All previous tasks
- **Done when**: `xcodebuild build` + `xcodebuild test` 通過

### T040 — End-to-End Integration Test

- [x] **[US1]** Verify complete game flow for all 4 games
- **Action**: Manual verification on simulator
- **Checklist**:
  - [x] App 開啟 → 「遊戲」tab → 4 個選擇按鈕
  - [x] Tic-Tac-Toe: 點按鈕 → Console 印出棋盤 → AI 回應 → 遊戲結束 → 再玩/回選單
  - [x] Connect Four: 同上驗證流程
  - [x] Reversi: 同上驗證流程，含跳過回合
  - [x] 2048: 同上驗證流程，含分數顯示
  - [x] Engine 層所有 .swift 只 import Foundation（grep 確認）
  - [x] 所有單元測試通過（Monster5 TCA macro 問題為預先存在，非 Monster6 造成）
- **Depends on**: T039
- **Done when**: All checklist items pass

**🔶 Final Checkpoint**: Feature complete. All 4 games playable, all tests pass.

---

## Dependency Graph

```
T001 (Setup dirs)
  ↓
T002-T006 (Shared Protocols & Models) [P — all parallel]
  ↓
T007-T008 (GameEngine tests → impl)
T009-T010 (MinimaxEngine tests → impl)
  ↓
┌─────────────────────────┬─────────────────────────┬─────────────────────┐
│ T011-T016               │ T017-T022               │ T023-T028           │ T029-T032
│ Tic-Tac-Toe (US2)       │ Connect Four (US3)      │ Reversi (US4)       │ 2048 (US5)
│ (sequential,            │ [P with others]          │ [P with others]     │ [P with others]
│  validates framework)   │                          │                     │
└────────────┬────────────┴─────────────┬────────────┴──────────┬──────────┘
             ↓                          ↓                       ↓
          T033-T038 (VC Layer + Integration)
             ↓
          T039 (Xcode Project)
             ↓
          T040 (E2E Verification)
```

## Parallel Execution Guide

### Maximum parallelism after Phase 2:

```
Agent 1: T011→T012→T013→T014→T015→T016 (Tic-Tac-Toe)
Agent 2: T017→T018→T019→T020→T021→T022 (Connect Four)  ← start after T010
Agent 3: T023→T024→T025→T026→T027→T028 (Reversi)       ← start after T010
Agent 4: T029→T030→T031→T032             (2048)          ← start after T010
```

### Within each game (sequential TDD):

```
Test → Implementation → Test → Implementation → ...
```

## Implementation Strategy

1. **MVP**: Phase 1 + Phase 2 (Shared Framework + Tic-Tac-Toe) — 驗證核心框架
2. **Incremental**: Phase 3-6 each adds one complete game — 每個 phase 獨立可交付
3. **TDD**: 每個遊戲先寫測試再寫實作，確保 90%+ 覆蓋率
4. **Foundation-only gate**: 每個 Engine 檔案完成後立即檢查 import 限制

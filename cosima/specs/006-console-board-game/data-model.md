# Data Model: Console Board Game 棋盤遊戲引擎

**Date**: 2026-02-26
**Feature**: 006-console-board-game

## Shared Framework Protocols & Types

### GameState (Enum)

```
GameState
├── idle                         // 遊戲未開始
├── playing(currentPlayer: Player) // 遊戲進行中，記錄當前玩家
└── gameOver(result: GameResult)  // 遊戲結束，記錄結果
```

### GameResult (Enum)

```
GameResult
├── win(player: Player)   // 某玩家勝利
├── draw                  // 平手
└── lose                  // 2048 專用：失敗
```

### Player (Enum)

```
Player
├── human    // 使用者
└── ai       // AI 對手
```

### Protocol: GameBoard

| Property/Method | Type | Description |
|----------------|------|-------------|
| associatedtype Move | GameMove | 該遊戲的合法操作型別 |
| cells | [CellState] 或自定義 | 棋盤格子狀態 |
| currentPlayer | Player | 當前操作者 |
| legalMoves() | [Move] | 目前可執行的合法操作列表 |
| applying(_ move: Move) | Self | 回傳執行操作後的新棋盤（值語義） |
| isTerminal | Bool | 遊戲是否已結束 |
| winner() | Player? | 勝利者（nil 表示平手或未結束） |
| evaluate(for: Player) | Double | AI 用：從指定玩家角度評估棋盤分數 |

### Protocol: GameMove (conform Hashable)

| Property | Type | Description |
|----------|------|-------------|
| description | String | 操作的人可讀描述 |

### Protocol: GameRenderer

| Method | Type | Description |
|--------|------|-------------|
| render(board:state:) | String | 將棋盤轉為 Console 顯示字串 |

### Protocol: GameAI

| Method | Type | Description |
|--------|------|-------------|
| associatedtype Board | GameBoard | 該 AI 對應的棋盤型別 |
| bestMove(for: Board) | Board.Move? | 計算最佳操作 |

---

## Tic-Tac-Toe

### TicTacToeBoard (Struct)

| Field | Type | Description |
|-------|------|-------------|
| cells | [CellState] (9 elements) | 3x3 棋盤，.empty / .x / .o |
| currentPlayer | Player | 當前玩家 |

### CellState (Enum, Tic-Tac-Toe)

```
CellState
├── empty   // 空格
├── x       // ❌ (human)
└── o       // ⭕ (AI)
```

### TicTacToeMove (Struct, Hashable)

| Field | Type | Description |
|-------|------|-------------|
| position | Int (0-8) | 落子位置 |

### State Transitions

```
idle → playing(.human)          // 開始遊戲，人類先手
playing(.human) → playing(.ai)  // 人類下子後，切換到 AI
playing(.ai) → playing(.human)  // AI 回應後，切換到人類
playing(_) → gameOver(.win/.draw) // 判定勝負
gameOver → idle                  // 重新開始
```

---

## Connect Four

### ConnectFourBoard (Struct)

| Field | Type | Description |
|-------|------|-------------|
| columns | [[CellState]] (7 columns) | 每欄一個 array，index 0 = 底部 |
| currentPlayer | Player | 當前玩家 |

### CellState (Enum, Connect Four)

```
CellState
├── empty   // 空格
├── red     // 🔴 (human)
└── yellow  // 🟡 (AI)
```

### ConnectFourMove (Struct, Hashable)

| Field | Type | Description |
|-------|------|-------------|
| column | Int (0-6) | 投入欄位 |

### Derived Properties

- `rows`: 6（固定）
- `columns[col].count < 6`: 欄位未滿，可投入
- 重力掉落：新棋子 append 到 column array 尾端

---

## Reversi

### ReversiBoard (Struct)

| Field | Type | Description |
|-------|------|-------------|
| cells | [[CellState]] (8x8) | 8x8 棋盤 |
| currentPlayer | Player | 當前玩家 |

### CellState (Enum, Reversi)

```
CellState
├── empty   // 空格
├── black   // ⚫ (human)
└── white   // ⚪ (AI)
```

### ReversiMove (Struct, Hashable)

| Field | Type | Description |
|-------|------|-------------|
| row | Int (0-7) | 列 |
| col | Int (0-7) | 欄 |
| flips | [(row: Int, col: Int)] | 此操作會翻轉的棋子座標列表 |

### Direction Vectors (8 方向)

```
directions = [
  (-1,-1), (-1,0), (-1,1),
  (0,-1),          (0,1),
  (1,-1),  (1,0),  (1,1)
]
```

### Initial State

```
     D4=⚪  E4=⚫
     D5=⚫  E5=⚪
```

### Position Weight Matrix (AI)

```
 100  -20  10   5   5  10  -20  100
 -20  -50  -2  -2  -2  -2  -50  -20
  10   -2   1   1   1   1   -2   10
   5   -2   1   0   0   1   -2    5
   5   -2   1   0   0   1   -2    5
  10   -2   1   1   1   1   -2   10
 -20  -50  -2  -2  -2  -2  -50  -20
 100  -20  10   5   5  10  -20  100
```

---

## 2048

### Game2048Board (Struct)

| Field | Type | Description |
|-------|------|-------------|
| cells | [[Int]] (4x4) | 4x4 棋盤，0 代表空格 |
| score | Int | 目前分數 |
| hasWon | Bool | 是否已合成 2048 |

### Game2048Move (Struct, Hashable)

| Field | Type | Description |
|-------|------|-------------|
| direction | Direction | 滑動方向 |

### Direction (Enum)

```
Direction
├── up
├── down
├── left
└── right
```

### Slide & Merge Algorithm

```
Input:  [2, 0, 2, 4]
Step 1: Remove zeros → [2, 2, 4]
Step 2: Merge adjacent same → [4, 4] (score += 4)
Step 3: Pad zeros → [4, 4, 0, 0]

Input:  [2, 2, 2, 2]
Step 1: Remove zeros → [2, 2, 2, 2]
Step 2: Merge pairs left-to-right → [4, 4] (score += 4 + 4 = 8)
         (每格只合併一次)
Step 3: Pad zeros → [4, 4, 0, 0]
```

### New Tile Generation

- 90% 機率生成 2，10% 機率生成 4
- 隨機選取一個空格放入

---

## Entity Relationships

```
GameBoard (Protocol)
  ├── TicTacToeBoard (conform)
  ├── ConnectFourBoard (conform)
  ├── ReversiBoard (conform)
  └── Game2048Board (conform)

GameMove (Protocol)
  ├── TicTacToeMove (conform)
  ├── ConnectFourMove (conform)
  ├── ReversiMove (conform)
  └── Game2048Move (conform)

GameRenderer (Protocol)
  ├── TicTacToeRenderer (conform)
  ├── ConnectFourRenderer (conform)
  ├── ReversiRenderer (conform)
  └── Game2048Renderer (conform)

GameAI (Protocol)
  ├── MinimaxAI<TicTacToeBoard> (conform, depth=9)
  ├── MinimaxAI<ConnectFourBoard> (conform, depth=6-8, alpha-beta)
  └── ReversiAI (conform, weight matrix + alpha-beta depth=4-6)

GameEngine (Generic)
  └── manages: GameBoard + GameState + GameAI + GameRenderer
```

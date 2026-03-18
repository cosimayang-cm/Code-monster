# Research: Console Board Game 棋盤遊戲引擎

**Date**: 2026-02-26
**Feature**: 006-console-board-game

## Decision 1: Architecture Pattern — Protocol + Delegate（非 TCA）

**Decision**: 採用 Protocol-Oriented Programming + Delegate Pattern，不使用 TCA。

**Rationale**:
- Monster6 的核心學習目標就是 **Protocol-Oriented Programming**，使用 TCA 會削弱學習重點
- 四個遊戲共用框架的設計天然適合 Protocol 定義共通介面
- Engine 層為純 Foundation，不需要 TCA 的 Reducer/Store 機制
- Delegate Pattern 是 UIKit 標準溝通模式，更貼近 iOS 業界慣例
- 無需引入第三方套件（TCA），降低依賴風險

**Alternatives considered**:
- TCA (ComposableArchitecture)：功能強大但過於重量級，且會隱藏 Protocol 設計的學習價值
- MVVM + Combine：需要 iOS 13+ Combine 框架，與 Foundation-only 限制衝突

## Decision 2: Protocol 設計 — Associated Type + Value Semantics

**Decision**: 使用 Associated Type Protocol 搭配 struct（值語義）。

**Rationale**:
- `GameBoard` protocol 使用 `associatedtype Move` 讓每個遊戲定義自己的 Move 型別
- Board 使用 struct 而非 class：值語義讓 AI Minimax 遞迴複製棋盤時安全無副作用
- Move 使用 struct 並 conform `Hashable`：可用於 Set/Dictionary，方便 AI 快取
- 避免 NSObject/NSCopying 的 GameplayKit 風格，保持純 Swift

**Alternatives considered**:
- GameplayKit (GKGameModel)：需要 NSObject 繼承，不適合值語義設計
- Generic Class 繼承：class 有引用語義，AI 遞迴時需要手動複製，容易出錯

## Decision 3: State Machine — Enum + Throws

**Decision**: 使用 enum `GameState` + enum `GameEvent` + `throws` 錯誤處理。

**Rationale**:
- Swift enum 的 exhaustive switch 確保所有狀態轉換都被處理
- `throws` 而非 `try!` 或 silent failure：非法轉換會被捕捉，不會 crash
- Associated values 攜帶狀態資料（如 winner、current player），無需額外 flag 變數
- 編譯時安全：新增狀態後，所有未處理的 case 會產生編譯錯誤

**Alternatives considered**:
- Bool flags（isPlaying, isGameOver）：容易產生非法組合（同時 isPlaying && isGameOver）
- State 類別繼承：過度設計，enum 已經足夠表達有限狀態

## Decision 4: AI Engine — Generic Minimax 共用實作

**Decision**: 實作一個 Generic `MinimaxEngine<Board>` 供 Tic-Tac-Toe、Connect Four、Reversi 共用。

**Rationale**:
- 三款 AI 遊戲都使用 Minimax 變體（純 Minimax / Alpha-Beta Pruning）
- Generic 泛型讓一份 AI 程式碼服務三款遊戲，差異只在 `evaluate()` 評估函數
- 使用 `Double` 而非 `Int` 作為分數型別：支援 Reversi 的權重矩陣浮點運算
- 回傳 `AIResult<Move>` enum 而非 Optional：明確表達「無合法步驟」的情境

**Alternatives considered**:
- 每個遊戲各自實作 AI：程式碼重複、不符合 Protocol 學習目標
- GameplayKit GKMinmaxStrategist：需要 NSObject 相容性，無法 Foundation-only

## Decision 5: Console Renderer — String 回傳而非直接 print

**Decision**: Renderer 回傳 `String`，由呼叫端決定 `print()` 時機。

**Rationale**:
- 回傳 String 讓 Renderer 成為純函數，100% 可測試（比對字串即可）
- 呼叫端可以決定何時印出、印到哪裡（future extensibility）
- 符合 Clean Architecture：Renderer 不依賴 I/O，只做格式轉換

**Alternatives considered**:
- Renderer 內部直接 `print()`：難以測試，且違反單一職責

## Decision 6: 導航架構 — UINavigationController Push/Pop

**Decision**: Monster6 以 UINavigationController 為容器，遊戲選單 push 各遊戲 VC。

**Rationale**:
- 與現有專案 Tab + Navigation 架構一致（Monster5 也使用 Coordinator + NavigationController）
- Push/Pop 提供自然的「回選單」行為（pop to root）
- 「再玩一局」直接 reset engine state，不需要新建 VC
- 不需要 Coordinator pattern：Monster6 的導航邏輯簡單（選單 → 遊戲 → 回選單）

**Alternatives considered**:
- Modal presentation：不適合遊戲流程，缺少返回導航
- Coordinator pattern：對於單層導航過於複雜

## Decision 7: Project Structure — 模組內分層

**Decision**: `CarSystem/Monster6/` 下按遊戲分子目錄，共用框架獨立為 `Shared/`。

**Rationale**:
- 與現有 Monster5 結構一致：`Monster6/` 為頂層目錄
- `Shared/` 目錄放共用 Protocol 和泛型 AI，各遊戲目錄放具體實作
- Engine（Foundation-only）和 VC（UIKit）在同一遊戲目錄下，透過檔案 import 約束分層
- 測試目錄 `CarSystemTests/Monster6/` 按遊戲分子目錄

**Alternatives considered**:
- 獨立 Framework/Module：對學習專案過於複雜，import 約束靠 code review 足夠
- 扁平結構（所有檔案一層）：檔案數量多（約 30+），不易維護

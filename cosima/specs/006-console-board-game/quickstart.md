# Quickstart: Console Board Game 棋盤遊戲引擎

## 建置與測試

```bash
# 建置專案
xcodebuild -project CarSystem.xcodeproj -scheme CarSystem -sdk iphoneos build

# 執行所有測試
xcodebuild -project CarSystem.xcodeproj -scheme CarSystem \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15' test

# 執行 Monster6 測試（XCTest filter）
xcodebuild -project CarSystem.xcodeproj -scheme CarSystem \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:CarSystemTests/Monster6 test
```

## 新增遊戲步驟（conform Protocol）

1. 建立 `NewGameBoard: GameBoard` struct
2. 建立 `NewGameMove: GameMove` struct
3. 建立 `NewGameRenderer: GameRenderer`
4. （可選）建立 AI conform `GameAI`
5. 建立 VC，在 `GameMenuViewController` 加入新選項

## 分層規則

- `Monster6/Shared/` + 各遊戲目錄 → `import Foundation` only
- `Monster6/Views/` → `import UIKit` allowed
- 違反分層 = 編譯時不會報錯，靠 code review 把關

## 關鍵 Protocol

```swift
protocol GameBoard {
    associatedtype Move: GameMove
    var currentPlayer: Player { get }
    var isTerminal: Bool { get }
    func legalMoves() -> [Move]
    func applying(_ move: Move) -> Self  // 值語義：回傳新棋盤
    func winner() -> Player?
    func evaluate(for player: Player) -> Double
}
```

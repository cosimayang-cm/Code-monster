# Research: Undo/Redo 編輯系統

**Date**: 2026-01-22
**Feature**: 002-undo-redo-system

## Command Pattern 實作方式

### Decision
使用 Protocol + Class 結構實作 Command Pattern。

### Rationale
- Protocol 定義 `execute()` 和 `undo()` 介面
- 每個具體 Command 為 class，持有 Receiver 的 reference
- class 而非 struct，因為 Command 需要被存在 stack 中並被多次引用

### Alternatives Considered
1. **Closure-based commands**: 較彈性但難以實作 undo
2. **Enum with associated values**: 適合簡單場景，但擴展性差
3. **Protocol + Struct**: 需要 type erasure，增加複雜度

---

## 文字位置索引方式

### Decision
使用 `String.Index` 進行文字位置操作。

### Rationale
- Swift String 使用 Unicode-aware 索引
- 直接使用整數索引可能在 emoji 或組合字元上出錯
- String.Index 是 Swift 標準做法

### Alternatives Considered
1. **Int 索引 + UTF-16 offset**: 需要轉換，容易出錯
2. **Range<Int>**: 直覺但不適合 Swift String
3. **NSRange**: 需要橋接到 NSString，增加複雜度

---

## UIKit-independent 顏色表示

### Decision
自定義 `Color` struct，包含 RGBA 數值。

### Rationale
- Model 層不能 import UIKit
- 使用 `(red: Double, green: Double, blue: Double, alpha: Double)` 表示
- 可輕易轉換為 UIColor（在 UI 層）

### Alternatives Considered
1. **直接使用 CGColor**: 需要 import CoreGraphics
2. **Hex String**: 需要解析，效能較差
3. **Enum 預定義顏色**: 限制太多，不夠彈性

---

## Shape 繼承結構

### Decision
使用 Protocol + Struct 實作不同圖形類型。

### Rationale
- `Shape` protocol 定義共同介面（id, position, size, colors）
- `Rectangle`, `Circle`, `Line` 為具體 struct
- struct 適合值語意的圖形資料

### Alternatives Considered
1. **Class 繼承**: 引入不必要的複雜度
2. **Enum with associated values**: 擴展新圖形類型較麻煩
3. **Single Shape class with type property**: 不夠型別安全

---

## CommandHistory 實作細節

### Decision
使用兩個 `[Command]` array 作為 undo/redo stack。

### Rationale
- 簡單直接，用 `append` 和 `popLast` 操作
- 不需要額外的 Stack 資料結構
- Swift Array 已經是高效能的實作

### Alternatives Considered
1. **Custom Stack class**: 過度設計
2. **Linked List**: 不必要的複雜度
3. **Single array + index pointer**: 需要額外管理 index

---

## 測試策略

### Decision
每個 Command 獨立測試，搭配整合測試驗證 CommandHistory。

### Rationale
- 單元測試：每個 Command 的 execute/undo 行為
- 整合測試：CommandHistory + Commands 的互動
- 不需要 mock，直接使用真實的 Receiver

### Alternatives Considered
1. **Mock Receiver**: 增加測試複雜度，收益不大
2. **只做整合測試**: 無法精確定位問題
3. **UI 測試優先**: 違反 TDD 原則

---

---

# UI Layer Research (2026-01-23)

## Observer Pattern in Swift

### Decision
使用自定義 Protocol + 弱引用陣列實作 Observer Pattern。

### Rationale
- 不依賴 Combine 或 NotificationCenter，保持簡單
- 弱引用避免循環引用和記憶體洩漏
- 與現有 Model 層架構一致（只 import Foundation）

### Alternatives Considered
| 方案 | 優點 | 缺點 | 結論 |
|------|------|------|------|
| NotificationCenter | 內建、解耦 | 型別不安全、需字串 key | ❌ 不選 |
| Combine | 功能強大、響應式 | iOS 13+ 限制、複雜度高 | ❌ 不選 |
| Delegation | 簡單、型別安全 | 只支援一對一 | ❌ 不適用 |
| Protocol + WeakRef | 簡單、型別安全、一對多 | 需手動管理 | ✅ 選擇 |

### Implementation Pattern
```swift
protocol CommandHistoryObserver: AnyObject {
    func commandHistoryDidChange(_ history: CommandHistory)
}

struct WeakObserver {
    weak var observer: CommandHistoryObserver?
}
```

---

## UIKit Navigation Pattern

### Decision
使用 UINavigationController + push/pop 導航模式。

### Rationale
- 標準 iOS 導航模式，使用者熟悉
- 自動提供返回按鈕
- 與 Navigation Bar 右上角按鈕相容

### Implementation
```swift
// SceneDelegate
let demoVC = UndoRedoDemoViewController()
let nav = UINavigationController(rootViewController: demoVC)
window.rootViewController = nav

// Navigation
navigationController?.pushViewController(TextEditorViewController(), animated: true)
```

---

## Custom Shape Rendering

### Decision
使用 UIView + Core Graphics (draw(_:)) 繪製圖形。

### Rationale
- 純 UIKit，無需額外框架
- 完全控制繪製邏輯
- 支援所有圖形類型（矩形、圓形、線條）

### Alternatives Considered
| 方案 | 優點 | 缺點 | 結論 |
|------|------|------|------|
| CAShapeLayer | 效能好、動畫支援 | 複雜度較高 | ❌ 過度設計 |
| SpriteKit | 遊戲級效能 | 需要 SKView 容器 | ❌ 過度設計 |
| UIBezierPath + draw | 簡單、足夠 | 大量圖形時效能下降 | ✅ 選擇 |

---

## Gesture Handling for Shape Movement

### Decision
在每個 ShapeView 上加入 UIPanGestureRecognizer。

### Rationale
- 每個 ShapeView 獨立處理拖曳
- 簡化觸控區域判定
- 直接存取對應的 Shape ID

### Implementation Pattern
```swift
// In ShapeView
let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
addGestureRecognizer(pan)

@objc func handlePan(_ gesture: UIPanGestureRecognizer) {
    if gesture.state == .ended {
        delegate?.shapeView(self, didMoveBy: totalTranslation)
    }
}
```

---

## Color Conversion Strategy

### Decision
在 UI 層建立 Model Color 的 Extension。

### Rationale
- 保持 Model Color 不依賴 UIKit
- 轉換邏輯集中在 UI 層
- 簡單的計算屬性

### Implementation
```swift
// In UI/Extensions/Color+UIKit.swift
import UIKit

extension Color {
    var uiColor: UIColor {
        UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
```

---

## Text Editor Input Handling

### Decision
使用 UITextView 顯示文字 + 底部工具列按鈕觸發操作。

### Rationale
- UITextView 提供完整文字顯示功能
- 底部工具列明確展示可用操作
- 避免攔截原生鍵盤輸入的複雜性

### Note
此 Demo 使用按鈕觸發操作，而非攔截使用者的即時輸入，以簡化展示 Command Pattern 的核心概念。

---

## UI Layer Resolved Clarifications

| 原始問題 | 決定 | 來源 |
|----------|------|------|
| Observer 機制選擇 | 自定義 Protocol + WeakRef | 研究結論 |
| 圖形繪製方式 | UIView + Core Graphics | 研究結論 |
| 導航架構 | UINavigationController | 標準實務 |
| 顏色轉換位置 | UI 層 Extension | 架構分層要求 |

---

## No Unresolved Issues

所有技術選擇已確定（Model 層 + UI 層），無需進一步釐清。

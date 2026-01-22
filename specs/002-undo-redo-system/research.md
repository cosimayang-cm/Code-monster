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

## No Unresolved Issues

所有技術選擇已確定，無需進一步釐清。

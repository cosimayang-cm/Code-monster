# CLAUDE.md - Project Instructions

## 專案概述
這是一個 iOS 學習專案，透過實作不同設計模式來學習軟體架構。

## 目前功能模組
1. **Code Monster #1**: Feature Toggle 車輛系統 - 學習依賴管理與功能開關
2. **Code Monster #2**: Popup Chain 彈窗連鎖機制 - 學習責任鏈模式
3. **Code Monster #3**: Undo/Redo 系統 - 學習 Command Pattern 與 Memento Pattern（進行中）

## 架構規範

### 分層限制
| 層級 | 允許的 import | 說明 |
|------|---------------|------|
| Model / Command / History | `Foundation` only | 純邏輯層，不可依賴 UI 框架 |
| ViewModel | `Foundation`, `UIKit` (可選) | 可做資料轉換 |
| ViewController | `Foundation`, `UIKit` | UI 層 |

### 命名慣例
- Protocol: 名詞或形容詞 (`Command`, `PopupHandler`)
- Class/Struct: 名詞 (`TextDocument`, `Canvas`)
- Command: 動詞 + 名詞 + Command (`InsertTextCommand`, `AddShapeCommand`)

### 測試規範
- 所有 Foundation only 層的類別必須有對應的單元測試
- 測試檔案放在 `CarSystemTests/` 對應目錄下
- 使用 XCTest 框架

## Spec 文件位置
所有功能規格文件放在 `specs/` 目錄下，以編號命名：
- `specs/001-popup-chain/` - 彈窗連鎖機制
- `specs/002-undo-redo-system/` - Undo/Redo 系統

## 常用指令
```bash
# 建置專案
xcodebuild -project CarSystem.xcodeproj -scheme CarSystem -sdk iphoneos build

# 執行測試
xcodebuild -project CarSystem.xcodeproj -scheme CarSystem -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' test
```

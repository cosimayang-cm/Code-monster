# Implementation Plan: 彈窗連鎖顯示機制 (Popup Response Chain)

**Branch**: `feature/monster2-popup-chain` | **Date**: 2026-01-16 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/monster2-popup-chain/spec.md`

## Summary

實現一個彈窗連鎖顯示機制，當用戶進入主畫面時，系統按照優先順序（新手教學 > 插頁式廣告 > 新功能公告 > 每日簽到 > 猜多空結果）依序檢查並顯示彈窗。採用 Protocol-Oriented Programming 設計，使用 Chain of Responsibility 模式處理彈窗序列，Combine 管理狀態，UserDefaults 持久化用戶彈窗狀態。

## Technical Context

**Language/Version**: Swift 5.0+
**Primary Dependencies**: UIKit, Combine
**Storage**: UserDefaults (本地存儲用戶彈窗狀態)
**Testing**: XCTest + Combine Testing
**Target Platform**: iOS 15.0+
**Project Type**: Mobile (iOS)
**Performance Goals**: 首個彈窗 <1秒顯示，彈窗切換 <0.5秒
**Constraints**: 單次最多顯示 3 個彈窗，單機離線模式
**Scale/Scope**: 5 種彈窗類型，可擴展架構

## Constitution Check

*GATE: Constitution 尚未定義具體規則，跳過此檢查*

- [ ] Constitution 未填寫實際內容（仍為模板狀態）
- [x] 採用現有專案的 Protocol-Oriented 架構風格
- [x] 遵循現有 Combine 狀態管理模式
- [x] 使用 Result<T, Error> 錯誤處理模式

## Project Intelligence Scan Results

### 可重用元件矩陣

| 現有元件 | 位置 | 重用方式 |
|---------|------|---------|
| `CarComponent` Protocol | Models/CarComponent.swift | 作為 `PopupChainItem` 協議模板 |
| `ToggleableComponent` Protocol | Models/CarComponent.swift | 作為 `PopupHandler` 協議模板 |
| `cascadeDisable()` 邏輯 | Car.swift | 適配為彈窗鏈序列邏輯 |
| `Result<Void, Error>` 模式 | Car.swift | 用於彈窗顯示結果處理 |
| Combine bindings | Car.swift | 用於彈窗佇列狀態管理 |
| `FeatureError` 枚舉 | FeatureError.swift | 作為 `PopupChainError` 模板 |

### 架構模式觀察

- **Protocol-Oriented Programming (POP)**: 主要設計原則
- **Observer Pattern** (via Combine): 狀態變更自動觸發 UI 更新
- **Facade Pattern**: 高階 API 隱藏複雜度
- **Self-Describing Components**: 元件包含所有配置資訊

### 整合建議

1. 新增 `PopupChain/` 模組於 `CarSystem/` 下
2. 沿用現有 Protocol + Combine 模式
3. 新增 UserDefaults 持久化層（現有專案無此實作）

## Project Structure

### Documentation (this feature)

```text
specs/monster2-popup-chain/
├── spec.md              # Feature specification
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   └── popup-chain-protocol.swift
└── tasks.md             # Phase 2 output (by /speckit.tasks)
```

### Source Code (repository root)

```text
CarSystem/
├── Models/
│   ├── CarComponent.swift         # 現有 - 可參考
│   ├── FeatureError.swift         # 現有 - 可參考
│   └── ...
├── PopupChain/                    # 新增模組
│   ├── Protocols/
│   │   ├── PopupChainItem.swift   # 彈窗項目協議
│   │   └── PopupHandler.swift     # 彈窗處理器協議
│   ├── Models/
│   │   ├── PopupType.swift        # 彈窗類型枚舉
│   │   ├── PopupChainError.swift  # 錯誤類型
│   │   └── PopupState.swift       # 用戶彈窗狀態
│   ├── Handlers/
│   │   ├── TutorialPopupHandler.swift      # 新手教學
│   │   ├── InterstitialAdHandler.swift     # 插頁式廣告
│   │   ├── NewFeaturePopupHandler.swift    # 新功能公告
│   │   ├── DailyCheckInHandler.swift       # 每日簽到
│   │   └── PredictionResultHandler.swift   # 猜多空結果
│   ├── Services/
│   │   ├── PopupChainManager.swift         # 彈窗鏈管理器
│   │   └── PopupStateStorage.swift         # UserDefaults 存儲
│   └── Views/
│       └── PopupPresenter.swift            # 彈窗呈現器
└── CarViewController.swift        # 整合入口

CarSystemTests/
└── PopupChainTests/               # 新增測試
    ├── PopupChainManagerTests.swift
    ├── PopupStateStorageTests.swift
    └── PopupHandlerTests.swift
```

**Structure Decision**: 採用 Mobile (iOS) 結構，新增 `PopupChain/` 模組於現有 `CarSystem/` 專案中，保持與現有架構風格一致。

## Complexity Tracking

> 無違反 Constitution 的情況（Constitution 未定義）

| Aspect | Decision | Rationale |
|--------|----------|-----------|
| Chain of Responsibility | 採用 | 符合彈窗依序處理需求，與現有 cascadeDisable 模式相似 |
| Protocol-Oriented | 採用 | 沿用現有專案風格，確保一致性 |
| UserDefaults | 採用 | 單機模式下最簡單的持久化方案 |

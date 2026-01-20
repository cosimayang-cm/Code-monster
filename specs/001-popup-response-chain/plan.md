# Implementation Plan: Popup Response Chain System

**Branch**: `001-popup-response-chain` | **Date**: 2026-01-16 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-popup-response-chain/spec.md`

## Summary

實作一個基於 Chain of Responsibility 設計模式的彈窗連鎖顯示系統。當用戶進入主畫面時，系統依優先順序檢查並顯示彈窗（Tutorial → Interstitial Ad → New Feature → Daily Check-in → Prediction Result），每次只顯示一個，關閉後繼續檢查下一個。系統需支援狀態持久化、多帳號隔離、錯誤降級處理，並遵循 SOLID 原則以便擴展。

## Technical Context

**Language/Version**: Swift 5.9+
**Primary Dependencies**: UIKit, Foundation
**Storage**: UserDefaults (encapsulated via Repository pattern)
**Testing**: XCTest
**Target Platform**: iOS 15.0+
**Project Type**: Mobile (iOS native)
**Performance Goals**: 彈窗鏈檢查 < 20ms；Repository 讀寫 < 10ms；彈窗過渡延遲 0.3-0.5s
**Constraints**: 單次 App 啟動只觸發一次彈窗鏈；僅按鈕關閉彈窗；錯誤時繼續執行不中斷
**Scale/Scope**: 5 種彈窗類型；支援多帳號；測試覆蓋 50+ 測試案例

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

> 注意：專案 constitution.md 尚未配置，以下根據規格文件中的架構原則進行檢查：

| 原則 | 狀態 | 說明 |
|------|------|------|
| SOLID 原則 | ✅ Pass | Chain of Responsibility 符合 OCP；Repository 抽象符合 DIP |
| 可測試性 | ✅ Pass | 所有依賴透過建構子注入，支援 Mock 替換 |
| 單一職責 | ✅ Pass | 每個 Handler 只負責一種彈窗 |
| 錯誤處理 | ✅ Pass | Result Type 處理錯誤，降級策略明確 |
| 無全域狀態 | ✅ Pass | 無 Singleton，狀態透過 Repository 管理 |

**Gate Result**: ✅ PASS - 可進入 Phase 0

## Project Structure

### Documentation (this feature)

```text
specs/001-popup-response-chain/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
PopupChain/
├── Models/
│   ├── PopupType.swift
│   ├── PopupState.swift
│   ├── PopupContext.swift
│   ├── PopupError.swift
│   ├── PopupEvent.swift
│   └── UserInfo.swift
├── Protocols/
│   ├── PopupHandler.swift
│   ├── PopupStateRepository.swift
│   ├── PopupPresenter.swift
│   ├── PopupEventObserver.swift
│   └── Logger.swift
├── Handlers/
│   ├── BasePopupHandler.swift
│   ├── TutorialPopupHandler.swift
│   ├── InterstitialAdPopupHandler.swift
│   ├── NewFeaturePopupHandler.swift
│   ├── DailyCheckInPopupHandler.swift
│   └── PredictionResultPopupHandler.swift
├── Repositories/
│   ├── InMemoryPopupStateRepository.swift
│   └── UserDefaultsPopupStateRepository.swift
├── Services/
│   ├── PopupChainManager.swift
│   └── PopupEventPublisher.swift
└── UI/
    ├── PopupViews/
    │   ├── TutorialPopupView.swift
    │   ├── InterstitialAdPopupView.swift
    │   ├── NewFeaturePopupView.swift
    │   ├── DailyCheckInPopupView.swift
    │   └── PredictionResultPopupView.swift
    └── PopupDebugViewController.swift

PopupChainTests/
├── HandlerTests/
│   ├── TutorialPopupHandlerTests.swift
│   ├── InterstitialAdPopupHandlerTests.swift
│   ├── NewFeaturePopupHandlerTests.swift
│   ├── DailyCheckInPopupHandlerTests.swift
│   └── PredictionResultPopupHandlerTests.swift
├── RepositoryTests/
│   ├── InMemoryPopupStateRepositoryTests.swift
│   └── UserDefaultsPopupStateRepositoryTests.swift
├── ServiceTests/
│   ├── PopupChainManagerTests.swift
│   └── PopupEventPublisherTests.swift
├── IntegrationTests/
│   ├── PopupChainIntegrationTests.swift
│   └── MultiAccountIsolationTests.swift
└── Mocks/
    ├── MockPopupStateRepository.swift
    ├── MockPopupPresenter.swift
    ├── MockLogger.swift
    └── SpyPopupEventObserver.swift
```

**Structure Decision**: 採用 iOS 單一模組結構，按職責分層（Models/Protocols/Handlers/Repositories/Services/UI），測試與原始碼平行組織。

## Complexity Tracking

> 無違規需要記錄 - 架構遵循既定原則

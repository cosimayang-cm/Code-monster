# Code Monster 作業2：彈窗連鎖顯示機制 (Popup Response Chain)

這是 Code Monster 練習系列的第二個作業。

## 作業主題

實作一個彈窗連鎖顯示系統，包含：
- 使用 Chain of Responsibility 設計模式
- 依優先順序檢查並顯示彈窗
- 可擴展的 Handler 架構

## 作業來源

[Monster 2 題目](../../CodeMonsters/monster2.md)

## 檔案說明

```
monster2/
├── README.md                      # 本檔案
├── spec.md                        # 功能規格文件
├── plan.md                        # 實作規劃（Pseudocode）
├── checklists/
│   └── requirements.md            # 規格品質檢查清單
├── Package.swift                  # Swift Package 配置（待建立）
├── Sources/
│   ├── Protocols/
│   │   └── PopupHandler.swift     # Handler Protocol
│   ├── Handlers/
│   │   ├── BasePopupHandler.swift
│   │   ├── TutorialHandler.swift
│   │   ├── InterstitialAdHandler.swift
│   │   ├── NewFeatureHandler.swift
│   │   ├── DailyCheckInHandler.swift
│   │   └── PredictionResultHandler.swift
│   ├── Models/
│   │   └── UserContext.swift
│   └── PopupChainManager.swift
└── Tests/
    ├── HandlerTests/
    └── PopupChainManagerTests.swift
```

## 開發進度

- [x] 規格定義 (spec.md)
- [x] 實作規劃 (plan.md)
- [ ] 程式碼實作
- [ ] 單元測試
- [ ] 整合測試

## 執行測試

```bash
swift test
```

# PopupChain - 彈窗連鎖顯示系統

## 作業 #2 實作

此資料夾包含 Monster #2 的所有實作代碼。

## 架構規劃

```
PopupChain/
├── Models/                    # 資料模型
│   ├── PopupType.swift
│   ├── PopupState.swift
│   ├── UserInfo.swift
│   ├── PopupContext.swift
│   └── PopupError.swift
│
├── Protocols/                 # 協議定義
│   ├── PopupHandler.swift
│   ├── PopupStateRepository.swift
│   ├── PopupPresenter.swift
│   ├── PopupEventObserver.swift
│   └── Logger.swift
│
├── Handlers/                  # 具體 Handler 實作
│   ├── BasePopupHandler.swift
│   ├── TutorialPopupHandler.swift
│   ├── InterstitialAdHandler.swift
│   ├── NewFeatureHandler.swift
│   ├── DailyCheckInHandler.swift
│   └── PredictionResultHandler.swift
│
├── Repositories/              # 狀態儲存實作
│   ├── InMemoryPopupStateRepository.swift
│   └── UserDefaultsPopupStateRepository.swift (可選)
│
├── Managers/                  # 管理器
│   ├── PopupChainManager.swift
│   └── PopupEventPublisher.swift
│
├── Simulators/                # 測試工具
│   └── UserStateSimulator.swift
│
├── UI/                        # UI 元件
│   └── PopupDebugViewController.swift
│
└── README.md                  # 本文件
```

## 開發狀態

🚧 **準備開始** - 資料夾結構已建立

## 參考文檔

- 規格文檔: `../../../#2/plan-popupResponseChain.prompt.md`
- 原始需求: `../../../#2/monster2.md`

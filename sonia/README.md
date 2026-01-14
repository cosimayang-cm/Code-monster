# Code Monster - Swift 實作練習

## 作業清單

### ✅ #1 - Car System
**主題**: 汽車組裝系統 - 依賴管理與組件生命週期

- 📁 規格文件: [#1/](https://github.com/path-to-repo/tree/main/%231)
- 💾 實作項目: [CodeMonster/CodeMonster/CarSystem/](CodeMonster/CodeMonster/CarSystem/)
- 📋 詳細說明: [#1/README.md](./%231/README.md)

**核心技術**:
- Builder Pattern
- Repository Pattern
- Observer Pattern
- Dependency Injection

**狀態**: ✅ 已完成並歸檔

---

### 🚧 #2 - Popup Response Chain System
**主題**: 彈窗連鎖顯示系統 - 責任鏈與多帳號管理

- 📁 規格文件: [#2/](https://github.com/path-to-repo/tree/main/%232)
- 📋 執行規格: [#2/plan-popupResponseChain.prompt.md](./%232/plan-popupResponseChain.prompt.md)
- � 實作項目: [CodeMonster/CodeMonster/PopupChain/](CodeMonster/CodeMonster/PopupChain/)
- �📋 詳細說明: [#2/README.md](./%232/README.md)

**核心技術**:
- Chain of Responsibility Pattern
- Repository Pattern (Multi-account)
- Observer Pattern
- UIKit

**狀態**: 🚧 Spec 完成，準備開始實作

---

## 目錄結構

```
sonia/
├── #1/                          # 作業 #1 規格文件
│   ├── monster1.md
│   ├── monster1-improvements.md
│   └── README.md
│
├── #2/                          # 作業 #2 規格文件
│   ├── monster2.md
│   ├── plan-popupResponseChain.prompt.md
│   └── README.md
│
├── CodeMonster/                 # Xcode 實作項目
│   ├── CodeMonster/            # 源代碼文件夾
│   │   ├── CarSystem/         # #1 實作（已完成）
│   │   │   ├── Car.swift
│   │   │   ├── Components/
│   │   │   ├── Managers/
│   │   │   ├── Models/
│   │   │   ├── Protocols/
│   │   │   └── Services/
│   │   └── PopupChain/        # #2 實作（進行中）
│   │       ├── Models/
│   │       ├── Protocols/
│   │       ├── Handlers/
│   │       ├── Repositories/
│   │       ├── Managers/
│   │       ├── Simulators/
│   │       └── UI/
│   ├── CodeMonster.xcodeproj/
│   ├── CodeMonsterTests/
│   └── CodeMonsterUITests/
│
└── README.md                    # 本文件
```

## 開發環境

- **語言**: Swift 5.9+
- **平台**: iOS 15.0+
- **開發工具**: Xcode 15.0+
- **測試框架**: XCTest

## 設計原則

所有作業遵循以下原則：
- ✅ SOLID 原則
- ✅ Protocol-Oriented Programming
- ✅ Dependency Injection
- ✅ TDD（測試驅動開發）
- ❌ 禁止 Singleton
- ❌ 禁止全局變量
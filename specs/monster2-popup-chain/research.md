# Research: 彈窗連鎖顯示機制 (Popup Response Chain)

**Date**: 2026-01-16
**Feature**: [spec.md](./spec.md)

## Research Summary

本研究針對彈窗連鎖機制的技術實作進行調研，基於現有 Cosima 專案架構（UIKit + Combine + POP）提出設計決策。

---

## 1. 彈窗鏈設計模式

### Decision: Chain of Responsibility Pattern + Array-based Priority

**Rationale**:
- 現有專案已有 `cascadeDisable()` 類似邏輯，可直接適配
- 每個彈窗處理器獨立判斷顯示條件（FR-008）
- 支援新增/移除彈窗類型而不需大幅修改（FR-006）
- 彈窗依序執行，符合「同一時間只顯示一個」需求（FR-003）
- **陣列順序即優先順序**，無需數字屬性，擴展更簡單

**Priority Strategy**:
- 不使用數字優先順序（避免插入困難、魔術數字問題）
- handlers 陣列索引即優先順序，索引越小越優先
- 新增彈窗只需插入陣列正確位置

**Alternatives Considered**:
| 方案 | 優點 | 缺點 | 結論 |
|------|------|------|------|
| State Machine | 狀態轉換明確 | 狀態爆炸風險，擴展困難 | 不採用 |
| Command Queue | 簡單直觀 | 無法獨立判斷條件 | 不採用 |
| Numeric Priority | 排序靈活 | 插入困難、魔術數字 | 不採用 |
| **Array Order Priority** | 直觀、易擴展 | 需維護陣列順序 | **採用** |

---

## 2. 狀態管理方案

### Decision: Combine + ObservableObject

**Rationale**:
- 現有專案 `Car` 類已使用此模式，保持一致性
- `@Published` 屬性自動觸發 UI 更新
- 可輕鬆實現彈窗佇列狀態訂閱

**Implementation Pattern** (from existing codebase):
```swift
class PopupChainManager: ObservableObject {
    @Published private(set) var currentPopup: PopupType?
    @Published private(set) var displayedCount: Int = 0

    private var cancellables = Set<AnyCancellable>()
}
```

**Alternatives Considered**:
| 方案 | 優點 | 缺點 | 結論 |
|------|------|------|------|
| **Combine** | 現有專案已用 | - | **採用** |
| NotificationCenter | iOS 原生 | 鬆散耦合，難追蹤 | 不採用 |
| Delegate Pattern | 簡單 | 1:1 限制，擴展性差 | 不採用 |

---

## 3. 本地存儲方案

### Decision: UserDefaults + Codable

**Rationale**:
- App 為單機模式，無需複雜同步機制
- UserDefaults 適合小量狀態資料（彈窗狀態 <1KB）
- Codable 提供類型安全的序列化

**Data Structure**:
```swift
struct PopupUserState: Codable {
    var hasSeenTutorial: Bool = false
    var lastCheckInDate: Date?
    var lastAdShownDate: Date?
    var seenFeatureAnnouncements: Set<String> = []
    var notifiedPredictionResults: Set<String> = []
}
```

**Alternatives Considered**:
| 方案 | 優點 | 缺點 | 結論 |
|------|------|------|------|
| **UserDefaults** | 簡單、足夠 | 不適合大量資料 | **採用** |
| CoreData | 功能強大 | 過度設計 | 不採用 |
| Keychain | 安全 | 非敏感資料不需要 | 不採用 |
| File-based JSON | 簡單 | 需自行管理檔案 | 不採用 |

---

## 4. 彈窗 UI 呈現方案

### Decision: Protocol-based Presenter + UIAlertController/Custom Views

**Rationale**:
- 不同彈窗可能需要不同 UI（Alert vs Custom View）
- Protocol 統一介面，各彈窗自行實作呈現邏輯
- 現有專案已有 `showAlert()` 基礎可擴展

**Protocol Design**:
```swift
protocol PopupPresentable {
    func present(on viewController: UIViewController, completion: @escaping (PopupResult) -> Void)
    func dismiss(animated: Bool)
}
```

**Alternatives Considered**:
| 方案 | 優點 | 缺點 | 結論 |
|------|------|------|------|
| **Protocol-based** | 靈活、可擴展 | 需定義協議 | **採用** |
| 統一 AlertController | 簡單 | 客製化受限 | 不採用 |
| SwiftUI Sheets | 現代化 | 現專案為 UIKit | 不採用 |

---

## 5. 錯誤處理模式

### Decision: Result<Void, PopupChainError>

**Rationale**:
- 現有專案 `Car.enable()` 已使用此模式
- 類型安全，編譯時期檢查
- 明確區分成功/失敗情境

**Error Types**:
```swift
enum PopupChainError: Error, LocalizedError {
    case maxPopupsReached       // 已達 3 個上限
    case popupDisplayFailed     // 顯示失敗（FR-011: 跳過不重試）
    case chainInterrupted       // 鏈被中斷
    case storageError           // 存儲錯誤

    var errorDescription: String? { ... }
}
```

---

## 6. 測試策略

### Decision: XCTest + Combine Testing

**Rationale**:
- 現有專案使用 XCTest
- Combine 提供 `XCTestExpectation` 整合
- 可測試非同步彈窗序列

**Test Categories**:
1. **Unit Tests**: 各 Handler 的條件判斷
2. **Integration Tests**: 完整彈窗鏈流程
3. **State Tests**: UserDefaults 持久化驗證

---

## 7. 效能考量

### Decision: Lazy Evaluation + Pre-check

**Rationale**:
- SC-001 要求首個彈窗 <1秒顯示
- SC-002 要求切換 <0.5秒

**Optimization Strategies**:
1. **Lazy Handler Initialization**: 僅在需要時初始化 Handler
2. **Pre-computed Conditions**: 進入主畫面時預先計算所有條件
3. **Background State Loading**: UserDefaults 讀取在背景執行

---

## Research Conclusion

| 領域 | 決策 | 信心度 |
|------|------|--------|
| 設計模式 | Chain of Responsibility | High |
| 狀態管理 | Combine + ObservableObject | High |
| 本地存儲 | UserDefaults + Codable | High |
| UI 呈現 | Protocol-based Presenter | High |
| 錯誤處理 | Result<T, Error> | High |
| 測試策略 | XCTest + Combine | High |

**所有 NEEDS CLARIFICATION 已解決，可進入 Phase 1 設計階段。**

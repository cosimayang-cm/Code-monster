# CodeMonster #2 - Popup Response Chain System

## 作業說明

實作一個彈窗連鎖顯示系統，使用 Chain of Responsibility 設計模式，支援多帳號狀態管理與彈窗優先順序控制。

## 文件

- [monster2.md](monster2.md) - 原始需求規格
- [plan-popupResponseChain.prompt.md](plan-popupResponseChain.prompt.md) - 完整執行規格與實作計劃

## 核心需求

### 彈窗類型（5 種）
1. **Tutorial** - 新手教學（僅新手看，看完即結束）
2. **InterstitialAd** - 廣告 A（老手未看過時顯示）
3. **NewFeature** - 廣告 B（老手已看過廣告 A 時顯示）
4. **DailyCheckIn** - 每日簽到（老手流程）
5. **PredictionResult** - 猜多空（老手流程）

### 業務流程

**新手**：Tutorial → 結束（直接回主畫面）

**老手**：
1. 廣告判斷（A/B 互斥）→ 2. 簽到檢查 → 3. 猜多空檢查

### 設計模式
- ✅ Chain of Responsibility（核心模式）
- ✅ Repository Pattern（狀態管理）
- ✅ Observer Pattern（事件通知）
- ✅ Dependency Injection（依賴注入）

### 技術約束
- **語言**: Swift 5.9+
- **平台**: iOS 15.0+
- **UI 框架**: UIKit（不使用 SwiftUI）
- **測試框架**: XCTest
- **禁止**: Singleton, 全局變量, 硬編碼依賴

## 實作階段（Phase 0-5）

### Phase 0: Spec Validation [P0]
- Spec 審查與邏輯驗證

### Phase 1: 核心基礎架構 [P0]
- Chain of Responsibility 實作
- 5 個 Handler 實作
- 20+ 單元測試

### Phase 2: 狀態管理與持久化 [P0]
- 多帳號支援（memberId 隔離）
- InMemoryPopupStateRepository
- UserStateSimulator
- 25+ Repository 測試

### Phase 3: 錯誤處理與降級策略 [P1]
- Result Type 錯誤處理
- 降級策略（失敗繼續）
- 10+ 錯誤處理測試

### Phase 4: Observer Pattern 整合 [P1]
- 事件發布系統
- UI 監聽彈窗事件
- 10+ Observer 測試

### Phase 5: 開發者測試控制台 [P1]
- PopupDebugViewController（UIKit）
- 6 個預設角色按鈕
- 自動遞增 memberId
- 雙重重置功能

## 多帳號支援

### UserInfo 模型
```swift
struct UserInfo {
    let memberId: String              // 整數序列（測試用）
    let isNewUser: Bool               // 新手 vs 老手
    let hasSeenTutorial: Bool
    let hasSeenAd: Bool               // 廣告 A
    let hasSeenNewFeature: Bool       // 廣告 B
    let lastCheckInDate: Date?
    let hasCompletedPrediction: Bool
}
```

### 5 個預設角色
1. **newUser** (memberId="1") - 新手，未看過任何內容
2. **returningUser** (memberId="2") - 老手，未看過廣告 A
3. **experiencedUser** (memberId="3") - 老手，已看過廣告 A，會看廣告 B
4. **checkedInUser** (memberId="4") - 已簽到，未猜多空
5. **allCompletedUser** (memberId="5") - 所有流程完成

## 驗收標準

- [ ] 50+ 單元測試通過
- [ ] 多帳號狀態隔離正確
- [ ] 同帳號登出重登狀態保留
- [ ] 換帳號登入視為全新用戶
- [ ] 新手只看教學即結束
- [ ] 老手廣告 A/B 互斥邏輯正確
- [ ] UI 測試控制台功能完整
- [ ] 符合 SOLID 原則
- [ ] 無 Singleton 或全局變量

## 實作項目

**位置**: `../CodeMonster/CodeMonster/PopupChain/`

在 CodeMonster 專案中的 PopupChain 文件夾內，與 #1 CarSystem 共用同一個 Xcode 專案。

## 狀態

🚧 **進行中** - Spec 完成，準備開始實作

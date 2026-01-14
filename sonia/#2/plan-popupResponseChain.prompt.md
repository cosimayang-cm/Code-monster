# Monster2 Spec 審查報告與執行規格

## 📋 Monster2.md Spec 審查報告

根據「AI 协作高效 Spec 撰写指南」進行全面審查：

### 🔴 Critical Issues（必須修正）

#### 1. **缺少 Phase 0 - Spec Validation**
- 當前直接進入設計要求，未經審查
- 建議：先定義完整需求，再進行驗證

#### 2. **邊界條件未定義**
- ❌ 當用戶在彈窗顯示過程中離開 App，再次進入如何處理？
- ❌ 彈窗顯示失敗（網路錯誤、資源載入失敗）如何處理？
- ❌ 用戶快速點擊「關閉」，尚未檢查下一個條件就離開？
- ❌ 同一彈窗「已看過」的判定標準？（點擊關閉？完整顯示 3 秒？）

#### 3. **狀態儲存機制未說明**
- ❌ 「已看過」狀態如何持久化？（UserDefaults? CoreData? Keychain?）
- ❌ 「今日簽到」如何判定？（本地時間？伺服器時間？）
- ❌ 「猜多空結果產生」如何得知？（輪詢？推播？本地儲存?）

#### 4. **錯誤處理策略缺失**
- ❌ 資料來源（Repository）讀取失敗如何處理？
- ❌ 彈窗顯示元件（Presenter）創建失敗如何處理？
- ❌ 是否需要降級策略？（例如：新功能公告載入失敗，跳過繼續檢查簽到）

### ⚠️ Important Issues（強烈建議修正）

#### 5. **缺少多格式依賴描述**
- ✅ 有流程圖（視覺化）
- ✅ 有表格（優先順序）
- ❌ **缺少代碼形式**（直接可用的數據結構）

#### 6. **缺少量化驗收標準**
- ❌ 未定義測試數量目標（建議：50+ tests）
- ❌ 未定義代碼質量標準（行數、複雜度）
- ❌ 未說明 SOLID 原則檢查點

#### 7. **缺少使用範例**
- ❌ 無 Happy Path 範例（正常流程）
- ❌ 無 Unhappy Path 範例（錯誤處理）
- ❌ 無 Edge Cases 範例（邊界情況）

#### 8. **優先級與時程未定義**
- ❌ 未標註 P0/P1/P2 優先級
- ❌ 未估計各階段時間
- ❌ 未說明時間不足時的取捨策略

### ℹ️ Nice to Have（可選改進）

#### 9. **技術約束不夠明確**
- ⚠️ 未指定 iOS 版本、Swift 版本
- ⚠️ 未禁止特定技術（例如：Singleton、全局變量）
- ⚠️ 未說明是否使用第三方套件

#### 10. **UI 互動細節不清楚**
- ⚠️ 彈窗樣式？（Modal? Alert? Custom View?）
- ⚠️ 關閉方式？（按鈕? 點擊背景? 自動消失?）
- ⚠️ 動畫效果需求？

---

## 📝 執行 Spec - Popup Response Chain System

> 基於 Chain of Responsibility 設計模式的彈窗連鎖顯示系統

---

## 0. 項目概述

### 背景
當用戶重新打開 App 並進入主畫面後，系統需要依照優先順序檢查各種彈窗的顯示條件，同一時間只顯示一個彈窗，用戶關閉後繼續檢查下一個。

### 目標
實作一個可擴展、易測試、符合 SOLID 原則的彈窗連鎖顯示系統。

### 預期成果
- 50+ 單元測試通過
- 完整的責任鏈實作
- 支援 5 種彈窗類型
- 可輕易擴展新彈窗

---

## 1. 實作計劃（Phase-based Roadmap）

### Phase 0: Spec Validation 🔍 [P0 - 必要]

**目標**: 確保 Spec 邏輯正確、完整、清晰

**預期成果**: 無矛盾、無模糊、邊界條件完整的 Spec

**AI 審查任務**:
1. 檢查業務邏輯矛盾
   - 責任鏈順序是否合理？
   - 狀態轉換流程是否完整？
   - 是否有相互衝突的規則？
2. 確認邊界條件完整性
   - App 生命週期影響（進入背景、重新進入）
   - 網路錯誤處理
   - 狀態讀寫失敗處理
3. 驗證狀態管理策略
   - 持久化方案合理性
   - 「已看過」判定標準明確性
   - 時間相關判定（簽到、日期）
4. 確認錯誤處理完整性
   - 各環節的失敗處理
   - 降級策略
   - 用戶體驗保證

**驗收標準**:
- [ ] 無邏輯矛盾（責任鏈正確、狀態一致）
- [ ] 無模糊描述（術語統一、需求明確）
- [ ] 邊界條件完整定義
- [ ] 錯誤處理策略完整
- [ ] 架構方向確認（Chain of Responsibility + Repository + Observer）
- [ ] Phase 劃分合理（5-6 個階段）

**輸出**:
- Spec 審查報告（矛盾、模糊、遺漏清單）
- 架構建議（設計模式、技術選型）
- 修正後的 Spec（如有需要）

**時間估計**: 1 session  
**依賴**: 無

---

### Phase 1: 核心基礎架構 [P0 - 必要]

**目標**: 建立 Chain of Responsibility 基礎框架

**預期成果**: 可運作的責任鏈，20+ 單元測試通過

**驗收標準**:
- [ ] `PopupHandler` 協議定義完成
- [ ] `PopupType` 枚舉定義（5 種彈窗）
- [ ] `PopupContext` 上下文結構定義
- [ ] `BasePopupHandler` 抽象實作
- [ ] 5 個具體 Handler 實作完成
  - `TutorialPopupHandler`
  - `InterstitialAdPopupHandler`
  - `NewFeaturePopupHandler`
  - `DailyCheckInPopupHandler`
  - `PredictionResultPopupHandler`
- [ ] `PopupChainManager` 實作完成
- [ ] 20+ XCTest 測試通過
- [ ] 責任鏈串接正確（按優先順序）

**實作清單**:
1. [ ] 定義 `PopupType` 枚舉
   ```swift
   enum PopupType: String, CaseIterable {
       case tutorial          // 新手教學（首次顯示後終止鏈，已看過則跳過）
       case interstitialAd    // 廣告 A - 插頁廣告（未看過時顯示）
       case newFeature        // 廣告 B - 新功能公告（已看過廣告 A 時顯示）
       case dailyCheckIn      // 每日簽到（今日未簽到時顯示）
       case predictionResult  // 猜多空結果（有結果且未看過時顯示）
   }
   ```
2. [ ] 定義 `UserInfo` 模型（用戶身份與彈窗狀態）
   ```swift
   /// 用戶資訊模型（包含身份與彈窗狀態）
   /// 注意：測試環境使用整數序列 memberId（1, 2, 3...）確保可重現性
   ///      生產環境應使用後端 API 提供的真實會員 ID
   struct UserInfo {
       let memberId: String
       let isNewUser: Bool              // 是否為新用戶（用於統計，不影響流程）
       let hasSeenTutorial: Bool        // 已看過新手教學（關鍵：false = 顯示後終止鏈）
       let hasSeenAd: Bool              // 已看過廣告 A（interstitialAd）
       let hasSeenNewFeature: Bool      // 已看過廣告 B（newFeature）
       let lastCheckInDate: Date?       // 最後簽到日期
       let hasCompletedPrediction: Bool // 今日是否已完成猜多空
       
       // MARK: - 測試用預設角色（固定 ID 確保測試可重現）
       
       static let newUser = UserInfo(
           memberId: "1",
           isNewUser: true,
           hasSeenTutorial: false,
           hasSeenAd: false,
           hasSeenNewFeature: false,
           lastCheckInDate: nil,
           hasCompletedPrediction: false
       )
       
       static let returningUser = UserInfo(
           memberId: "2",
           isNewUser: false,
           hasSeenTutorial: true,
           hasSeenAd: false,           // 未看過廣告 A，會顯示 interstitialAd
           hasSeenNewFeature: false,
           lastCheckInDate: Date().addingTimeInterval(-86400 * 7),
           hasCompletedPrediction: false
       )
       
       static let experiencedUser = UserInfo(
           memberId: "3",
           isNewUser: false,
           hasSeenTutorial: true,
           hasSeenAd: true,            // 已看過廣告 A，會顯示 newFeature（廣告 B）
           hasSeenNewFeature: false,
           lastCheckInDate: Date().addingTimeInterval(-86400),
           hasCompletedPrediction: false
       )
       
       static let checkedInUser = UserInfo(
           memberId: "4",
           isNewUser: false,
           hasSeenTutorial: true,
           hasSeenAd: true,
           hasSeenNewFeature: true,
           lastCheckInDate: Date(),        // 今天已簽到
           hasCompletedPrediction: false   // 未猜多空，會顯示
       )
       
       static let allCompletedUser = UserInfo(
           memberId: "5",
           isNewUser: false,
           hasSeenTutorial: true,
           hasSeenAd: true,
           hasSeenNewFeature: true,
           lastCheckInDate: Date(),        // 今天已簽到
           hasCompletedPrediction: true    // 已猜多空
       )
   }
   ```
3. [ ] 定義 `PopupContext` 結構
   ```swift
   struct PopupContext {
       let userInfo: UserInfo
       let stateRepository: PopupStateRepository
       let presenter: PopupPresenter?
   }
   ```
3. [ ] 定義 `PopupHandler` 協議
   ```swift
   protocol PopupHandler: AnyObject {
       var next: PopupHandler? { get set }
       func handle(context: PopupContext) -> Result<Bool, PopupError>
   }
   ```
4. [ ] 實作 `BasePopupHandler`（包含 next 串接邏輯）
5. [ ] 實作 5 個具體 Handler
   - **特別注意**：`TutorialHandler` 如果顯示彈窗（用戶首次看），關閉後返回成功但**不調用 next**（終止鏈）
   - 其他 Handler 顯示彈窗後，關閉時調用 next 繼續檢查
6. [ ] 實作 `PopupChainManager`（組裝與啟動）
7. [ ] 新增測試套件
   - Handler 邏輯測試
   - Chain 串接測試
   - 優先順序測試

**時間估計**: 2-3 sessions  
**依賴**: Phase 0 完成

---

### Phase 2: 狀態管理與持久化 [P0 - 必要]

**目標**: 實作彈窗狀態追蹤與持久化

**預期成果**: 狀態可正確儲存與讀取，15+ Repository 測試通過

**驗收標準**:
- [ ] `PopupState` 模型定義
- [ ] `PopupStateRepository` 協議定義（支援多帳號）
- [ ] `InMemoryPopupStateRepository` 實作（測試用）
- [ ] `UserInfo` 模型定義（5 個預設角色）
- [ ] `UserStateSimulator` 實作（測試輔助）
- [ ] 依賴注入到各 Handler
- [ ] 多帳號狀態隔離正確
- [ ] 同帳號登出重登狀態保留
- [ ] 換帳號登入視為全新用戶
- [ ] 「已看過」狀態持久化直到明確重置
- [ ] 「今日簽到」時間判定正確
- [ ] resetAll 清空所有用戶與重置計數器
- [ ] 新增 25+ Repository 測試（含多帳號場景）

**實作清單**:
1. [ ] 定義 `PopupState` 模型
   ```swift
   struct PopupState {
       let type: PopupType
       let hasShown: Bool
       let lastShownDate: Date?
       let showCount: Int
   }
   ```
2. [ ] 定義 `PopupStateRepository` 協議（支援多帳號）
   ```swift
   protocol PopupStateRepository {
       func getState(for type: PopupType, memberId: String) -> Result<PopupState, PopupError>
       func updateState(_ state: PopupState, memberId: String) -> Result<Void, PopupError>
       func markAsShown(type: PopupType, memberId: String) -> Result<Void, PopupError>
       func resetUser(memberId: String) // 重置特定用戶
       func resetAll() // 重置所有用戶（測試用）
       func generateNextMemberId() -> String // 生成遞增 ID（測試用）
   }
   ```
3. [ ] 實作 `InMemoryPopupStateRepository`（測試用，支援多帳號）
   ```swift
   class InMemoryPopupStateRepository: PopupStateRepository {
       private var userStates: [String: [PopupType: PopupState]] = [:]
       private var nextMemberId: Int = 1
       
       func getState(for type: PopupType, memberId: String) -> Result<PopupState, PopupError> {
           if let state = userStates[memberId]?[type] {
               return .success(state)
           }
           // 用戶不存在或該彈窗未顯示過，返回初始狀態
           let initialState = PopupState(type: type, hasShown: false, lastShownDate: nil, showCount: 0)
           return .success(initialState)
       }
       
       func updateState(_ state: PopupState, memberId: String) -> Result<Void, PopupError> {
           if userStates[memberId] == nil {
               userStates[memberId] = [:]
           }
           userStates[memberId]?[state.type] = state
           return .success(())
       }
       
       func markAsShown(type: PopupType, memberId: String) -> Result<Void, PopupError> {
           let currentState = (try? getState(for: type, memberId: memberId).get()) 
               ?? PopupState(type: type, hasShown: false, lastShownDate: nil, showCount: 0)
           let newState = PopupState(
               type: type,
               hasShown: true,
               lastShownDate: Date(),
               showCount: currentState.showCount + 1
           )
           return updateState(newState, memberId: memberId)
       }
       
       func resetUser(memberId: String) {
           userStates[memberId] = nil
       }
       
       func resetAll() {
           userStates.removeAll()
           nextMemberId = 1
       }
       
       func generateNextMemberId() -> String {
           defer { nextMemberId += 1 }
           return "\(nextMemberId)"
       }
   }
   ```
4. [ ] 實作 `UserDefaultsPopupStateRepository`（可選，生產環境用）
   - UserDefaults 儲存實作（key 格式: "popup_\(memberId)_\(type)"）
   - 日期比對邏輯（isToday, isThisWeek 等）
5. [ ] 實作 `UserStateSimulator`（測試輔助工具，支援多帳號）
   ```swift
   class UserStateSimulator {
       private let repository: PopupStateRepository
       private var currentUserInfo: UserInfo
       
       init(repository: PopupStateRepository, userInfo: UserInfo = .newUser) {
           self.repository = repository
           self.currentUserInfo = userInfo
       }
       
       /// 切換到指定用戶（保留該用戶之前的狀態）
       func switchToUser(_ userInfo: UserInfo) {
           currentUserInfo = userInfo
           applyUserInfoToRepository(userInfo)
       }
       
       /// 將 UserInfo 的狀態同步到 Repository（僅同步尚未存在的狀態）
       private func applyUserInfoToRepository(_ userInfo: UserInfo) {
           let memberId = userInfo.memberId
           
           if userInfo.hasSeenTutorial {
               _ = repository.markAsShown(type: .tutorial, memberId: memberId)
           }
           if userInfo.hasSeenAd {
               _ = repository.markAsShown(type: .interstitialAd, memberId: memberId)
           }
           if userInfo.hasSeenNewFeature {
               _ = repository.markAsShown(type: .newFeature, memberId: memberId)
           }
           if let lastCheckIn = userInfo.lastCheckInDate {
               _ = repository.updateState(
                   PopupState(type: .dailyCheckIn, hasShown: true, lastShownDate: lastCheckIn, showCount: 1),
                   memberId: memberId
               )
           }
       }
       
       /// 預覽當前用戶應顯示的彈窗
       func getExpectedPopups(for userInfo: UserInfo) -> [PopupType] {
           var expected: [PopupType] = []
           
           if !userInfo.hasSeenTutorial {
               expected.append(.tutorial)
           }
           if !userInfo.hasSeenAd && !userInfo.isVIP {
               expected.append(.interstitialAd)
           }
           if !userInfo.hasSeenNewFeature {
               expected.append(.newFeature)
           }
           if !isTodayCheckedIn(userInfo.lastCheckInDate) {
               expected.append(.dailyCheckIn)
           }
           if userInfo.hasPredictionResult {
               expected.append(.predictionResult)
           }
           
           return expected
       }
       
       private func isTodayCheckedIn(_ lastCheckIn: Date?) -> Bool {
           guard let lastCheckIn = lastCheckIn else { return false }
           return Calendar.current.isDateInToday(lastCheckIn)
       }
   }
   ```
6. [ ] 更新各 Handler 使用 context.userInfo.memberId 調用 Repository
7. [ ] 實作狀態更新邏輯（關閉彈窗時標記已看過）
8. [ ] 新增 Repository 測試（25+ 測試，包含多帳號場景）
   - 單一用戶讀寫測試
   - 多用戶隔離測試
   - 帳號切換測試（同帳號保留狀態、換帳號全新開始）
   - resetAll 測試
   - 時間判定測試
   - 邊界條件測試

**時間估計**: 2 sessions  
**依賴**: Phase 1 完成

---

### Phase 3: 錯誤處理與降級策略 [P1 - 重要]

**目標**: 完善錯誤處理，確保系統穩定

**預期成果**: 任何失敗不影響下一個彈窗檢查，10+ 錯誤處理測試通過

**驗收標準**:
- [ ] `PopupError` 錯誤類型定義
- [ ] Result Type 包裝所有操作
- [ ] 失敗時自動跳到下一個 Handler
- [ ] Logger 整合完成
- [ ] 降級策略實作（繼續檢查 vs 中斷）
- [ ] 新增 10+ 錯誤處理測試

**實作清單**:
1. [ ] 定義 `PopupError` 枚舉
   ```swift
   enum PopupError: Error {
       case repositoryReadFailed
       case repositoryWriteFailed
       case presenterCreationFailed
       case invalidState
       case unknown(Error)
   }
   ```
2. [ ] 所有方法改用 `Result<T, PopupError>`
3. [ ] 實作降級邏輯（失敗繼續）
   - Repository 讀取失敗：跳過該彈窗
   - Presenter 創建失敗：記錄錯誤，繼續下一個
4. [ ] 整合 Logger 協議
   ```swift
   protocol Logger {
       func log(_ message: String, level: LogLevel)
   }
   ```
5. [ ] 新增錯誤處理測試
   - Repository 失敗測試
   - Presenter 失敗測試
   - 降級策略測試

**時間估計**: 2 sessions  
**依賴**: Phase 2 完成

---

### Phase 4: Observer Pattern 整合 [P1 - 重要]

**目標**: 讓 UI 可監聽彈窗事件

**預期成果**: 彈窗顯示/關閉可通知觀察者，10+ Observer 測試通過

**驗收標準**:
- [ ] `PopupEvent` 枚舉定義
- [ ] `PopupEventObserver` 協議定義
- [ ] `PopupEventPublisher` 實作
- [ ] 事件發布正確
- [ ] Weak reference 避免記憶體洩漏
- [ ] Manager 整合 Publisher
- [ ] 新增 10+ Observer 測試

**實作清單**:
1. [ ] 定義 `PopupEvent` 枚舉
   ```swift
   enum PopupEvent: Equatable {
       case popupWillShow(PopupType)
       case popupDidShow(PopupType)
       case popupWillDismiss(PopupType)
       case popupDidDismiss(PopupType)
       case chainCompleted
   }
   ```
2. [ ] 定義 `PopupEventObserver` 協議
   ```swift
   protocol PopupEventObserver: AnyObject {
       func popupChain(didPublish event: PopupEvent)
   }
   ```
3. [ ] 實作 `PopupEventPublisher`
   - 觀察者管理（weak reference）
   - 事件發布機制
4. [ ] Manager 整合 Publisher
   - 在適當時機發布事件
5. [ ] 新增 Observer 測試
   - 訂閱/取消訂閱測試
   - 事件發布測試
   - Weak reference 測試

**時間估計**: 2 sessions  
**依賴**: Phase 3 完成

---

### Phase 5: 開發者測試控制台 UI [P1 - 重要]

**目標**: 建立可視化的用戶狀態設定介面，快速模擬各種場景

**預期成果**: 
- 開發者可透過 UI 設定所有用戶狀態參數
- 一鍵啟動彈窗流程模擬
- 即時顯示流程執行結果並自動驗證一致性

**UI 設計概念**:
```
┌─────────────────────────────────────────┐
│   🧪 彈窗流程測試控制台                    │
├─────────────────────────────────────────┤
│  當前用戶: MemberId #6                    │
│                                          │
│  快速選擇預設角色（固定 ID 1-5）           │
│  [  👶新手  ] [  👴老手  ] [  ⭐VIP  ]   │
│  [  ✅已簽  ] [ 👁全看過 ]                │
│  [ ➕ 建立新用戶 (ID自動+1) ]              │
│                                          │
│  詳細狀態設定                             │
│  ☑️ 新手教學已看過                        │
│  ☑️ 插頁廣告已看過                        │
│  ☐ 新功能公告已看過                       │
│  ☐ 今日已簽到                            │
│  ☑️ 有預測結果                            │
│  ☐ 新用戶                                │
│  ☐ VIP 會員                              │
│  📅 最後簽到: 2026-01-13                 │
│                                          │
│  [    ▶️  開 始 模 擬    ]               │
│  [  🔄 重置當前用戶  ] [  🗑 重置全部  ]  │
│                                          │
│  執行結果                                 │
│  📋 預期: Ad → NewFeature → CheckIn      │
│  ✅ 實際: Ad → NewFeature → CheckIn      │
│  ✅ 流程完成 - 結果一致！                 │
│  💾 已快取用戶數: 6                       │
└─────────────────────────────────────────┘
```

**驗收標準**:
- [ ] 用戶狀態設定 UI 完成
  - [ ] 當前 memberId 顯示（Label）
  - [ ] 5 個預設角色按鈕（固定 ID 1-5）
  - [ ] 建立新用戶按鈕（自動遞增 ID）
  - [ ] 個別彈窗狀態開關（5 個 Toggle）
  - [ ] 新用戶狀態開關
  - [ ] VIP 狀態開關
  - [ ] 簽到日期選擇器
  - [ ] 已快取用戶數顯示
- [ ] 「開始模擬」按鈕功能完成（從當前 UI 狀態組成 UserInfo）
- [ ] 流程執行可視化
  - [ ] 即時顯示當前執行步驟
  - [ ] 顯示已顯示的彈窗清單
  - [ ] 預期 vs 實際彈窗對比
  - [ ] 自動標註一致性（✅一致 / ⚠️不符）
- [ ] 雙重重置功能
  - [ ] 重置當前用戶（resetUser）
  - [ ] 重置全部（resetAll + 計數器歸 1）
- [ ] 5 個簡化版彈窗 View 實作（Alert 或自訂 View）
- [ ] 開發模式下可輕鬆進入控制台（`#if DEBUG`）

**實作清單**:

1. [ ] 建立 `PopupDebugViewController`（主控制台）
   - UI Components（按鈕組、Switches、DatePicker、Labels）
   - 用戶狀態模擬器整合
   - 即時預期彈窗計算
   - memberId 自動管理（預設角色固定 ID、新用戶自動遞增）

2. [ ] 實作 UI 佈局
   ```swift
   // 主要區塊
   - 當前 memberId 顯示區（Label）
   - 快速選擇區（6 個按鈕：5 個預設角色 + 1 個建立新用戶）
   - 詳細設定區（8 個狀態開關）
   - 執行按鈕區（開始模擬）
   - 重置按鈕區（重置當前用戶/重置全部）
   - 結果顯示區（預期/實際/狀態/已快取用戶數）
   ```

3. [ ] 實作業務邏輯
   ```swift
   @objc func presetButtonTapped(_ sender: UIButton) // 預設角色按鈕
   @objc func createNewUserTapped() // 建立新用戶（ID 自動+1）
   @objc func switchChanged(_ sender: UISwitch)
   @objc func startSimulation()
   @objc func resetCurrentUser() // 重置當前用戶
   @objc func resetAllUsers() // 重置全部（含計數器）
   
   func buildUserInfoFromUI() -> UserInfo // 從 UI 狀態組成 UserInfo
   func updateCurrentMemberIdDisplay() // 更新 memberId 顯示
   func updateExpectedPopups()
   func compareResults()
   func updateCachedUserCountDisplay() // 更新已快取用戶數
   ```

4. [ ] 實作 `PopupPresenter` 協議
   ```swift
   extension PopupDebugViewController: PopupPresenter {
       func present(type: PopupType, 
                    from viewController: UIViewController,
                    completion: @escaping () -> Void) {
           // 記錄實際顯示的彈窗
           // 建立簡化的 Alert 彈窗（開發測試用）
           // 更新實際顯示清單
       }
   }
   ```

5. [ ] 實作 `PopupEventObserver`（監聽流程事件）
   ```swift
   extension PopupDebugViewController: PopupEventObserver {
       func popupChain(didPublish event: PopupEvent) {
           // 更新 UI 狀態顯示
           // popupWillShow, popupDidShow, popupDidDismiss, chainCompleted
       }
   }
   ```

6. [ ] 整合到 App 進入點
   ```swift
   // SceneDelegate.swift
   #if DEBUG
   window.rootViewController = UINavigationController(
       rootViewController: PopupDebugViewController()
   )
   #else
   window.rootViewController = MainViewController()
   #endif
   ```

7. [ ] 實作 5 個簡化彈窗 View
   - TutorialPopupView（Alert 版本）
   - InterstitialAdPopupView（Alert 版本）
   - NewFeaturePopupView（Alert 版本）
   - DailyCheckInPopupView（Alert 版本）
   - PredictionResultPopupView（Alert 版本）

**時間估計**: 3-4 sessions  
**依賴**: Phase 2 完成（需要 UserStateSimulator）

---

## 2. 用戶狀態模擬器（整合到 Phase 2）

### 為什麼需要用戶模擬？

在測試和開發時，需要快速切換不同用戶身份來驗證彈窗流程：
- **新用戶**：首次進入，應顯示所有彈窗
- **老用戶**：只看簽到和結果
- **VIP 用戶**：可能跳過廣告
- **已簽到用戶**：今日已簽到，不顯示簽到彈窗

### 用戶狀態模型

```swift
/// 用戶狀態配置
struct UserProfile {
    let userId: String
    let isNewUser: Bool
    let hasSeenTutorial: Bool
    let hasSeenAd: Bool
    let hasSeenNewFeature: Bool
    let lastCheckInDate: Date?
    let hasPredictionResult: Bool
    let isVIP: Bool
    
    // 預設配置
    static let newUser = UserProfile(
        userId: "new_user",
        isNewUser: true,
        hasSeenTutorial: false,
        hasSeenAd: false,
        hasSeenNewFeature: false,
        lastCheckInDate: nil,
        hasPredictionResult: false,
        isVIP: false
    )
    
    static let returningUser = UserProfile(
        userId: "returning_user",
        isNewUser: false,
        hasSeenTutorial: true,
        hasSeenAd: true,
        hasSeenNewFeature: true,
        lastCheckInDate: Date().addingTimeInterval(-86400), // 昨天
        hasPredictionResult: true,
        isVIP: false
    )
    
    static let vipUser = UserProfile(
        userId: "vip_user",
        isNewUser: false,
        hasSeenTutorial: true,
        hasSeenAd: true,
        hasSeenNewFeature: true,
        lastCheckInDate: Date().addingTimeInterval(-86400),
        hasPredictionResult: false,
        isVIP: true
    )
    
    static let checkedInUser = UserProfile(
        userId: "checked_in_user",
        isNewUser: false,
        hasSeenTutorial: true,
        hasSeenAd: true,
        hasSeenNewFeature: true,
        lastCheckInDate: Date(), // 今天已簽到
        hasPredictionResult: true,
        isVIP: false
    )
    
    static let allSeenUser = UserProfile(
        userId: "all_seen_user",
        isNewUser: false,
        hasSeenTutorial: true,
        hasSeenAd: true,
        hasSeenNewFeature: true,
        lastCheckInDate: Date(),
        hasPredictionResult: false,
        isVIP: false
    )
}
```

### 用戶狀態模擬器

```swift
/// 用戶狀態模擬器（開發/測試用）
class UserStateSimulator {
    
    private let repository: PopupStateRepository
    private var currentProfile: UserProfile
    
    init(repository: PopupStateRepository, 
         profile: UserProfile = .newUser) {
        self.repository = repository
        self.currentProfile = profile
        applyProfile(profile)
    }
    
    // MARK: - 切換用戶身份
    
    func switchToNewUser() {
        applyProfile(.newUser)
    }
    
    func switchToReturningUser() {
        applyProfile(.returningUser)
    }
    
    func switchToVIPUser() {
        applyProfile(.vipUser)
    }
    
    func switchToCheckedInUser() {
        applyProfile(.checkedInUser)
    }
    
    func switchToAllSeenUser() {
        applyProfile(.allSeenUser)
    }
    
    func switchToCustomProfile(_ profile: UserProfile) {
        applyProfile(profile)
    }
    
    // MARK: - 應用配置
    
    private func applyProfile(_ profile: UserProfile) {
        currentProfile = profile
        resetAllStates()
        
        if profile.hasSeenTutorial {
            _ = repository.markAsShown(type: .tutorial)
        }
        if profile.hasSeenAd {
            _ = repository.markAsShown(type: .interstitialAd)
        }
        if profile.hasSeenNewFeature {
            _ = repository.markAsShown(type: .newFeature)
        }
        if let lastCheckIn = profile.lastCheckInDate {
            _ = repository.updateState(PopupState(
                type: .dailyCheckIn,
                hasShown: true,
                lastShownDate: lastCheckIn,
                showCount: 1
            ))
        }
    }
    
    private func resetAllStates() {
        PopupType.allCases.forEach { type in
            _ = repository.updateState(PopupState(
                type: type,
                hasShown: false,
                lastShownDate: nil,
                showCount: 0
            ))
        }
    }
    
    // MARK: - 查詢當前狀態
    
    func getCurrentProfile() -> UserProfile {
        currentProfile
    }
    
    /// 取得當前應該顯示的彈窗（預覽用）
    func getExpectedPopups() -> [PopupType] {
        var expected: [PopupType] = []
        
        if !currentProfile.hasSeenTutorial {
            expected.append(.tutorial)
        }
        if !currentProfile.hasSeenAd && !currentProfile.isVIP {
            expected.append(.interstitialAd)
        }
        if !currentProfile.hasSeenNewFeature {
            expected.append(.newFeature)
        }
        if !isTodayCheckedIn() {
            expected.append(.dailyCheckIn)
        }
        if currentProfile.hasPredictionResult {
            expected.append(.predictionResult)
        }
        
        return expected
    }
    
    private func isTodayCheckedIn() -> Bool {
        guard let lastCheckIn = currentProfile.lastCheckInDate else {
            return false
        }
        return Calendar.current.isDateInToday(lastCheckIn)
    }
}
```

### 整合到 Phase 2

在 **Phase 2: 狀態管理與持久化** 中，新增：

**實作清單**:
7. [ ] 定義 `UserProfile` 模型
8. [ ] 實作 `UserStateSimulator`（開發/測試工具）
   - 5 種預設用戶配置
   - 切換用戶身份方法
   - 預期彈窗計算功能
9. [ ] 新增 Simulator 測試
   - 切換身份測試
   - 預期彈窗計算測試
   - 與實際流程一致性測試

**驗收標準**:
- [ ] 可快速切換 5 種預設用戶身份
- [ ] 預期彈窗計算 100% 正確
- [ ] 新增 10+ Simulator 測試

---

## 3. 依賴關係

### 表格形式（實際業務流程）

| 用戶狀態 | 流程 | 彈窗順序 |
|:--------:|------|----------|
| **首次進入<br>未看過教學** | 顯示教學後終止 | Tutorial → 關閉後結束 |
| **已看過教學** | 完整責任鏈流程 | 1. AdA 或 AdB<br>2. CheckIn（未簽到才顯示）<br>3. Prediction（未猜才顯示） |

**彈窗判斷邏輯**：

| 順序 | 彈窗類型 | 顯示條件 | 備註 |
|:----:|----------|----------|------|
| 0 | 新手教學 (tutorial) | 未看過教學 | `hasSeenTutorial == false`<br>**顯示後終止鏈** |
| 1 | 廣告 A (interstitialAd) | 未看過廣告 A | `hasSeenAd == false` |
| 1 | 廣告 B (newFeature) | 已看過廣告 A | `hasSeenAd == true` |
| 2 | 每日簽到 (dailyCheckIn) | 今日尚未簽到 | 檢查 `lastCheckInDate` |
| 3 | 猜多空 (predictionResult) | 今日尚未完成猜多空 | `hasCompletedPrediction == false` |

**特殊規則**：
- **Tutorial 終止規則**：如果用戶未看過教學（`hasSeenTutorial == false`），顯示 Tutorial 彈窗，用戶關閉後**直接結束責任鏈**，不繼續檢查後續彈窗
- **已看過教學則繼續**：如果 `hasSeenTutorial == true`，跳過 Tutorial，繼續檢查後續彈窗
- **廣告 A/B 互斥**：
  - 未看過廣告 A (`hasSeenAd == false`) → 顯示 `interstitialAd`
  - 已看過廣告 A (`hasSeenAd == true`) → 顯示 `newFeature`
- **任一彈窗顯示後暫停**：待用戶關閉後繼續檢查下一個（Tutorial 除外）
- **已完成的跳過**：已簽到或已猜多空的直接跳過

---

### 圖示形式（責任鏈流程）

```
進入主畫面
    ↓
┌──────────────────────┐
│ TutorialHandler      │ → 未看過？→ 顯示 Tutorial → 關閉 → 繼續
│ (檢查新手教學)        │    ↓ 已看過
└──────────────────────┘    ↓
           ↓                ↓
┌──────────────────────┐    ↓
│ InterstitialAdHandler│ ←──┘
│ (檢查插頁式廣告)      │ → 未看過？→ 顯示 Ad → 關閉 → 繼續
└──────────────────────┘    ↓ 已看過
           ↓                ↓
┌──────────────────────┐    ↓
│ NewFeatureHandler    │ ←──┘
│ (檢查新功能公告)      │ → 未看過？→ 顯示 NewFeature → 關閉 → 繼續
└──────────────────────┘    ↓ 已看過
           ↓                ↓
┌──────────────────────┐    ↓
│ DailyCheckInHandler  │ ←──┘
│ (檢查每日簽到)        │ → 未簽到？→ 顯示 CheckIn → 關閉 → 繼續
└──────────────────────┘    ↓ 已簽到
           ↓                ↓
┌──────────────────────┐    ↓
│ PredictionHandler    │ ←──┘
│ (檢查猜多空結果)      │ → 有結果？→ 顯示 Result → 關閉 → 結束
└──────────────────────┘    ↓ 無結果
           ↓                ↓
        結束 ←──────────────┘
```

---

### 代碼形式（直接可用）

```swift
/// 彈窗類型枚舉
enum PopupType: String, CaseIterable {
    case tutorial           // 新手教學
    case interstitialAd     // 插頁式廣告
    case newFeature         // 新功能公告
    case dailyCheckIn       // 每日簽到
    case predictionResult   // 猜多空結果
    
    var priority: Int {
        switch self {
        case .tutorial: return 1
        case .interstitialAd: return 2
        case .newFeature: return 3
        case .dailyCheckIn: return 4
        case .predictionResult: return 5
        }
    }
    
    var displayName: String {
        switch self {
        case .tutorial: return "新手教學"
        case .interstitialAd: return "插頁式廣告"
        case .newFeature: return "新功能公告"
        case .dailyCheckIn: return "每日簽到"
        case .predictionResult: return "猜多空結果"
        }
    }
}

/// 彈窗狀態
struct PopupState: Codable, Equatable {
    let type: PopupType
    let hasShown: Bool
    let lastShownDate: Date?
    let showCount: Int
    
    init(type: PopupType, 
         hasShown: Bool = false, 
         lastShownDate: Date? = nil, 
         showCount: Int = 0) {
        self.type = type
        self.hasShown = hasShown
        self.lastShownDate = lastShownDate
        self.showCount = showCount
    }
}

/// 彈窗錯誤
enum PopupError: Error, Equatable {
    case repositoryReadFailed
    case repositoryWriteFailed
    case presenterCreationFailed
    case invalidState
    case unknown(String)
    
    var localizedDescription: String {
        switch self {
        case .repositoryReadFailed: return "讀取彈窗狀態失敗"
        case .repositoryWriteFailed: return "儲存彈窗狀態失敗"
        case .presenterCreationFailed: return "建立彈窗顯示器失敗"
        case .invalidState: return "彈窗狀態無效"
        case .unknown(let message): return "未知錯誤: \(message)"
        }
    }
}

/// 彈窗上下文
struct PopupContext {
    let userInfo: UserInfo
    let stateRepository: PopupStateRepository
    let presenter: PopupPresenter?
    let logger: Logger
}
```

---

## 3. 完成定義（Definition of Done）

### 功能完整性
- [ ] **所有核心功能**可正常運作
  - [ ] 5 種彈窗類型可正確檢查
  - [ ] 責任鏈按優先順序執行
  - [ ] 彈窗顯示後暫停，關閉後繼續
- [ ] **狀態管理**正確
  - [ ] 「已看過」狀態正確持久化
  - [ ] 「今日簽到」時間判定正確
  - [ ] 狀態讀寫異常不影響流程
- [ ] **錯誤處理**完整
  - [ ] Repository 失敗降級處理
  - [ ] Presenter 失敗降級處理
  - [ ] 錯誤記錄完整

### 架構質量（SOLID 原則）
- [ ] **SRP（單一職責）**
  - [ ] 每個 Handler 只負責一種彈窗
  - [ ] Repository 只負責狀態管理
  - [ ] Manager 只負責組裝與啟動
  - [ ] 驗證：單一文件 < 200 行
- [ ] **OCP（開放封閉）**
  - [ ] 新增彈窗類型不需修改現有代碼
  - [ ] 驗證：新增 PopupType 即可擴展
- [ ] **LSP（里氏替換）**
  - [ ] Handler 實作可自由替換
  - [ ] Repository 實作可自由替換
  - [ ] 驗證：Mock 對象可替換真實對象
- [ ] **ISP（接口隔離）**
  - [ ] 接口隔離清晰
  - [ ] 驗證：PopupHandler、PopupStateRepository 分離
- [ ] **DIP（依賴反轉）**
  - [ ] 依賴抽象（協議）而非實作
  - [ ] 驗證：所有依賴通過構造函數注入

### 設計模式應用
- [ ] Chain of Responsibility Pattern（責任鏈）
- [ ] Repository Pattern（狀態儲存）
- [ ] Observer Pattern（事件發布）
- [ ] Strategy Pattern（條件檢查，可選）

### 測試覆蓋
- [ ] **50+ 單元測試**全部通過
  - [ ] Handler 邏輯測試（~15 tests）
  - [ ] Chain 串接測試（~10 tests）
  - [ ] Repository 測試（~15 tests）
  - [ ] 錯誤處理測試（~10 tests）
  - [ ] Observer 測試（~10 tests）
- [ ] **測試可讀性**
  - [ ] 使用 Given-When-Then 結構
  - [ ] 測試方法命名清晰：`test[功能]_[條件]_[預期結果]()`
- [ ] **邊界情況覆蓋**
  - [ ] 所有彈窗已看過
  - [ ] Repository 讀取失敗
  - [ ] Presenter 創建失敗
  - [ ] 重複顯示同一彈窗

### 代碼質量
- [ ] **命名規範**
  - [ ] 類別名稱：PascalCase
  - [ ] 方法名稱：camelCase
  - [ ] 常數名稱：camelCase（Swift 風格）
- [ ] **注釋完整**
  - [ ] 公開 API 有文檔注釋
  - [ ] 複雜邏輯有說明注釋
- [ ] **無編譯警告**
- [ ] **無 SwiftLint 警告**（如果使用）

### 文檔完整
- [ ] **設計決策**記錄在案
  - [ ] 為什麼選擇 Chain of Responsibility
  - [ ] 為什麼使用 UserDefaults 儲存狀態
  - [ ] 降級策略的選擇理由
- [ ] **責任鏈流程圖**正確且最新
- [ ] **README**包含
  - [ ] 項目概述
  - [ ] 如何運行測試
  - [ ] 架構說明
  - [ ] 使用範例

---

## 4. 優先級定義

### P0 - 必須完成（阻塞後續開發）

**定義**：缺少這些功能，系統無法運作或後續 Phase 無法進行

- [ ] Phase 0: Spec Validation
  - [ ] Spec 審查完成
  - [ ] 邊界條件明確
  - [ ] 架構方向確認
- [ ] Phase 1: 核心基礎架構
  - [ ] PopupHandler 協議
  - [ ] 5 個 Handler 實作
  - [ ] PopupChainManager 實作
  - [ ] 20+ 單元測試
- [ ] Phase 2: 狀態管理與持久化
  - [ ] PopupStateRepository 協議
  - [ ] UserDefaults 實作
  - [ ] 狀態讀寫正確
  - [ ] 15+ Repository 測試

**完成標準**：所有核心功能測試通過，責任鏈可正常運作

---

### P1 - 重要（顯著提升質量）

**定義**：缺少這些功能，系統可運作但質量不佳或擴展性差

- [ ] Phase 3: 錯誤處理與降級策略
  - [ ] PopupError 定義
  - [ ] Result Type 包裝
  - [ ] 降級策略實作
  - [ ] Logger 整合
- [ ] Phase 4: Observer Pattern
  - [ ] PopupEvent 定義
  - [ ] PopupEventObserver 協議
  - [ ] PopupEventPublisher 實作
  - [ ] 10+ Observer 測試

**完成標準**：架構符合 SOLID 原則，錯誤處理完整

---

### P2 - 可選（Nice to have）

**定義**：錦上添花，時間不夠可以延後或刪減

- [ ] Phase 5: UI 整合
  - [ ] PopupPresenter 協議
  - [ ] 5 個彈窗 UI
  - [ ] ViewController 整合
- [ ] 額外功能
  - [ ] 彈窗顯示動畫
  - [ ] 彈窗統計（顯示次數、轉換率）
  - [ ] A/B Testing 支援

**完成標準**：依時間而定，可選擇性實作

---

### 時間不足時的取捨策略

**如果只有 50% 時間**：
1. ✅ 完成 Phase 0-2（核心功能必須可運作）
2. ⚠️ Phase 3 簡化（基本錯誤處理，不實作降級策略）
3. ❌ Phase 4-5 砍掉

**如果只有 70% 時間**：
1. ✅ 完成 Phase 0-3
2. ⚠️ Phase 4 簡化（不實作 Publisher，直接用 Delegate）
3. ❌ Phase 5 延後

**如果有 100% 時間**：
1. ✅ 完成所有 P0、P1
2. ✅ 選擇性完成 P2（優先 UI 整合）

---

## 5. 使用範例

### ✅ 成功案例（Happy Path）

#### 案例 1：首次進入 App，依序顯示彈窗

```swift
func testNewUserFirstEntry_shouldShowAllEligiblePopups() {
    // Given: 全新用戶（memberId = "1"），所有彈窗都未看過
    let userInfo = UserInfo.newUser  // memberId = "1"
    let repository = InMemoryPopupStateRepository()
    let presenter = MockPopupPresenter()
    let logger = ConsoleLogger()
    let context = PopupContext(
        userInfo: userInfo,
        stateRepository: repository, 
        presenter: presenter,
        logger: logger
    )

    let manager = PopupChainManager(context: context)

    // When: 啟動彈窗檢查
    manager.startPopupChain()

    // Then: 依序顯示 Tutorial → Ad → NewFeature → CheckIn（無結果跳過）
    XCTAssertEqual(presenter.shownPopups, [
        .tutorial,
        .interstitialAd,
        .newFeature,
        .dailyCheckIn
    ])

    // 驗證狀態已更新
    let tutorialState = try! repository.getState(for: .tutorial, memberId: "1").get()
    XCTAssertTrue(tutorialState.hasShown)
}
```

---

#### 案例 2：老用戶，只顯示簽到

```swift
func testReturningUser_shouldOnlyShowCheckIn() {
    // Given: 老用戶（memberId = "2"），已看過 Tutorial, Ad, NewFeature
    let userInfo = UserInfo.returningUser  // memberId = "2"
    let repository = InMemoryPopupStateRepository()
    
    // 預先標記該用戶已看過的彈窗
    _ = repository.markAsShown(type: .tutorial, memberId: "2")
    _ = repository.markAsShown(type: .interstitialAd, memberId: "2")
    _ = repository.markAsShown(type: .newFeature, memberId: "2")

    let presenter = MockPopupPresenter()
    let context = PopupContext(
        userInfo: userInfo,
        stateRepository: repository,
        presenter: presenter,
        logger: ConsoleLogger()
    )

    let manager = PopupChainManager(context: context)

    // When: 啟動彈窗檢查
    manager.startPopupChain()

    // Then: 只顯示簽到彈窗
    XCTAssertEqual(presenter.shownPopups, [.dailyCheckIn])
    XCTAssertEqual(presenter.shownPopups.count, 1)
}
```

---

#### 案例 3：用戶關閉彈窗後繼續檢查下一個

```swift
func testPopupDismissal_shouldContinueToNextPopup() {
    // Given: 新手用戶（memberId = "1"），未看過任何彈窗
    let userInfo = UserInfo.newUser
    let repository = InMemoryPopupStateRepository()
    let presenter = MockPopupPresenter()
    let context = PopupContext(
        userInfo: userInfo,
        stateRepository: repository,
        presenter: presenter,
        logger: ConsoleLogger()
    )

    let manager = PopupChainManager(context: context)

    // When: 啟動彈窗檢查
    manager.startPopupChain()

    // Then: 第一個彈窗顯示
    XCTAssertEqual(presenter.currentPopup, .tutorial)

    // When: 用戶關閉 Tutorial
    presenter.simulateDismiss(.tutorial)

    // Then: 自動檢查並顯示下一個彈窗
    XCTAssertEqual(presenter.currentPopup, .interstitialAd)

    // When: 用戶關閉 Ad
    presenter.simulateDismiss(.interstitialAd)

    // Then: 繼續顯示 NewFeature
    XCTAssertEqual(presenter.currentPopup, .newFeature)
}
```

---

### ❌ 失敗案例（Unhappy Path）

#### 案例 1：Repository 讀取失敗，跳過該彈窗繼續檢查

```swift
func testRepositoryReadFailure_shouldSkipPopupAndContinue() {
    // Given: Tutorial 狀態讀取失敗，memberId = "1"
    let userInfo = UserInfo.newUser
    let repository = FaultyMockRepository(failOn: .tutorial, memberId: "1")
    let presenter = MockPopupPresenter()
    let logger = SpyLogger() // 可檢查日誌的 Mock
    let context = PopupContext(
        userInfo: userInfo,
        stateRepository: repository,
        presenter: presenter,
        logger: logger
    )

    let manager = PopupChainManager(context: context)

    // When: 啟動彈窗檢查
    let result = manager.startPopupChain()

// Then: 跳過 Tutorial，繼續檢查其他彈窗
XCTAssertTrue(result.isSuccess)
XCTAssertEqual(presenter.shownPopups, [
    .interstitialAd,
    .newFeature,
    .dailyCheckIn
])

// 驗證錯誤已記錄
XCTAssertTrue(logger.containsError("Failed to read state for tutorial"))
```

---

#### 案例 2：Presenter 創建失敗，不影響狀態更新

```swift
// Given: Presenter 為 nil（創建失敗）
let repository = MockPopupStateRepository()
let context = PopupContext(
    stateRepository: repository,
    presenter: nil, // 模擬 Presenter 創建失敗
    logger: ConsoleLogger()
)

let manager = PopupChainManager(context: context)

// When: 啟動彈窗檢查
let result = manager.startPopupChain()

// Then: 不顯示彈窗，但狀態仍正常更新（標記已嘗試）
XCTAssertTrue(result.isSuccess)
XCTAssertTrue(repository.getState(for: .tutorial).hasShown)
```

---

#### 案例 3：Repository 寫入失敗，記錄錯誤繼續

```swift
// Given: Repository 寫入失敗
let repository = FaultyMockRepository(failOnWrite: true)
let presenter = MockPopupPresenter()
let logger = SpyLogger()
let context = PopupContext(
    stateRepository: repository,
    presenter: presenter,
    logger: logger
)

let manager = PopupChainManager(context: context)

// When: 啟動彈窗檢查並關閉彈窗
manager.startPopupChain()
presenter.simulateDismiss(.tutorial)

// Then: 彈窗有顯示，但狀態更新失敗已記錄
XCTAssertEqual(presenter.shownPopups, [.tutorial])
XCTAssertTrue(logger.containsError("Failed to update state"))
```

---

### ⚠️ 邊界案例（Edge Cases）

#### 案例 1：所有彈窗都已看過，不顯示任何彈窗

```swift
// Given: 所有彈窗都已看過
let repository = MockPopupStateRepository()
PopupType.allCases.forEach { type in
    repository.markAsShown(type)
}

let presenter = MockPopupPresenter()
let context = PopupContext(
    stateRepository: repository,
    presenter: presenter,
    logger: ConsoleLogger()
)

let manager = PopupChainManager(context: context)

// When: 啟動彈窗檢查
manager.startPopupChain()

// Then: 不顯示任何彈窗
XCTAssertTrue(presenter.shownPopups.isEmpty)
XCTAssertEqual(presenter.shownPopups.count, 0)
```

---

#### 案例 2：今日已簽到，跳過簽到彈窗

```swift
// Given: 今日已簽到
let repository = MockPopupStateRepository()
repository.markAsShown(.dailyCheckIn)
repository.setLastShownDate(.dailyCheckIn, date: Date()) // 今天

let presenter = MockPopupPresenter()
let context = PopupContext(
    stateRepository: repository,
    presenter: presenter,
    logger: ConsoleLogger()
)

let manager = PopupChainManager(context: context)

// When: 啟動彈窗檢查
manager.startPopupChain()

// Then: 不顯示簽到彈窗
XCTAssertFalse(presenter.shownPopups.contains(.dailyCheckIn))
```

---

#### 案例 3：無猜多空結果，跳過結果彈窗

```swift
// Given: 無猜多空結果
let repository = MockPopupStateRepository()
repository.setPredictionResult(nil) // 無結果

let presenter = MockPopupPresenter()
let context = PopupContext(
    stateRepository: repository,
    presenter: presenter,
    logger: ConsoleLogger()
)

let manager = PopupChainManager(context: context)

// When: 啟動彈窗檢查
manager.startPopupChain()

// Then: 不顯示猜多空結果彈窗
XCTAssertFalse(presenter.shownPopups.contains(.predictionResult))
```

---

#### 案例 4：用戶重複進入 App，彈窗狀態持久化

```swift
// Given: 第一次進入，顯示並關閉 Tutorial
let repository = UserDefaultsPopupStateRepository()
let presenter = MockPopupPresenter()
let context = PopupContext(
    stateRepository: repository,
    presenter: presenter,
    logger: ConsoleLogger()
)

let manager1 = PopupChainManager(context: context)
manager1.startPopupChain()
presenter.simulateDismiss(.tutorial)

// When: 用戶離開 App 後重新進入（創建新 Manager）
let manager2 = PopupChainManager(context: context)
manager2.startPopupChain()

// Then: Tutorial 不再顯示（狀態已持久化）
XCTAssertFalse(presenter.shownPopups.contains(.tutorial))
XCTAssertEqual(presenter.shownPopups.first, .interstitialAd)
```

---

#### 案例 5：App 進入背景後重新進入，彈窗流程繼續

```swift
// Given: 正在顯示 Tutorial
let repository = MockPopupStateRepository()
let presenter = MockPopupPresenter()
let context = PopupContext(
    stateRepository: repository,
    presenter: presenter,
    logger: ConsoleLogger()
)

let manager = PopupChainManager(context: context)
manager.startPopupChain()
XCTAssertEqual(presenter.currentPopup, .tutorial)

// When: App 進入背景
NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)

// Then: 彈窗隱藏但狀態未更新（用戶未關閉）
XCTAssertNil(presenter.currentPopup)
XCTAssertFalse(repository.getState(for: .tutorial).hasShown)

// When: App 重新進入前景
NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)

// Then: Tutorial 重新顯示（繼續流程）
XCTAssertEqual(presenter.currentPopup, .tutorial)
```

---

## 6. 技術約束

### 開發環境
- **語言**: Swift 5.9+
- **平台**: iOS 15.0+
- **Xcode**: 15.0+
- **UI 框架**: UIKit（不使用 SwiftUI）
- **測試框架**: XCTest（內建，不使用第三方）

---

### 架構限制

#### ❌ 禁止使用
- **Singleton Pattern**（全局狀態，難以測試）
- **全局變量**（狀態不可控）
- **硬編碼依賴**（違反 DIP）
- **繼承**（優先使用組合與協議）
- **NotificationCenter 用於業務邏輯**（已有 Observer Pattern）
- **UserDefaults 直接存取**（應使用 Repository 封裝）
- **SwiftUI**（項目使用 UIKit）

#### ✅ 必須使用
- **UIKit**（UI 全部使用 UIKit，不使用 SwiftUI）
- **協議**（Protocol）定義抽象
- **依賴注入**（Dependency Injection）
- **組合優於繼承**（Composition over Inheritance）
- **值類型**（struct）優於引用類型（class）（除非需要繼承或引用語意）
- **Result Type** 處理錯誤（而非拋出異常）
- **TDD**：測試先行驅動開發
- **Chain of Responsibility**：核心設計模式
- **Repository Pattern**：狀態管理

---

### 代碼規範

#### 命名規範
- **類別/結構**: PascalCase（`PopupHandler`, `PopupChainManager`）
- **方法/變量**: camelCase（`startPopupChain`, `hasShown`）
- **協議**: PascalCase + 描述性名詞或動詞（`PopupStateRepository`, `PopupPresenting`）
- **枚舉**: PascalCase，case 用 camelCase（`PopupType.tutorial`）
- **常數**: camelCase（Swift 風格）

#### 文件組織
```
PopupChain/
├── Models/              # 數據模型
│   ├── PopupType.swift
│   ├── PopupState.swift
│   ├── PopupContext.swift
│   └── PopupError.swift
├── Protocols/           # 協議定義
│   ├── PopupHandler.swift
│   ├── PopupStateRepository.swift
│   ├── PopupPresenter.swift
│   └── PopupEventObserver.swift
├── Handlers/            # 責任鏈處理器
│   ├── BasePopupHandler.swift
│   ├── TutorialPopupHandler.swift
│   ├── InterstitialAdPopupHandler.swift
│   ├── NewFeaturePopupHandler.swift
│   ├── DailyCheckInPopupHandler.swift
│   └── PredictionResultPopupHandler.swift
├── Repositories/        # 狀態儲存實作
│   └── UserDefaultsPopupStateRepository.swift
├── Services/            # 業務服務
│   ├── PopupChainManager.swift
│   └── PopupEventPublisher.swift
└── UI/                  # UI 相關（Phase 5）
    ├── PopupViews/
    └── PopupViewController.swift
```

#### 代碼質量限制
- **單一文件**: 不超過 250 行（複雜邏輯需拆分）
- **單一方法**: 不超過 30 行（複雜方法需拆分）
- **嵌套深度**: 不超過 3 層（使用 guard early return）
- **參數數量**: 不超過 4 個（使用結構封裝）
- **循環複雜度**: McCabe < 10

#### 測試規範
- **命名格式**: `test[功能]_[條件]_[預期結果]()`
  - 範例: `testStartPopupChain_WhenAllPopupsShown_ShowsNothing()`
- **結構格式**: Given-When-Then
  ```swift
  func testExample() {
      // Given: 設定前置條件
      let repository = MockPopupStateRepository()
      let manager = PopupChainManager(context: context)
      
      // When: 執行操作
      let result = manager.startPopupChain()
      
      // Then: 驗證結果
      XCTAssertTrue(result.isSuccess)
  }
  ```
- **測試覆蓋**: 每個公開方法都要有測試
- **Mock 對象**: 使用協議實現 Mock（不使用第三方 Mock 框架）
- **測試隔離**: 每個測試獨立，不依賴其他測試

---

### 性能要求
- **責任鏈檢查**: < 20ms（單次檢查）
- **Repository 讀取**: < 10ms（UserDefaults）
- **Repository 寫入**: < 10ms（UserDefaults）
- **Observer 通知**: < 5ms（單次發布）
- **彈窗顯示**: < 300ms（UI 動畫）

---

### 非功能需求
- **可維護性**: 代碼注釋完整，命名清晰，邏輯簡潔
- **可測試性**: 100% 公開 API 可測試，依賴可注入
- **可擴展性**: 新增彈窗類型不需修改現有代碼（OCP）
- **可讀性**: 使用有意義的變數名，避免縮寫（除非是業界通用）
- **穩定性**: 任何單一失敗不影響整體流程（降級策略）

---

## 7. 設計決策記錄

### 為什麼選擇 Chain of Responsibility？
- **符合需求**: 依序檢查多個條件，符合責任鏈模式特性
- **易於擴展**: 新增彈窗只需新增 Handler，不需修改現有代碼
- **職責清晰**: 每個 Handler 只負責一種彈窗判斷
- **降低耦合**: Handler 之間不需要知道彼此存在

### 為什麼使用 UserDefaults 儲存狀態？
- **需求簡單**: 只需儲存簡單的布林值和日期
- **效能足夠**: UserDefaults 讀寫速度符合需求（< 10ms）
- **易於實作**: 無需複雜的資料庫設計
- **可替換性**: 透過 Repository Pattern 封裝，未來可替換為其他儲存方式

### 為什麼使用 Observer Pattern？
- **UI 解耦**: UI 不需直接依賴 Manager，透過事件通知更新
- **可測試性**: 可用 Mock Observer 驗證事件發布
- **擴展性**: 可輕易加入多個觀察者（統計、日誌等）

### 降級策略的選擇
- **繼續檢查 vs 中斷**: 選擇繼續檢查下一個彈窗
- **理由**: 單一彈窗失敗不應影響用戶體驗，其他彈窗仍可正常顯示
- **記錄錯誤**: 失敗情況記錄到日誌，便於後續追蹤修復

---

## 8. 參考資料

### 設計模式
- [Chain of Responsibility Pattern - Refactoring Guru](https://refactoring.guru/design-patterns/chain-of-responsibility)
- [Repository Pattern - Martin Fowler](https://martinfowler.com/eaaCatalog/repository.html)
- [Observer Pattern - Gang of Four](https://en.wikipedia.org/wiki/Observer_pattern)

### Swift 最佳實踐
- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [Protocol-Oriented Programming in Swift](https://developer.apple.com/videos/play/wwdc2015/408/)
- [SOLID Principles in Swift](https://www.raywenderlich.com/books/advanced-ios-app-architecture/v2.0/chapters/2-solid-principles)

### 測試相關
- [XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [Test Driven Development in Swift](https://www.raywenderlich.com/books/ios-test-driven-development-by-tutorials)

---

## 總結

這份執行 Spec 符合「AI 协作高效 Spec 撰写指南」的所有原則：

✅ **Phase 0 Validation** - 先審查再實作，避免返工  
✅ **漸進式分階段** - 5 個清晰的 Phase，每個都可獨立驗證  
✅ **多格式描述** - 表格 + 流程圖 + 代碼，三重驗證  
✅ **量化驗收標準** - 50+ 測試、< 200 行代碼、SOLID 檢查點  
✅ **優先級清晰** - P0/P1/P2 分級 + 時間不足取捨策略  
✅ **範例驅動** - Happy/Unhappy/Edge Cases 完整覆蓋  
✅ **約束明確** - 禁止/必須使用的技術清單明確  

準備好開始實作了！🚀

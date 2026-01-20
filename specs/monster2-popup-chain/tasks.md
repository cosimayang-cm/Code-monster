# Tasks: 彈窗連鎖顯示機制 (Popup Response Chain)

**Branch**: `feature/monster2-popup-chain`
**Generated**: 2026-01-16
**Spec**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)

---

## User Stories Summary

| ID | Story | Priority | Handler |
|----|-------|----------|---------|
| US1 | 新用戶首次進入 App（新手教學） | P1 | TutorialPopupHandler |
| US2 | 老用戶每日簽到流程 | P1 | DailyCheckInHandler |
| US3 | 猜多空結果通知 | P2 | PredictionResultHandler |
| US4 | 新功能公告推送 | P2 | NewFeaturePopupHandler |
| US5 | 插頁式廣告展示 | P3 | InterstitialAdHandler |

---

## Phase 1: Setup

**Goal**: 建立 PopupChain 模組的基礎結構

- [x] T001 Create PopupChain folder structure in `CarSystem/PopupChain/`
- [x] T002 [P] Create Protocols folder in `CarSystem/PopupChain/Protocols/`
- [x] T003 [P] Create Models folder in `CarSystem/PopupChain/Models/`
- [x] T004 [P] Create Handlers folder in `CarSystem/PopupChain/Handlers/`
- [x] T005 [P] Create Services folder in `CarSystem/PopupChain/Services/`
- [x] T006 [P] Create Views folder in `CarSystem/PopupChain/Views/`
- [x] T007 Create PopupChainTests folder in `CarSystemTests/PopupChainTests/`

---

## Phase 2: Foundational

**Goal**: 實作所有 User Story 共用的核心元件（必須先完成才能進行 User Story）

### Models

- [x] T008 [P] Implement PopupType enum in `CarSystem/PopupChain/Models/PopupType.swift`
  - Cases: tutorial, interstitialAd, newFeature, dailyCheckIn, predictionResult
  - Conform to String, CaseIterable

- [x] T009 [P] Implement PopupResult enum in `CarSystem/PopupChain/Models/PopupResult.swift`
  - Cases: completed, dismissed, failed(Error)

- [x] T010 [P] Implement PopupChainError enum in `CarSystem/PopupChain/Models/PopupChainError.swift`
  - Cases: maxPopupsReached, popupDisplayFailed, chainInterrupted, storageError
  - Conform to Error, LocalizedError

- [x] T011 Implement PopupUserState struct in `CarSystem/PopupChain/Models/PopupUserState.swift`
  - Properties: hasSeenTutorial, lastCheckInDate, lastAdShownDate, seenFeatureAnnouncements, notifiedPredictionResults
  - Conform to Codable, Equatable
  - Add helper methods: hasCheckedInToday(), hasShownAdToday()

### Protocols

- [x] T012 Implement PopupHandler protocol in `CarSystem/PopupChain/Protocols/PopupHandler.swift`
  - Property: popupType
  - Property: stopsChainOnDismiss (預設 false，用於控制 dismiss 後是否終止彈窗鏈)
  - Methods: shouldDisplay(state:), display(on:completion:), updateState(storage:)

### Services

- [x] T013 Implement PopupStateStorage class in `CarSystem/PopupChain/Services/PopupStateStorage.swift`
  - UserDefaults persistence layer
  - Methods: load(), save(), markTutorialSeen(), markDailyCheckIn(), markAdShown(), markFeatureSeen(id:), markPredictionNotified(id:)
  - Include PopupStateStorageProtocol for testability

- [x] T014 Implement PopupChainManager class in `CarSystem/PopupChain/Services/PopupChainManager.swift`
  - ObservableObject with @Published: currentPopup, displayedCount, isRunning
  - Methods: startChain(on:), proceedToNext(), cancelChain()
  - Array order = priority order (no sorting needed)
  - ~~Enforce max 3 popups per session (FR-010)~~ **[已移除]** 無數量上限
  - Skip failed popups without retry (FR-011)

---

## Phase 3: User Story 1 - 新用戶首次進入 App [P1]

**Story Goal**: 新用戶首次打開 App 時看到新手教學引導

**Independent Test**: 清除用戶資料後重新開啟 App，驗證新手教學彈窗正確顯示

**Acceptance Criteria**:
- 用戶從未看過 → 顯示新手教學
- 完成/關閉後 → 記錄已看過，檢查下一個
- 已看過 → 不再顯示

### Implementation

- [x] T015 [US1] Implement TutorialPopupHandler in `CarSystem/PopupChain/Handlers/TutorialPopupHandler.swift`
  - shouldDisplay: return !state.hasSeenTutorial
  - display: Present tutorial UI (UIAlertController or custom view)
  - updateState: storage.markTutorialSeen()

- [x] T016 [US1] Create tutorial popup UI in `CarSystem/PopupChain/Views/TutorialPopupView.swift` (optional custom view)
  - Using UIAlertController for MVP, custom view can be added later

---

## Phase 4: User Story 2 - 老用戶每日簽到流程 [P1]

**Story Goal**: 老用戶每天打開 App 時看到簽到彈窗

**Independent Test**: 模擬不同日期登入，驗證簽到彈窗在當日首次登入時正確顯示

**Acceptance Criteria**:
- 今日未簽到 → 顯示簽到彈窗
- 完成/關閉後 → 記錄當日簽到狀態
- 今日已簽到 → 跳過

### Implementation

- [x] T017 [US2] Implement DailyCheckInHandler in `CarSystem/PopupChain/Handlers/DailyCheckInHandler.swift`
  - shouldDisplay: return !state.hasCheckedInToday()
  - display: Present check-in UI
  - updateState: storage.markDailyCheckIn()

- [x] T018 [US2] Create check-in popup UI in `CarSystem/PopupChain/Views/CheckInPopupView.swift` (optional custom view)
  - Using UIAlertController for MVP, custom view can be added later

---

## Phase 5: User Story 3 - 猜多空結果通知 [P2]

**Story Goal**: 用戶有預測結果時在進入 App 時看到結果

**Independent Test**: 建立預測紀錄並等待結果產生後，驗證結果彈窗正確顯示

**Acceptance Criteria**:
- 有待顯示結果 → 顯示結果彈窗
- 關閉後 → 標記已通知
- 無結果 → 跳過

### Implementation

- [x] T019 [US3] Implement PredictionResultHandler in `CarSystem/PopupChain/Handlers/PredictionResultHandler.swift`
  - shouldDisplay: Check for pending prediction results not in notifiedPredictionResults
  - display: Present result UI with prediction outcome
  - updateState: storage.markPredictionNotified(id:)

- [x] T020 [US3] Create prediction result popup UI in `CarSystem/PopupChain/Views/PredictionResultPopupView.swift` (optional custom view)
  - Using UIAlertController for MVP, custom view can be added later

---

## Phase 6: User Story 4 - 新功能公告推送 [P2]

**Story Goal**: 用戶在有新功能公告時收到通知

**Independent Test**: 設定新功能公告內容並標記用戶未讀，驗證公告彈窗正確顯示

**Acceptance Criteria**:
- 有未讀公告 → 顯示新功能彈窗
- 關閉後 → 記錄已看過
- 已看過所有公告 → 跳過

### Implementation

- [x] T021 [US4] Implement NewFeaturePopupHandler in `CarSystem/PopupChain/Handlers/NewFeaturePopupHandler.swift`
  - shouldDisplay: Check for unseen feature announcements
  - display: Present feature announcement UI
  - updateState: storage.markFeatureSeen(id:)

- [x] T022 [US4] Create new feature popup UI in `CarSystem/PopupChain/Views/NewFeaturePopupView.swift` (optional custom view)
  - Using UIAlertController for MVP, custom view can be added later

---

## Phase 7: User Story 5 - 插頁式廣告展示 [P3]

**Story Goal**: 在適當時機向用戶展示插頁式廣告（每日最多 1 次）

**Independent Test**: 設定廣告活動並驗證在符合條件時正確顯示廣告彈窗

**Acceptance Criteria**:
- 今日未看過 → 顯示廣告 (FR-012) *(單機模式：廣告永遠可用)*
- 關閉後 → 記錄已曝光及當日已顯示
- 今日已看過 → 跳過

### Implementation

- [x] T023 [US5] Implement InterstitialAdHandler in `CarSystem/PopupChain/Handlers/InterstitialAdHandler.swift`
  - shouldDisplay: return !state.hasShownAdToday() *(單機模式：廣告永遠可用)*
  - display: Present interstitial ad UI (內建預設廣告內容)
  - updateState: storage.markAdShown()

- [x] T024 [US5] Create interstitial ad popup UI in `CarSystem/PopupChain/Views/InterstitialAdView.swift` (optional custom view)
  - Using UIAlertController for MVP, custom view can be added later

---

## Phase 8: Integration & Polish

**Goal**: 整合到主畫面並處理跨功能需求

### Integration

- [x] T025 Create PopupPresenter utility in `CarSystem/PopupChain/Views/PopupPresenter.swift`
  - Unified popup presentation logic
  - Handle different popup types (Alert, Custom View)

- [x] T026 Integrate PopupChainManager into CarViewController in `CarSystem/CarViewController.swift`
  - Initialize handlers array with correct order (FR-002)
  - Call startChain(on:) in viewDidAppear
  - Setup Combine bindings for state observation

### Edge Cases (FR-011)

- [x] T027 ~~Implement max 3 popups limit logic~~ **[已移除]** 無數量上限
  - ~~Track displayedCount~~
  - ~~Stop chain when limit reached~~
  - 已從 PopupChainManager 移除此限制

- [x] T028 Implement error handling and skip logic in `CarSystem/PopupChain/Services/PopupChainManager.swift`
  - On .failed result → proceedToNext() without retry
  - (Already implemented in T014)

### Testing

- [x] T029 [P] Create PopupStateStorageTests in `CarSystemTests/PopupChainTests/PopupStateStorageTests.swift`
  - Test load/save cycle
  - Test mark methods

- [x] T030 [P] Create PopupChainManagerTests in `CarSystemTests/PopupChainTests/PopupChainManagerTests.swift`
  - Test priority order (array index)
  - ~~Test max 3 popups limit~~ **[已更新]** Test displays all popups (無上限)
  - Test skip on failure

- [x] T031 [P] Create PopupHandlerTests in `CarSystemTests/PopupChainTests/PopupHandlerTests.swift`
  - Test each handler's shouldDisplay logic

---

## Dependencies

```
Phase 1 (Setup)
    │
    ▼
Phase 2 (Foundational) ─────────────────────────────────────┐
    │                                                        │
    ├──────────┬──────────┬──────────┬──────────┐           │
    ▼          ▼          ▼          ▼          ▼           │
Phase 3    Phase 4    Phase 5    Phase 6    Phase 7         │
  [US1]      [US2]      [US3]      [US4]      [US5]         │
    │          │          │          │          │           │
    └──────────┴──────────┴──────────┴──────────┘           │
                          │                                  │
                          ▼                                  │
                    Phase 8 (Integration) ◄──────────────────┘
```

**Key Dependencies**:
- All User Story phases depend on Phase 2 (Foundational)
- User Story phases (3-7) can be implemented in parallel
- Phase 8 depends on all User Story phases

---

## Parallel Execution Opportunities

### Within Phase 2 (Foundational)
```
T008, T009, T010 can run in parallel (independent enums)
T011 depends on nothing
T012 depends on T008, T009
T013 depends on T011
T014 depends on T008, T009, T010, T011, T012, T013
```

### User Story Phases (3-7)
```
All User Story phases can run in parallel after Phase 2 completes:
- Phase 3 [US1]: T015, T016
- Phase 4 [US2]: T017, T018
- Phase 5 [US3]: T019, T020
- Phase 6 [US4]: T021, T022
- Phase 7 [US5]: T023, T024
```

### Within Phase 8 (Integration)
```
T029, T030, T031 can run in parallel (independent test files)
T025, T026 should be sequential
T027, T028 can be done with T014 or in Phase 8
```

---

## Implementation Strategy

### MVP Scope (Recommended)
1. **Phase 1**: Setup
2. **Phase 2**: Foundational (all core infrastructure)
3. **Phase 3 [US1]**: Tutorial popup only

**MVP Deliverable**: 完整的彈窗鏈架構 + 新手教學彈窗，可獨立測試驗證

### Incremental Delivery
- **Increment 1**: MVP (US1)
- **Increment 2**: Add US2 (Daily Check-in) - P1 priority
- **Increment 3**: Add US3, US4 (P2 priorities)
- **Increment 4**: Add US5 (Ads) - P3 priority
- **Increment 5**: Integration & Polish

---

## Summary

| Metric | Count |
|--------|-------|
| **Total Tasks** | 31 |
| **Setup Tasks** | 7 |
| **Foundational Tasks** | 7 |
| **US1 Tasks** | 2 |
| **US2 Tasks** | 2 |
| **US3 Tasks** | 2 |
| **US4 Tasks** | 2 |
| **US5 Tasks** | 2 |
| **Integration Tasks** | 7 |
| **Parallelizable Tasks** | 15 |

### Files to Create

| Category | Files |
|----------|-------|
| Models | PopupType.swift, PopupResult.swift, PopupChainError.swift, PopupUserState.swift |
| Protocols | PopupHandler.swift |
| Services | PopupStateStorage.swift, PopupChainManager.swift |
| Handlers | TutorialPopupHandler.swift, DailyCheckInHandler.swift, PredictionResultHandler.swift, NewFeaturePopupHandler.swift, InterstitialAdHandler.swift |
| Views | PopupPresenter.swift, TutorialPopupView.swift, CheckInPopupView.swift, PredictionResultPopupView.swift, NewFeaturePopupView.swift, InterstitialAdView.swift |
| Tests | PopupStateStorageTests.swift, PopupChainManagerTests.swift, PopupHandlerTests.swift |

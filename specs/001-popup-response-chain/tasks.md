# Tasks: Popup Response Chain System

**Input**: Design documents from `/specs/001-popup-response-chain/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: 根據規格文件要求（50+ 測試案例），本任務清單包含測試任務。

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

Based on plan.md structure:
- **Source**: `PopupChain/` at repository root
- **Tests**: `PopupChainTests/` at repository root

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Create project directory structure per plan.md (PopupChain/, PopupChainTests/)
- [ ] T002 [P] Create PopupChain Xcode project/package with iOS 15.0+ target
- [ ] T003 [P] Configure XCTest target for PopupChainTests

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Models (Shared by all stories)

- [ ] T004 [P] Create PopupType enum with priority and resetPolicy in PopupChain/Models/PopupType.swift
- [ ] T005 [P] Create PopupState struct in PopupChain/Models/PopupState.swift
- [ ] T006 [P] Create PopupError enum in PopupChain/Models/PopupError.swift
- [ ] T007 [P] Create PopupEvent enum in PopupChain/Models/PopupEvent.swift
- [ ] T008 [P] Create PopupHandleResult enum in PopupChain/Models/PopupHandleResult.swift
- [ ] T009 [P] Create UserInfo struct with test profiles in PopupChain/Models/UserInfo.swift
- [ ] T010 Create PopupContext struct in PopupChain/Models/PopupContext.swift

### Protocols (Shared by all stories)

- [ ] T011 [P] Define PopupHandler protocol in PopupChain/Protocols/PopupHandler.swift
- [ ] T012 [P] Define PopupStateRepository protocol in PopupChain/Protocols/PopupStateRepository.swift
- [ ] T013 [P] Define PopupPresenter protocol in PopupChain/Protocols/PopupPresenter.swift
- [ ] T014 [P] Define PopupEventObserver protocol in PopupChain/Protocols/PopupEventObserver.swift
- [ ] T015 [P] Define Logger protocol with LogLevel in PopupChain/Protocols/Logger.swift

### Mock Infrastructure (Shared by all tests)

- [ ] T016 [P] Create MockPopupStateRepository in PopupChainTests/Mocks/MockPopupStateRepository.swift
- [ ] T017 [P] Create MockPopupPresenter in PopupChainTests/Mocks/MockPopupPresenter.swift
- [ ] T018 [P] Create MockLogger in PopupChainTests/Mocks/MockLogger.swift
- [ ] T019 [P] Create SpyPopupEventObserver in PopupChainTests/Mocks/SpyPopupEventObserver.swift
- [ ] T020 Create InMemoryPopupStateRepository in PopupChain/Repositories/InMemoryPopupStateRepository.swift

### Base Handler (Required for all handlers)

- [ ] T021 Create BasePopupHandler abstract class in PopupChain/Handlers/BasePopupHandler.swift

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - First-Time User Tutorial Flow (Priority: P1) 🎯 MVP

**Goal**: New user sees tutorial popup, chain terminates after dismissal

**Independent Test**: Create new user profile, verify only tutorial popup appears, confirm no subsequent popups after dismissal

### Tests for User Story 1

- [ ] T022 [P] [US1] Unit tests for TutorialPopupHandler in PopupChainTests/HandlerTests/TutorialPopupHandlerTests.swift
- [ ] T023 [P] [US1] Integration test for new user tutorial flow in PopupChainTests/IntegrationTests/PopupChainIntegrationTests.swift

### Implementation for User Story 1

- [ ] T024 [US1] Implement TutorialPopupHandler with chain termination logic in PopupChain/Handlers/TutorialPopupHandler.swift
- [ ] T025 [US1] Create TutorialPopupView (Alert-based) in PopupChain/UI/PopupViews/TutorialPopupView.swift
- [ ] T026 [US1] Implement PopupChainManager with single-handler chain support in PopupChain/Services/PopupChainManager.swift
- [ ] T027 [US1] Implement ConsoleLogger for debugging in PopupChain/Services/ConsoleLogger.swift

**Checkpoint**: User Story 1 complete - new users see tutorial and chain terminates correctly

---

## Phase 4: User Story 2 - Returning User Popup Chain (Priority: P1)

**Goal**: Returning user sees applicable popups in sequence (Ad/NewFeature → CheckIn → PredictionResult)

**Independent Test**: Create returning user profile with various states, verify correct sequence appears

### Tests for User Story 2

- [ ] T028 [P] [US2] Unit tests for InterstitialAdPopupHandler in PopupChainTests/HandlerTests/InterstitialAdPopupHandlerTests.swift
- [ ] T029 [P] [US2] Unit tests for NewFeaturePopupHandler in PopupChainTests/HandlerTests/NewFeaturePopupHandlerTests.swift
- [ ] T030 [P] [US2] Unit tests for DailyCheckInPopupHandler in PopupChainTests/HandlerTests/DailyCheckInPopupHandlerTests.swift
- [ ] T031 [P] [US2] Unit tests for PredictionResultPopupHandler in PopupChainTests/HandlerTests/PredictionResultPopupHandlerTests.swift
- [ ] T032 [US2] Integration test for returning user full chain in PopupChainTests/IntegrationTests/PopupChainIntegrationTests.swift

### Implementation for User Story 2

- [ ] T033 [P] [US2] Implement InterstitialAdPopupHandler in PopupChain/Handlers/InterstitialAdPopupHandler.swift
- [ ] T034 [P] [US2] Implement NewFeaturePopupHandler with Ad exclusivity logic in PopupChain/Handlers/NewFeaturePopupHandler.swift
- [ ] T035 [P] [US2] Implement DailyCheckInPopupHandler with daily reset logic in PopupChain/Handlers/DailyCheckInPopupHandler.swift
- [ ] T036 [P] [US2] Implement PredictionResultPopupHandler in PopupChain/Handlers/PredictionResultPopupHandler.swift
- [ ] T037 [P] [US2] Create InterstitialAdPopupView in PopupChain/UI/PopupViews/InterstitialAdPopupView.swift
- [ ] T038 [P] [US2] Create NewFeaturePopupView in PopupChain/UI/PopupViews/NewFeaturePopupView.swift
- [ ] T039 [P] [US2] Create DailyCheckInPopupView in PopupChain/UI/PopupViews/DailyCheckInPopupView.swift
- [ ] T040 [P] [US2] Create PredictionResultPopupView in PopupChain/UI/PopupViews/PredictionResultPopupView.swift
- [ ] T041 [US2] Update PopupChainManager to build full 5-handler chain in PopupChain/Services/PopupChainManager.swift
- [ ] T042 [US2] Add 0.3-0.5s delay between popup transitions in PopupChainManager

**Checkpoint**: User Story 2 complete - returning users see full popup sequence in correct order

---

## Phase 5: User Story 3 - Popup State Persistence (Priority: P1)

**Goal**: Popup states persist across app restarts using UserDefaults

**Independent Test**: Display popup, close it, simulate app restart, verify popup doesn't reappear

### Tests for User Story 3

- [ ] T043 [P] [US3] Unit tests for InMemoryPopupStateRepository in PopupChainTests/RepositoryTests/InMemoryPopupStateRepositoryTests.swift
- [ ] T044 [P] [US3] Unit tests for UserDefaultsPopupStateRepository in PopupChainTests/RepositoryTests/UserDefaultsPopupStateRepositoryTests.swift
- [ ] T045 [US3] Integration test for state persistence across restarts in PopupChainTests/IntegrationTests/PopupChainIntegrationTests.swift

### Implementation for User Story 3

- [ ] T046 [US3] Implement UserDefaultsPopupStateRepository with key schema in PopupChain/Repositories/UserDefaultsPopupStateRepository.swift
- [ ] T047 [US3] Add daily reset detection for DailyCheckIn in UserDefaultsPopupStateRepository
- [ ] T048 [US3] Integrate repository into PopupChainManager state updates

**Checkpoint**: User Story 3 complete - popup states persist correctly across app restarts

---

## Phase 6: User Story 4 - Multi-Account State Isolation (Priority: P2)

**Goal**: Different user accounts have separate popup states

**Independent Test**: Create two user profiles, view popups on one, switch to other, verify independent state

### Tests for User Story 4

- [ ] T049 [P] [US4] Unit tests for multi-account isolation in PopupChainTests/RepositoryTests/UserDefaultsPopupStateRepositoryTests.swift
- [ ] T050 [US4] Integration test for multi-account scenarios in PopupChainTests/IntegrationTests/MultiAccountIsolationTests.swift

### Implementation for User Story 4

- [ ] T051 [US4] Verify memberId-based key isolation in UserDefaultsPopupStateRepository
- [ ] T052 [US4] Add resetUser(memberId:) method for account-specific reset
- [ ] T053 [US4] Update integration to pass correct memberId from authentication system

**Checkpoint**: User Story 4 complete - multi-account state isolation verified

---

## Phase 7: User Story 5 - Error Recovery and Graceful Degradation (Priority: P2)

**Goal**: System continues chain when errors occur (repository/presenter failures)

**Independent Test**: Inject failures in repository, verify chain continues to subsequent popups

### Tests for User Story 5

- [ ] T054 [P] [US5] Create FaultyMockRepository for error injection in PopupChainTests/Mocks/FaultyMockRepository.swift
- [ ] T055 [P] [US5] Unit tests for error handling in handlers in PopupChainTests/HandlerTests/ErrorHandlingTests.swift
- [ ] T056 [US5] Integration test for graceful degradation in PopupChainTests/IntegrationTests/PopupChainIntegrationTests.swift

### Implementation for User Story 5

- [ ] T057 [US5] Add error logging in all handlers using Logger protocol
- [ ] T058 [US5] Implement skip-on-error logic in BasePopupHandler
- [ ] T059 [US5] Add presenter nil check and continue logic in PopupChainManager

**Checkpoint**: User Story 5 complete - system gracefully handles errors

---

## Phase 8: Observer Pattern & Event Publishing (Cross-cutting)

**Goal**: UI can observe popup events (FR-012)

### Tests

- [ ] T060 [P] Unit tests for PopupEventPublisher in PopupChainTests/ServiceTests/PopupEventPublisherTests.swift

### Implementation

- [ ] T061 Implement PopupEventPublisher with weak observer management in PopupChain/Services/PopupEventPublisher.swift
- [ ] T062 Integrate event publishing into PopupChainManager lifecycle methods
- [ ] T063 Add event publishing for willShow, didShow, willDismiss, didDismiss, chainCompleted

**Checkpoint**: Observer pattern integrated - UI can monitor popup events

---

## Phase 9: Debug UI & Developer Tools

**Goal**: Developer testing console for simulating scenarios

### Implementation

- [ ] T064 [P] Create PopupDebugViewController with user profile selection in PopupChain/UI/PopupDebugViewController.swift
- [ ] T065 [P] Add popup state toggles and simulation controls to debug UI
- [ ] T066 Add expected vs actual popup comparison display
- [ ] T067 Integrate debug console entry point with #if DEBUG guard

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Final improvements affecting multiple user stories

- [ ] T068 [P] Run all 50+ tests and verify pass rate in PopupChainTests/
- [ ] T069 [P] Verify quickstart.md examples compile and work
- [ ] T070 Code cleanup: ensure all files < 250 lines per SOLID guidelines
- [ ] T071 Add documentation comments to all public APIs
- [ ] T072 Verify session-once trigger behavior (FR-013) with SceneDelegate integration example
- [ ] T073 Final integration test: complete end-to-end scenario validation

---

## Dependencies & Execution Order

### Phase Dependencies

```text
Phase 1 (Setup) → Phase 2 (Foundational) → [User Stories 1-5 can proceed]
                                          ↓
                       Phase 8 (Observer) → Phase 9 (Debug UI)
                                          ↓
                                    Phase 10 (Polish)
```

### User Story Dependencies

| Story | Priority | Can Start After | Dependencies on Other Stories |
|-------|----------|-----------------|-------------------------------|
| US1 (Tutorial) | P1 | Phase 2 | None - MVP |
| US2 (Chain) | P1 | Phase 2 | None (uses same handlers as US1) |
| US3 (Persistence) | P1 | Phase 2 | None |
| US4 (Multi-Account) | P2 | US3 | Requires persistence implementation |
| US5 (Error Handling) | P2 | Phase 2 | None |

### Parallel Opportunities

**Phase 2 (High parallelism)**:
- All models (T004-T010) can run in parallel
- All protocols (T011-T015) can run in parallel
- All mocks (T016-T019) can run in parallel

**User Story Phases**:
- Handler tests within each story can run in parallel
- Handler implementations within US2 can run in parallel (T033-T036)
- Popup views within US2 can run in parallel (T037-T040)

---

## Parallel Example: Phase 2 Models

```bash
# Launch all models in parallel:
Task: "Create PopupType enum in PopupChain/Models/PopupType.swift"
Task: "Create PopupState struct in PopupChain/Models/PopupState.swift"
Task: "Create PopupError enum in PopupChain/Models/PopupError.swift"
Task: "Create PopupEvent enum in PopupChain/Models/PopupEvent.swift"
Task: "Create PopupHandleResult enum in PopupChain/Models/PopupHandleResult.swift"
Task: "Create UserInfo struct in PopupChain/Models/UserInfo.swift"
```

## Parallel Example: User Story 2 Handlers

```bash
# Launch all US2 handlers in parallel:
Task: "Implement InterstitialAdPopupHandler in PopupChain/Handlers/InterstitialAdPopupHandler.swift"
Task: "Implement NewFeaturePopupHandler in PopupChain/Handlers/NewFeaturePopupHandler.swift"
Task: "Implement DailyCheckInPopupHandler in PopupChain/Handlers/DailyCheckInPopupHandler.swift"
Task: "Implement PredictionResultPopupHandler in PopupChain/Handlers/PredictionResultPopupHandler.swift"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1 (Tutorial)
4. **STOP and VALIDATE**: Test new user flow independently
5. Deploy/demo if ready - new users can see tutorial

### Incremental Delivery

1. Phase 1-2 → Foundation ready
2. + US1 → Test → Deploy (Tutorial works!)
3. + US2 → Test → Deploy (Full chain works!)
4. + US3 → Test → Deploy (Persistence works!)
5. + US4 → Test → Deploy (Multi-account works!)
6. + US5 → Test → Deploy (Error handling works!)
7. + Phase 8-10 → Polish → Final release

### Suggested MVP Scope

**Minimum**: User Stories 1 + 2 + 3 (P1 stories)
- New user tutorial flow
- Returning user full chain
- State persistence

**Extended**: Add US4 + US5 (P2 stories)
- Multi-account support
- Error resilience

---

## Summary

| Metric | Count |
|--------|-------|
| Total Tasks | 73 |
| Phase 1 (Setup) | 3 |
| Phase 2 (Foundational) | 18 |
| US1 (Tutorial) | 6 |
| US2 (Chain) | 15 |
| US3 (Persistence) | 6 |
| US4 (Multi-Account) | 5 |
| US5 (Error Handling) | 6 |
| Phase 8 (Observer) | 4 |
| Phase 9 (Debug UI) | 4 |
| Phase 10 (Polish) | 6 |
| Parallel Tasks [P] | 38 (52%) |

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing (TDD)
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- All handlers extend BasePopupHandler for shared chain logic
- UserDefaults keys use format: `popup_{memberId}_{popupType}`

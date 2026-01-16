# Feature Specification: Popup Response Chain System

**Feature Branch**: `001-popup-response-chain`
**Created**: 2026-01-16
**Status**: Draft
**Input**: User description: "Popup Response Chain System - Chain of Responsibility based popup display system that sequentially checks and displays popups when users re-enter the app"

## Clarifications

### Session 2026-01-16

- Q: 彈窗關閉互動方式？ → A: 僅按鈕關閉（彈窗內的「關閉」或「確定」按鈕）
- Q: 彈窗鏈觸發時機？ → A: 每次 App 啟動（從背景恢復或冷啟動）執行一次，同會話內不重複
- Q: 「猜多空結果」資料來源？ → A: 由 UserInfo 傳入 `hasPredictionResult` 布林值
- Q: 彈窗「已看過」狀態的重置週期？ → A: Tutorial/Ad/NewFeature 永久不重置；DailyCheckIn 每日重置；PredictionResult 有新結果時重置
- Q: 彈窗之間的過渡行為？ → A: 短暫延遲（0.3-0.5 秒），讓用戶有喘息空間

## Overview

When users re-open the app and enter the main screen, the system needs to check various popup display conditions in priority order. Only one popup is displayed at a time; after the user closes it, the system continues checking the next popup in the chain.

### Goals

- Implement an extensible, testable popup chain display system following SOLID principles
- Support 5 popup types with priority-based sequential display
- Enable easy addition of new popup types without modifying existing code

## User Scenarios & Testing *(mandatory)*

### User Story 1 - First-Time User Tutorial Flow (Priority: P1)

A new user opens the app for the first time and sees the tutorial popup. After closing the tutorial, the chain terminates (no further popups are shown).

**Why this priority**: First-time user experience is critical for user retention. The tutorial must display correctly and terminate the chain to avoid overwhelming new users.

**Independent Test**: Can be fully tested by creating a new user profile and verifying only the tutorial popup appears, then confirming no subsequent popups display after dismissal.

**Acceptance Scenarios**:

1. **Given** a user who has never seen the tutorial (`hasSeenTutorial == false`), **When** they enter the main screen, **Then** the tutorial popup is displayed
2. **Given** the tutorial popup is displayed, **When** the user closes it, **Then** no further popups are shown (chain terminates)
3. **Given** a user who has already seen the tutorial (`hasSeenTutorial == true`), **When** they enter the main screen, **Then** the tutorial popup is skipped and the chain continues to the next popup

---

### User Story 2 - Returning User Popup Chain (Priority: P1)

A returning user (who has completed the tutorial) enters the app and sees applicable popups in sequence: Interstitial Ad OR New Feature announcement, then Daily Check-in (if not checked in today), then Prediction Result (if available).

**Why this priority**: Core business value - ensures users see relevant content (ads, features, engagement prompts) in the correct order.

**Independent Test**: Can be tested by creating a returning user profile with various popup states and verifying the correct sequence of popups appears.

**Acceptance Scenarios**:

1. **Given** a returning user who hasn't seen Ad A (`hasSeenAd == false`), **When** they enter the main screen, **Then** the Interstitial Ad popup is displayed
2. **Given** a returning user who has seen Ad A (`hasSeenAd == true`) but not the new feature (`hasSeenNewFeature == false`), **When** they enter the main screen, **Then** the New Feature popup is displayed
3. **Given** a user who hasn't checked in today, **When** earlier popups are dismissed, **Then** the Daily Check-in popup is displayed
4. **Given** a user who has prediction results to view, **When** earlier popups are dismissed, **Then** the Prediction Result popup is displayed

---

### User Story 3 - Popup State Persistence (Priority: P1)

When a user views and closes a popup, the "seen" state is persisted. When they re-enter the app later, previously seen popups are skipped.

**Why this priority**: Essential for correct system behavior - without persistence, users would see the same popups repeatedly.

**Independent Test**: Can be tested by displaying a popup, closing it, simulating app restart, and verifying the popup doesn't appear again.

**Acceptance Scenarios**:

1. **Given** a user closes the Tutorial popup, **When** they re-enter the app, **Then** the Tutorial popup is not shown again
2. **Given** a user closes the Interstitial Ad popup, **When** they re-enter the app, **Then** the Interstitial Ad is not shown again (New Feature may show instead)
3. **Given** a user checks in today, **When** they re-enter the app later today, **Then** the Daily Check-in popup is not shown

---

### User Story 4 - Multi-Account State Isolation (Priority: P2)

Different user accounts maintain separate popup states. Switching accounts loads the correct state for each user.

**Why this priority**: Important for multi-user scenarios but not critical for single-user MVP.

**Independent Test**: Can be tested by creating two user profiles, viewing popups on one, switching to the other, and verifying independent state.

**Acceptance Scenarios**:

1. **Given** User A has seen all popups and User B is new, **When** switching from User A to User B, **Then** User B sees all applicable popups
2. **Given** User A has popup states saved, **When** logging out and back in as User A, **Then** User A's popup states are preserved
3. **Given** switching to a completely new account, **When** entering the app, **Then** the new account is treated as a fresh user

---

### User Story 5 - Error Recovery and Graceful Degradation (Priority: P2)

When errors occur (state read/write failures, presenter failures), the system gracefully continues to the next popup instead of crashing.

**Why this priority**: System stability is important but errors should be rare in normal operation.

**Independent Test**: Can be tested by injecting failures in the state repository and verifying the chain continues to subsequent popups.

**Acceptance Scenarios**:

1. **Given** the state repository fails to read Tutorial state, **When** entering the main screen, **Then** the Tutorial popup is skipped and the chain continues
2. **Given** the popup presenter fails to display a popup, **When** a popup should be shown, **Then** the error is logged and the chain continues
3. **Given** the state repository fails to save "seen" state, **When** a popup is closed, **Then** the error is logged and the chain continues

---

### Edge Cases

- What happens when a user is in the middle of viewing a popup and the app goes to background? The popup state is NOT marked as seen until explicitly dismissed by the user.
- How are popups dismissed? Only via explicit button tap (e.g., "Close" or "OK" button); background tap and swipe gestures do NOT dismiss popups.
- How does the system handle rapid popup dismissals? Each dismissal triggers the next check sequentially; rapid taps do not skip popups or cause race conditions.
- What happens if all popups have been seen? The chain completes with no popups shown.
- How is "today" determined for daily check-in? Uses local device calendar date.
- What if prediction results become available mid-chain? Results are checked at the time the Prediction handler runs in the chain.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST check popup conditions in priority order: Tutorial (1) → Interstitial Ad (2) → New Feature (3) → Daily Check-in (4) → Prediction Result (5)
- **FR-002**: System MUST display only one popup at a time; the next popup is checked only after the current one is dismissed
- **FR-013**: System MUST execute the popup chain once per app launch (cold start or background resume); subsequent navigation within the same session MUST NOT re-trigger the chain
- **FR-014**: System MUST wait 0.3-0.5 seconds after a popup is dismissed before displaying the next popup in the chain
- **FR-003**: Tutorial popup MUST terminate the chain after display (no subsequent popups shown for first-time users)
- **FR-004**: Interstitial Ad and New Feature popups MUST be mutually exclusive: Ad shown if `hasSeenAd == false`, otherwise New Feature shown if `hasSeenNewFeature == false`
- **FR-005**: Daily Check-in popup MUST only display if the user has not checked in on the current calendar day
- **FR-006**: Prediction Result popup MUST only display if prediction results exist and haven't been viewed
- **FR-007**: System MUST persist popup "seen" states per user account with the following reset rules:
  - Tutorial, Interstitial Ad, New Feature: permanent (never reset, shown only once per user)
  - Daily Check-in: resets daily (can show once per calendar day)
  - Prediction Result: resets when new prediction results become available
- **FR-008**: System MUST isolate popup states between different user accounts
- **FR-009**: System MUST continue the chain when any single popup check or display fails
- **FR-010**: System MUST log errors when popup operations fail
- **FR-011**: System MUST support adding new popup types without modifying existing handler code
- **FR-012**: System MUST notify observers when popups are shown, dismissed, or when the chain completes

### Key Entities

- **PopupType**: Enumeration of popup kinds (Tutorial, Interstitial Ad, New Feature, Daily Check-in, Prediction Result) with associated priorities
- **PopupState**: Tracks whether a popup has been shown, when it was last shown, and display count
- **PopupContext**: Contains user information, state repository reference, presenter reference, and logger for chain execution
- **UserInfo**: User identity and popup-related state flags (memberId, hasSeenTutorial, hasSeenAd, hasSeenNewFeature, lastCheckInDate, hasPredictionResult). The `hasPredictionResult` flag is passed in externally, consistent with other state flags.
- **PopupHandler**: Defines the contract for checking and handling a specific popup type in the chain
- **PopupEvent**: Represents lifecycle events (willShow, didShow, willDismiss, didDismiss, chainCompleted)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users see popups in correct priority order with 100% accuracy
- **SC-002**: Popup state persists correctly across app restarts for the same user account
- **SC-003**: Multi-account users experience isolated popup states with zero cross-contamination
- **SC-004**: First-time users see only the Tutorial popup on initial app entry
- **SC-005**: System gracefully handles errors and continues the popup chain in degraded scenarios
- **SC-006**: Adding a new popup type requires creating only one new handler class with no changes to existing handlers
- **SC-007**: Daily check-in popup appears once per calendar day maximum per user

## Assumptions

- The app uses UIKit for UI (not SwiftUI)
- State persistence uses UserDefaults (encapsulated via Repository pattern for testability)
- "Today" for check-in is determined by the local device calendar, not server time
- Popup UI implementation is simple Alert-style views for initial development; custom views are a future enhancement
- The system runs on iOS 15.0+ with Swift 5.9+
- Error handling follows a "log and continue" strategy rather than retry or user notification

## Dependencies

- Existing user session/authentication system to provide `memberId`
- Main screen view controller to trigger popup chain on appearance
- UserDefaults for state persistence (wrapped in Repository)

## Out of Scope

- Popup display animations (future enhancement)
- A/B testing for popup variations
- Analytics/conversion tracking for popups
- Custom popup UI designs (using system Alerts initially)
- Server-side popup configuration or remote feature flags
- Retry mechanisms for failed popup displays

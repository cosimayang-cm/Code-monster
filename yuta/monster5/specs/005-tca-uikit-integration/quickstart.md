# Quickstart: TCA + UIKit 整合實戰

**Feature**: Monster 5 - TCA + UIKit Integration

---

## Prerequisites

- Xcode 15.0+ (Swift 5.9+)
- iOS Simulator (iOS 15.0+)
- 網路連線（Login API + Posts API）

## Setup

### 1. Open Project

```bash
cd yuta/monster5/
open Monster5.xcodeproj
```

### 2. Resolve SPM Dependencies

Xcode 開啟後會自動解析 Swift Package Manager 依賴：
- `swift-composable-architecture` 1.7+

若未自動解析：`File → Packages → Resolve Package Versions`

### 3. Build & Run

- **Build**: `Cmd + B`
- **Run**: `Cmd + R` (選擇 iPhone Simulator)
- **Test**: `Cmd + U`

## Test Account

| Field | Value |
|-------|-------|
| Username | `emilys` |
| Password | `emilyspass` |

## Manual Test Flow

1. **Launch App** → 顯示 Login 頁面
2. **空欄位登入** → 顯示「請輸入帳號密碼」
3. **錯誤帳密登入** → 顯示 Error Toast → 3 秒後自動消失
4. **正確帳密登入** (`emilys` / `emilyspass`) → 動畫轉場到 Home
5. **Home 頁面** → 顯示 100 篇文章列表
6. **點擊任一文章** → push 到 PostDetail
7. **按讚** → likeCount +1 → 返回列表確認同步
8. **留言** → 輸入文字 → 送出 → commentCount +1
9. **分享** → 出現 UIActivityViewController → shareCount +1
10. **點擊留言按鈕 (從 Cell)** → push 到 PostDetail 且 keyboard 自動彈出
11. **殺掉 App 重開** → 互動數據保留

## API Endpoints

| API | Method | URL |
|-----|--------|-----|
| Login | POST | `https://dummyjson.com/auth/login` |
| Posts | GET | `https://jsonplaceholder.typicode.com/posts` |

## Architecture Overview

```text
AppFeature (Root Reducer)
├── LoginFeature → LoginViewController
└── HomeFeature → HomeViewController (UITableView)
    └── PostDetailFeature → PostDetailViewController (StackState navigation)

Dependencies:
├── AuthClient (login API)
├── PostsClient (posts API)
└── StorageClient (UserDefaults persistence)

Coordinator:
└── AppCoordinator (manages UIKit navigation based on Store state)
```

## Key TCA Patterns Used

| Pattern | Where | Purpose |
|---------|-------|---------|
| `observe {}` | All ViewControllers | UIKit state observation |
| `@DependencyClient` | AuthClient, PostsClient, StorageClient | Dependency injection |
| `StackState/StackAction` | HomeFeature → PostDetail | Push/pop navigation |
| Delegate Action | PostDetail → Home, Login → App | Child-to-parent communication |
| `cancellable` Effect | LoginFeature error timer | Cancelable auto-dismiss |
| `TestClock` | LoginFeatureTests | Deterministic time control |

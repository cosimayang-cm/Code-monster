# Monster 5: TCA + UIKit 整合實戰

## 目標
學習如何將 **The Composable Architecture (TCA)** 與 **UIKit** 整合，實作狀態管理、副作用處理、以及畫面轉場。

## 技術需求
- Swift 5.9+
- The Composable Architecture (TCA) 1.7+
- UIKit
- Combine

## TCA Repository
https://github.com/pointfreeco/swift-composable-architecture

---

## 題目一：Login 頁面

### 需求
實作一個登入頁面，使用 TCA 管理狀態，UIKit 建構 UI。

### API 資訊
- **Endpoint**: `POST https://dummyjson.com/auth/login`
- **Request Body**: JSON 格式，包含 `username` 和 `password` 欄位
- **Success Response**: 回傳用戶資訊（id, username, email, firstName, lastName, gender, image）以及 accessToken、refreshToken
- **API 文件**: https://dummyjson.com/docs/auth

#### 測試用 curl

成功登入：
```bash
curl -X POST https://dummyjson.com/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "emilys",
    "password": "emilyspass",
    "expiresInMins": 30
  }'
```

失敗登入：
```bash
curl -X POST https://dummyjson.com/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "wronguser",
    "password": "wrongpass"
  }'
```

### UI 需求
1. 帳號輸入欄位（UITextField）
2. 密碼輸入欄位（UITextField）
3. 登入按鈕（UIButton）
4. Loading 狀態顯示（UIActivityIndicatorView）
5. 登入失敗時顯示 Error Toast

### TCA 需求

#### State
需包含以下狀態：
- 帳號輸入值
- 密碼輸入值
- 是否正在載入中
- 錯誤訊息（可選）
- 登入成功後的用戶資訊（可選）

#### Action
需處理以下事件：
- 帳號輸入變更
- 密碼輸入變更
- 點擊登入按鈕
- API 回應（成功/失敗）
- 關閉錯誤訊息

#### Dependency
- 定義 AuthClient 依賴，提供登入功能

### 驗收條件
- [ ] 輸入帳號密碼後點擊登入，發送真實 API 請求
- [ ] Loading 狀態時按鈕 disabled，顯示 loading indicator
- [ ] 登入成功：轉場到第二頁（UITableView 頁面）
- [ ] 登入失敗：顯示 error toast，3 秒後自動消失
- [ ] 使用 TCA 的 `observe { }` 模式與 UIKit 整合

---

## 題目二：Posts 列表頁面

### 需求
實作一個文章列表頁面，使用 TCA 管理狀態，UIKit 的 UITableView 建構 UI。

### API 資訊
- **Endpoint**: `GET https://jsonplaceholder.typicode.com/posts`
- **Response**: 回傳 100 篇文章，每篇包含 `userId`、`id`、`title`、`body`
- **API 文件**: https://jsonplaceholder.typicode.com/

#### 測試用 curl
```bash
curl https://jsonplaceholder.typicode.com/posts
```

### UI 需求

#### Posts 列表頁（UITableView）
1. 使用 `UITableView` 顯示文章列表
2. 每個 Cell 顯示：
   - 文章標題（title）
   - 文章內容預覽（body，可截斷）
   - 按讚數
   - 留言數
   - 分享按鈕
3. 點擊 Cell 進入 Post Detail 頁面

#### Post Detail 頁（獨立 UIViewController）
1. 顯示完整文章內容（title、body）
2. 顯示按讚/留言/分享的 UI
3. 可進行按讚、留言操作
4. 使用 `UINavigationController` push 進入此頁面

### TCA 需求

#### 互動數據（按讚/留言/分享）
- API 不提供按讚數、留言數、分享數，需自行實作
- 使用 Local Storage 儲存互動數據（UserDefaults 或其他方式）
- 定義合適的 Model 儲存每篇文章的互動狀態

#### 狀態同步
- **重要**：在 Post Detail 頁面按讚後，返回列表頁時對應的 Cell 必須同步更新按讚狀態
- 因為是同一篇文章，狀態必須保持一致
- 請思考如何在 TCA 架構下實現此狀態同步

#### State
需包含以下狀態：
- 文章列表
- 每篇文章的互動數據（按讚數、留言數、是否已按讚等）
- 載入狀態
- 錯誤訊息
- 當前選中的文章（用於導航到 Detail）

#### Action
需處理以下事件：
- 載入文章列表
- API 回應處理
- 點擊文章（進入 Detail）
- 按讚操作
- 留言操作
- 分享操作
- 儲存/讀取 Local Storage

#### Dependency
- 定義 PostsClient 依賴，提供取得文章列表功能
- 定義 StorageClient 依賴，提供 Local Storage 讀寫功能

### 驗收條件
- [ ] 進入頁面時載入文章列表，發送真實 API 請求
- [ ] UITableView 正確顯示所有文章
- [ ] 每個 Cell 顯示按讚數、留言數、分享按鈕
- [ ] 點擊 Cell 使用 Navigation Controller push 到 Post Detail 頁面
- [ ] Post Detail 頁面可進行按讚操作
- [ ] 在 Detail 頁面按讚後，返回列表頁對應 Cell 的按讚狀態同步更新
- [ ] 互動數據使用 Local Storage 持久化儲存
- [ ] 使用 TCA 的 `observe { }` 模式與 UIKit 整合

---

## App 架構需求

### 導航管理
使用 TCA 管理畫面轉場，TCA 提供兩種導航模式：

1. **Tree-based Navigation**
   - 使用 `@Presents` + `PresentationAction` + `ifLet`

2. **Stack-based Navigation**
   - 使用 `StackState` + `StackAction` + `forEach`

請根據本題需求選擇適合的導航模式實作。

### 專案結構建議
```
Monster5/
├── App/
│   ├── AppFeature.swift      // App 層級 Reducer
│   └── AppCoordinator.swift  // UIKit 導航協調器
├── Features/
│   ├── Login/
│   │   ├── LoginFeature.swift
│   │   └── LoginViewController.swift
│   └── Home/
│       ├── HomeFeature.swift
│       ├── HomeViewController.swift
│       └── HomeTableViewCell.swift
├── Dependencies/
│   ├── AuthClient.swift
│   └── APIClient.swift
└── Models/
    └── User.swift
```

---

## 學習重點

1. **TCA + UIKit 整合**：使用 `observe { }` closure 觀察狀態變化，在 `viewDidLoad` 中設定觀察，透過 `store.send()` 發送 Action

2. **導航管理**：使用 TCA 導航模式控制畫面轉場，在 observe closure 中處理導航邏輯

3. **副作用處理**：使用 `Effect.run` 處理 async 操作，使用 `@Dependency` 注入依賴

4. **錯誤處理**：將 API 錯誤轉換為 UI 可顯示的訊息，實作自動消失的 Toast

5. **UITableView + TCA**：在 UITableView 中使用 TCA 管理列表狀態，處理 Cell 的 Action 傳遞

6. **狀態同步**：子頁面（Detail）的狀態變更如何同步回父頁面（List），保持資料一致性

7. **Local Storage**：使用 Dependency 封裝 Local Storage 操作，實現資料持久化

---

## 參考資源
- [TCA GitHub Repository](https://github.com/pointfreeco/swift-composable-architecture)
- [DummyJSON Auth API](https://dummyjson.com/docs/auth)
- [TCA UIKit Integration](https://www.iamsim.me/composable-architecture-and-uikit-the-view-controller/)
- [Observation in TCA](https://www.pointfree.co/blog/posts/130-observation-comes-to-the-composable-architecture)

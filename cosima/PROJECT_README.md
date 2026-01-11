# 🚗 Code Monster #1: Feature Toggle 車輛系統

Swift 實作的功能切換（Feature Toggle）設計模式示例。

## 📋 項目結構

```
cosima/
├── Package.swift                 # Swift Package 配置
├── Sources/
│   ├── Core/
│   │   └── Car.swift            # 核心實作（Car 類別和所有組件）
│   ├── Main/
│   │   └── main.swift           # 簡單使用示例
│   └── Tests/
│       └── main.swift           # 完整測試套件（8 個測試場景）
└── README.md                     # 本文件
```

## 🎯 核心概念

### Feature Toggle 設計模式
Feature Toggle 是一種設計模式，允許在運行時動態啟用或停用某些功能，而無需重新編譯或部署代碼。

### 實現的功能相依性

| 功能 | 相依條件 |
|------|----------|
| **空調系統** | 中控電腦 |
| **導航系統** | 中控電腦 |
| **娛樂系統** | 中控電腦 |
| **藍牙系統** | 中控電腦 |
| **倒車鏡頭** | 中控電腦 |
| **環景攝影** | 中控電腦 + 倒車鏡頭 |
| **盲點偵測** | 中控電腦 |
| **前方雷達** | 中控電腦 |
| **停車輔助** | 環景攝影 + 盲點偵測 |
| **車道維持** | 導航 + 前方雷達 + 引擎運行中 |
| **緊急煞車** | 前方雷達 + 引擎運行中 |
| **自動駕駛** | 車道維持 + 緊急煞車 + 環景攝影 |

## 🚀 使用方法

### 構建項目
```bash
cd /Users/cosima/CodeMonster/cosima
swift build
```

### 運行示例
```bash
# 運行簡單示例
./.build/debug/car-main

# 運行完整測試套件
./.build/debug/car-tests
```

## 💻 代碼示例

### 基本用法
```swift
let car = Car()

// 開啟中控電腦
car.turnOnCentralComputer()

// 啟用功能
do {
    try car.enableFeature(.airConditioner)
    print("✅ 空調系統已啟用")
} catch {
    print("❌ 啟用失敗: \(error)")
}

// 查詢功能狀態
if car.isFeatureEnabled(.airConditioner) {
    print("空調系統已啟用")
}

// 獲取所有已啟用的功能
for feature in car.getEnabledFeatures() {
    print("- \(feature.rawValue)")
}
```

### 處理相依性
```swift
// 嘗試啟用需要倒車鏡頭的環景攝影
do {
    try car.enableFeature(.surroundView)
} catch FeatureError.dependencyNotMet(let reason) {
    print("無法啟用：\(reason)")
}

// 先啟用相依功能
try car.enableFeature(.rearCamera)
try car.enableFeature(.surroundView)  // 現在可以啟用
```

### 級聯停用
```swift
// 停用倒車鏡頭會自動停用所有依賴它的功能
// 例如：環景、停車輔助、自動駕駛
try car.disableFeature(.rearCamera)
```

## 🧪 測試場景

項目包含 8 個完整的測試場景：

### 1️⃣ 基本功能啟用
驗證基本功能（空調、娛樂系統）可以正常啟用。

### 2️⃣ 引擎相依性
驗證需要引擎運行的功能（緊急煞車、車道維持）在引擎停止時無法啟用。

### 3️⃣ 中控電腦相依性
驗證所有功能都需要中控電腦開啟才能使用。

### 4️⃣ 功能相依性
驗證環景攝影需要倒車鏡頭才能啟用。

### 5️⃣ 複雜相依性 - 自動駕駛
驗證可以成功啟用複雜的功能鏈（最終啟用自動駕駛）。

### 6️⃣ 停用時的級聯效應
驗證停用倒車鏡頭會自動級聯停用所有依賴它的功能。

### 7️⃣ 引擎停止時的影響
驗證停止引擎會停用所有需要引擎運行的功能。

### 8️⃣ 中控電腦關閉時的影響
驗證關閉中控電腦會停用所有依賴它的功能。

## 🔑 關鍵類和協議

### CarComponent 協議
所有車輛組件都實現此協議：
```swift
protocol CarComponent {
    var name: String { get }
    var isEnabled: Bool { get }
}
```

### Feature 列舉
所有可切換的功能：
```swift
enum Feature: String, CaseIterable {
    case airConditioner
    case navigation
    case entertainment
    case bluetooth
    case rearCamera
    case surroundView
    case blindSpotDetection
    case frontRadar
    case parkingAssist
    case laneKeeping
    case emergencyBraking
    case autoPilot
}
```

### FeatureError 錯誤類型
```swift
enum FeatureError: Error, Equatable {
    case dependencyNotMet(String)
    case featureDependency(String)
    case engineNotRunning
    case centralComputerOffline
    case cannotDisable(String)
}
```

### Car 類別的主要 API
```swift
public class Car {
    // 啟用/停用功能
    func enableFeature(_ feature: Feature) throws
    func disableFeature(_ feature: Feature) throws
    
    // 查詢功能狀態
    func isFeatureEnabled(_ feature: Feature) -> Bool
    func getEnabledFeatures() -> [Feature]
    
    // 控制引擎和中控電腦
    func startEngine() throws
    func stopEngine() throws
    func turnOnCentralComputer()
    func turnOffCentralComputer() throws
}
```

## 📚 設計模式亮點

1. **相依性管理**：通過樹型結構管理功能間的相依性
2. **級聯操作**：停用功能時會遞迴停用所有依賴它的功能
3. **狀態同步**：中控電腦和引擎的狀態變化會自動影響相關功能
4. **錯誤處理**：通過自定義 Error 類型提供詳細的錯誤信息

## 🎓 學習收穫

通過實現此項目，你將學到：
- Swift 的 Protocol 和 Error Handling
- 設計模式（Feature Toggle、Dependency Injection）
- 遞迴算法和狀態管理
- Swift Package Manager 的使用
- 單元測試的最佳實踐

## 📝 文件說明

- **Sources/Core/Car.swift**：包含所有的核心類和協議實現，共約 400 行代碼
- **Sources/Main/main.swift**：簡單的使用示例
- **Sources/Tests/main.swift**：完整的測試套件，包含 8 個測試函數

---

**開發者**：GitHub Copilot  
**日期**：2026 年 1 月 11 日  
**版本**：1.0

# Code Monster #1: Feature Toggle 車輛系統

## 學習目標

透過設計一個車輛系統，學習 **Feature Toggle** 設計模式：
- 理解如何在物件層級管理功能開關
- 實作功能相依性檢查
- 設計清晰的 API 介面

---

## 需求規格

### 元件設計

設計以下元件，每個元件需實作 `CarComponent` Protocol：

| # | 元件 | 類別名稱 | 類型 | 可 Toggle |
|---|------|----------|------|-----------|
| 1 | 車輪 | `Wheel` | 必要 | 否 |
| 2 | 引擎 | `Engine` | 必要 | 否 |
| 3 | 空調系統 | `AirConditioner` | 選配 | 是 |
| 4 | 導航系統 | `NavigationSystem` | 選配 | 是 |
| 5 | 自動駕駛 | `AutoPilot` | 選配 | 是 |
| 6 | 倒車鏡頭 | `RearCamera` | 選配 | 是 |
| 7 | 停車輔助 | `ParkingAssist` | 選配 | 是 |
| 8 | 車道維持 | `LaneKeeping` | 選配 | 是 |
| 9 | 盲點偵測 | `BlindSpotDetection` | 選配 | 是 |
| 10 | 緊急煞車 | `EmergencyBraking` | 選配 | 是 |

### Car 類別 Spec

- 定義 `Feature` 列舉，包含八個可 toggle 的功能
- 定義 `FeatureError` 錯誤類型
- `Car` 類別需提供以下功能：
  - 啟用指定功能，回傳成功或錯誤
  - 停用指定功能，回傳成功或錯誤
  - 查詢指定功能是否啟用
  - 取得所有已啟用功能的列表

---

## Toggle 規則

### 功能相依性

| 功能 | 相依條件 |
|------|----------|
| `airConditioner` | 無相依 |
| `navigation` | Engine 運行中 |
| `rearCamera` | Engine 運行中 |
| `blindSpotDetection` | Engine 運行中 |
| `parkingAssist` | RearCamera + BlindSpotDetection |
| `laneKeeping` | Navigation + BlindSpotDetection |
| `emergencyBraking` | BlindSpotDetection |
| `autoPilot` | Navigation + LaneKeeping + EmergencyBraking |

### 相依性圖

```
                    ┌─────────────────┐
                    │    AutoPilot    │
                    └────────┬────────┘
           ┌─────────────────┼─────────────────┐
           ▼                 ▼                 ▼
    ┌─────────────┐   ┌─────────────┐   ┌─────────────┐
    │ LaneKeeping │   │ Navigation  │   │ Emergency   │
    │             │   │             │   │ Braking     │
    └──────┬──────┘   └──────┬──────┘   └──────┬──────┘
           │                 │                 │
     ┌─────┴─────┐           │                 │
     ▼           ▼           │                 │
┌─────────┐ ┌─────────────┐  │                 │
│Navigation│ │BlindSpot   │◀─┴─────────────────┘
│         │ │Detection   │
└────┬────┘ └──────┬─────┘
     │             │
     │      ┌──────┴──────┐
     │      ▼             ▼
     │ ┌─────────┐ ┌─────────────┐
     │ │Parking  │ │ RearCamera  │
     │ │Assist   │ └──────┬──────┘
     │ └────┬────┘        │
     │      │             │
     └──────┴──────┬──────┘
                   ▼
            ┌─────────────┐
            │   Engine    │
            │ (運行中)     │
            └─────────────┘
```

### 啟用/停用邏輯

- **啟用時**: 檢查所有相依條件是否滿足，不滿足則回傳錯誤
- **停用時**: 若有其他功能依賴此功能，選擇以下其一：
  - 方案 A: 回傳錯誤，拒絕停用
  - 方案 B: 連帶停用所有依賴它的功能（遞迴）

---

## 進階需求

### Engine 狀態整合

- Engine 需有 start/stop 功能與運行狀態
- Engine 停止時，所有依賴 Engine 的功能必須連鎖停用

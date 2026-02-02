# Research: RPG 道具系統

**Feature**: 003-rpg-item-system
**Date**: 2026-01-30

## 研究摘要

本專案技術選型已明確（Swift 5.9+ / Foundation），此研究文件記錄關鍵設計決策與最佳實踐。

---

## 1. UUID 生成策略

### 決策
使用 Swift 原生 `UUID` 類型（UUID v4）

### 理由
- Foundation 內建，無需額外依賴
- 全域唯一性保證
- 符合規格書要求
- 效能優秀，適合大量生成

### 替代方案評估
| 方案 | 優點 | 缺點 | 結論 |
|------|------|------|------|
| UUID v4 (Foundation) | 內建、簡單、唯一性保證 | 無法排序 | ✅ 採用 |
| 自訂遞增 ID | 可排序、可讀 | 需管理狀態、跨實例衝突 | ❌ 不採用 |
| 時間戳 + 隨機 | 可排序 | 實作複雜、碰撞風險 | ❌ 不採用 |

---

## 2. Bitmask 實作方式

### 決策
使用 Swift `OptionSet` 協定搭配 `UInt32` raw value

### 理由
- Swift 原生支援，語法優雅
- O(1) 時間複雜度的集合操作
- 型別安全
- 8 種詞條類型僅需 8 bits，`UInt32` 充足且預留擴展空間

### 實作範例
```swift
struct AffixType: OptionSet {
    let rawValue: UInt32

    static let crit            = AffixType(rawValue: 1 << 0)
    static let energyRecharge  = AffixType(rawValue: 1 << 1)
    static let attack          = AffixType(rawValue: 1 << 2)
    static let defense         = AffixType(rawValue: 1 << 3)
    static let hp              = AffixType(rawValue: 1 << 4)
    static let elementalMastery = AffixType(rawValue: 1 << 5)
    static let elementalDamage  = AffixType(rawValue: 1 << 6)
    static let healingBonus     = AffixType(rawValue: 1 << 7)
}
```

### 替代方案評估
| 方案 | 優點 | 缺點 | 結論 |
|------|------|------|------|
| OptionSet + UInt32 | 型別安全、語法優雅、O(1) | 需熟悉 OptionSet | ✅ 採用 |
| Set<AffixType> | 簡單直覺 | O(n) 查詢、記憶體較大 | ❌ 不採用 |
| 原始整數 Bitmask | 效能最佳 | 不型別安全、易出錯 | ❌ 不採用 |

---

## 3. 詞條權重隨機生成演算法

### 決策
使用加權隨機選擇（Weighted Random Selection）

### 理由
- 符合規格書要求的權重分布
- 實作簡單易理解
- 可測試性高

### 演算法
```
1. 計算所有詞條權重總和 totalWeight
2. 生成 [0, totalWeight) 範圍內的隨機數 r
3. 累加權重直到超過 r，返回對應詞條
```

### 可測試性設計
- 注入隨機數生成器協定 (`RandomNumberGenerator`)
- 測試時使用可預測的 seeded generator

---

## 4. 數值計算公式

### 決策
採用加法疊加百分比的公式：
```
最終值 = (角色基礎值 + Σ固定加成) × (1 + Σ百分比加成)
```

### 理由
- 規格書 Clarification 中已確認
- 與主流遊戲（原神、崩鐵）設計一致
- 數值易於理解和預測
- 避免百分比乘法導致的數值爆炸

### 實作考量
- Stats 結構區分 `flatBonus` 和 `percentBonus`
- 計算時先合併所有裝備的同類加成，再套用公式

---

## 5. 物品模板 vs 實例設計

### 決策
採用 Flyweight Pattern（享元模式）

### 理由
- 模板為不可變共享資料，節省記憶體
- 實例只存儲差異資料（UUID、等級、詞條）
- 符合規格書 FR-003 要求

### 結構設計
```
ItemTemplate (struct, immutable)
├── templateId: String
├── name: String
├── slot: EquipmentSlot
├── rarity: Rarity
├── baseStats: Stats
└── ...

Item (class, mutable)
├── instanceId: UUID
├── templateId: String (reference to template)
├── level: Int
├── mainAffix: Affix
├── subAffixes: [Affix]
└── affixMask: AffixType (Bitmask)
```

---

## 6. 錯誤處理策略

### 決策
使用 Swift `Result` 類型和自訂 Error enum

### 理由
- Swift 標準做法
- 明確的錯誤類型
- 易於測試

### 錯誤類型設計
```swift
enum ItemSystemError: Error {
    case inventoryFull
    case slotMismatch(expected: EquipmentSlot, actual: EquipmentSlot)
    case levelRequirementNotMet(required: Int, current: Int)
    case templateNotFound(templateId: String)
    case emptyAffixPool
}
```

---

## 7. JSON 編解碼策略

### 決策
使用 Swift `Codable` 協定

### 理由
- Swift 原生支援
- 自動合成編解碼
- 支援自訂編解碼邏輯
- 與 Foundation JSONEncoder/JSONDecoder 無縫整合

### 考量
- Enum 使用 `String` rawValue 確保 JSON 可讀性
- OptionSet 需自訂編解碼（存儲 rawValue）

---

## 8. 測試策略

### 決策
遵循 TDD + Given-When-Then 結構

### 測試命名規範
```
testMethodNameWhenConditionThenExpectedResult
```

範例：
- `testEquipItemWhenSlotMatchesThenItemEquipped`
- `testCalculateStatsWhenMultipleItemsEquippedThenStatsCorrectlyAggregated`

### 測試類別
| 類別 | 說明 | 優先級 |
|------|------|--------|
| 單元測試 | 個別類型/方法的功能測試 | P1 |
| 整合測試 | 多個元件協作測試（如穿戴流程） | P2 |
| 屬性測試 | 隨機生成驗證（如詞條權重分布） | P3 |

---

## 結論

所有技術決策已確認，無待釐清事項。可進入 Phase 1 設計階段。

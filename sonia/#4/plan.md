# Implementation Plan: RPG 道具系統

**Branch**: `003-rpg-item-system` | **Date**: 2026-01-30 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `sonia/#4/spec.md`

## Summary

實作一個 RPG 遊戲的道具系統，包含物品模板/實例、裝備欄位、背包管理、詞條系統（含 Bitmask）、套裝效果等功能。採用純 Model 層實作，遵循 TDD 開發方法論，使用 Swift 5.9+ 與 Foundation 框架。

## Technical Context

**Language/Version**: Swift 5.9+
**Primary Dependencies**: Foundation (UUID, Codable, OptionSet)
**Storage**: 記憶體內操作 + JSON 序列化/反序列化
**Testing**: XCTest + TDD (Red → Green → Refactor)
**Target Platform**: macOS/iOS (純 Model 層，無 UI 依賴)
**Project Type**: Single project (練習專案)
**Performance Goals**:
- 數值計算 < 100ms
- Bitmask 查詢 O(1)
- UUID 唯一性 100%
**Constraints**:
- 純 Model 層，無 UI 依賴
- 保持乾淨架構但可適度簡化
- TDD：每項任務完成前須通過所有單元測試
**Scale/Scope**:
- 5 個裝備欄位
- 5 種稀有度
- 8 種詞條類型
- 背包容量 100 格（可配置）

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### 適用性評估

| 規範類別 | 適用性 | 說明 |
|---------|--------|------|
| PAGEs Architecture | ⚠️ 部分適用 | 純 Model 層，無 ViewModel/ViewComponent/StateManager |
| Dependency Injection | ✅ 適用 | 使用協定導向設計，支援依賴注入 |
| Testing Standards | ✅ 適用 | 遵循 Given-When-Then 結構，使用標準命名 |
| Code Quality | ✅ 適用 | 遵循 Swift 標準慣例 |
| XcodeGen | ⏭️ 不適用 | 練習專案，使用 Swift Package 或直接 Xcode 專案 |

### Gate 評估

| Gate | 狀態 | 說明 |
|------|------|------|
| Project Intelligence Scan | ⏭️ 略過 | 獨立練習專案，無既有架構需掃描 |
| Architecture Compliance | ✅ 通過 | 純 Model 層，不涉及 UI 架構規範 |
| Testing Standards | ✅ 通過 | 將遵循 Given-When-Then + 標準命名 |

### 違規追蹤

無違規。本專案為獨立練習專案，不涉及 PAGEs Framework 的 UI 層規範。

## Project Structure

### Documentation (this feature)

```text
sonia/#4/
├── spec.md              # 功能規格書
├── plan.md              # 本檔案（實作計畫）
├── research.md          # Phase 0 研究輸出
├── data-model.md        # Phase 1 資料模型
├── quickstart.md        # Phase 1 快速入門
└── tasks.md             # Phase 2 任務清單（由 /speckit.tasks 產生）
```

### Source Code (repository root)

```text
sonia/#4/
├── Sources/
│   └── ItemSystem/
│       ├── Models/
│       │   ├── EquipmentSlot.swift      # 裝備欄位列舉
│       │   ├── Rarity.swift             # 稀有度列舉
│       │   ├── Stats.swift              # 數值結構
│       │   ├── AffixType.swift          # 詞條類型 (OptionSet/Bitmask)
│       │   ├── Affix.swift              # 詞條結構
│       │   ├── ItemTemplate.swift       # 物品模板
│       │   └── Item.swift               # 物品實例
│       ├── Systems/
│       │   ├── AffixGenerator.swift     # 詞條生成器
│       │   ├── AffixPool.swift          # 詞條池
│       │   ├── EquipmentSet.swift       # 套裝定義
│       │   └── SetBonusCalculator.swift # 套裝效果計算
│       ├── Containers/
│       │   ├── Inventory.swift          # 背包
│       │   └── EquipmentSlots.swift     # 裝備欄
│       ├── Avatar/
│       │   └── Avatar.swift             # 角色
│       └── Persistence/
│           ├── ItemTemplateLoader.swift # 模板載入
│           └── ItemSerializer.swift     # 物品序列化
│
└── Tests/
    └── ItemSystemTests/
        ├── Models/
        │   ├── EquipmentSlotTests.swift
        │   ├── RarityTests.swift
        │   ├── StatsTests.swift
        │   ├── AffixTypeTests.swift
        │   ├── AffixTests.swift
        │   ├── ItemTemplateTests.swift
        │   └── ItemTests.swift
        ├── Systems/
        │   ├── AffixGeneratorTests.swift
        │   ├── AffixPoolTests.swift
        │   ├── EquipmentSetTests.swift
        │   └── SetBonusCalculatorTests.swift
        ├── Containers/
        │   ├── InventoryTests.swift
        │   └── EquipmentSlotsTests.swift
        ├── Avatar/
        │   └── AvatarTests.swift
        └── Persistence/
            ├── ItemTemplateLoaderTests.swift
            └── ItemSerializerTests.swift
```

**Structure Decision**: 採用簡化的 Clean Architecture 結構，依功能領域分層（Models → Systems → Containers → Avatar → Persistence），每層都有對應的測試目錄。

## Complexity Tracking

無需追蹤。本專案結構簡單，未違反任何架構限制。

---

## Phase 0: Research - COMPLETED

**輸出**: [research.md](./research.md)

關鍵決策摘要：
- UUID 生成：使用 Foundation 原生 `UUID` (v4)
- Bitmask：使用 `OptionSet` + `UInt32`
- 隨機生成：加權隨機選擇演算法
- 數值計算：`(基礎值 + 固定加成) × (1 + Σ百分比加成)`
- 錯誤處理：`Result` 類型 + 自訂 `Error` enum
- 序列化：Swift `Codable`

---

## Phase 1: Design & Contracts - COMPLETED

**輸出**:
- [data-model.md](./data-model.md) - 資料模型定義
- [contracts/protocols.swift](./contracts/protocols.swift) - 協定介面
- [quickstart.md](./quickstart.md) - 快速入門指南

### 設計摘要

| 類別 | 數量 | 說明 |
|------|------|------|
| Enumerations | 3 | EquipmentSlot, Rarity, AffixType |
| Structures | 6 | Stats, Affix, ItemTemplate, WeightedAffix, SetBonus, EquipmentSet |
| Classes | 8 | Item, Inventory, EquipmentSlots, Avatar, AffixGenerator, SetBonusCalculator, ItemFactory, ItemSerializer |
| Protocols | 9 | 用於依賴注入和測試 |
| Error Types | 1 | ItemSystemError (7 cases) |

---

## Implementation Examples (TDD)

### 測試結構範例

```swift
// 測試命名: testMethodNameWhenConditionThenExpectedResult
func testEquipItemWhenSlotMatchesThenItemEquipped() {
    // Given - 準備測試資料
    let slots = EquipmentSlots()
    let helmet = createTestHelmet(slot: .helmet)

    // When - 執行測試行為
    let result = slots.equip(helmet, to: .helmet)

    // Then - 驗證結果
    XCTAssertTrue(result.isSuccess)
    XCTAssertEqual(slots.item(at: .helmet)?.instanceId, helmet.instanceId)
}
```

### Bitmask 使用範例

```swift
// AffixType 定義
struct AffixType: OptionSet, Codable {
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

// 使用範例
var affixMask: AffixType = [.crit, .attack]
affixMask.contains(.crit)                        // true
affixMask.contains([.crit, .attack])             // true
!affixMask.isDisjoint(with: [.crit, .defense])   // true (有其中之一)
```

### 數值計算範例

```swift
extension Avatar {
    var totalStats: Stats {
        // 收集所有裝備的數值
        let equippedItems = equipmentSlots.allEquippedItems()

        // 分離固定加成和百分比加成
        var flatBonus = Stats.zero
        var percentBonus = Stats.zero

        for item in equippedItems {
            for affix in [item.mainAffix] + item.subAffixes {
                if affix.isPercentage {
                    percentBonus = percentBonus + affix.toStats()
                } else {
                    flatBonus = flatBonus + affix.toStats()
                }
            }
            flatBonus = flatBonus + item.baseStats
        }

        // 套用公式: (基礎值 + 固定加成) × (1 + 百分比加成)
        return (baseStats + flatBonus) * (1.0 + percentBonus.asMultiplier)
    }
}
```

---

## Next Steps

執行 `/speckit.tasks` 生成任務清單，開始 TDD 實作流程。

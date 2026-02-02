# Implementation Plan: RPG 道具/物品欄/背包系統

**Branch**: `004-rpg-item-inventory-system` | **Date**: 2026-02-01 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/004-rpg-item-inventory-system/spec.md`

**Note**: 此為獨立練習專案，使用 Pseudo Code + 單元測試方式規劃，不涉及實際 CMProductionLego 專案整合。

## Summary

設計一套 RPG 遊戲的裝備道具系統，包含：
- **物品 ID 系統**：Template ID（模板）+ Instance ID（UUID 實例）
- **裝備欄位**：5 個欄位（helmet、body、gloves、boots、belt）
- **數值系統**：7 種基礎數值（attack、defense、maxHP、maxMP、critRate、critDamage、speed）
- **詞條系統**：主詞條 + 副詞條，使用 Bitmask 快速查詢
- **套裝系統**：2 件套 / 4 件套效果觸發
- **背包系統**：容量限制與物品管理

技術方案採用 Swift 5.9+ 純 Model 層實作，透過 Pseudo Code 設計與 TDD 測試驅動開發。

## Technical Context

**Language/Version**: Swift 5.9+ (Pseudo Code 形式)
**Primary Dependencies**: Foundation（UUID、Codable）
**Storage**: 記憶體內操作 + JSON 序列化（無持久化儲存）
**Testing**: XCTest（單元測試，BDD Given-When-Then 風格）
**Target Platform**: 教學練習（不限定平台）
**Project Type**: Single Project（純 Model 層練習）
**Performance Goals**: N/A（教學專案）
**Constraints**: N/A（教學專案）
**Scale/Scope**: 完整實作規格中定義的所有功能

## Constitution Check

*GATE: 此為獨立練習專案，簡化合規檢查*

### Principle Compliance

| Principle | Status | Notes |
|-----------|--------|-------|
| I. 架構規則 | PASS | 純 Model 層實作，不涉及 ViewModel/ViewComponent |
| II. 依賴注入 | PASS | 使用協議導向設計，支援測試注入 |
| III. 層級邊界 | N/A | 無 UseCase/Repository/DataSource 分層需求 |
| IV. 測試標準 | PASS | 採用 Given-When-Then 模式 |
| V. XcodeGen | N/A | 獨立練習專案，無專案檔管理需求 |
| VI. 代碼品質 | PASS | 遵循 Swift 命名規範 |
| VII. Agent 執行 | N/A | 教學練習性質 |
| VIII. 治理 | PASS | 遵循 constitution 指導原則 |

### Gates

- [x] 無違規項目
- [x] 可進入 Phase 0 研究階段

## Project Intelligence

*此為獨立練習專案，不涉及現有 CMProductionLego 專案整合。*

### Project Scope

本專案為 Code Monster #4 練習題目，目標是透過 Pseudo Code + TDD 方式學習：
1. RPG 物品系統的 OOP 設計
2. Bitmask 在遊戲開發中的應用
3. Swift OptionSet 的使用
4. 協議導向設計（Protocol-Oriented Programming）
5. JSON 序列化/反序列化

### Reusable Components

由於是獨立練習專案，無需參考現有專案元件。所有元件皆為新建。

### Integration Recommendations

**無整合需求**：此專案獨立存在於 `specs/004-rpg-item-inventory-system/` 目錄下。

## Project Structure

### Documentation (this feature)

```text
specs/004-rpg-item-inventory-system/
├── spec.md              # 功能規格（已完成）
├── plan.md              # 本檔案（實作計畫）
├── research.md          # Phase 0 研究結果
├── data-model.md        # Phase 1 資料模型設計
├── quickstart.md        # Phase 1 快速入門指南
├── contracts/           # Phase 1 API 契約（Pseudo Code）
├── checklists/          # 檢查清單
│   └── requirements.md  # 規格品質檢查（已完成）
└── tasks.md             # Phase 2 任務清單（由 /speckit.tasks 生成）
```

### Source Code (Pseudo Code 形式)

```text
# 練習專案結構（Pseudo Code）
ItemSystem/
├── Models/
│   ├── Enums/
│   │   ├── EquipmentSlot.swift      # 裝備欄位列舉
│   │   ├── Rarity.swift             # 稀有度列舉
│   │   └── Element.swift            # 元素類型列舉
│   ├── Stats/
│   │   ├── Stats.swift              # 基礎數值結構
│   │   └── StatType.swift           # 數值類型列舉
│   ├── Affix/
│   │   ├── AffixType.swift          # 詞條類型（OptionSet Bitmask）
│   │   ├── Affix.swift              # 詞條結構
│   │   └── AffixPool.swift          # 詞條池（權重生成）
│   ├── Item/
│   │   ├── ItemTemplate.swift       # 物品模板
│   │   ├── Item.swift               # 物品實例
│   │   └── ItemFactory.swift        # 物品工廠
│   ├── Set/
│   │   ├── EquipmentSet.swift       # 套裝定義
│   │   ├── SetBonus.swift           # 套裝效果
│   │   └── SetBonusCalculator.swift # 套裝效果計算器
│   ├── Attribute/
│   │   ├── Attribute.swift          # 屬性基礎協議
│   │   ├── StatBonusAttribute.swift # 數值加成屬性
│   │   ├── ElementAttribute.swift   # 元素附加屬性
│   │   └── SpecialAttribute.swift   # 特殊效果屬性
│   └── Container/
│       ├── EquipmentSlots.swift     # 裝備欄容器
│       ├── Inventory.swift          # 背包容器
│       └── Avatar.swift             # 角色（整合裝備欄+背包）
│
├── Services/
│   ├── ItemService.swift            # 物品服務（穿戴/卸下）
│   ├── StatsCalculator.swift        # 數值計算服務
│   └── AffixGenerator.swift         # 詞條生成服務
│
├── Serialization/
│   ├── ItemTemplateLoader.swift     # 模板載入（JSON）
│   ├── ItemSerializer.swift         # 物品序列化
│   └── AffixPoolLoader.swift        # 詞條池載入
│
└── Tests/
    ├── Models/
    │   ├── ItemTests.swift
    │   ├── AffixTypeTests.swift
    │   ├── StatsTests.swift
    │   └── SetBonusTests.swift
    ├── Services/
    │   ├── ItemServiceTests.swift
    │   ├── StatsCalculatorTests.swift
    │   └── AffixGeneratorTests.swift
    └── Serialization/
        ├── ItemSerializerTests.swift
        └── TemplateLoaderTests.swift
```

**Structure Decision**: 採用 Single Project 結構，分為 Models（資料模型）、Services（業務邏輯）、Serialization（序列化）、Tests（測試）四大區塊。

## Complexity Tracking

> 無違規項目，無需追蹤

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| N/A | N/A | N/A |

## Design Decisions

### D1: Bitmask 詞條類型設計

**Decision**: 使用 `OptionSet` 實現詞條類型的 Bitmask

**Rationale**:
- O(1) 時間複雜度查詢詞條組合
- 支援位運算（AND、OR、XOR）快速篩選物品
- Swift 原生支援，型別安全

**Pseudo Code**:
```swift
struct AffixType: OptionSet {
    let rawValue: UInt32

    static let crit            = AffixType(rawValue: 1 << 0)  // 0b0001
    static let energyRecharge  = AffixType(rawValue: 1 << 1)  // 0b0010
    static let attack          = AffixType(rawValue: 1 << 2)  // 0b0100
    static let defense         = AffixType(rawValue: 1 << 3)  // 0b1000
    static let hp              = AffixType(rawValue: 1 << 4)  // 0b0001_0000
    static let elementalMastery = AffixType(rawValue: 1 << 5)
    static let elementalDamage  = AffixType(rawValue: 1 << 6)
    static let healingBonus     = AffixType(rawValue: 1 << 7)
}
```

### D2: 數值計算順序

**Decision**: 先加總固定值，再套用百分比

**Formula**:
```
最終數值 = (基礎值 + Σ固定加成) × (1 + Σ百分比加成)
```

**Rationale**:
- 符合大多數 RPG 遊戲的數值設計慣例
- 避免百分比疊加造成數值爆炸

### D3: 詞條權重隨機生成

**Decision**: 使用加權隨機演算法

**Pseudo Code**:
```swift
func selectAffix(from pool: [WeightedAffix]) -> AffixType {
    let totalWeight = pool.reduce(0) { $0 + $1.weight }
    let random = Int.random(in: 0..<totalWeight)

    var cumulative = 0
    for affix in pool {
        cumulative += affix.weight
        if random < cumulative {
            return affix.type
        }
    }
    return pool.last!.type  // fallback
}
```

### D4: 套裝效果判定

**Decision**: 使用 Dictionary 計數已穿戴套裝件數

**Pseudo Code**:
```swift
func calculateSetBonuses(equipped: [Item]) -> [SetBonus] {
    var setCounts: [String: Int] = [:]

    for item in equipped where item.setId != nil {
        setCounts[item.setId!, default: 0] += 1
    }

    var activeBonuses: [SetBonus] = []
    for (setId, count) in setCounts {
        let set = getSet(byId: setId)
        for bonus in set.bonuses where bonus.requiredPieces <= count {
            activeBonuses.append(bonus)
        }
    }
    return activeBonuses
}
```

## Implementation Phases

### Level 1: 基礎結構（P1 核心功能）

**目標**: 建立物品系統的基礎型別

**Tasks**:
1. EquipmentSlot 列舉
2. Rarity 列舉（含副詞條數量映射）
3. Stats 結構（7 種數值）
4. ItemTemplate 結構
5. Item 類別（含 UUID 生成）

### Level 2: 詞條系統（P2 詞條功能）

**目標**: 實現詞條 Bitmask 與隨機生成

**Tasks**:
1. AffixType OptionSet
2. Affix 結構
3. AffixPool 結構（權重定義）
4. AffixGenerator 服務

### Level 3: 套裝系統（P3 套裝功能）

**目標**: 實現套裝定義與效果計算

**Tasks**:
1. SetBonus 結構
2. EquipmentSet 結構
3. SetBonusCalculator 服務

### Level 4: 容器系統（P1 核心功能）

**目標**: 實現裝備欄與背包

**Tasks**:
1. EquipmentSlots 類別
2. Inventory 類別（含容量限制）
3. Avatar 類別（整合角色）
4. ItemService 服務（穿戴/卸下）
5. StatsCalculator 服務

### Level 5: 序列化（P3 輔助功能）

**目標**: JSON 載入與序列化

**Tasks**:
1. ItemTemplate JSON 載入
2. AffixPool JSON 載入
3. Item 序列化/反序列化

## Testing Strategy

### Test Naming Convention

使用 `testMethodNameWhenConditionThenExpectedResult` 格式：

```swift
// 正確範例
func testCreateItemWhenLegendaryRarityThenHasFourSubAffixes()
func testEquipItemWhenSlotMismatchThenReturnsFalse()
func testCalculateStatsWhenPercentageBonusThenAppliesAfterFlat()

// 錯誤範例（避免）
func test_create_item_legendary()  // snake_case
func test創建傳說物品()              // 中文方法名
```

### Test Structure (Given-When-Then)

```swift
func testEquipItemWhenSlotMatchesThenItemEquipped() {
    // Given: 準備測試資料
    let avatar = Avatar(level: 10)
    let helmet = Item(template: helmetTemplate)

    // When: 執行待測行為
    let result = avatar.equip(helmet, to: .helmet)

    // Then: 驗證預期結果
    XCTAssertTrue(result.isSuccess)
    XCTAssertEqual(avatar.equipped(.helmet), helmet)
}
```

### Test Categories

| 類別 | 測試重點 | 優先級 |
|------|----------|--------|
| 物品建立 | UUID 唯一性、副詞條數量 | P1 |
| 裝備穿戴 | 欄位驗證、等級限制 | P1 |
| 數值計算 | 固定值、百分比、總計 | P1 |
| Bitmask | contains、isDisjoint、insert | P2 |
| 詞條生成 | 權重分布、池過濾 | P2 |
| 套裝效果 | 2件套、4件套、混搭 | P3 |
| 序列化 | 編碼、解碼、完整性 | P3 |
| 背包管理 | 容量限制、新增移除 | P2 |

## Risk Assessment

| 風險 | 影響 | 緩解措施 |
|------|------|----------|
| Bitmask 位元衝突 | 詞條判定錯誤 | 使用 1 << n 確保唯一位元 |
| 浮點數精度問題 | 百分比計算誤差 | 使用 Decimal 或定點數 |
| UUID 衝突 | 物品 ID 重複 | UUID v4 機率極低，不需處理 |
| JSON 格式不符 | 載入失敗 | 使用 Codable 自動驗證 |

## Definition of Done

- [ ] 所有 Level 1-5 功能實作完成（Pseudo Code）
- [ ] 所有單元測試通過
- [ ] 測試覆蓋率達 80% 以上
- [ ] 程式碼符合 Swift 命名規範
- [ ] Pseudo Code 可讀性高，附有說明註解

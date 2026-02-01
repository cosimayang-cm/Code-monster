# Tasks: RPG 道具/物品欄/背包系統

**Input**: Design documents from `/specs/004-rpg-item-inventory-system/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: 此為 TDD 練習專案，所有 User Story 皆包含測試任務。

**Organization**: 任務按 User Story 組織，支援獨立實作與測試。

## Format: `[ID] [P?] [Story] Description`

- **[P]**: 可平行執行（不同檔案、無相依性）
- **[Story]**: 所屬 User Story（US1-US7）
- 包含完整檔案路徑

## Path Conventions

```text
ItemSystem/
├── Models/          # 資料模型
├── Services/        # 業務邏輯
├── Serialization/   # JSON 序列化
└── Tests/           # 單元測試
```

---

## Phase 1: Setup (專案初始化)

**Purpose**: 建立專案結構與基礎設施

- [ ] T001 建立專案目錄結構 ItemSystem/Models/, ItemSystem/Services/, ItemSystem/Serialization/, ItemSystem/Tests/
- [ ] T002 [P] 建立 Swift Package 或 Xcode 專案配置
- [ ] T003 [P] 配置 XCTest 測試框架

---

## Phase 2: Foundational (基礎型別 - 阻塞所有 User Stories)

**Purpose**: 建立所有 User Story 共用的基礎列舉與結構

**⚠️ CRITICAL**: 此階段必須完成後才能開始任何 User Story

### Enumerations

- [ ] T004 [P] 實作 EquipmentSlot 列舉（5 個裝備欄位）in ItemSystem/Models/Enums/EquipmentSlot.swift
- [ ] T005 [P] 實作 Rarity 列舉（含 subAffixCount 計算屬性）in ItemSystem/Models/Enums/Rarity.swift
- [ ] T006 [P] 實作 StatType 列舉（7 種數值類型）in ItemSystem/Models/Enums/StatType.swift
- [ ] T007 [P] 實作 Element 列舉（fire, ice, lightning, poison）in ItemSystem/Models/Enums/Element.swift
- [ ] T008 [P] 實作 SpecialEffect 列舉（lifesteal, reflect, thorns）in ItemSystem/Models/Enums/SpecialEffect.swift

### Core Structures

- [ ] T009 實作 Stats 結構（含 +, * 運算子）in ItemSystem/Models/Stats/Stats.swift
- [ ] T010 [P] 實作 AffixType OptionSet（Bitmask 實作）in ItemSystem/Models/Affix/AffixType.swift
- [ ] T011 實作 Affix 結構（type, value, isPercentage）in ItemSystem/Models/Affix/Affix.swift

### Tests for Foundational

- [ ] T012 [P] 撰寫測試: testRaritySubAffixCountWhenCommonThenReturnsZero in ItemSystem/Tests/Models/RarityTests.swift
- [ ] T013 [P] 撰寫測試: testAffixTypeContainsWhenSingleTypeThenReturnsTrue in ItemSystem/Tests/Models/AffixTypeTests.swift
- [ ] T014 [P] 撰寫測試: testAffixTypeContainsWhenMultipleTypesThenReturnsTrue in ItemSystem/Tests/Models/AffixTypeTests.swift
- [ ] T015 [P] 撰寫測試: testStatsAdditionWhenTwoStatsThenSumsCorrectly in ItemSystem/Tests/Models/StatsTests.swift

**Checkpoint**: 基礎型別完成 - 可開始 User Story 實作

---

## Phase 3: User Story 1 - 建立物品實例 (Priority: P1) 🎯 MVP

**Goal**: 玩家獲得新裝備時，系統從物品模板建立一個獨特的物品實例，每個實例有唯一 UUID 且副詞條數量符合稀有度規範。

**Independent Test**: 建立多個物品實例，驗證 UUID 唯一性與副詞條數量。

### Tests for User Story 1

- [ ] T016 [P] [US1] 撰寫測試: testCreateItemWhenCommonRarityThenHasZeroSubAffixes in ItemSystem/Tests/Models/ItemTests.swift
- [ ] T017 [P] [US1] 撰寫測試: testCreateItemWhenLegendaryRarityThenHasFourSubAffixes in ItemSystem/Tests/Models/ItemTests.swift
- [ ] T018 [P] [US1] 撰寫測試: testCreateItemWhenCalledTwiceThenDifferentInstanceIds in ItemSystem/Tests/Models/ItemTests.swift
- [ ] T019 [P] [US1] 撰寫測試: testItemFactoryCreateItemWhenValidTemplateThenReturnsItem in ItemSystem/Tests/Services/ItemFactoryTests.swift
- [ ] T020 [P] [US1] 撰寫測試: testAffixGeneratorGenerateMainAffixWhenValidPoolThenReturnsAffix in ItemSystem/Tests/Services/AffixGeneratorTests.swift

### Implementation for User Story 1

- [ ] T021 [P] [US1] 實作 ItemTemplate 結構 in ItemSystem/Models/Item/ItemTemplate.swift
- [ ] T022 [US1] 實作 Item 類別（含 UUID 生成、affixMask 計算）in ItemSystem/Models/Item/Item.swift
- [ ] T023 [P] [US1] 實作 WeightedAffix 結構 in ItemSystem/Models/Affix/WeightedAffix.swift
- [ ] T024 [P] [US1] 實作 AffixPool 結構 in ItemSystem/Models/Affix/AffixPool.swift
- [ ] T025 [US1] 實作 AffixGenerating 協議 in ItemSystem/Services/AffixGenerating.swift
- [ ] T026 [US1] 實作 AffixGenerator 服務（權重隨機選擇）in ItemSystem/Services/AffixGenerator.swift
- [ ] T027 [US1] 實作 ItemCreating 協議 in ItemSystem/Services/ItemCreating.swift
- [ ] T028 [US1] 實作 ItemFactory 服務（從模板建立物品）in ItemSystem/Models/Item/ItemFactory.swift

**Checkpoint**: User Story 1 完成 - 可獨立驗證物品建立功能

---

## Phase 4: User Story 2 - 裝備穿戴與卸下 (Priority: P1)

**Goal**: 玩家可將背包中的裝備穿戴到對應欄位，也可卸下已穿戴的裝備回到背包。

**Independent Test**: 穿戴/卸下不同類型裝備，驗證欄位限制與等級限制。

**Dependencies**: 需要 US1（Item 建立）與 US4（Inventory 背包）

### Tests for User Story 2

- [ ] T029 [P] [US2] 撰寫測試: testEquipItemWhenSlotMatchesThenItemEquipped in ItemSystem/Tests/Services/ItemServiceTests.swift
- [ ] T030 [P] [US2] 撰寫測試: testEquipItemWhenSlotMismatchThenReturnsFailure in ItemSystem/Tests/Services/ItemServiceTests.swift
- [ ] T031 [P] [US2] 撰寫測試: testEquipItemWhenLevelTooLowThenReturnsFailure in ItemSystem/Tests/Services/ItemServiceTests.swift
- [ ] T032 [P] [US2] 撰寫測試: testEquipItemWhenSlotOccupiedThenSwapsItems in ItemSystem/Tests/Services/ItemServiceTests.swift
- [ ] T033 [P] [US2] 撰寫測試: testUnequipItemWhenInventoryFullThenReturnsFailure in ItemSystem/Tests/Services/ItemServiceTests.swift

### Implementation for User Story 2

- [ ] T034 [P] [US2] 實作 EquipmentSlots 類別（5 個欄位管理）in ItemSystem/Models/Container/EquipmentSlots.swift
- [ ] T035 [US2] 實作 ItemServicing 協議 in ItemSystem/Services/ItemServicing.swift
- [ ] T036 [US2] 實作 EquipResult, UnequipResult 結果型別 in ItemSystem/Services/ItemServiceResults.swift
- [ ] T037 [US2] 實作 ItemService.equip() 方法 in ItemSystem/Services/ItemService.swift
- [ ] T038 [US2] 實作 ItemService.unequip() 方法 in ItemSystem/Services/ItemService.swift
- [ ] T039 [US2] 實作 ItemService.swap() 方法 in ItemSystem/Services/ItemService.swift

**Checkpoint**: User Story 2 完成 - 可獨立驗證裝備穿戴功能

---

## Phase 5: User Story 3 - 角色數值計算 (Priority: P1)

**Goal**: 計算角色穿戴所有裝備後的總數值，包括基礎數值、主詞條、副詞條的加成。

**Independent Test**: 穿戴/卸下裝備並驗證角色總數值變化。

**Dependencies**: 需要 US1（Item）與 US2（Equipment）

### Tests for User Story 3

- [ ] T040 [P] [US3] 撰寫測試: testCalculateTotalStatsWhenNoEquipmentThenReturnsBaseStats in ItemSystem/Tests/Services/StatsCalculatorTests.swift
- [ ] T041 [P] [US3] 撰寫測試: testCalculateTotalStatsWhenFlatBonusThenAddsCorrectly in ItemSystem/Tests/Services/StatsCalculatorTests.swift
- [ ] T042 [P] [US3] 撰寫測試: testCalculateTotalStatsWhenPercentBonusThenMultipliesCorrectly in ItemSystem/Tests/Services/StatsCalculatorTests.swift
- [ ] T043 [P] [US3] 撰寫測試: testCalculateTotalStatsWhenMixedBonusesThenAppliesFlatThenPercent in ItemSystem/Tests/Services/StatsCalculatorTests.swift
- [ ] T044 [P] [US3] 撰寫測試: testCalculateMainAffixValueWhenLevel10ThenGrowsLinearly in ItemSystem/Tests/Services/StatsCalculatorTests.swift

### Implementation for User Story 3

- [ ] T045 [US3] 實作 StatsCalculating 協議 in ItemSystem/Services/StatsCalculating.swift
- [ ] T046 [US3] 實作 StatsCalculator.calculateTotalStats() 方法 in ItemSystem/Services/StatsCalculator.swift
- [ ] T047 [US3] 實作 StatsCalculator.calculateItemStats() 方法（單件裝備貢獻）in ItemSystem/Services/StatsCalculator.swift
- [ ] T048 [US3] 實作主詞條成長公式 calculateMainAffixValue() in ItemSystem/Services/StatsCalculator.swift

**Checkpoint**: User Story 3 完成 - 可獨立驗證數值計算功能

---

## Phase 6: User Story 4 - 背包管理 (Priority: P2)

**Goal**: 玩家可在背包中管理物品，包括容量限制下新增/移除物品。

**Independent Test**: 新增/移除物品並驗證背包容量狀態。

### Tests for User Story 4

- [ ] T049 [P] [US4] 撰寫測試: testInventoryAddWhenNotFullThenReturnsTrue in ItemSystem/Tests/Models/InventoryTests.swift
- [ ] T050 [P] [US4] 撰寫測試: testInventoryAddWhenFullThenReturnsFalse in ItemSystem/Tests/Models/InventoryTests.swift
- [ ] T051 [P] [US4] 撰寫測試: testInventoryRemoveWhenItemExistsThenReturnsTrue in ItemSystem/Tests/Models/InventoryTests.swift
- [ ] T052 [P] [US4] 撰寫測試: testInventoryFilterByAffixMaskWhenMatchAllThenReturnsMatchingItems in ItemSystem/Tests/Models/InventoryTests.swift

### Implementation for User Story 4

- [ ] T053 [US4] 實作 Inventory 類別（容量限制、新增/移除）in ItemSystem/Models/Container/Inventory.swift
- [ ] T054 [US4] 實作 Inventory.filter(byAffixMask:matchAll:) 方法 in ItemSystem/Models/Container/Inventory.swift
- [ ] T055 [US4] 實作 Avatar 類別（整合 EquipmentSlots + Inventory）in ItemSystem/Models/Container/Avatar.swift

**Checkpoint**: User Story 4 完成 - 可獨立驗證背包管理功能

---

## Phase 7: User Story 5 - 詞條系統運作 (Priority: P2)

**Goal**: 主詞條數值隨裝備等級提升，副詞條依權重隨機生成，支援 Bitmask 快速查詢。

**Independent Test**: 裝備升級驗證主詞條成長，Bitmask 查詢驗證。

### Tests for User Story 5

- [ ] T056 [P] [US5] 撰寫測試: testItemLevelUpWhenCalledThenLevelIncreases in ItemSystem/Tests/Models/ItemTests.swift
- [ ] T057 [P] [US5] 撰寫測試: testAffixGeneratorWeightDistributionWhenLargeSampleThenMatchesWeights in ItemSystem/Tests/Services/AffixGeneratorTests.swift
- [ ] T058 [P] [US5] 撰寫測試: testAffixTypeIsDisjointWhenNoOverlapThenReturnsTrue in ItemSystem/Tests/Models/AffixTypeTests.swift
- [ ] T059 [P] [US5] 撰寫測試: testAffixMaskContainsWhenHasCritAndAttackThenReturnsTrue in ItemSystem/Tests/Models/ItemTests.swift

### Implementation for User Story 5

- [ ] T060 [US5] 實作 Item.levelUp() 方法 in ItemSystem/Models/Item/Item.swift
- [ ] T061 [US5] 增強 AffixGenerator 支援 excluding 參數（避免副詞條重複）in ItemSystem/Services/AffixGenerator.swift
- [ ] T062 [US5] 實作 AffixType 複合類型（offensive, defensive）in ItemSystem/Models/Affix/AffixType.swift

**Checkpoint**: User Story 5 完成 - 可獨立驗證詞條系統功能

---

## Phase 8: User Story 6 - 套裝效果觸發 (Priority: P3)

**Goal**: 穿戴同套裝的多件裝備時，自動觸發對應的套裝效果（2件套/4件套）。

**Independent Test**: 穿戴不同數量的同套裝備，驗證套裝效果觸發。

**Dependencies**: 需要 US2（Equipment）

### Tests for User Story 6

- [ ] T063 [P] [US6] 撰寫測試: testCalculateSetBonusesWhenTwoPiecesThenTriggersTwoPieceBonus in ItemSystem/Tests/Services/SetBonusCalculatorTests.swift
- [ ] T064 [P] [US6] 撰寫測試: testCalculateSetBonusesWhenFourPiecesThenTriggersBothBonuses in ItemSystem/Tests/Services/SetBonusCalculatorTests.swift
- [ ] T065 [P] [US6] 撰寫測試: testCalculateSetBonusesWhenMixedSetsThenTriggersMultipleBonuses in ItemSystem/Tests/Services/SetBonusCalculatorTests.swift
- [ ] T066 [P] [US6] 撰寫測試: testCalculateSetBonusesWhenThreePiecesThenTriggersTwoPieceBonusOnly in ItemSystem/Tests/Services/SetBonusCalculatorTests.swift

### Implementation for User Story 6

- [ ] T067 [P] [US6] 實作 SetEffect 列舉 in ItemSystem/Models/Set/SetEffect.swift
- [ ] T068 [P] [US6] 實作 SetBonus 結構 in ItemSystem/Models/Set/SetBonus.swift
- [ ] T069 [US6] 實作 EquipmentSet 結構 in ItemSystem/Models/Set/EquipmentSet.swift
- [ ] T070 [US6] 實作 SetBonusCalculating 協議 in ItemSystem/Services/SetBonusCalculating.swift
- [ ] T071 [US6] 實作 SetBonusCalculator.calculateSetBonuses() 方法 in ItemSystem/Models/Set/SetBonusCalculator.swift
- [ ] T072 [US6] 整合 StatsCalculator 套用套裝效果 in ItemSystem/Services/StatsCalculator.swift

**Checkpoint**: User Story 6 完成 - 可獨立驗證套裝效果功能

---

## Phase 9: User Story 7 - 資料持久化 (Priority: P3)

**Goal**: 支援從 JSON 載入物品模板與詞條池，以及物品實例的序列化/反序列化。

**Independent Test**: 序列化物品後重新載入，驗證資料完整性。

### Tests for User Story 7

- [ ] T073 [P] [US7] 撰寫測試: testItemTemplateLoaderLoadWhenValidJsonThenReturnsTemplate in ItemSystem/Tests/Serialization/ItemTemplateLoaderTests.swift
- [ ] T074 [P] [US7] 撰寫測試: testItemSerializerEncodeWhenValidItemThenReturnsJsonData in ItemSystem/Tests/Serialization/ItemSerializerTests.swift
- [ ] T075 [P] [US7] 撰寫測試: testItemSerializerDecodeWhenValidJsonThenReturnsItem in ItemSystem/Tests/Serialization/ItemSerializerTests.swift
- [ ] T076 [P] [US7] 撰寫測試: testItemSerializerRoundTripWhenEncodeThenDecodeThenEqual in ItemSystem/Tests/Serialization/ItemSerializerTests.swift

### Implementation for User Story 7

- [ ] T077 [P] [US7] 確保所有 Model 遵循 Codable 協議 in ItemSystem/Models/
- [ ] T078 [US7] 實作 ItemSerializing 協議 in ItemSystem/Serialization/ItemSerializing.swift
- [ ] T079 [US7] 實作 ItemSerializer（encode/decode）in ItemSystem/Serialization/ItemSerializer.swift
- [ ] T080 [US7] 實作 ItemTemplateLoader（JSON 載入模板）in ItemSystem/Serialization/ItemTemplateLoader.swift
- [ ] T081 [US7] 實作 AffixPoolLoader（JSON 載入詞條池）in ItemSystem/Serialization/AffixPoolLoader.swift
- [ ] T082 [P] [US7] 建立範例 JSON 檔案 templates.json in ItemSystem/Resources/templates.json
- [ ] T083 [P] [US7] 建立範例 JSON 檔案 affix_pools.json in ItemSystem/Resources/affix_pools.json

**Checkpoint**: User Story 7 完成 - 可獨立驗證資料持久化功能

---

## Phase 10: Attribute System (輔助功能)

**Purpose**: 完成屬性系統（數值加成、元素附加、特殊效果）

- [ ] T084 [P] 實作 Attribute 協議 in ItemSystem/Models/Attribute/Attribute.swift
- [ ] T085 [P] 實作 StatBonusAttribute 結構 in ItemSystem/Models/Attribute/StatBonusAttribute.swift
- [ ] T086 [P] 實作 ElementAttribute 結構 in ItemSystem/Models/Attribute/ElementAttribute.swift
- [ ] T087 [P] 實作 SpecialAttribute 結構 in ItemSystem/Models/Attribute/SpecialAttribute.swift
- [ ] T088 撰寫測試: testStatBonusAttributeApplyWhenPercentageThenCalculatesCorrectly in ItemSystem/Tests/Models/AttributeTests.swift

---

## Phase 11: Polish & Cross-Cutting Concerns

**Purpose**: 程式碼品質提升與文件驗證

- [ ] T089 [P] 為所有公開 API 新增文件註解
- [ ] T090 [P] 程式碼重構與命名一致性檢查
- [ ] T091 執行 quickstart.md 範例驗證
- [ ] T092 [P] 補充邊界條件測試（Edge Cases）in ItemSystem/Tests/
- [ ] T093 測試覆蓋率檢查（目標 80%+）

---

## Dependencies & Execution Order

### Phase Dependencies

```
Phase 1: Setup
    ↓
Phase 2: Foundational (BLOCKS all user stories)
    ↓
┌───────────────────────────────────────────────────────────┐
│  User Stories can proceed in priority order or parallel   │
│                                                           │
│  US1 (P1) ─────────────────────────────────────────────→  │
│      ↓                                                    │
│  US2 (P1) ← depends on US1 (Item) + US4 (Inventory) ───→  │
│      ↓                                                    │
│  US3 (P1) ← depends on US1, US2 ────────────────────────→ │
│      ↓                                                    │
│  US4 (P2) ─────────────────────────────────────────────→  │
│      ↓                                                    │
│  US5 (P2) ─────────────────────────────────────────────→  │
│      ↓                                                    │
│  US6 (P3) ← depends on US2 (Equipment) ─────────────────→ │
│      ↓                                                    │
│  US7 (P3) ─────────────────────────────────────────────→  │
└───────────────────────────────────────────────────────────┘
    ↓
Phase 10: Attribute System
    ↓
Phase 11: Polish
```

### User Story Dependencies

| Story | Depends On | Can Start After |
|-------|------------|-----------------|
| US1 | - | Phase 2 |
| US2 | US1, US4 | US1 + US4 基礎實作 |
| US3 | US1, US2 | US2 完成 |
| US4 | - | Phase 2 |
| US5 | US1 | US1 完成 |
| US6 | US2 | US2 完成 |
| US7 | US1 | US1 完成 |

### Parallel Opportunities

**Phase 2 內部平行**:
```bash
# 所有 Enum 可平行
T004, T005, T006, T007, T008

# Core Structures
T009 → T010 → T011 (有依賴)

# 所有測試可平行
T012, T013, T014, T015
```

**User Story 內部平行**:
```bash
# US1 Tests (all parallel)
T016, T017, T018, T019, T020

# US1 Implementation
T021, T023, T024 (parallel) → T022 → T025, T026 → T027, T028
```

---

## Parallel Example: User Story 1

```bash
# 平行執行所有 US1 測試:
Task: "testCreateItemWhenCommonRarityThenHasZeroSubAffixes"
Task: "testCreateItemWhenLegendaryRarityThenHasFourSubAffixes"
Task: "testCreateItemWhenCalledTwiceThenDifferentInstanceIds"
Task: "testItemFactoryCreateItemWhenValidTemplateThenReturnsItem"
Task: "testAffixGeneratorGenerateMainAffixWhenValidPoolThenReturnsAffix"

# 確認測試失敗後，平行執行獨立的 Model:
Task: "實作 ItemTemplate 結構"
Task: "實作 WeightedAffix 結構"
Task: "實作 AffixPool 結構"

# 然後依序實作有相依性的部分:
Task: "實作 Item 類別"
Task: "實作 AffixGenerator 服務"
Task: "實作 ItemFactory 服務"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: 驗證物品建立功能獨立運作
5. Demo: 可展示物品建立、UUID 唯一性、副詞條生成

### Incremental Delivery

1. Setup + Foundational → 基礎完成
2. Add US1 → 物品建立 → Demo (MVP!)
3. Add US4 → 背包管理 → Demo
4. Add US2 → 裝備穿戴 → Demo
5. Add US3 → 數值計算 → Demo
6. Add US5 → 詞條系統 → Demo
7. Add US6 → 套裝效果 → Demo
8. Add US7 → 資料持久化 → Demo
9. Polish → 完整功能

### Suggested MVP Scope

**最小可行產品 (MVP)**: Phase 1 + Phase 2 + Phase 3 (User Story 1)
- 可展示：物品模板定義、物品實例建立、UUID 唯一性、詞條隨機生成

---

## Task Count Summary

| Phase | Task Count | Parallel Tasks |
|-------|------------|----------------|
| Phase 1: Setup | 3 | 2 |
| Phase 2: Foundational | 12 | 9 |
| Phase 3: US1 (P1) | 13 | 8 |
| Phase 4: US2 (P1) | 11 | 6 |
| Phase 5: US3 (P1) | 9 | 5 |
| Phase 6: US4 (P2) | 7 | 4 |
| Phase 7: US5 (P2) | 7 | 4 |
| Phase 8: US6 (P3) | 10 | 5 |
| Phase 9: US7 (P3) | 11 | 5 |
| Phase 10: Attribute | 5 | 3 |
| Phase 11: Polish | 5 | 3 |
| **Total** | **93** | **54** |

---

## Notes

- [P] tasks = 不同檔案、無相依性
- [Story] label 用於追蹤任務所屬 User Story
- 每個 User Story 可獨立完成與測試
- 測試先撰寫並確認失敗後再實作
- 每個 Checkpoint 後可暫停驗證功能
- 避免：模糊的任務描述、同檔案衝突、破壞獨立性的跨 Story 相依

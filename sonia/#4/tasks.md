# Tasks: RPG 道具系統

**Feature**: 003-rpg-item-system
**Generated**: 2026-01-30
**Methodology**: TDD (Test-Driven Development)
**Base Path**: `sonia/#4/`

---

## Summary

| Phase | Description | Task Count |
|-------|-------------|------------|
| Phase 1 | Setup | 3 |
| Phase 2 | Foundational Models | 16 |
| Phase 3 | US2 - 物品生成與唯一識別 (P1) | 12 |
| Phase 4 | US1 - 穿戴與卸下裝備 (P1) | 14 |
| Phase 5 | US3 - 詞條系統與隨機生成 (P2) | 14 |
| Phase 6 | US4 - 背包管理 (P2) | 10 |
| Phase 7 | US5 - 套裝效果 (P3) | 10 |
| Phase 8 | US6 - 詞條快速查詢 (P3) | 6 |
| Phase 9 | US7 - 資料持久化 (P3) | 10 |
| Phase 10 | Polish & Edge Cases | 6 |
| **Total** | | **101** |

---

## Phase 1: Setup

**Goal**: Initialize Swift Package project structure

- [ ] T001 Create Swift Package: `swift package init --name ItemSystem --type library` in `sonia/#4/`
- [ ] T002 Create directory structure per plan.md: `Sources/ItemSystem/{Models,Systems,Containers,Avatar,Persistence}` and `Tests/ItemSystemTests/{Models,Systems,Containers,Avatar,Persistence}`
- [ ] T003 Verify project builds: `swift build` in `sonia/#4/`

---

## Phase 2: Foundational Models

**Goal**: Implement core types used across all user stories

### EquipmentSlot

- [ ] T004 [P] Write test: testEquipmentSlotRawValuesAreCorrect in `Tests/ItemSystemTests/Models/EquipmentSlotTests.swift`
- [ ] T005 [P] Write test: testEquipmentSlotCaseIterableReturnsAllCases in `Tests/ItemSystemTests/Models/EquipmentSlotTests.swift`
- [ ] T006 Implement EquipmentSlot enum with String rawValue, CaseIterable, Codable in `Sources/ItemSystem/Models/EquipmentSlot.swift`
- [ ] T007 Run tests and verify green: `swift test --filter EquipmentSlotTests`

### Rarity

- [ ] T008 [P] Write test: testRarityInitialSubAffixCountReturnsCorrectValue in `Tests/ItemSystemTests/Models/RarityTests.swift`
- [ ] T009 [P] Write test: testRarityMaxSubAffixCountReturnsCorrectValue in `Tests/ItemSystemTests/Models/RarityTests.swift`
- [ ] T010 [P] Write test: testRarityComparableOrdersCorrectly in `Tests/ItemSystemTests/Models/RarityTests.swift`
- [ ] T011 Implement Rarity enum with computed properties in `Sources/ItemSystem/Models/Rarity.swift`
- [ ] T012 Run tests and verify green: `swift test --filter RarityTests`

### Stats

- [ ] T013 [P] Write test: testStatsAdditionCombinesValues in `Tests/ItemSystemTests/Models/StatsTests.swift`
- [ ] T014 [P] Write test: testStatsMultiplicationScalesValues in `Tests/ItemSystemTests/Models/StatsTests.swift`
- [ ] T015 [P] Write test: testStatsZeroReturnsAllZeros in `Tests/ItemSystemTests/Models/StatsTests.swift`
- [ ] T016 Implement Stats struct with operators in `Sources/ItemSystem/Models/Stats.swift`
- [ ] T017 Run tests and verify green: `swift test --filter StatsTests`

### ItemSystemError

- [ ] T018 Implement ItemSystemError enum in `Sources/ItemSystem/Models/ItemSystemError.swift`
- [ ] T019 Run all Phase 2 tests: `swift test`

---

## Phase 3: US2 - 物品生成與唯一識別 (P1)

**Goal**: 系統可以根據物品模板生成物品實例，每個實例擁有全域唯一的識別碼

**Independent Test**: 從同一模板生成多個物品，驗證每個實例的 UUID 都不相同

### ItemTemplate

- [ ] T020 [P] [US2] Write test: testItemTemplateInitializationSetsAllProperties in `Tests/ItemSystemTests/Models/ItemTemplateTests.swift`
- [ ] T021 [P] [US2] Write test: testItemTemplateCodableEncodesAndDecodes in `Tests/ItemSystemTests/Models/ItemTemplateTests.swift`
- [ ] T022 [US2] Implement ItemTemplate struct in `Sources/ItemSystem/Models/ItemTemplate.swift`
- [ ] T023 [US2] Run tests and verify green: `swift test --filter ItemTemplateTests`

### Item (Basic)

- [ ] T024 [P] [US2] Write test: testItemInitializationGeneratesUniqueUUID in `Tests/ItemSystemTests/Models/ItemTests.swift`
- [ ] T025 [P] [US2] Write test: testMultipleItemsFromSameTemplateHaveDifferentUUIDs in `Tests/ItemSystemTests/Models/ItemTests.swift`
- [ ] T026 [P] [US2] Write test: testItemStoresTemplateIdCorrectly in `Tests/ItemSystemTests/Models/ItemTests.swift`
- [ ] T027 [US2] Implement Item class (basic properties) in `Sources/ItemSystem/Models/Item.swift`
- [ ] T028 [US2] Run tests and verify green: `swift test --filter ItemTests`

### ItemFactory

- [ ] T029 [P] [US2] Write test: testCreateItemFromTemplateIdWhenTemplateExistsThenReturnsItem in `Tests/ItemSystemTests/Systems/ItemFactoryTests.swift`
- [ ] T030 [P] [US2] Write test: testCreateItemFromTemplateIdWhenTemplateNotFoundThenReturnsError in `Tests/ItemSystemTests/Systems/ItemFactoryTests.swift`
- [ ] T031 [US2] Implement ItemFactory class in `Sources/ItemSystem/Systems/ItemFactory.swift`
- [ ] T032 [US2] Run all US2 tests: `swift test --filter "ItemTemplateTests|ItemTests|ItemFactoryTests"`

---

## Phase 4: US1 - 穿戴與卸下裝備 (P1)

**Goal**: 玩家可以將裝備穿戴到角色的對應欄位上，穿戴後角色的能力數值會即時更新

**Independent Test**: 建立一個角色、一件裝備，執行穿戴/卸下操作，驗證數值計算是否正確

### EquipmentSlots

- [ ] T033 [P] [US1] Write test: testEquipItemWhenSlotMatchesThenItemEquipped in `Tests/ItemSystemTests/Containers/EquipmentSlotsTests.swift`
- [ ] T034 [P] [US1] Write test: testEquipItemWhenSlotMismatchThenSlotMismatchError in `Tests/ItemSystemTests/Containers/EquipmentSlotsTests.swift`
- [ ] T035 [P] [US1] Write test: testEquipItemWhenSlotOccupiedThenReturnsPreviousItem in `Tests/ItemSystemTests/Containers/EquipmentSlotsTests.swift`
- [ ] T036 [P] [US1] Write test: testUnequipWhenSlotHasItemThenReturnsItem in `Tests/ItemSystemTests/Containers/EquipmentSlotsTests.swift`
- [ ] T037 [P] [US1] Write test: testUnequipWhenSlotEmptyThenSlotEmptyError in `Tests/ItemSystemTests/Containers/EquipmentSlotsTests.swift`
- [ ] T038 [US1] Implement EquipmentSlots class in `Sources/ItemSystem/Containers/EquipmentSlots.swift`
- [ ] T039 [US1] Run tests and verify green: `swift test --filter EquipmentSlotsTests`

### Avatar (Basic)

- [ ] T040 [P] [US1] Write test: testAvatarEquipItemWhenValidThenItemEquipped in `Tests/ItemSystemTests/Avatar/AvatarTests.swift`
- [ ] T041 [P] [US1] Write test: testAvatarEquipItemWhenLevelTooLowThenLevelRequirementNotMetError in `Tests/ItemSystemTests/Avatar/AvatarTests.swift`
- [ ] T042 [P] [US1] Write test: testAvatarUnequipItemWhenEquippedThenItemReturnsToInventory in `Tests/ItemSystemTests/Avatar/AvatarTests.swift`
- [ ] T043 [P] [US1] Write test: testAvatarTotalStatsWhenItemsEquippedThenCalculatesCorrectly in `Tests/ItemSystemTests/Avatar/AvatarTests.swift`
- [ ] T044 [US1] Implement Avatar class (basic) in `Sources/ItemSystem/Avatar/Avatar.swift`
- [ ] T045 [US1] Run tests and verify green: `swift test --filter AvatarTests`
- [ ] T046 [US1] Run all US1 tests: `swift test --filter "EquipmentSlotsTests|AvatarTests"`

---

## Phase 5: US3 - 詞條系統與隨機生成 (P2)

**Goal**: 裝備具有主詞條和副詞條，副詞條根據稀有度隨機生成

**Independent Test**: 生成不同稀有度的物品，驗證副詞條數量和隨機分布是否符合規則

### AffixType (OptionSet)

- [ ] T047 [P] [US3] Write test: testAffixTypeContainsSingleType in `Tests/ItemSystemTests/Models/AffixTypeTests.swift`
- [ ] T048 [P] [US3] Write test: testAffixTypeContainsMultipleTypes in `Tests/ItemSystemTests/Models/AffixTypeTests.swift`
- [ ] T049 [P] [US3] Write test: testAffixTypeIsDisjointWithNoOverlap in `Tests/ItemSystemTests/Models/AffixTypeTests.swift`
- [ ] T050 [US3] Implement AffixType OptionSet in `Sources/ItemSystem/Models/AffixType.swift`
- [ ] T051 [US3] Run tests and verify green: `swift test --filter AffixTypeTests`

### Affix

- [ ] T052 [P] [US3] Write test: testAffixInitializationSetsProperties in `Tests/ItemSystemTests/Models/AffixTests.swift`
- [ ] T053 [P] [US3] Write test: testAffixToStatsConvertsCorrectly in `Tests/ItemSystemTests/Models/AffixTests.swift`
- [ ] T054 [US3] Implement Affix struct in `Sources/ItemSystem/Models/Affix.swift`
- [ ] T055 [US3] Run tests and verify green: `swift test --filter AffixTests`

### AffixPool & AffixGenerator

- [ ] T056 [P] [US3] Write test: testAffixGeneratorGenerateMainAffixReturnsValidAffix in `Tests/ItemSystemTests/Systems/AffixGeneratorTests.swift`
- [ ] T057 [P] [US3] Write test: testAffixGeneratorGenerateSubAffixesWhenLegendaryThenFourAffixes in `Tests/ItemSystemTests/Systems/AffixGeneratorTests.swift`
- [ ] T058 [P] [US3] Write test: testAffixGeneratorGenerateSubAffixesWhenCommonThenZeroAffixes in `Tests/ItemSystemTests/Systems/AffixGeneratorTests.swift`
- [ ] T059 [P] [US3] Write test: testAffixGeneratorWeightedDistributionMatchesExpected in `Tests/ItemSystemTests/Systems/AffixGeneratorTests.swift`
- [ ] T060 [US3] Implement WeightedAffix and AffixPoolEntry in `Sources/ItemSystem/Systems/AffixPool.swift`
- [ ] T061 [US3] Implement AffixGenerator with RandomNumberGenerating injection in `Sources/ItemSystem/Systems/AffixGenerator.swift`
- [ ] T062 [US3] Run all US3 tests: `swift test --filter "AffixTypeTests|AffixTests|AffixGeneratorTests"`

---

## Phase 6: US4 - 背包管理 (P2)

**Goal**: 玩家擁有一個背包來存放未穿戴的物品，背包有容量上限

**Independent Test**: 向背包添加物品直到滿載，驗證容量限制是否生效

### Inventory

- [ ] T063 [P] [US4] Write test: testInventoryAddItemWhenNotFullThenSuccess in `Tests/ItemSystemTests/Containers/InventoryTests.swift`
- [ ] T064 [P] [US4] Write test: testInventoryAddItemWhenFullThenInventoryFullError in `Tests/ItemSystemTests/Containers/InventoryTests.swift`
- [ ] T065 [P] [US4] Write test: testInventoryRemoveItemWhenExistsThenSuccess in `Tests/ItemSystemTests/Containers/InventoryTests.swift`
- [ ] T066 [P] [US4] Write test: testInventoryRemoveItemWhenNotFoundThenItemNotFoundError in `Tests/ItemSystemTests/Containers/InventoryTests.swift`
- [ ] T067 [P] [US4] Write test: testInventoryContainsWhenItemExistsThenTrue in `Tests/ItemSystemTests/Containers/InventoryTests.swift`
- [ ] T068 [P] [US4] Write test: testInventoryItemWithIdWhenExistsThenReturnsItem in `Tests/ItemSystemTests/Containers/InventoryTests.swift`
- [ ] T069 [US4] Implement Inventory class in `Sources/ItemSystem/Containers/Inventory.swift`
- [ ] T070 [US4] Run tests and verify green: `swift test --filter InventoryTests`

### Avatar + Inventory Integration

- [ ] T071 [US4] Write test: testAvatarUnequipWhenInventoryFullThenInventoryFullError in `Tests/ItemSystemTests/Avatar/AvatarTests.swift`
- [ ] T072 [US4] Update Avatar to integrate Inventory in `Sources/ItemSystem/Avatar/Avatar.swift`
- [ ] T073 [US4] Run all US4 tests: `swift test --filter "InventoryTests|AvatarTests"`

---

## Phase 7: US5 - 套裝效果 (P3)

**Goal**: 穿戴同一套裝的多件裝備時，觸發套裝效果

**Independent Test**: 穿戴不同數量的同套裝備，驗證套裝效果是否正確觸發

### SetBonus & EquipmentSet

- [ ] T074 [P] [US5] Write test: testSetBonusInitializationSetsProperties in `Tests/ItemSystemTests/Systems/EquipmentSetTests.swift`
- [ ] T075 [P] [US5] Write test: testEquipmentSetContainsPiecesCorrectly in `Tests/ItemSystemTests/Systems/EquipmentSetTests.swift`
- [ ] T076 [US5] Implement SetBonus and EquipmentSet structs in `Sources/ItemSystem/Systems/EquipmentSet.swift`
- [ ] T077 [US5] Run tests and verify green: `swift test --filter EquipmentSetTests`

### SetBonusCalculator

- [ ] T078 [P] [US5] Write test: testCalculateBonusesWhenTwoPiecesEquippedThenTwoPieceBonusActive in `Tests/ItemSystemTests/Systems/SetBonusCalculatorTests.swift`
- [ ] T079 [P] [US5] Write test: testCalculateBonusesWhenFourPiecesEquippedThenBothBonusesActive in `Tests/ItemSystemTests/Systems/SetBonusCalculatorTests.swift`
- [ ] T080 [P] [US5] Write test: testCalculateBonusesWhenMixedSetsThenCorrectBonusesActive in `Tests/ItemSystemTests/Systems/SetBonusCalculatorTests.swift`
- [ ] T081 [P] [US5] Write test: testCalculateBonusesWhenBelowThresholdThenNoBonuses in `Tests/ItemSystemTests/Systems/SetBonusCalculatorTests.swift`
- [ ] T082 [US5] Implement SetBonusCalculator in `Sources/ItemSystem/Systems/SetBonusCalculator.swift`
- [ ] T083 [US5] Run all US5 tests: `swift test --filter "EquipmentSetTests|SetBonusCalculatorTests"`

---

## Phase 8: US6 - 詞條快速查詢 (P3)

**Goal**: 使用 Bitmask 機制快速檢測裝備是否擁有特定詞條或詞條組合

**Independent Test**: 建立擁有特定詞條的裝備，執行各種 Bitmask 查詢來驗證

### Item Bitmask Methods

- [ ] T084 [P] [US6] Write test: testItemHasAffixWhenAffixPresentThenTrue in `Tests/ItemSystemTests/Models/ItemTests.swift`
- [ ] T085 [P] [US6] Write test: testItemHasAllAffixesWhenAllPresentThenTrue in `Tests/ItemSystemTests/Models/ItemTests.swift`
- [ ] T086 [P] [US6] Write test: testItemHasAllAffixesWhenSomeMissingThenFalse in `Tests/ItemSystemTests/Models/ItemTests.swift`
- [ ] T087 [P] [US6] Write test: testItemHasAnyAffixWhenOnePresentThenTrue in `Tests/ItemSystemTests/Models/ItemTests.swift`
- [ ] T088 [US6] Implement hasAffix, hasAllAffixes, hasAnyAffix methods on Item in `Sources/ItemSystem/Models/Item.swift`
- [ ] T089 [US6] Run all US6 tests: `swift test --filter ItemTests`

---

## Phase 9: US7 - 資料持久化 (P3)

**Goal**: 系統可以從 JSON 載入物品模板，也可以將物品實例序列化/反序列化

**Independent Test**: 建立物品、序列化、反序列化後比對資料是否一致

### ItemTemplateLoader

- [ ] T090 [P] [US7] Write test: testLoadFromJsonDataWhenValidThenReturnsTemplates in `Tests/ItemSystemTests/Persistence/ItemTemplateLoaderTests.swift`
- [ ] T091 [P] [US7] Write test: testLoadFromJsonDataWhenInvalidThenReturnsError in `Tests/ItemSystemTests/Persistence/ItemTemplateLoaderTests.swift`
- [ ] T092 [US7] Implement ItemTemplateLoader in `Sources/ItemSystem/Persistence/ItemTemplateLoader.swift`
- [ ] T093 [US7] Run tests and verify green: `swift test --filter ItemTemplateLoaderTests`

### ItemSerializer

- [ ] T094 [P] [US7] Write test: testSerializeItemThenDeserializeReturnsEqualItem in `Tests/ItemSystemTests/Persistence/ItemSerializerTests.swift`
- [ ] T095 [P] [US7] Write test: testSerializeInventoryThenDeserializeReturnsEqualInventory in `Tests/ItemSystemTests/Persistence/ItemSerializerTests.swift`
- [ ] T096 [P] [US7] Write test: testDeserializeFromInvalidDataThenReturnsError in `Tests/ItemSystemTests/Persistence/ItemSerializerTests.swift`
- [ ] T097 [US7] Implement ItemSerializer in `Sources/ItemSystem/Persistence/ItemSerializer.swift`
- [ ] T098 [US7] Run tests and verify green: `swift test --filter ItemSerializerTests`
- [ ] T099 [US7] Run all US7 tests: `swift test --filter "ItemTemplateLoaderTests|ItemSerializerTests"`

---

## Phase 10: Polish & Edge Cases

**Goal**: 處理邊界案例，確保所有測試通過

### Edge Case Tests

- [ ] T100 Write test: testAvatarEquipItemWhenReplacingThenOldItemGoesToInventory in `Tests/ItemSystemTests/Avatar/AvatarTests.swift`
- [ ] T101 Write test: testAffixGeneratorWhenEmptyPoolThenEmptyAffixPoolError in `Tests/ItemSystemTests/Systems/AffixGeneratorTests.swift`
- [ ] T102 Write test: testItemFactoryWhenTemplateNotFoundThenTemplateNotFoundError in `Tests/ItemSystemTests/Systems/ItemFactoryTests.swift`
- [ ] T103 Implement edge case handling for all identified scenarios

### Final Validation

- [ ] T104 Run full test suite: `swift test`
- [ ] T105 Verify all 101 tasks completed and tests pass

---

## Dependencies

```
Phase 1 (Setup)
    │
    ▼
Phase 2 (Foundational)
    │
    ├──────────────────┐
    ▼                  ▼
Phase 3 (US2)      Phase 6 (US4)
    │                  │
    ▼                  │
Phase 4 (US1) ◄────────┘
    │
    ├──────────────────┐
    ▼                  ▼
Phase 5 (US3)      Phase 7 (US5)
    │                  │
    ▼                  │
Phase 8 (US6) ◄────────┘
    │
    ▼
Phase 9 (US7)
    │
    ▼
Phase 10 (Polish)
```

### Story Dependencies

| Story | Depends On |
|-------|------------|
| US1 - 穿戴與卸下裝備 | US2, US4 (Inventory for unequip) |
| US2 - 物品生成 | Foundational Models |
| US3 - 詞條系統 | US2 (Item) |
| US4 - 背包管理 | Foundational Models |
| US5 - 套裝效果 | US1, US2 |
| US6 - Bitmask 查詢 | US3 (AffixType) |
| US7 - 持久化 | All models |

---

## Parallel Execution Opportunities

### Phase 2 Parallelization

```
T004-T007 (EquipmentSlot) ─┐
T008-T012 (Rarity) ────────┼─► T019 (Run all)
T013-T017 (Stats) ─────────┘
T018 (ItemSystemError) ────┘
```

### Phase 3-4 Parallelization

```
T020-T023 (ItemTemplate) ─┐
T024-T028 (Item) ─────────┼─► T032 (Run all US2)
T029-T031 (ItemFactory) ──┘
```

### Phase 5-6 Parallelization

```
T047-T055 (AffixType, Affix) ─┐
T063-T070 (Inventory) ────────┼─► Can run in parallel
```

---

## MVP Scope

**Suggested MVP**: Complete Phase 1-4 (Setup + Foundational + US2 + US1)

This provides:
- Basic item generation from templates
- Equipment slots with equip/unequip
- Stats calculation
- 36 tasks total for MVP

---

## Implementation Strategy

1. **Start with Phase 1-2**: Get project structure and foundational models working
2. **P1 Stories (US2, US1)**: Core functionality first - item generation and equipment
3. **P2 Stories (US3, US4)**: Add depth - affix system and inventory
4. **P3 Stories (US5, US6, US7)**: Polish - set bonuses, optimization, persistence
5. **Phase 10**: Edge cases and final validation

**TDD Cycle per Task**:
1. Write test (Red)
2. Implement minimum code to pass (Green)
3. Refactor if needed
4. Verify all tests pass before next task

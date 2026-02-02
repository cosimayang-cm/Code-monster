# Tasks: RPG 物品/背包系統

**Feature**: 004-rpg-inventory-system
**Date**: 2026-02-01

## Task Overview

| Phase | Tasks | Priority | Estimated LOC |
|-------|-------|----------|---------------|
| Phase 1 | 6 | P1 | ~400 |
| Phase 2 | 4 | P1 | ~350 |
| Phase 3 | 5 | P1 | ~400 |
| Phase 4 | 3 | P2 | ~250 |
| Phase 5 | 4 | P2 | ~350 |
| Phase 6 | 3 | P3 | ~200 |
| Phase 7 | 3 | P2 | ~100 |
| **Total** | **28** | - | **~2050** |

---

## Phase 1: Core Data Models (P1)

### TASK-001: 建立 Stats 結構
**Story**: US-001
**File**: `src/Models/Stats.swift`
**LOC**: ~80

- [ ] 定義 Stats struct 包含 7 個數值屬性
- [ ] 實作 Codable 協定
- [ ] 實作 Equatable 協定
- [ ] 實作 `static var zero` 初始值
- [ ] 實作 `+` 運算子支援數值相加
- [ ] 實作 `*` 運算子支援倍率調整
- [ ] 撰寫單元測試

**Acceptance Criteria**:
- 所有數值預設為 0
- 可正確 JSON 序列化/反序列化
- 運算子正確計算

---

### TASK-002: 建立 EquipmentSlot 列舉
**Story**: US-003
**File**: `src/Models/EquipmentSlot.swift`
**LOC**: ~30

- [ ] 定義 5 個裝備欄位 (helmet, body, gloves, boots, belt)
- [ ] 實作 Codable, CaseIterable 協定
- [ ] 新增 displayName 計算屬性
- [ ] 撰寫單元測試

---

### TASK-003: 建立 Rarity 列舉
**Story**: US-001
**File**: `src/Models/Rarity.swift`
**LOC**: ~60

- [ ] 定義 5 個稀有度等級
- [ ] 實作 Codable, CaseIterable, Comparable 協定
- [ ] 新增 initialSubAffixCount 計算屬性
- [ ] 新增 maxSubAffixCount 計算屬性
- [ ] 新增 displayColor 計算屬性
- [ ] 撰寫單元測試

---

### TASK-004: 建立 AffixType OptionSet (Bitmask)
**Story**: US-007
**File**: `src/Models/AffixType.swift`
**LOC**: ~120

- [ ] 使用 OptionSet 定義 11 種詞條類型
- [ ] 實作自訂 Codable (字串陣列格式)
- [ ] 新增 stringKey 映射
- [ ] 新增 allTypes 靜態屬性
- [ ] 實作 init(stringKeys:) 建構子
- [ ] 撰寫單元測試 (含序列化測試)

---

### TASK-005: 建立 Affix 結構
**Story**: US-001
**File**: `src/Models/Affix.swift`
**LOC**: ~50

- [ ] 定義 Affix struct (type, value, isPercentage)
- [ ] 實作 Codable, Equatable 協定
- [ ] 新增 displayText 計算屬性
- [ ] 撰寫單元測試

---

### TASK-006: 建立錯誤類型
**Story**: All
**File**: `src/Models/Errors.swift`
**LOC**: ~60

- [ ] 定義 InventoryError 列舉
- [ ] 定義 EquipmentError 列舉
- [ ] 定義 ItemError 列舉
- [ ] 實作 LocalizedError 協定
- [ ] 撰寫單元測試

---

## Phase 2: Affix System (P1)

### TASK-007: 建立 AffixPool 服務
**Story**: US-001
**File**: `src/Services/AffixPool.swift`
**LOC**: ~100

- [ ] 定義可用主詞條池 (by slot)
- [ ] 定義可用副詞條池
- [ ] 實作隨機選取方法
- [ ] 實作排除重複選取
- [ ] 撰寫單元測試

---

### TASK-008: 建立 AffixValueCalculator
**Story**: US-002
**File**: `src/Services/AffixValueCalculator.swift`
**LOC**: ~80

- [ ] 定義詞條數值範圍
- [ ] 實作隨機數值生成
- [ ] 實作升級數值計算 (+10%/level)
- [ ] 撰寫單元測試

---

### TASK-009: 實作 AffixContainer 協定
**Story**: US-007
**File**: `src/Protocols/AffixContainer.swift`
**LOC**: ~80

- [ ] 定義協定方法
- [ ] 實作預設方法 (hasAffix, getAffixes)
- [ ] 確保 O(1) 查詢複雜度
- [ ] 撰寫單元測試

---

### TASK-010: Affix Bitmask 整合測試
**Story**: US-007
**File**: `tests/AffixBitmaskTests.swift`
**LOC**: ~90

- [ ] 測試單一詞條查詢
- [ ] 測試多重詞條查詢
- [ ] 測試 AND/OR 組合查詢
- [ ] 測試序列化往返
- [ ] 效能測試 (1000 次查詢 < 10ms)

---

## Phase 3: Item System (P1)

### TASK-011: 建立 ItemTemplate 結構
**Story**: US-001
**File**: `src/Models/ItemTemplate.swift`
**LOC**: ~100

- [ ] 定義所有模板屬性
- [ ] 實作 Codable, Identifiable 協定
- [ ] 新增驗證方法
- [ ] 撰寫單元測試

---

### TASK-012: 建立 Item 類別
**Story**: US-001, US-002
**File**: `src/Models/Item.swift`
**LOC**: ~150

- [ ] 定義所有實例屬性
- [ ] 實作 Codable, Identifiable, Equatable, Hashable
- [ ] 實作 AffixContainer 協定
- [ ] 實作 Upgradable 協定
- [ ] 實作 Equippable 協定
- [ ] 實作 StatProvider 協定
- [ ] 維護 affixMask 一致性
- [ ] 撰寫單元測試

---

### TASK-013: 建立 ItemFactory
**Story**: US-001
**File**: `src/Services/ItemFactory.swift`
**LOC**: ~80

- [ ] 依賴注入 TemplateService
- [ ] 實作 createItem 方法
- [ ] 實作 createRandomItem 方法
- [ ] 驗證副詞條數量符合稀有度
- [ ] 撰寫單元測試

---

### TASK-014: Item 升級系統
**Story**: US-002
**File**: 擴充 `src/Models/Item.swift`
**LOC**: ~50

- [ ] 實作 upgrade() 方法
- [ ] 每 4 級新增/強化副詞條
- [ ] 數值 +10%/level 成長
- [ ] 撰寫單元測試

---

### TASK-015: Item JSON 序列化測試
**Story**: US-008
**File**: `tests/ItemSerializationTests.swift`
**LOC**: ~60

- [ ] 測試基本 JSON 往返
- [ ] 測試 Bitmask 正確序列化
- [ ] 測試複雜物品序列化
- [ ] 測試向後相容性

---

## Phase 4: Set Bonus System (P2)

### TASK-016: 建立 EquipmentSet 結構
**Story**: US-006
**File**: `src/Models/EquipmentSet.swift`
**LOC**: ~70

- [ ] 定義套裝屬性 (setId, name, pieces, bonuses)
- [ ] 實作 Codable, Identifiable 協定
- [ ] 撰寫單元測試

---

### TASK-017: 建立 SetBonus 結構
**Story**: US-006
**File**: `src/Models/SetBonus.swift`
**LOC**: ~80

- [ ] 定義套裝效果 (requiredPieces, effect, description)
- [ ] 定義 SetBonusEffect 列舉 (statBonus, specialEffect)
- [ ] 實作 Codable 協定
- [ ] 撰寫單元測試

---

### TASK-018: 建立 SetBonusCalculator
**Story**: US-006
**File**: `src/Services/SetBonusCalculator.swift`
**LOC**: ~100

- [ ] 計算啟動的套裝效果
- [ ] 支援多套裝同時啟動
- [ ] 回傳 ActiveSetBonus 列表
- [ ] 撰寫單元測試

---

## Phase 5: Container System (P2)

### TASK-019: 建立 Inventory 類別
**Story**: US-004
**File**: `src/Containers/Inventory.swift`
**LOC**: ~120

- [ ] 實作 ItemContainer 協定
- [ ] 支援 Sequence 迭代
- [ ] 實作容量檢查
- [ ] 實作 add/remove 方法
- [ ] 實作 filter 方法 (by slot, by affix)
- [ ] 撰寫單元測試

---

### TASK-020: 建立 EquipmentSlots 類別
**Story**: US-003
**File**: `src/Containers/EquipmentSlots.swift`
**LOC**: ~100

- [ ] 實作 EquipmentSlotContainer 協定
- [ ] 實作 equip/unequip 方法
- [ ] 等級需求檢查
- [ ] 返回被替換物品
- [ ] 撰寫單元測試

---

### TASK-021: 建立 Avatar 類別
**Story**: US-005
**File**: `src/Models/Avatar.swift`
**LOC**: ~100

- [ ] 整合 EquipmentSlots 和 Inventory
- [ ] 實作 finalStats 計算
- [ ] 實作 activeSetBonuses 計算
- [ ] 實作便捷 equip/unequip 方法
- [ ] 撰寫單元測試

---

### TASK-022: Avatar 整合測試
**Story**: US-005
**File**: `tests/AvatarIntegrationTests.swift`
**LOC**: ~80

- [ ] 測試完整裝備流程
- [ ] 測試數值正確計算
- [ ] 測試套裝效果啟動
- [ ] 測試錯誤處理

---

## Phase 6: Service Layer (P3)

### TASK-023: 建立 ItemTemplateService
**Story**: US-001
**File**: `src/Services/ItemTemplateService.swift`
**LOC**: ~80

- [ ] 載入 JSON 模板資料
- [ ] 快取模板
- [ ] 實作查詢方法
- [ ] 撰寫單元測試

---

### TASK-024: 建立 EquipmentSetService
**Story**: US-006
**File**: `src/Services/EquipmentSetService.swift`
**LOC**: ~60

- [ ] 載入 JSON 套裝資料
- [ ] 快取套裝
- [ ] 實作查詢方法
- [ ] 撰寫單元測試

---

### TASK-025: 建立 JSON 資源檔
**Story**: US-008
**File**: `Resources/item_templates.json`, `Resources/equipment_sets.json`
**LOC**: ~60

- [ ] 建立 5+ 物品模板
- [ ] 建立 2+ 套裝定義
- [ ] 驗證 JSON 格式正確
- [ ] 載入測試

---

## Phase 7: Testing & Documentation (P2)

### TASK-026: 效能測試
**Story**: SC-003
**File**: `tests/PerformanceTests.swift`
**LOC**: ~50

- [ ] Bitmask 查詢 1000 次 < 10ms
- [ ] 物品建立 100 個 < 100ms
- [ ] 套裝計算 < 5ms

---

### TASK-027: 邊界條件測試
**Story**: All
**File**: `tests/EdgeCaseTests.swift`
**LOC**: ~60

- [ ] 空背包操作
- [ ] 滿背包操作
- [ ] 等級邊界 (1, maxLevel)
- [ ] 空詞條處理

---

### TASK-028: README 文件
**Story**: -
**File**: `README.md`
**LOC**: ~50 (不計入)

- [ ] 功能概述
- [ ] 快速開始指南
- [ ] API 文件連結
- [ ] 授權資訊

---

## Task Dependencies

```
TASK-001 ─┬─► TASK-005 ─┬─► TASK-007 ─► TASK-008
TASK-002 ─┤            │
TASK-003 ─┤            └─► TASK-011 ─► TASK-012 ─┬─► TASK-013 ─► TASK-014
TASK-004 ─┴─► TASK-009 ─► TASK-010              │
                                                 │
TASK-016 ─► TASK-017 ─► TASK-018 ───────────────┼─► TASK-021 ─► TASK-022
                                                 │
TASK-019 ──────────────────────────────────────┬─┘
TASK-020 ──────────────────────────────────────┘
```

---

## Implementation Order

建議實作順序（考慮依賴關係）：

1. **Day 1**: TASK-001 ~ TASK-006 (Core Models)
2. **Day 2**: TASK-007 ~ TASK-010 (Affix System)
3. **Day 3**: TASK-011 ~ TASK-015 (Item System)
4. **Day 4**: TASK-016 ~ TASK-018 (Set System)
5. **Day 5**: TASK-019 ~ TASK-022 (Containers + Avatar)
6. **Day 6**: TASK-023 ~ TASK-025 (Services + Resources)
7. **Day 7**: TASK-026 ~ TASK-028 (Testing + Docs)

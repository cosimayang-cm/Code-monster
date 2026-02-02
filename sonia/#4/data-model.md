# Data Model: RPG 道具系統

**Feature**: 003-rpg-item-system
**Date**: 2026-01-30

---

## Entity Relationship Diagram

```
┌─────────────────┐     1:N     ┌─────────────────┐
│  ItemTemplate   │────────────▶│      Item       │
│  (物品模板)      │             │   (物品實例)     │
└─────────────────┘             └─────────────────┘
                                        │
                                        │ 1:1 (主詞條)
                                        │ 1:N (副詞條)
                                        ▼
                                ┌─────────────────┐
                                │     Affix       │
                                │    (詞條)        │
                                └─────────────────┘

┌─────────────────┐     N:1     ┌─────────────────┐
│      Item       │────────────▶│  EquipmentSet   │
│   (物品實例)     │             │    (套裝)        │
└─────────────────┘             └─────────────────┘

┌─────────────────┐             ┌─────────────────┐
│     Avatar      │─────────────│ EquipmentSlots  │
│    (角色)        │  contains   │   (裝備欄)       │
└─────────────────┘             └─────────────────┘
        │                               │
        │ contains                      │ 0..5 Items
        ▼                               ▼
┌─────────────────┐             ┌─────────────────┐
│   Inventory     │             │      Item       │
│    (背包)        │────────────▶│   (物品實例)     │
└─────────────────┘   0..N      └─────────────────┘
```

---

## Enumerations

### EquipmentSlot（裝備欄位）

| Case | Raw Value | 說明 |
|------|-----------|------|
| helmet | "helmet" | 頭盔 |
| body | "body" | 身體 |
| gloves | "gloves" | 手套 |
| boots | "boots" | 鞋子 |
| belt | "belt" | 腰帶 |

**協定**: `String`, `CaseIterable`, `Codable`

---

### Rarity（稀有度）

| Case | Raw Value | 初始副詞條 | 最大副詞條 |
|------|-----------|-----------|-----------|
| common | "common" | 0 | 0 |
| uncommon | "uncommon" | 1 | 2 |
| rare | "rare" | 2 | 3 |
| epic | "epic" | 3 | 4 |
| legendary | "legendary" | 4 | 4 |

**協定**: `String`, `CaseIterable`, `Codable`, `Comparable`

**計算屬性**:
- `initialSubAffixCount: Int`
- `maxSubAffixCount: Int`

---

### AffixType（詞條類型 - OptionSet）

| Case | Bit Position | Raw Value | Key |
|------|--------------|-----------|-----|
| crit | 0 | 0b0000_0001 | 暴擊 |
| energyRecharge | 1 | 0b0000_0010 | 充能 |
| attack | 2 | 0b0000_0100 | 攻擊 |
| defense | 3 | 0b0000_1000 | 防禦 |
| hp | 4 | 0b0001_0000 | 生命 |
| elementalMastery | 5 | 0b0010_0000 | 元素精通 |
| elementalDamage | 6 | 0b0100_0000 | 元素傷害 |
| healingBonus | 7 | 0b1000_0000 | 治療加成 |

**協定**: `OptionSet`, `Codable`
**Raw Type**: `UInt32`

---

## Structures

### Stats（數值）

| Property | Type | 說明 |
|----------|------|------|
| attack | Double | 攻擊力 |
| defense | Double | 防禦力 |
| maxHP | Double | 最大生命 |
| maxMP | Double | 最大魔力 |
| critRate | Double | 暴擊率 (0.0~1.0) |
| critDamage | Double | 暴擊傷害倍率 |
| speed | Double | 速度 |

**協定**: `Codable`, `Equatable`

**運算子**:
- `static func + (lhs: Stats, rhs: Stats) -> Stats`
- `static func * (lhs: Stats, rhs: Double) -> Stats`

**初始化**:
- `static let zero: Stats`

---

### Affix（詞條）

| Property | Type | 說明 |
|----------|------|------|
| type | AffixType | 詞條類型（單一類型） |
| value | Double | 數值 |
| isPercentage | Bool | 是否為百分比 |

**協定**: `Codable`, `Equatable`

**驗證規則**:
- `type` 必須只有一個 bit 被設置（單一詞條類型）
- `value` 必須 > 0

---

### ItemTemplate（物品模板）

| Property | Type | Required | 說明 |
|----------|------|----------|------|
| templateId | String | ✓ | 模板唯一識別碼 |
| name | String | ✓ | 顯示名稱 |
| description | String | ✓ | 物品描述 |
| slot | EquipmentSlot | ✓ | 裝備欄位 |
| rarity | Rarity | ✓ | 稀有度 |
| levelRequirement | Int | ✓ | 等級需求 |
| baseStats | Stats | ✓ | 基礎數值 |
| setId | String? | | 套裝 ID |
| iconAsset | String? | | 圖示資源名稱 |
| modelAsset | String? | | 3D 模型資源名稱 |

**協定**: `Codable`, `Equatable`, `Identifiable`

**驗證規則**:
- `templateId` 不可為空
- `levelRequirement` >= 1

---

### WeightedAffix（加權詞條）

| Property | Type | 說明 |
|----------|------|------|
| type | AffixType | 詞條類型 |
| weight | Int | 權重 |

**協定**: `Codable`

---

### AffixPoolEntry（詞條池項目）

| Property | Type | 說明 |
|----------|------|------|
| mainAffixPool | [WeightedAffix] | 主詞條池 |
| subAffixPool | [WeightedAffix] | 副詞條池 |

**協定**: `Codable`

---

### SetBonus（套裝效果）

| Property | Type | 說明 |
|----------|------|------|
| requiredPieces | Int | 所需件數 |
| statBonus | Stats | 數值加成 |
| description | String | 效果描述 |

**協定**: `Codable`, `Equatable`

---

### EquipmentSet（套裝定義）

| Property | Type | 說明 |
|----------|------|------|
| setId | String | 套裝 ID |
| name | String | 套裝名稱 |
| pieces | [String] | 所屬物品模板 ID 列表 |
| bonuses | [SetBonus] | 套裝效果列表 |

**協定**: `Codable`, `Equatable`, `Identifiable`

---

## Classes

### Item（物品實例）

| Property | Type | 說明 |
|----------|------|------|
| instanceId | UUID | 實例唯一識別碼 |
| templateId | String | 模板 ID |
| level | Int | 當前等級 |
| maxLevel | Int | 最大等級 |
| mainAffix | Affix | 主詞條 |
| subAffixes | [Affix] | 副詞條列表 |
| affixMask | AffixType | 詞條 Bitmask |

**協定**: `Codable`, `Equatable`, `Identifiable`

**計算屬性**:
- `totalStats: Stats` - 計算所有詞條提供的數值

**方法**:
- `func levelUp()` - 提升等級，增加主詞條數值
- `func hasAffix(_ type: AffixType) -> Bool` - 使用 Bitmask 檢查單一詞條
- `func hasAllAffixes(_ types: AffixType) -> Bool` - 檢查是否擁有所有指定詞條
- `func hasAnyAffix(_ types: AffixType) -> Bool` - 檢查是否擁有任一指定詞條

**狀態轉換**:
```
Created (level: 1) → Leveled Up (level: 2..20) → Max Level (level: 20)
```

---

### Inventory（背包）

| Property | Type | 說明 |
|----------|------|------|
| capacity | Int | 容量上限 |
| items | [Item] | 物品列表（私有） |

**協定**: `Codable`

**計算屬性**:
- `count: Int`
- `isFull: Bool`
- `isEmpty: Bool`

**方法**:
- `func add(_ item: Item) -> Result<Void, ItemSystemError>`
- `func remove(_ item: Item) -> Result<Item, ItemSystemError>`
- `func remove(at index: Int) -> Result<Item, ItemSystemError>`
- `func contains(_ item: Item) -> Bool`
- `func item(withId id: UUID) -> Item?`
- `func allItems() -> [Item]`

---

### EquipmentSlots（裝備欄）

| Property | Type | 說明 |
|----------|------|------|
| slots | [EquipmentSlot: Item?] | 欄位對應表（私有） |

**協定**: `Codable`

**方法**:
- `func equip(_ item: Item, to slot: EquipmentSlot) -> Result<Item?, ItemSystemError>`
  - 返回被替換的舊裝備（如有）
- `func unequip(from slot: EquipmentSlot) -> Result<Item, ItemSystemError>`
- `func item(at slot: EquipmentSlot) -> Item?`
- `func allEquippedItems() -> [Item]`
- `func equippedCount(forSetId setId: String) -> Int`

---

### Avatar（角色）

| Property | Type | 說明 |
|----------|------|------|
| id | UUID | 角色 ID |
| name | String | 角色名稱 |
| level | Int | 角色等級 |
| baseStats | Stats | 基礎數值 |
| equipmentSlots | EquipmentSlots | 裝備欄 |
| inventory | Inventory | 背包 |

**協定**: `Codable`, `Identifiable`

**計算屬性**:
- `totalStats: Stats` - 計算穿戴所有裝備後的總數值
- `activeSetBonuses: [SetBonus]` - 當前生效的套裝效果

**方法**:
- `func equip(_ item: Item, to slot: EquipmentSlot) -> Result<Void, ItemSystemError>`
- `func unequip(from slot: EquipmentSlot) -> Result<Void, ItemSystemError>`
- `func canEquip(_ item: Item) -> Bool`

---

## Service Classes

### AffixGenerator（詞條生成器）

**依賴**:
- `affixPools: [EquipmentSlot: AffixPoolEntry]`
- `randomGenerator: RandomNumberGenerator`（可注入，預設使用系統隨機）

**方法**:
- `func generateMainAffix(for slot: EquipmentSlot) -> Result<Affix, ItemSystemError>`
- `func generateSubAffixes(for slot: EquipmentSlot, rarity: Rarity, excluding: AffixType) -> Result<[Affix], ItemSystemError>`

---

### SetBonusCalculator（套裝效果計算器）

**依賴**:
- `equipmentSets: [String: EquipmentSet]`

**方法**:
- `func calculateBonuses(for equippedItems: [Item]) -> [SetBonus]`
- `func setId(for templateId: String) -> String?`

---

### ItemFactory（物品工廠）

**依賴**:
- `templates: [String: ItemTemplate]`
- `affixGenerator: AffixGenerator`

**方法**:
- `func createItem(from templateId: String) -> Result<Item, ItemSystemError>`
- `func createItem(from template: ItemTemplate) -> Item`

---

### ItemTemplateLoader（模板載入器）

**方法**:
- `func load(from jsonData: Data) -> Result<[ItemTemplate], Error>`
- `func load(from url: URL) -> Result<[ItemTemplate], Error>`

---

### ItemSerializer（物品序列化器）

**方法**:
- `func serialize(_ item: Item) -> Result<Data, Error>`
- `func deserialize(from data: Data) -> Result<Item, Error>`
- `func serialize(_ inventory: Inventory) -> Result<Data, Error>`
- `func deserialize(inventoryFrom data: Data) -> Result<Inventory, Error>`

---

## Error Types

### ItemSystemError

| Case | 說明 |
|------|------|
| inventoryFull | 背包已滿 |
| slotMismatch(expected:actual:) | 欄位不匹配 |
| levelRequirementNotMet(required:current:) | 等級不足 |
| templateNotFound(templateId:) | 模板不存在 |
| emptyAffixPool | 詞條池為空 |
| itemNotFound | 物品不存在 |
| slotEmpty | 欄位為空 |

---

## Validation Rules Summary

| Entity | Rule | Error |
|--------|------|-------|
| Item | 只能裝備到對應 slot | slotMismatch |
| Item | 角色等級 >= levelRequirement | levelRequirementNotMet |
| Inventory | count < capacity | inventoryFull |
| AffixGenerator | affixPool 不為空 | emptyAffixPool |
| ItemFactory | template 存在 | templateNotFound |

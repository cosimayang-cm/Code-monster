# Data Model: RPG 物品/背包系統

**Feature**: 004-rpg-inventory-system
**Date**: 2026-02-01

## Entity Relationship Diagram

```
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│ ItemTemplate│◄──────│    Item     │───────►│    Affix    │
│             │  1:N  │  (Instance) │  1:N   │             │
└─────────────┘       └──────┬──────┘       └─────────────┘
                             │                     │
                             │ N:1                 │ uses
                             ▼                     ▼
                      ┌──────────────┐      ┌─────────────┐
                      │EquipmentSet │      │  AffixType  │
                      │             │      │  (Bitmask)  │
                      └──────┬──────┘      └─────────────┘
                             │
                             │ 1:N
                             ▼
                      ┌─────────────┐
                      │  SetBonus   │
                      └─────────────┘
```

## Core Entities

### 1. EquipmentSlot (Enum)

裝備欄位定義。

```swift
enum EquipmentSlot: String, Codable, CaseIterable {
    case helmet  // 頭盔
    case body    // 身體
    case gloves  // 手套
    case boots   // 鞋子
    case belt    // 腰帶
}
```

| Value | Display Name | Description |
|-------|--------------|-------------|
| helmet | 頭盔 | 頭部防具 |
| body | 身體 | 軀幹護甲 |
| gloves | 手套 | 手部裝備 |
| boots | 鞋子 | 腳部裝備 |
| belt | 腰帶 | 腰部配件 |

---

### 2. Rarity (Enum)

稀有度定義，決定副詞條數量。

```swift
enum Rarity: String, Codable, CaseIterable, Comparable {
    case common    // 普通
    case uncommon  // 優良
    case rare      // 稀有
    case epic      // 史詩
    case legendary // 傳說
}
```

| Value | Display | Color | Initial Sub-Affixes | Max Sub-Affixes |
|-------|---------|-------|---------------------|-----------------|
| common | 普通 | 白色 | 0 | 0 |
| uncommon | 優良 | 綠色 | 1 | 2 |
| rare | 稀有 | 藍色 | 2 | 3 |
| epic | 史詩 | 紫色 | 3 | 4 |
| legendary | 傳說 | 橘色 | 4 | 4 |

---

### 3. Stats (Struct)

角色/裝備的數值集合。

```swift
struct Stats: Codable, Equatable {
    var attack: Double       // 攻擊力
    var defense: Double      // 防禦力
    var maxHP: Double        // 最大生命值
    var maxMP: Double        // 最大魔力值
    var critRate: Double     // 暴擊率 (0.0~1.0)
    var critDamage: Double   // 暴擊傷害倍率
    var speed: Double        // 速度
}
```

| Property | Type | Range | Description |
|----------|------|-------|-------------|
| attack | Double | 0+ | 物理攻擊傷害 |
| defense | Double | 0+ | 物理傷害減免 |
| maxHP | Double | 0+ | 生命值上限 |
| maxMP | Double | 0+ | 魔力值上限 |
| critRate | Double | 0.0~1.0 | 暴擊機率 |
| critDamage | Double | 0+ | 暴擊傷害倍率 |
| speed | Double | 0+ | 行動速度 |

---

### 4. AffixType (OptionSet - Bitmask)

詞條類型，使用位元遮罩實現快速查詢。

```swift
struct AffixType: OptionSet, Codable, Hashable {
    let rawValue: UInt32
    
    static let crit             = AffixType(rawValue: 1 << 0)  // 0b0000_0001
    static let energyRecharge   = AffixType(rawValue: 1 << 1)  // 0b0000_0010
    static let attack           = AffixType(rawValue: 1 << 2)  // 0b0000_0100
    static let defense          = AffixType(rawValue: 1 << 3)  // 0b0000_1000
    static let hp               = AffixType(rawValue: 1 << 4)  // 0b0001_0000
    static let elementalMastery = AffixType(rawValue: 1 << 5)  // 0b0010_0000
    static let elementalDamage  = AffixType(rawValue: 1 << 6)  // 0b0100_0000
    static let healingBonus     = AffixType(rawValue: 1 << 7)  // 0b1000_0000
    static let critDamage       = AffixType(rawValue: 1 << 8)
    static let mp               = AffixType(rawValue: 1 << 9)
    static let speed            = AffixType(rawValue: 1 << 10)
}
```

| Bit | Mask | Type | String Key |
|-----|------|------|------------|
| 0 | 0x01 | 暴擊率 | crit |
| 1 | 0x02 | 充能效率 | energyRecharge |
| 2 | 0x04 | 攻擊力 | attack |
| 3 | 0x08 | 防禦力 | defense |
| 4 | 0x10 | 生命值 | hp |
| 5 | 0x20 | 元素精通 | elementalMastery |
| 6 | 0x40 | 元素傷害 | elementalDamage |
| 7 | 0x80 | 治療加成 | healingBonus |
| 8 | 0x100 | 暴擊傷害 | critDamage |
| 9 | 0x200 | 魔力值 | mp |
| 10 | 0x400 | 速度 | speed |

---

### 5. Affix (Struct)

詞條實例。

```swift
struct Affix: Codable, Equatable {
    let type: AffixType
    var value: Double
    let isPercentage: Bool
}
```

| Property | Type | Description |
|----------|------|-------------|
| type | AffixType | 詞條類型 |
| value | Double | 數值 |
| isPercentage | Bool | 是否為百分比加成 |

---

### 6. ItemTemplate (Struct)

物品模板，作為生成物品實例的藍圖。

```swift
struct ItemTemplate: Codable, Identifiable {
    let templateId: String
    let name: String
    let description: String
    let slot: EquipmentSlot
    let rarity: Rarity
    let levelRequirement: Int
    let baseStats: Stats
    let attributes: [ItemAttribute]
    let setId: String?
    let iconAsset: String?
    let modelAsset: String?
    let maxLevel: Int
}
```

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| templateId | String | ✓ | 模板唯一識別碼 |
| name | String | ✓ | 顯示名稱 |
| description | String | ✓ | 物品描述 |
| slot | EquipmentSlot | ✓ | 裝備欄位 |
| rarity | Rarity | ✓ | 稀有度 |
| levelRequirement | Int | ✓ | 等級需求 |
| baseStats | Stats | ✓ | 基礎數值 |
| attributes | [ItemAttribute] | ✓ | 特殊屬性 |
| setId | String? | - | 套裝 ID |
| iconAsset | String? | - | 圖示資源 |
| modelAsset | String? | - | 3D 模型資源 |
| maxLevel | Int | ✓ | 最大等級 |

---

### 7. Item (Class)

物品實例，從模板生成的實際物品。

```swift
final class Item: Identifiable, Codable, Equatable, Hashable {
    let instanceId: UUID
    let templateId: String
    let name: String
    let description: String
    let slot: EquipmentSlot
    let rarity: Rarity
    private(set) var level: Int
    let maxLevel: Int
    let levelRequirement: Int
    let setId: String?
    let baseStats: Stats
    let attributes: [ItemAttribute]
    let mainAffix: Affix
    private(set) var subAffixes: [Affix]
    private(set) var affixMask: AffixType
}
```

| Property | Type | Mutable | Description |
|----------|------|---------|-------------|
| instanceId | UUID | ✗ | 實例唯一識別碼 (v4) |
| templateId | String | ✗ | 模板 ID |
| level | Int | ✓ | 當前等級 |
| mainAffix | Affix | ✗ | 主詞條 |
| subAffixes | [Affix] | ✓ | 副詞條列表 |
| affixMask | AffixType | ✓ | 詞條 Bitmask |

---

### 8. EquipmentSet (Struct)

套裝定義。

```swift
struct EquipmentSet: Codable, Identifiable {
    let setId: String
    let name: String
    let pieces: [String]
    let bonuses: [SetBonus]
}
```

| Property | Type | Description |
|----------|------|-------------|
| setId | String | 套裝唯一識別碼 |
| name | String | 套裝名稱 |
| pieces | [String] | 包含的模板 ID 列表 |
| bonuses | [SetBonus] | 套裝效果列表 |

---

### 9. SetBonus (Struct)

套裝效果。

```swift
struct SetBonus: Codable {
    let requiredPieces: Int
    let effect: SetBonusEffect
    let description: String
}
```

| Property | Type | Description |
|----------|------|-------------|
| requiredPieces | Int | 所需件數 (2, 4, etc.) |
| effect | SetBonusEffect | 效果內容 |
| description | String | 效果描述 |

---

## Container Entities

### 10. EquipmentSlots (Class)

裝備欄管理器。

```swift
final class EquipmentSlots {
    private var slots: [EquipmentSlot: Item]
    
    var equippedItems: [Item]
    var equippedCount: Int
    var emptySlots: [EquipmentSlot]
    
    func equip(_ item: Item, characterLevel: Int) throws -> Item?
    func unequip(slot: EquipmentSlot) throws -> Item
    func getItem(at slot: EquipmentSlot) -> Item?
}
```

---

### 11. Inventory (Class)

背包管理器。

```swift
final class Inventory: Sequence {
    private var items: [Item]
    let capacity: Int
    
    var count: Int
    var isFull: Bool
    var remainingSpace: Int
    
    func add(_ item: Item) throws
    func remove(byId id: UUID) throws -> Item
    func filter(by slot: EquipmentSlot) -> [Item]
    func filter(hasAffix type: AffixType) -> [Item]
}
```

---

### 12. Avatar (Class)

角色，整合所有系統。

```swift
final class Avatar {
    let name: String
    private(set) var level: Int
    private(set) var baseStats: Stats
    let equipmentSlots: EquipmentSlots
    let inventory: Inventory
    
    var finalStats: Stats  // 計算最終數值
    var equippedItems: [Item]
    var activeSetBonuses: [ActiveSetBonus]
    
    func equip(_ item: Item) throws -> Item?
    func unequipToInventory(slot: EquipmentSlot) throws
}
```

---

## JSON Schema Examples

### Item Template JSON

```json
{
  "templateId": "helmet_royal_001",
  "name": "宗室冠冕",
  "description": "昔日宗室之儀的王冠",
  "slot": "helmet",
  "rarity": "legendary",
  "levelRequirement": 40,
  "maxLevel": 20,
  "setId": "royal_set",
  "baseStats": {
    "attack": 0,
    "defense": 50,
    "maxHP": 200,
    "maxMP": 0,
    "critRate": 0,
    "critDamage": 0,
    "speed": 0
  },
  "attributes": []
}
```

### Item Instance JSON

```json
{
  "instanceId": "550e8400-e29b-41d4-a716-446655440000",
  "templateId": "helmet_royal_001",
  "name": "宗室冠冕",
  "slot": "helmet",
  "rarity": "legendary",
  "level": 4,
  "maxLevel": 20,
  "mainAffix": {
    "type": "hp",
    "value": 14.9,
    "isPercentage": true
  },
  "subAffixes": [
    { "type": "crit", "value": 3.5, "isPercentage": true },
    { "type": "attack", "value": 14, "isPercentage": false }
  ],
  "affixMask": 21
}
```

### Equipment Set JSON

```json
{
  "setId": "royal_set",
  "name": "昔日宗室之儀",
  "pieces": ["helmet_royal_001", "body_royal_001", "gloves_royal_001"],
  "bonuses": [
    {
      "requiredPieces": 2,
      "effect": {
        "type": "statBonus",
        "stat": "attack",
        "value": 18,
        "isPercentage": true
      },
      "description": "攻擊力提升18%"
    }
  ]
}
```

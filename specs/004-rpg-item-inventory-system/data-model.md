# Data Model: RPG 道具/物品欄/背包系統

**Feature**: 004-rpg-item-inventory-system
**Date**: 2026-02-01
**Status**: Complete

---

## Entity Relationship Diagram

```
┌─────────────────┐         ┌─────────────────┐
│  ItemTemplate   │ 1     * │      Item       │
│─────────────────│─────────│─────────────────│
│ templateId (PK) │         │ instanceId (PK) │
│ name            │         │ templateId (FK) │
│ description     │         │ level           │
│ slot            │         │ mainAffix       │
│ rarity          │         │ subAffixes[]    │
│ levelRequirement│         │ affixMask       │
│ baseStats       │         └────────┬────────┘
│ attributes[]    │                  │
│ setId (FK)?     │                  │ *
└────────┬────────┘                  │
         │                           │
         │ *                         │ 5 (max)
         ▼                           ▼
┌─────────────────┐         ┌─────────────────┐
│  EquipmentSet   │         │ EquipmentSlots  │
│─────────────────│         │─────────────────│
│ setId (PK)      │         │ helmet?         │
│ name            │         │ body?           │
│ pieces[]        │         │ gloves?         │
│ bonuses[]       │         │ boots?          │
└─────────────────┘         │ belt?           │
                            └────────┬────────┘
                                     │ 1
                                     │
                                     ▼
                            ┌─────────────────┐
                            │     Avatar      │
                            │─────────────────│
                            │ level           │
                            │ baseStats       │
                            │ equipment (1)   │◄─── EquipmentSlots
                            │ inventory (1)   │◄─── Inventory
                            └─────────────────┘
                                     │
                                     │ 1
                                     ▼
                            ┌─────────────────┐
                            │    Inventory    │
                            │─────────────────│
                            │ capacity        │
                            │ items[] (0..50) │
                            └─────────────────┘
```

---

## Enumerations

### EquipmentSlot

```swift
enum EquipmentSlot: String, Codable, CaseIterable {
    case helmet = "helmet"
    case body = "body"
    case gloves = "gloves"
    case boots = "boots"
    case belt = "belt"
}
```

| Case | Raw Value | Description |
|------|-----------|-------------|
| helmet | "helmet" | 頭部裝備欄 |
| body | "body" | 身體裝備欄 |
| gloves | "gloves" | 手部裝備欄 |
| boots | "boots" | 腳部裝備欄 |
| belt | "belt" | 腰部裝備欄 |

### Rarity

```swift
enum Rarity: String, Codable, CaseIterable {
    case common = "common"
    case uncommon = "uncommon"
    case rare = "rare"
    case epic = "epic"
    case legendary = "legendary"

    var subAffixCount: Int {
        switch self {
        case .common: return 0
        case .uncommon: return 1
        case .rare: return 2
        case .epic: return 3
        case .legendary: return 4
        }
    }

    var maxSubAffixCount: Int {
        switch self {
        case .common: return 0
        case .uncommon: return 2
        case .rare: return 3
        case .epic: return 4
        case .legendary: return 4
        }
    }
}
```

| Case | Raw Value | Initial Sub Affixes | Max Sub Affixes | Display Color |
|------|-----------|---------------------|-----------------|---------------|
| common | "common" | 0 | 0 | 白色 |
| uncommon | "uncommon" | 1 | 2 | 綠色 |
| rare | "rare" | 2 | 3 | 藍色 |
| epic | "epic" | 3 | 4 | 紫色 |
| legendary | "legendary" | 4 | 4 | 橘色 |

### StatType

```swift
enum StatType: String, Codable, CaseIterable {
    case attack = "attack"
    case defense = "defense"
    case maxHP = "maxHP"
    case maxMP = "maxMP"
    case critRate = "critRate"
    case critDamage = "critDamage"
    case speed = "speed"
}
```

### Element

```swift
enum Element: String, Codable {
    case fire = "fire"
    case ice = "ice"
    case lightning = "lightning"
    case poison = "poison"
}
```

### SpecialEffect

```swift
enum SpecialEffect: String, Codable {
    case lifesteal = "lifesteal"
    case reflect = "reflect"
    case thorns = "thorns"
}
```

---

## Core Structures

### AffixType (Bitmask)

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

    // 複合類型
    static let offensive: AffixType = [.crit, .attack, .elementalDamage]
    static let defensive: AffixType = [.defense, .hp, .healingBonus]
}
```

### Affix

```swift
struct Affix: Codable, Equatable {
    let type: AffixType
    let value: Double
    let isPercentage: Bool

    // 計算實際加成值
    func calculateBonus(baseValue: Double) -> Double {
        if isPercentage {
            return baseValue * (value / 100.0)
        } else {
            return value
        }
    }
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| type | AffixType | Yes | 詞條類型（Bitmask） |
| value | Double | Yes | 數值 |
| isPercentage | Bool | Yes | 是否為百分比加成 |

### Stats

```swift
struct Stats: Codable, Equatable {
    var attack: Double = 0
    var defense: Double = 0
    var maxHP: Double = 0
    var maxMP: Double = 0
    var critRate: Double = 0
    var critDamage: Double = 0
    var speed: Double = 0

    // 數值相加
    static func + (lhs: Stats, rhs: Stats) -> Stats {
        Stats(
            attack: lhs.attack + rhs.attack,
            defense: lhs.defense + rhs.defense,
            maxHP: lhs.maxHP + rhs.maxHP,
            maxMP: lhs.maxMP + rhs.maxMP,
            critRate: lhs.critRate + rhs.critRate,
            critDamage: lhs.critDamage + rhs.critDamage,
            speed: lhs.speed + rhs.speed
        )
    }

    // 數值相乘（百分比套用）
    static func * (lhs: Stats, rhs: Double) -> Stats {
        Stats(
            attack: lhs.attack * rhs,
            defense: lhs.defense * rhs,
            maxHP: lhs.maxHP * rhs,
            maxMP: lhs.maxMP * rhs,
            critRate: lhs.critRate * rhs,
            critDamage: lhs.critDamage * rhs,
            speed: lhs.speed * rhs
        )
    }
}
```

---

## Item Entities

### ItemTemplate

```swift
struct ItemTemplate: Codable, Identifiable {
    let templateId: String        // PK, e.g., "helmet_iron_001"
    let name: String
    let description: String
    let slot: EquipmentSlot
    let rarity: Rarity
    let levelRequirement: Int
    let baseStats: Stats
    let attributes: [Attribute]
    let setId: String?            // FK to EquipmentSet
    let iconAsset: String?
    let modelAsset: String?

    var id: String { templateId }
}
```

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| templateId | String | Yes | Pattern: `^[a-z_]+_\d{3}$` |
| name | String | Yes | Non-empty |
| description | String | Yes | Non-empty |
| slot | EquipmentSlot | Yes | Valid enum value |
| rarity | Rarity | Yes | Valid enum value |
| levelRequirement | Int | Yes | >= 1 |
| baseStats | Stats | Yes | - |
| attributes | [Attribute] | Yes | Can be empty |
| setId | String? | No | Must exist in SetRegistry if present |
| iconAsset | String? | No | - |
| modelAsset | String? | No | - |

### Item

```swift
class Item: Codable, Identifiable, Equatable {
    let instanceId: UUID          // PK, auto-generated
    let templateId: String        // FK to ItemTemplate
    private(set) var level: Int
    let mainAffix: Affix
    let subAffixes: [Affix]
    private(set) var affixMask: AffixType

    // Computed properties (from template)
    var template: ItemTemplate { TemplateRegistry.get(templateId) }
    var name: String { template.name }
    var slot: EquipmentSlot { template.slot }
    var rarity: Rarity { template.rarity }
    var setId: String? { template.setId }

    var id: UUID { instanceId }

    init(template: ItemTemplate, mainAffix: Affix, subAffixes: [Affix]) {
        self.instanceId = UUID()
        self.templateId = template.templateId
        self.level = 1
        self.mainAffix = mainAffix
        self.subAffixes = subAffixes
        self.affixMask = Self.calculateMask(mainAffix: mainAffix, subAffixes: subAffixes)
    }

    // 升級
    func levelUp() {
        level += 1
    }

    // 計算 Bitmask
    private static func calculateMask(mainAffix: Affix, subAffixes: [Affix]) -> AffixType {
        var mask = mainAffix.type
        for affix in subAffixes {
            mask.insert(affix.type)
        }
        return mask
    }

    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.instanceId == rhs.instanceId
    }
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| instanceId | UUID | Yes | Auto-generated, unique |
| templateId | String | Yes | Reference to ItemTemplate |
| level | Int | Yes | 1-20, upgradeable |
| mainAffix | Affix | Yes | Primary stat bonus |
| subAffixes | [Affix] | Yes | 0-4 based on rarity |
| affixMask | AffixType | Yes | Computed from affixes |

---

## Set Entities

### SetBonus

```swift
struct SetBonus: Codable {
    let requiredPieces: Int       // 2 or 4
    let effect: SetEffect
    let description: String
}
```

### SetEffect

```swift
enum SetEffect: Codable {
    case statBonus(stat: StatType, value: Double, isPercentage: Bool)
    case teamBuff(stat: StatType, value: Double, isPercentage: Bool, duration: Int, trigger: String)
    case conditional(condition: String, effect: String)
    case elementalReaction(element: Element, bonus: Double)
}
```

### EquipmentSet

```swift
struct EquipmentSet: Codable, Identifiable {
    let setId: String             // PK
    let name: String
    let pieces: [String]          // templateIds in this set
    let bonuses: [SetBonus]

    var id: String { setId }
}
```

---

## Container Entities

### EquipmentSlots

```swift
class EquipmentSlots: Codable {
    private var slots: [EquipmentSlot: Item] = [:]

    // 取得特定欄位的裝備
    func getItem(at slot: EquipmentSlot) -> Item? {
        slots[slot]
    }

    // 裝備物品（回傳被替換的舊裝備）
    func equip(_ item: Item) -> Item? {
        let slot = item.slot
        let oldItem = slots[slot]
        slots[slot] = item
        return oldItem
    }

    // 卸下裝備
    func unequip(slot: EquipmentSlot) -> Item? {
        let item = slots[slot]
        slots[slot] = nil
        return item
    }

    // 取得所有已裝備物品
    var allEquipped: [Item] {
        Array(slots.values)
    }

    // 檢查是否為空
    var isEmpty: Bool {
        slots.isEmpty
    }
}
```

### Inventory

```swift
class Inventory: Codable {
    private var items: [Item] = []
    let capacity: Int

    init(capacity: Int = 50) {
        self.capacity = capacity
    }

    var count: Int { items.count }
    var isFull: Bool { count >= capacity }
    var availableSpace: Int { capacity - count }

    // 新增物品
    func add(_ item: Item) -> Bool {
        guard !isFull else { return false }
        items.append(item)
        return true
    }

    // 移除物品
    func remove(_ item: Item) -> Bool {
        if let index = items.firstIndex(of: item) {
            items.remove(at: index)
            return true
        }
        return false
    }

    // 取得物品（by instanceId）
    func getItem(byId id: UUID) -> Item? {
        items.first { $0.instanceId == id }
    }

    // 取得所有物品
    var allItems: [Item] {
        items
    }

    // 依詞條篩選物品
    func filter(byAffixMask mask: AffixType, matchAll: Bool = true) -> [Item] {
        items.filter { item in
            if matchAll {
                return item.affixMask.contains(mask)
            } else {
                return !item.affixMask.isDisjoint(with: mask)
            }
        }
    }
}
```

### Avatar

```swift
class Avatar: Codable {
    let id: UUID
    var name: String
    private(set) var level: Int
    var baseStats: Stats
    let equipment: EquipmentSlots
    let inventory: Inventory

    init(name: String, level: Int = 1, baseStats: Stats = Stats()) {
        self.id = UUID()
        self.name = name
        self.level = level
        self.baseStats = baseStats
        self.equipment = EquipmentSlots()
        self.inventory = Inventory()
    }

    // 升級
    func levelUp() {
        level += 1
    }

    // 檢查是否可裝備（等級需求）
    func canEquip(_ item: Item) -> Bool {
        level >= item.template.levelRequirement
    }
}
```

---

## Attribute Protocol

```swift
protocol Attribute: Codable {
    var attributeType: String { get }
    func apply(to stats: inout Stats)
}

// 數值加成屬性
struct StatBonusAttribute: Attribute {
    let attributeType: String = "stat_bonus"
    let stat: StatType
    let value: Double
    let isPercentage: Bool

    func apply(to stats: inout Stats) {
        // Implementation based on stat type
    }
}

// 元素附加屬性
struct ElementAttribute: Attribute {
    let attributeType: String = "element"
    let element: Element
    let value: Double

    func apply(to stats: inout Stats) {
        // Element damage calculation
    }
}

// 特殊效果屬性
struct SpecialAttribute: Attribute {
    let attributeType: String = "special"
    let effect: SpecialEffect
    let value: Double

    func apply(to stats: inout Stats) {
        // Special effect handling
    }
}
```

---

## Affix Pool (Weight Configuration)

```swift
struct WeightedAffix: Codable {
    let type: AffixType
    let weight: Int
    let minValue: Double
    let maxValue: Double
    let isPercentage: Bool
}

struct AffixPool: Codable {
    let slot: EquipmentSlot
    let mainAffixPool: [WeightedAffix]
    let subAffixPool: [WeightedAffix]
}
```

---

## State Transitions

### Item Level

```
State: level = 1
  ↓ levelUp()
State: level = 2
  ↓ levelUp()
...
  ↓ levelUp()
State: level = 20 (max)
```

### Equipment Flow

```
[Inventory]
    ↓ equip(item, to: slot)
    ├─ Check: slot matches item.slot
    ├─ Check: avatar.level >= item.levelRequirement
    ├─ Check: inventory.contains(item)
    ↓
[EquipmentSlots]
    ↓ unequip(slot)
    ├─ Check: !inventory.isFull
    ↓
[Inventory]
```

---

## Validation Rules

| Entity | Rule | Error |
|--------|------|-------|
| Item | subAffixes.count == rarity.subAffixCount | InvalidSubAffixCount |
| Item | slot matches template.slot | SlotMismatch |
| Inventory | count < capacity | InventoryFull |
| Avatar | level >= item.levelRequirement | LevelTooLow |
| EquipmentSlots | item.slot == target slot | WrongSlot |

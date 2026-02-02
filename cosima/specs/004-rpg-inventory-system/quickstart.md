# Quickstart: RPG 物品/背包系統

**Feature**: 004-rpg-inventory-system
**Date**: 2026-02-01

## 快速開始

### 1. 基本使用

```swift
import Foundation

// 1. 載入模板資料
let templateService = ItemTemplateService()
try templateService.loadTemplates(from: "item_templates.json")
try templateService.loadSets(from: "equipment_sets.json")

// 2. 建立角色
let avatar = Avatar(name: "勇者", level: 50, inventoryCapacity: 100)

// 3. 從模板生成物品
let factory = ItemFactory(templateService: templateService)
let sword = try factory.createItem(
    templateId: "sword_dragon_001",
    mainAffixType: .attack,
    subAffixTypes: [.crit, .critDamage]
)

// 4. 裝備物品
let replacedItem = try avatar.equip(sword)

// 5. 查看最終數值
print("角色攻擊力: \(avatar.finalStats.attack)")
```

---

## 測試案例

### TC-001: 建立基本物品

**Given**: 已載入物品模板
**When**: 使用 `ItemFactory.createItem()` 建立物品
**Then**: 物品應有唯一 UUID、正確主詞條、符合稀有度的副詞條數量

```swift
func testCreateBasicItem() throws {
    // Given
    let factory = ItemFactory(templateService: mockTemplateService)
    
    // When
    let item = try factory.createItem(
        templateId: "helmet_test_001",
        mainAffixType: .hp,
        subAffixTypes: [.crit, .defense]
    )
    
    // Then
    XCTAssertNotNil(item.instanceId)
    XCTAssertEqual(item.mainAffix.type, .hp)
    XCTAssertEqual(item.subAffixes.count, 2)
    XCTAssertTrue(item.hasAffix(.crit))
}
```

---

### TC-002: Bitmask 詞條查詢

**Given**: 物品有 [暴擊, 攻擊, 防禦] 三種詞條
**When**: 使用 `hasAffix()` 查詢
**Then**: 對應類型返回 true，其他類型返回 false

```swift
func testAffixBitmaskQuery() throws {
    // Given
    let item = createItemWithAffixes([.crit, .attack, .defense])
    
    // When & Then
    XCTAssertTrue(item.hasAffix(.crit))
    XCTAssertTrue(item.hasAffix(.attack))
    XCTAssertTrue(item.hasAffix(.defense))
    XCTAssertFalse(item.hasAffix(.hp))
    XCTAssertFalse(item.hasAffix(.elementalDamage))
}
```

---

### TC-003: 物品升級

**Given**: 等級 1 的傳說物品
**When**: 連續升級到等級 4
**Then**: 每次升級應新增或強化一個副詞條

```swift
func testItemUpgrade() throws {
    // Given
    var item = createLegendaryItem(level: 1)
    let initialSubAffixCount = item.subAffixes.count
    
    // When
    for _ in 1...3 {
        try item.upgrade()
    }
    
    // Then
    XCTAssertEqual(item.level, 4)
    XCTAssertGreaterThanOrEqual(item.subAffixes.count, initialSubAffixCount)
}
```

---

### TC-004: 背包容量管理

**Given**: 容量為 5 的背包，已有 4 個物品
**When**: 嘗試新增第 5 和第 6 個物品
**Then**: 第 5 個成功，第 6 個拋出 `InventoryFullError`

```swift
func testInventoryCapacity() throws {
    // Given
    let inventory = Inventory(capacity: 5)
    for i in 1...4 {
        try inventory.add(createTestItem(id: i))
    }
    
    // When & Then
    XCTAssertNoThrow(try inventory.add(createTestItem(id: 5)))
    XCTAssertThrowsError(try inventory.add(createTestItem(id: 6))) { error in
        XCTAssertTrue(error is InventoryError)
    }
}
```

---

### TC-005: 裝備與替換

**Given**: 角色已裝備 A 頭盔
**When**: 裝備 B 頭盔
**Then**: B 頭盔裝備成功，A 頭盔返回

```swift
func testEquipAndReplace() throws {
    // Given
    let avatar = Avatar(name: "Test", level: 50, inventoryCapacity: 10)
    let helmetA = createHelmet(name: "A")
    let helmetB = createHelmet(name: "B")
    _ = try avatar.equip(helmetA)
    
    // When
    let replaced = try avatar.equip(helmetB)
    
    // Then
    XCTAssertEqual(replaced?.name, "A")
    XCTAssertEqual(avatar.equipmentSlots.getItem(at: .helmet)?.name, "B")
}
```

---

### TC-006: 套裝效果啟動

**Given**: 角色裝備同套裝的 1 件物品
**When**: 再裝備同套裝的第 2 件物品
**Then**: 2 件套效果應啟動

```swift
func testSetBonusActivation() throws {
    // Given
    let avatar = Avatar(name: "Test", level: 50, inventoryCapacity: 10)
    let royalHelmet = createSetItem(setId: "royal", slot: .helmet)
    _ = try avatar.equip(royalHelmet)
    
    XCTAssertEqual(avatar.activeSetBonuses.count, 0)
    
    // When
    let royalBody = createSetItem(setId: "royal", slot: .body)
    _ = try avatar.equip(royalBody)
    
    // Then
    XCTAssertEqual(avatar.activeSetBonuses.count, 1)
    XCTAssertTrue(avatar.activeSetBonuses.contains { $0.setId == "royal" && $0.requiredPieces == 2 })
}
```

---

### TC-007: 等級需求檢查

**Given**: 等級需求為 40 的裝備
**When**: 等級 30 的角色嘗試裝備
**Then**: 應拋出 `LevelRequirementError`

```swift
func testLevelRequirement() throws {
    // Given
    let avatar = Avatar(name: "Test", level: 30, inventoryCapacity: 10)
    let highLevelItem = createItem(levelRequirement: 40)
    
    // When & Then
    XCTAssertThrowsError(try avatar.equip(highLevelItem)) { error in
        guard case EquipmentError.levelRequirementNotMet(let required, let current) = error else {
            XCTFail("Wrong error type")
            return
        }
        XCTAssertEqual(required, 40)
        XCTAssertEqual(current, 30)
    }
}
```

---

### TC-008: 副詞條不重複

**Given**: 物品已有 [暴擊, 攻擊] 副詞條
**When**: 升級新增副詞條
**Then**: 新副詞條不應為暴擊或攻擊

```swift
func testSubAffixNoDuplicate() throws {
    // Given
    var item = createItem(subAffixes: [.crit, .attack])
    
    // When
    try item.addSubAffix()
    
    // Then
    let affixTypes = item.subAffixes.map { $0.type }
    let uniqueTypes = Set(affixTypes)
    XCTAssertEqual(affixTypes.count, uniqueTypes.count, "副詞條應不重複")
}
```

---

### TC-009: JSON 序列化往返

**Given**: 一個完整的物品實例
**When**: 編碼為 JSON 再解碼回來
**Then**: 所有屬性應完全相同

```swift
func testJSONRoundTrip() throws {
    // Given
    let original = createCompleteItem()
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    // When
    let data = try encoder.encode(original)
    let decoded = try decoder.decode(Item.self, from: data)
    
    // Then
    XCTAssertEqual(original.instanceId, decoded.instanceId)
    XCTAssertEqual(original.level, decoded.level)
    XCTAssertEqual(original.mainAffix, decoded.mainAffix)
    XCTAssertEqual(original.subAffixes, decoded.subAffixes)
    XCTAssertEqual(original.affixMask, decoded.affixMask)
}
```

---

### TC-010: Bitmask 序列化

**Given**: AffixType bitmask `[.crit, .attack, .hp]`
**When**: 編碼為 JSON
**Then**: 應使用字串陣列格式

```swift
func testAffixTypeSerialization() throws {
    // Given
    let mask: AffixType = [.crit, .attack, .hp]
    
    // When
    let encoder = JSONEncoder()
    let data = try encoder.encode(mask)
    let json = String(data: data, encoding: .utf8)!
    
    // Then
    XCTAssertTrue(json.contains("crit"))
    XCTAssertTrue(json.contains("attack"))
    XCTAssertTrue(json.contains("hp"))
}
```

---

### TC-011: 最終數值計算

**Given**: 基礎攻擊力 100，裝備提供 +50 攻擊和 +10% 攻擊
**When**: 計算 `finalStats`
**Then**: 最終攻擊力應為 165 (100 + 50 + 100*0.1 + 50*0.1)

```swift
func testFinalStatsCalculation() throws {
    // Given
    let avatar = Avatar(name: "Test", level: 50, inventoryCapacity: 10)
    avatar.baseStats = Stats(attack: 100, defense: 0, maxHP: 0, maxMP: 0, 
                             critRate: 0, critDamage: 0, speed: 0)
    
    let item = createItem(
        baseStats: Stats(attack: 50, defense: 0, maxHP: 0, maxMP: 0,
                        critRate: 0, critDamage: 0, speed: 0),
        mainAffix: Affix(type: .attack, value: 10, isPercentage: true)
    )
    _ = try avatar.equip(item)
    
    // When
    let final = avatar.finalStats
    
    // Then
    // 公式: (baseATK + flatATK) * (1 + percentATK)
    // = (100 + 50) * (1 + 0.1) = 150 * 1.1 = 165
    XCTAssertEqual(final.attack, 165, accuracy: 0.01)
}
```

---

## Mock 資料設置

```swift
class MockTemplateService: ItemTemplateService {
    override func loadTemplates(from filename: String) throws {
        // 使用內嵌測試資料
        templates = [
            "helmet_test_001": ItemTemplate(
                templateId: "helmet_test_001",
                name: "測試頭盔",
                description: "用於測試",
                slot: .helmet,
                rarity: .rare,
                levelRequirement: 1,
                baseStats: Stats.zero,
                attributes: [],
                setId: nil,
                iconAsset: nil,
                modelAsset: nil,
                maxLevel: 20
            )
        ]
    }
}
```

---

## 常見操作

### 批量篩選物品

```swift
// 找出所有有暴擊詞條的頭盔
let critHelmets = avatar.inventory
    .filter(by: .helmet)
    .filter { $0.hasAffix(.crit) }

// 找出所有傳說品質物品
let legendaries = avatar.inventory.filter { $0.rarity == .legendary }
```

### 計算套裝件數

```swift
let setCounter = avatar.equippedItems
    .compactMap { $0.setId }
    .reduce(into: [:]) { counts, setId in
        counts[setId, default: 0] += 1
    }
```

### 最佳化裝備選擇

```swift
// 找出攻擊力最高的武器
let bestWeapon = avatar.inventory
    .filter(by: .weapon)
    .max { $0.totalAttackBonus < $1.totalAttackBonus }
```

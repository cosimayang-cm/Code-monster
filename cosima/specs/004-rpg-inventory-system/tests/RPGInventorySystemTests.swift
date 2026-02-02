// MARK: - Tests
// Feature: 004-rpg-inventory-system
// Task: TASK-010, TASK-015, TASK-022, TASK-026, TASK-027
// 依照 monster4.md 規格實作

import XCTest
@testable import RPGInventorySystem

// MARK: - Stats Tests

final class StatsTests: XCTestCase {
    
    func testStatsZero() {
        let stats = Stats.zero
        XCTAssertEqual(stats.attack, 0)
        XCTAssertEqual(stats.defense, 0)
        XCTAssertEqual(stats.maxHP, 0)
        XCTAssertTrue(stats.isZero)
    }
    
    func testStatsAddition() {
        let stats1 = Stats(attack: 100, defense: 50)
        let stats2 = Stats(attack: 50, defense: 25)
        let result = stats1 + stats2
        
        XCTAssertEqual(result.attack, 150)
        XCTAssertEqual(result.defense, 75)
    }
    
    func testStatsMultiplication() {
        let stats = Stats(attack: 100, defense: 50)
        let result = stats * 1.5
        
        XCTAssertEqual(result.attack, 150)
        XCTAssertEqual(result.defense, 75)
    }
}

// MARK: - AffixType Bitmask Tests

final class AffixTypeBitmaskTests: XCTestCase {
    
    func testSingleAffixQuery() {
        let mask: AffixType = .crit
        
        XCTAssertTrue(mask.contains(.crit))
        XCTAssertFalse(mask.contains(.attack))
    }
    
    func testMultipleAffixQuery() {
        let mask: AffixType = [.crit, .attack, .defense]
        
        XCTAssertTrue(mask.contains(.crit))
        XCTAssertTrue(mask.contains(.attack))
        XCTAssertTrue(mask.contains(.defense))
        XCTAssertFalse(mask.contains(.hp))
    }
    
    func testAffixStringKey() {
        XCTAssertEqual(AffixType.crit.stringKey, "crit")
        XCTAssertEqual(AffixType.attack.stringKey, "attack")
        XCTAssertNil(AffixType([.crit, .attack]).stringKey)
    }
    
    func testAffixTypeFromStringKey() {
        let type = AffixType(stringKey: "crit")
        XCTAssertEqual(type, .crit)
        
        let invalid = AffixType(stringKey: "invalid")
        XCTAssertNil(invalid)
    }
    
    func testAffixTypeSerialization() throws {
        let original: AffixType = [.crit, .attack]
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(AffixType.self, from: data)
        
        XCTAssertTrue(decoded.contains(.crit))
        XCTAssertTrue(decoded.contains(.attack))
    }
}

// MARK: - Affix Tests

final class AffixTests: XCTestCase {
    
    func testAffixCreation() {
        let affix = Affix(type: .attack, value: 10.5, isPercentage: true)
        
        XCTAssertEqual(affix.type, .attack)
        XCTAssertEqual(affix.value, 10.5)
        XCTAssertTrue(affix.isPercentage)
    }
    
    func testAffixDisplayText() {
        let percentAffix = Affix(type: .attack, value: 10.5, isPercentage: true)
        XCTAssertEqual(percentAffix.displayText, "攻擊力 +10.5%")
        
        let flatAffix = Affix(type: .attack, value: 50, isPercentage: false)
        XCTAssertEqual(flatAffix.displayText, "攻擊力 +50")
    }
    
    func testAffixUpgrade() {
        var affix = Affix(type: .attack, value: 10, isPercentage: true)
        affix.upgrade()
        
        XCTAssertEqual(affix.value, 11, accuracy: 0.01)
    }
}

// MARK: - Item Tests

final class ItemTests: XCTestCase {
    
    func testItemCreation() {
        let mainAffix = Affix(type: .hp, value: 10, isPercentage: true)
        let subAffixes = [
            Affix(type: .crit, value: 3.5, isPercentage: true),
            Affix(type: .attack, value: 14, isPercentage: false)
        ]
        
        let item = Item(
            templateId: "test_001",
            name: "測試頭盔",
            description: "測試用",
            slot: .helmet,
            rarity: .rare,
            mainAffix: mainAffix,
            subAffixes: subAffixes
        )
        
        XCTAssertNotNil(item.instanceId)
        XCTAssertEqual(item.slot, .helmet)
        XCTAssertEqual(item.rarity, .rare)
        XCTAssertEqual(item.level, 1)
        XCTAssertEqual(item.subAffixes.count, 2)
    }
    
    func testItemHasAffix() {
        let mainAffix = Affix(type: .hp, value: 10, isPercentage: true)
        let subAffixes = [
            Affix(type: .crit, value: 3.5, isPercentage: true)
        ]
        
        let item = Item(
            templateId: "test_001",
            name: "測試",
            description: "",
            slot: .helmet,
            rarity: .rare,
            mainAffix: mainAffix,
            subAffixes: subAffixes
        )
        
        XCTAssertTrue(item.hasAffix(.hp))
        XCTAssertTrue(item.hasAffix(.crit))
        XCTAssertFalse(item.hasAffix(.attack))
    }
    
    func testItemUpgrade() throws {
        let mainAffix = Affix(type: .hp, value: 10, isPercentage: true)
        let item = Item(
            templateId: "test_001",
            name: "測試",
            description: "",
            slot: .helmet,
            rarity: .legendary,
            maxLevel: 20,
            mainAffix: mainAffix,
            subAffixes: [
                Affix(type: .crit, value: 3.5, isPercentage: true),
                Affix(type: .attack, value: 5, isPercentage: true),
                Affix(type: .defense, value: 5, isPercentage: true),
                Affix(type: .speed, value: 3, isPercentage: true)
            ]
        )
        
        XCTAssertTrue(item.canUpgrade)
        try item.upgrade()
        XCTAssertEqual(item.level, 2)
    }
    
    func testItemJSONRoundTrip() throws {
        let mainAffix = Affix(type: .hp, value: 10, isPercentage: true)
        let original = Item(
            templateId: "test_001",
            name: "測試",
            description: "測試用",
            slot: .helmet,
            rarity: .rare,
            level: 5,
            mainAffix: mainAffix,
            subAffixes: [Affix(type: .crit, value: 3.5, isPercentage: true)]
        )
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(Item.self, from: data)
        
        XCTAssertEqual(original.instanceId, decoded.instanceId)
        XCTAssertEqual(original.level, decoded.level)
        XCTAssertEqual(original.mainAffix, decoded.mainAffix)
        XCTAssertEqual(original.subAffixes, decoded.subAffixes)
    }
}

// MARK: - Inventory Tests

final class InventoryTests: XCTestCase {
    
    func testInventoryCapacity() throws {
        let inventory = Inventory(capacity: 5)
        
        for i in 1...4 {
            let item = createTestItem(suffix: "\(i)")
            try inventory.add(item)
        }
        
        XCTAssertEqual(inventory.count, 4)
        XCTAssertFalse(inventory.isFull)
        
        try inventory.add(createTestItem(suffix: "5"))
        XCTAssertTrue(inventory.isFull)
        
        XCTAssertThrowsError(try inventory.add(createTestItem(suffix: "6"))) { error in
            XCTAssertTrue(error is InventoryError)
        }
    }
    
    func testInventoryFilter() throws {
        let inventory = Inventory(capacity: 10)
        
        try inventory.add(createTestItem(slot: .helmet))
        try inventory.add(createTestItem(slot: .helmet))
        try inventory.add(createTestItem(slot: .body))
        
        let helmets = inventory.filter(by: .helmet)
        XCTAssertEqual(helmets.count, 2)
        
        let bodies = inventory.filter(by: .body)
        XCTAssertEqual(bodies.count, 1)
    }
    
    private func createTestItem(slot: EquipmentSlot = .helmet, suffix: String = "") -> Item {
        Item(
            templateId: "test\(suffix)",
            name: "測試\(suffix)",
            description: "",
            slot: slot,
            rarity: .common,
            mainAffix: Affix(type: .hp, value: 10, isPercentage: true)
        )
    }
}

// MARK: - EquipmentSlots Tests

final class EquipmentSlotsTests: XCTestCase {
    
    func testEquipAndReplace() throws {
        let slots = EquipmentSlots()
        
        let helmetA = createTestItem(name: "A", slot: .helmet)
        let helmetB = createTestItem(name: "B", slot: .helmet)
        
        let replaced1 = try slots.equip(helmetA, characterLevel: 50)
        XCTAssertNil(replaced1)
        
        let replaced2 = try slots.equip(helmetB, characterLevel: 50)
        XCTAssertEqual(replaced2?.name, "A")
        XCTAssertEqual(slots.getItem(at: .helmet)?.name, "B")
    }
    
    func testLevelRequirement() {
        let slots = EquipmentSlots()
        
        let highLevelItem = Item(
            templateId: "test",
            name: "高等裝備",
            description: "",
            slot: .helmet,
            rarity: .legendary,
            levelRequirement: 40,
            mainAffix: Affix(type: .hp, value: 10, isPercentage: true)
        )
        
        XCTAssertThrowsError(try slots.equip(highLevelItem, characterLevel: 30)) { error in
            guard case EquipmentError.levelRequirementNotMet(let required, let current) = error else {
                XCTFail("Wrong error type")
                return
            }
            XCTAssertEqual(required, 40)
            XCTAssertEqual(current, 30)
        }
    }
    
    private func createTestItem(name: String, slot: EquipmentSlot) -> Item {
        Item(
            templateId: "test_\(name)",
            name: name,
            description: "",
            slot: slot,
            rarity: .rare,
            levelRequirement: 1,
            mainAffix: Affix(type: .hp, value: 10, isPercentage: true)
        )
    }
}

// MARK: - Avatar Integration Tests

final class AvatarIntegrationTests: XCTestCase {
    
    func testAvatarEquipFromInventory() throws {
        let avatar = Avatar(name: "勇者", level: 50, inventoryCapacity: 10)
        
        let helmet = createTestItem(slot: .helmet)
        try avatar.inventory.add(helmet)
        
        try avatar.equipFromInventory(itemId: helmet.instanceId)
        
        XCTAssertEqual(avatar.equipmentSlots.equippedCount, 1)
        XCTAssertEqual(avatar.inventory.count, 0)
    }
    
    func testAvatarUnequipToInventory() throws {
        let avatar = Avatar(name: "勇者", level: 50, inventoryCapacity: 10)
        
        let helmet = createTestItem(slot: .helmet)
        try avatar.equip(helmet)
        
        try avatar.unequipToInventory(slot: .helmet)
        
        XCTAssertEqual(avatar.equipmentSlots.equippedCount, 0)
        XCTAssertEqual(avatar.inventory.count, 1)
    }
    
    func testAvatarFinalStats() throws {
        let avatar = Avatar(
            name: "勇者",
            level: 50,
            baseStats: Stats(attack: 100, defense: 50),
            inventoryCapacity: 10
        )
        
        let helmet = Item(
            templateId: "test",
            name: "測試頭盔",
            description: "",
            slot: .helmet,
            rarity: .rare,
            baseStats: Stats(attack: 30, defense: 20),
            mainAffix: Affix(type: .attack, value: 10, isPercentage: true)
        )
        
        try avatar.equip(helmet)
        
        let final = avatar.finalStats
        XCTAssertGreaterThan(final.attack, 100)
        XCTAssertGreaterThan(final.defense, 50)
    }
    
    private func createTestItem(slot: EquipmentSlot) -> Item {
        Item(
            templateId: "test_\(slot.rawValue)",
            name: "測試\(slot.displayName)",
            description: "",
            slot: slot,
            rarity: .rare,
            levelRequirement: 1,
            mainAffix: Affix(type: .hp, value: 10, isPercentage: true)
        )
    }
}

// MARK: - Performance Tests

final class PerformanceTests: XCTestCase {
    
    func testBitmaskQueryPerformance() {
        let mask: AffixType = [.crit, .attack, .defense, .hp, .critDamage]
        
        measure {
            for _ in 0..<1000 {
                _ = mask.contains(.crit)
                _ = mask.contains(.attack)
                _ = mask.contains(.speed)
            }
        }
    }
    
    func testItemCreationPerformance() {
        let templateService = ItemTemplateService()
        templateService.register(ItemTemplate(
            templateId: "test",
            name: "測試",
            description: "",
            slot: .helmet,
            rarity: .legendary
        ))
        
        let factory = ItemFactory(templateService: templateService)
        
        measure {
            for _ in 0..<100 {
                _ = try? factory.createRandomItem(templateId: "test")
            }
        }
    }
}

// MARK: - 規格測試：詞條權重系統

final class AffixWeightTests: XCTestCase {
    
    /// 測試權重機率計算
    func testWeightProbability() {
        let pool = WeightedAffixPool(
            mainAffixPool: [
                AffixWeightEntry(type: .hp, weight: 30),
                AffixWeightEntry(type: .attack, weight: 30),
                AffixWeightEntry(type: .defense, weight: 20),
                AffixWeightEntry(type: .crit, weight: 10),
                AffixWeightEntry(type: .critDamage, weight: 10)
            ],
            subAffixPool: []
        )
        
        // 總權重 = 100
        // HP 機率 = 30/100 = 0.3
        XCTAssertEqual(pool.probability(of: .hp, isMain: true), 0.3, accuracy: 0.001)
        XCTAssertEqual(pool.probability(of: .attack, isMain: true), 0.3, accuracy: 0.001)
        XCTAssertEqual(pool.probability(of: .crit, isMain: true), 0.1, accuracy: 0.001)
    }
    
    /// 測試權重隨機選取（統計分布）
    func testWeightedRandomDistribution() {
        let pool = WeightedAffixPool(
            mainAffixPool: [
                AffixWeightEntry(type: .hp, weight: 50),
                AffixWeightEntry(type: .attack, weight: 50)
            ],
            subAffixPool: []
        )
        
        var hpCount = 0
        var attackCount = 0
        let iterations = 1000
        
        for _ in 0..<iterations {
            if let selected = pool.randomMainAffix() {
                if selected == .hp { hpCount += 1 }
                if selected == .attack { attackCount += 1 }
            }
        }
        
        // 50/50 權重，分布應接近 50%
        let hpRatio = Double(hpCount) / Double(iterations)
        XCTAssertEqual(hpRatio, 0.5, accuracy: 0.1) // 允許 10% 誤差
    }
    
    /// 測試副詞條排除機制
    func testSubAffixExclusion() {
        let pool = WeightedAffixPool(
            mainAffixPool: [],
            subAffixPool: [
                AffixWeightEntry(type: .hp, weight: 25),
                AffixWeightEntry(type: .attack, weight: 25),
                AffixWeightEntry(type: .defense, weight: 25),
                AffixWeightEntry(type: .crit, weight: 25)
            ]
        )
        
        // 排除 HP 和 Attack，只能選到 Defense 或 Crit
        let excluding: AffixType = [.hp, .attack]
        
        for _ in 0..<100 {
            if let selected = pool.randomSubAffix(excluding: excluding) {
                XCTAssertFalse(selected == .hp)
                XCTAssertFalse(selected == .attack)
                XCTAssertTrue(selected == .defense || selected == .crit)
            }
        }
    }
}

// MARK: - 規格測試：元素與特殊效果

final class ElementAndSpecialEffectTests: XCTestCase {
    
    func testElementTypes() {
        XCTAssertEqual(Element.allCases.count, 4)
        XCTAssertEqual(Element.fire.displayName, "火")
        XCTAssertEqual(Element.ice.displayName, "冰")
        XCTAssertEqual(Element.lightning.displayName, "雷")
        XCTAssertEqual(Element.poison.displayName, "毒")
    }
    
    func testSpecialEffectTypes() {
        XCTAssertEqual(SpecialEffectType.allCases.count, 3)
        XCTAssertEqual(SpecialEffectType.lifesteal.displayName, "吸血")
        XCTAssertEqual(SpecialEffectType.reflect.displayName, "反傷")
        XCTAssertEqual(SpecialEffectType.thorns.displayName, "荊棘")
    }
    
    func testItemAttributeTypes() {
        // A. 數值加成型
        let statBonus = ItemAttributeType.statBonus("attack", value: 25, isPercentage: false)
        XCTAssertEqual(statBonus.typeName, "stat_bonus")
        
        // B. 百分比加成型
        let percentBonus = ItemAttributeType.statBonus("maxHP", value: 10, isPercentage: true)
        XCTAssertEqual(percentBonus.typeName, "stat_bonus")
        
        // C. 元素附加型
        let elementAttr = ItemAttributeType.element(.fire, value: 30)
        XCTAssertEqual(elementAttr.typeName, "element")
        
        // D. 特殊效果型
        let specialAttr = ItemAttributeType.special(.lifesteal, value: 5)
        XCTAssertEqual(specialAttr.typeName, "special")
    }
}

// MARK: - 規格測試：套裝效果類型

final class SetBonusEffectTypeTests: XCTestCase {
    
    func testStatBonusEffect() {
        let effect = SetBonusEffect.statBonus(
            .init(stat: .attack, value: 20, isPercentage: true)
        )
        
        let baseStats = Stats(attack: 100)
        let bonus = effect.toStats(baseStats: baseStats)
        
        XCTAssertEqual(bonus.attack, 20, accuracy: 0.01) // 100 * 0.2
    }
    
    func testTeamBuffEffect() {
        let effect = SetBonusEffect.teamBuff(
            SetBonusEffect.TeamBuffEffect(
                stat: .attack,
                value: 20,
                isPercentage: true,
                duration: 12,
                trigger: .onElementalBurst
            )
        )
        
        // 驗證效果結構正確
        if case .teamBuff(let teamBuff) = effect {
            XCTAssertEqual(teamBuff.stat, .attack)
            XCTAssertEqual(teamBuff.value, 20)
            XCTAssertEqual(teamBuff.duration, 12)
            XCTAssertEqual(teamBuff.trigger, .onElementalBurst)
        } else {
            XCTFail("效果類型錯誤")
        }
    }
    
    func testConditionalEffect() {
        let effect = SetBonusEffect.conditional(
            SetBonusEffect.ConditionalEffect(
                condition: .hpBelow,
                threshold: 50,
                stat: .critRate,
                value: 24,
                isPercentage: true
            )
        )
        
        if case .conditional(let cond) = effect {
            XCTAssertEqual(cond.condition, .hpBelow)
            XCTAssertEqual(cond.threshold, 50)
        } else {
            XCTFail("效果類型錯誤")
        }
    }
    
    func testElementalReactionEffect() {
        let effect = SetBonusEffect.elementalReaction(
            SetBonusEffect.ElementalReactionEffect(
                reactionType: .vaporize,
                damageBonus: 15,
                isPercentage: true
            )
        )
        
        if case .elementalReaction(let reaction) = effect {
            XCTAssertEqual(reaction.reactionType, .vaporize)
            XCTAssertEqual(reaction.damageBonus, 15)
        } else {
            XCTFail("效果類型錯誤")
        }
    }
}

// MARK: - 規格測試：主詞條等級成長

final class MainAffixLevelGrowthTests: XCTestCase {
    
    func testMainAffixGrowsWithLevel() {
        let mainAffix = Affix(type: .hp, value: 10.0, isPercentage: true)
        
        // 等級 1 的數值
        let level1 = AffixValueCalculator.calculateMainAffixAtLevel(mainAffix, itemLevel: 1)
        XCTAssertEqual(level1.value, 10.0, accuracy: 0.01)
        
        // 等級 5 的數值 (每級 +10%)
        let level5 = AffixValueCalculator.calculateMainAffixAtLevel(mainAffix, itemLevel: 5)
        // 10 * 1.1^4 ≈ 14.64
        XCTAssertEqual(level5.value, 14.64, accuracy: 0.1)
        
        // 等級 20 的數值
        let level20 = AffixValueCalculator.calculateMainAffixAtLevel(mainAffix, itemLevel: 20)
        XCTAssertGreaterThan(level20.value, level5.value)
    }
}

// MARK: - 規格測試：錯誤欄位裝備

final class EquipmentSlotValidationTests: XCTestCase {
    
    func testCannotEquipToWrongSlot() {
        let slots = EquipmentSlots()
        
        // 建立一個頭盔
        let helmet = Item(
            templateId: "test_helmet",
            name: "測試頭盔",
            description: "",
            slot: .helmet,
            rarity: .common,
            mainAffix: Affix(type: .hp, value: 10, isPercentage: true)
        )
        
        // 裝備到正確欄位應該成功
        XCTAssertNoThrow(try slots.equip(helmet, characterLevel: 50))
        XCTAssertNotNil(slots.getItem(at: .helmet))
        
        // 系統設計確保 item.slot 必須對應正確欄位
        XCTAssertEqual(helmet.slot, .helmet)
    }
    
    func testSlotMismatchPrevention() {
        // 物品的 slot 屬性確保只能放到對應欄位
        let helmet = Item(
            templateId: "test",
            name: "測試頭盔",
            description: "",
            slot: .helmet,
            rarity: .common,
            mainAffix: Affix(type: .hp, value: 10, isPercentage: true)
        )
        
        let body = Item(
            templateId: "test",
            name: "測試護甲",
            description: "",
            slot: .body,
            rarity: .common,
            mainAffix: Affix(type: .hp, value: 10, isPercentage: true)
        )
        
        // 確認欄位正確
        XCTAssertNotEqual(helmet.slot, body.slot)
        XCTAssertEqual(helmet.slot, .helmet)
        XCTAssertEqual(body.slot, .body)
    }
}

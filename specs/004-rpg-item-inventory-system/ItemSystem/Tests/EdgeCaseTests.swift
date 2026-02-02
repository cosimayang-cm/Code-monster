import XCTest
@testable import ItemSystem

/// 邊界條件測試
final class EdgeCaseTests: XCTestCase {

    // MARK: - Inventory Edge Cases

    func testInventoryWhenCapacityZeroThenAlwaysFull() {
        // Given
        let inventory = Inventory(capacity: 0)
        let template = ItemTemplate(
            templateId: "test_001",
            name: "Test",
            description: "Test",
            slot: .helmet,
            rarity: .common,
            levelRequirement: 1,
            baseStats: Stats()
        )
        let item = Item(
            template: template,
            mainAffix: Affix(type: .attack, value: 10, isPercentage: false),
            subAffixes: []
        )

        // When
        let result = inventory.add(item)

        // Then
        XCTAssertFalse(result)
        XCTAssertTrue(inventory.isFull)
        XCTAssertEqual(inventory.availableSpace, 0)
    }

    // MARK: - Item Level Edge Cases

    func testItemLevelWhenMaxLevelThenContinuesIncreasing() {
        // Given - 模擬升級到很高等級
        let template = ItemTemplate(
            templateId: "test_001",
            name: "Test",
            description: "Test",
            slot: .helmet,
            rarity: .legendary,
            levelRequirement: 1,
            baseStats: Stats()
        )
        let item = Item(
            template: template,
            mainAffix: Affix(type: .attack, value: 100, isPercentage: false),
            subAffixes: []
        )

        // When - 升級 100 次
        for _ in 1...100 {
            item.levelUp()
        }

        // Then
        XCTAssertEqual(item.level, 101) // 初始 1 + 100 次升級
    }

    // MARK: - AffixType Edge Cases

    func testAffixTypeWhenEmptyThenContainsNothing() {
        // Given
        let empty: AffixType = []

        // Then
        XCTAssertFalse(empty.contains(.attack))
        XCTAssertFalse(empty.contains(.defense))
        XCTAssertTrue(empty.isEmpty)
    }

    func testAffixTypeWhenAllTypesThenContainsEverything() {
        // Given
        let all: AffixType = [.crit, .energyRecharge, .attack, .defense, .hp, .elementalMastery, .elementalDamage, .healingBonus]

        // Then
        XCTAssertTrue(all.contains(.crit))
        XCTAssertTrue(all.contains(.energyRecharge))
        XCTAssertTrue(all.contains(.attack))
        XCTAssertTrue(all.contains(.defense))
        XCTAssertTrue(all.contains(.hp))
        XCTAssertTrue(all.contains(.elementalMastery))
        XCTAssertTrue(all.contains(.elementalDamage))
        XCTAssertTrue(all.contains(.healingBonus))
    }

    // MARK: - Stats Edge Cases

    func testStatsWhenNegativeValuesThenAllowsNegative() {
        // Given
        let stats1 = Stats(attack: 100, defense: 50)
        let stats2 = Stats(attack: -150, defense: -30)

        // When
        let result = stats1 + stats2

        // Then
        XCTAssertEqual(result.attack, -50, accuracy: 0.01)
        XCTAssertEqual(result.defense, 20, accuracy: 0.01)
    }

    func testStatsWhenZeroMultiplierThenAllZero() {
        // Given
        let stats = Stats(attack: 100, defense: 50, maxHP: 1000)

        // When
        let result = stats * 0

        // Then
        XCTAssertEqual(result.attack, 0, accuracy: 0.01)
        XCTAssertEqual(result.defense, 0, accuracy: 0.01)
        XCTAssertEqual(result.maxHP, 0, accuracy: 0.01)
    }

    // MARK: - Weighted Affix Edge Cases

    func testAffixGeneratorWhenSingleItemPoolThenAlwaysReturnsSame() {
        // Given
        let generator = AffixGenerator()
        let pool = [
            WeightedAffix(type: .attack, weight: 100, minValue: 50, maxValue: 50, isPercentage: false)
        ]

        // When
        var allAttack = true
        for _ in 0..<100 {
            if let affix = generator.generateMainAffix(from: pool) {
                if affix.type != .attack {
                    allAttack = false
                    break
                }
            }
        }

        // Then
        XCTAssertTrue(allAttack)
    }

    func testAffixGeneratorWhenEmptyPoolThenReturnsNil() {
        // Given
        let generator = AffixGenerator()
        let emptyPool: [WeightedAffix] = []

        // When
        let result = generator.generateMainAffix(from: emptyPool)

        // Then
        XCTAssertNil(result)
    }

    // MARK: - EquipmentSlots Edge Cases

    func testEquipmentSlotsWhenEquipSameSlotTwiceThenReplacesItem() {
        // Given
        let slots = EquipmentSlots()
        let template = ItemTemplate(
            templateId: "helmet_001",
            name: "Helmet 1",
            description: "First",
            slot: .helmet,
            rarity: .rare,
            levelRequirement: 1,
            baseStats: Stats()
        )
        let item1 = Item(
            template: template,
            mainAffix: Affix(type: .hp, value: 100, isPercentage: false),
            subAffixes: []
        )
        let template2 = ItemTemplate(
            templateId: "helmet_002",
            name: "Helmet 2",
            description: "Second",
            slot: .helmet,
            rarity: .epic,
            levelRequirement: 1,
            baseStats: Stats()
        )
        let item2 = Item(
            template: template2,
            mainAffix: Affix(type: .defense, value: 200, isPercentage: false),
            subAffixes: []
        )

        // When
        let replaced1 = slots.equip(item1)
        let replaced2 = slots.equip(item2)

        // Then
        XCTAssertNil(replaced1) // 第一次裝備沒有替換
        XCTAssertNotNil(replaced2) // 第二次裝備替換了第一個
        XCTAssertEqual(replaced2?.instanceId, item1.instanceId)
        XCTAssertEqual(slots.getItem(at: .helmet)?.instanceId, item2.instanceId)
    }
}

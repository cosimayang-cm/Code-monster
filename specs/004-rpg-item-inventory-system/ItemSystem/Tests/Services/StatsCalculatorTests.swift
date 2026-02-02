import XCTest
@testable import ItemSystem

final class StatsCalculatorTests: XCTestCase {

    var sut: StatsCalculator!

    override func setUp() {
        super.setUp()
        sut = StatsCalculator()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Helper

    private func createTestItem(
        slot: EquipmentSlot = .helmet,
        level: Int = 1,
        mainAffix: Affix,
        subAffixes: [Affix] = [],
        baseStats: Stats = Stats()
    ) -> Item {
        let template = ItemTemplate(
            templateId: "test_\(slot.rawValue)_001",
            name: "Test Item",
            description: "Test",
            slot: slot,
            rarity: .rare,
            levelRequirement: 1,
            baseStats: baseStats
        )
        let item = Item(template: template, mainAffix: mainAffix, subAffixes: subAffixes)
        // 模擬升級
        for _ in 1..<level {
            item.levelUp()
        }
        return item
    }

    // MARK: - T040: testCalculateTotalStatsWhenNoEquipmentThenReturnsBaseStats

    func testCalculateTotalStatsWhenNoEquipmentThenReturnsBaseStats() {
        // Given
        let baseStats = Stats(attack: 100, defense: 50, maxHP: 1000)
        let avatar = Avatar(name: "TestHero", level: 10, baseStats: baseStats)

        // When
        let result = sut.calculateTotalStats(for: avatar)

        // Then
        XCTAssertEqual(result.attack, 100, accuracy: 0.01)
        XCTAssertEqual(result.defense, 50, accuracy: 0.01)
        XCTAssertEqual(result.maxHP, 1000, accuracy: 0.01)
    }

    // MARK: - T041: testCalculateTotalStatsWhenFlatBonusThenAddsCorrectly

    func testCalculateTotalStatsWhenFlatBonusThenAddsCorrectly() {
        // Given
        let baseStats = Stats(attack: 100)
        let avatar = Avatar(name: "TestHero", level: 10, baseStats: baseStats)

        let helmet = createTestItem(
            slot: .helmet,
            mainAffix: Affix(type: .attack, value: 50, isPercentage: false),
            baseStats: Stats(attack: 10)
        )
        avatar.inventory.add(helmet)
        _ = avatar.equipment.equip(helmet)
        avatar.inventory.remove(helmet)

        // When
        let result = sut.calculateTotalStats(for: avatar)

        // Then
        // 基礎 100 + 裝備基礎 10 + 主詞條 50 = 160
        XCTAssertEqual(result.attack, 160, accuracy: 0.01)
    }

    // MARK: - T042: testCalculateTotalStatsWhenPercentBonusThenMultipliesCorrectly

    func testCalculateTotalStatsWhenPercentBonusThenMultipliesCorrectly() {
        // Given
        let baseStats = Stats(attack: 100)
        let avatar = Avatar(name: "TestHero", level: 10, baseStats: baseStats)

        let helmet = createTestItem(
            slot: .helmet,
            mainAffix: Affix(type: .attack, value: 20, isPercentage: true) // +20%
        )
        avatar.inventory.add(helmet)
        _ = avatar.equipment.equip(helmet)
        avatar.inventory.remove(helmet)

        // When
        let result = sut.calculateTotalStats(for: avatar)

        // Then
        // 基礎 100 × (1 + 20%) = 120
        XCTAssertEqual(result.attack, 120, accuracy: 0.01)
    }

    // MARK: - T043: testCalculateTotalStatsWhenMixedBonusesThenAppliesFlatThenPercent

    func testCalculateTotalStatsWhenMixedBonusesThenAppliesFlatThenPercent() {
        // Given
        let baseStats = Stats(attack: 100)
        let avatar = Avatar(name: "TestHero", level: 10, baseStats: baseStats)

        let helmet = createTestItem(
            slot: .helmet,
            mainAffix: Affix(type: .attack, value: 50, isPercentage: false),
            subAffixes: [Affix(type: .attack, value: 10, isPercentage: true)]
        )
        avatar.inventory.add(helmet)
        _ = avatar.equipment.equip(helmet)
        avatar.inventory.remove(helmet)

        // When
        let result = sut.calculateTotalStats(for: avatar)

        // Then
        // (基礎 100 + 固定 50) × (1 + 10%) = 150 × 1.1 = 165
        XCTAssertEqual(result.attack, 165, accuracy: 0.01)
    }

    // MARK: - T044: testCalculateMainAffixValueWhenLevel10ThenGrowsLinearly

    func testCalculateMainAffixValueWhenLevel10ThenGrowsLinearly() {
        // Given
        let affix = Affix(type: .attack, value: 100, isPercentage: false)

        // When
        let valueAtLevel1 = sut.calculateMainAffixValue(affix: affix, level: 1)
        let valueAtLevel10 = sut.calculateMainAffixValue(affix: affix, level: 10)

        // Then
        // Level 1: 100 × 1.0 = 100
        // Level 10: 100 × (1 + 0.9) = 190
        XCTAssertEqual(valueAtLevel1, 100, accuracy: 0.01)
        XCTAssertEqual(valueAtLevel10, 190, accuracy: 0.01)
    }

    // MARK: - Additional Tests

    func testCalculateItemStatsWhenItemHasAffixesThenCombinesAll() {
        // Given
        let item = createTestItem(
            slot: .helmet,
            level: 5,
            mainAffix: Affix(type: .attack, value: 100, isPercentage: false),
            subAffixes: [
                Affix(type: .defense, value: 30, isPercentage: false),
                Affix(type: .crit, value: 5, isPercentage: true)
            ],
            baseStats: Stats(attack: 10, defense: 5)
        )

        // When
        let stats = sut.calculateItemStats(item)

        // Then
        // 主詞條 level 5: 100 × (1 + 0.4) = 140
        // attack = 10 + 140 = 150
        XCTAssertEqual(stats.attack, 150, accuracy: 0.01)
        // defense = 5 + 30 = 35
        XCTAssertEqual(stats.defense, 35, accuracy: 0.01)
        // critRate = 0 + 5 = 5
        XCTAssertEqual(stats.critRate, 5, accuracy: 0.01)
    }
}

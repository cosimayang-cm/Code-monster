import XCTest
@testable import ItemSystem

final class ItemExtendedTests: XCTestCase {

    // MARK: - Helper

    private func createTestItem(mainAffixType: AffixType, subAffixTypes: [AffixType]) -> Item {
        let template = ItemTemplate(
            templateId: "test_helmet_001",
            name: "Test Helmet",
            description: "Test",
            slot: .helmet,
            rarity: .legendary,
            levelRequirement: 1,
            baseStats: Stats()
        )

        let mainAffix = Affix(type: mainAffixType, value: 100, isPercentage: false)
        let subAffixes = subAffixTypes.map { Affix(type: $0, value: 10, isPercentage: true) }

        return Item(template: template, mainAffix: mainAffix, subAffixes: subAffixes)
    }

    // MARK: - T056: testItemLevelUpWhenCalledThenLevelIncreases

    func testItemLevelUpWhenCalledThenLevelIncreases() {
        // Given
        let item = createTestItem(mainAffixType: .attack, subAffixTypes: [])
        XCTAssertEqual(item.level, 1)

        // When
        item.levelUp()
        item.levelUp()
        item.levelUp()

        // Then
        XCTAssertEqual(item.level, 4)
    }

    // MARK: - T059: testAffixMaskContainsWhenHasCritAndAttackThenReturnsTrue

    func testAffixMaskContainsWhenHasCritAndAttackThenReturnsTrue() {
        // Given
        let item = createTestItem(
            mainAffixType: .attack,
            subAffixTypes: [.crit, .defense, .hp]
        )

        // When
        let hasCritAndAttack = item.affixMask.contains([.crit, .attack])
        let hasCritAndHp = item.affixMask.contains([.crit, .hp])
        let hasEnergyRecharge = item.affixMask.contains(.energyRecharge)

        // Then
        XCTAssertTrue(hasCritAndAttack)
        XCTAssertTrue(hasCritAndHp)
        XCTAssertFalse(hasEnergyRecharge)
    }

    // MARK: - Additional Tests

    func testItemAffixMaskCombinesMainAndSubAffixes() {
        // Given
        let item = createTestItem(
            mainAffixType: .attack,
            subAffixTypes: [.crit, .defense]
        )

        // Then
        XCTAssertTrue(item.affixMask.contains(.attack))
        XCTAssertTrue(item.affixMask.contains(.crit))
        XCTAssertTrue(item.affixMask.contains(.defense))
        XCTAssertFalse(item.affixMask.contains(.hp))
    }
}

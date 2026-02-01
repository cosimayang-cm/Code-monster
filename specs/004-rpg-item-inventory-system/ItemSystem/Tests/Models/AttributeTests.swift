import XCTest
@testable import ItemSystem

final class AttributeTests: XCTestCase {

    // MARK: - T088: testStatBonusAttributeApplyWhenPercentageThenCalculatesCorrectly

    func testStatBonusAttributeApplyWhenPercentageThenCalculatesCorrectly() {
        // Given
        var stats = Stats(attack: 100, defense: 50)
        let attribute = StatBonusAttribute(stat: .attack, value: 20, isPercentage: true) // +20%

        // When
        attribute.apply(to: &stats)

        // Then
        XCTAssertEqual(stats.attack, 120, accuracy: 0.01) // 100 + 100 * 0.2 = 120
        XCTAssertEqual(stats.defense, 50, accuracy: 0.01) // 不變
    }

    func testStatBonusAttributeApplyWhenFlatThenAddsValue() {
        // Given
        var stats = Stats(attack: 100, defense: 50)
        let attribute = StatBonusAttribute(stat: .defense, value: 30, isPercentage: false)

        // When
        attribute.apply(to: &stats)

        // Then
        XCTAssertEqual(stats.attack, 100, accuracy: 0.01) // 不變
        XCTAssertEqual(stats.defense, 80, accuracy: 0.01) // 50 + 30 = 80
    }

    func testElementAttributeApplyDoesNotModifyStats() {
        // Given
        var stats = Stats(attack: 100)
        let attribute = ElementAttribute(element: .fire, value: 50)

        // When
        attribute.apply(to: &stats)

        // Then
        XCTAssertEqual(stats.attack, 100, accuracy: 0.01) // 不變
    }

    func testSpecialAttributeApplyDoesNotModifyStats() {
        // Given
        var stats = Stats(maxHP: 1000)
        let attribute = SpecialAttribute(effect: .lifesteal, value: 10)

        // When
        attribute.apply(to: &stats)

        // Then
        XCTAssertEqual(stats.maxHP, 1000, accuracy: 0.01) // 不變
    }

    func testStatBonusAttributeApplyForAllStatTypes() {
        // Given
        var stats = Stats(
            attack: 100,
            defense: 100,
            maxHP: 1000,
            maxMP: 500,
            critRate: 10,
            critDamage: 50,
            speed: 100
        )

        let attributes = [
            StatBonusAttribute(stat: .attack, value: 10, isPercentage: false),
            StatBonusAttribute(stat: .defense, value: 10, isPercentage: false),
            StatBonusAttribute(stat: .maxHP, value: 100, isPercentage: false),
            StatBonusAttribute(stat: .maxMP, value: 50, isPercentage: false),
            StatBonusAttribute(stat: .critRate, value: 5, isPercentage: false),
            StatBonusAttribute(stat: .critDamage, value: 20, isPercentage: false),
            StatBonusAttribute(stat: .speed, value: 10, isPercentage: false)
        ]

        // When
        for attr in attributes {
            attr.apply(to: &stats)
        }

        // Then
        XCTAssertEqual(stats.attack, 110, accuracy: 0.01)
        XCTAssertEqual(stats.defense, 110, accuracy: 0.01)
        XCTAssertEqual(stats.maxHP, 1100, accuracy: 0.01)
        XCTAssertEqual(stats.maxMP, 550, accuracy: 0.01)
        XCTAssertEqual(stats.critRate, 15, accuracy: 0.01)
        XCTAssertEqual(stats.critDamage, 70, accuracy: 0.01)
        XCTAssertEqual(stats.speed, 110, accuracy: 0.01)
    }
}

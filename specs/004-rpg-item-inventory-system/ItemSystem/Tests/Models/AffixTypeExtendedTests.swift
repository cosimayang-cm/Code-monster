import XCTest
@testable import ItemSystem

final class AffixTypeExtendedTests: XCTestCase {

    // MARK: - T058: testAffixTypeIsDisjointWhenNoOverlapThenReturnsTrue

    func testAffixTypeIsDisjointWhenNoOverlapThenReturnsTrue() {
        // Given
        let offensive: AffixType = [.attack, .crit]
        let defensive: AffixType = [.defense, .hp]

        // When
        let result = offensive.isDisjoint(with: defensive)

        // Then
        XCTAssertTrue(result)
    }

    func testAffixTypeIsDisjointWhenHasOverlapThenReturnsFalse() {
        // Given
        let set1: AffixType = [.attack, .crit, .defense]
        let set2: AffixType = [.defense, .hp]

        // When
        let result = set1.isDisjoint(with: set2)

        // Then
        XCTAssertFalse(result)
    }

    // MARK: - Test offensive/defensive composite types

    func testAffixTypeOffensiveContainsCritAttackElementalDamage() {
        // Given
        let offensive = AffixType.offensive

        // Then
        XCTAssertTrue(offensive.contains(.crit))
        XCTAssertTrue(offensive.contains(.attack))
        XCTAssertTrue(offensive.contains(.elementalDamage))
        XCTAssertFalse(offensive.contains(.defense))
        XCTAssertFalse(offensive.contains(.hp))
    }

    func testAffixTypeDefensiveContainsDefenseHpHealingBonus() {
        // Given
        let defensive = AffixType.defensive

        // Then
        XCTAssertTrue(defensive.contains(.defense))
        XCTAssertTrue(defensive.contains(.hp))
        XCTAssertTrue(defensive.contains(.healingBonus))
        XCTAssertFalse(defensive.contains(.attack))
        XCTAssertFalse(defensive.contains(.crit))
    }
}

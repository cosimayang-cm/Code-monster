import XCTest
@testable import ItemSystem

final class AffixTypeTests: XCTestCase {

    func testAffixTypeContainsWhenSingleTypeThenReturnsTrue() {
        // Given: 一個包含 crit 類型的 AffixType
        let affixType: AffixType = .crit

        // When: 檢查是否包含 crit
        let contains = affixType.contains(.crit)

        // Then: 返回 true
        XCTAssertTrue(contains)
    }

    func testAffixTypeContainsWhenMultipleTypesThenReturnsTrue() {
        // Given: 一個包含多個類型的 AffixType
        let affixType: AffixType = [.crit, .attack, .hp]

        // When: 檢查是否包含 attack
        let containsAttack = affixType.contains(.attack)
        let containsHp = affixType.contains(.hp)

        // Then: 都返回 true
        XCTAssertTrue(containsAttack)
        XCTAssertTrue(containsHp)
    }

    func testAffixTypeContainsWhenNotPresentThenReturnsFalse() {
        // Given: 一個包含 crit 類型的 AffixType
        let affixType: AffixType = .crit

        // When: 檢查是否包含 defense
        let contains = affixType.contains(.defense)

        // Then: 返回 false
        XCTAssertFalse(contains)
    }

    func testAffixTypeOffensiveWhenCheckedThenContainsCorrectTypes() {
        // Given: offensive 複合類型
        let offensive = AffixType.offensive

        // When & Then: 驗證包含正確的類型
        XCTAssertTrue(offensive.contains(.crit))
        XCTAssertTrue(offensive.contains(.attack))
        XCTAssertTrue(offensive.contains(.elementalDamage))
        XCTAssertFalse(offensive.contains(.defense))
    }

    func testAffixTypeDefensiveWhenCheckedThenContainsCorrectTypes() {
        // Given: defensive 複合類型
        let defensive = AffixType.defensive

        // When & Then: 驗證包含正確的類型
        XCTAssertTrue(defensive.contains(.defense))
        XCTAssertTrue(defensive.contains(.hp))
        XCTAssertTrue(defensive.contains(.healingBonus))
        XCTAssertFalse(defensive.contains(.attack))
    }
}

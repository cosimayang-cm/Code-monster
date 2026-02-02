import XCTest
@testable import ItemSystem

final class RarityTests: XCTestCase {

    func testRaritySubAffixCountWhenCommonThenReturnsZero() {
        // Given: 一個 common 稀有度
        let rarity = Rarity.common

        // When: 查詢副詞條數量
        let subAffixCount = rarity.subAffixCount

        // Then: 返回 0
        XCTAssertEqual(subAffixCount, 0)
    }

    func testRaritySubAffixCountWhenLegendaryThenReturnsFour() {
        // Given: 一個 legendary 稀有度
        let rarity = Rarity.legendary

        // When: 查詢副詞條數量
        let subAffixCount = rarity.subAffixCount

        // Then: 返回 4
        XCTAssertEqual(subAffixCount, 4)
    }

    func testRarityMaxSubAffixCountWhenRareThenReturnsThree() {
        // Given: 一個 rare 稀有度
        let rarity = Rarity.rare

        // When: 查詢最大副詞條數量
        let maxCount = rarity.maxSubAffixCount

        // Then: 返回 3
        XCTAssertEqual(maxCount, 3)
    }
}

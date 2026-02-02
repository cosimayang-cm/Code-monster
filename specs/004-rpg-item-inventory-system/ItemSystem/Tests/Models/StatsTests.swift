import XCTest
@testable import ItemSystem

final class StatsTests: XCTestCase {

    func testStatsAdditionWhenTwoStatsThenSumsCorrectly() {
        // Given: 兩個 Stats 實例
        let stats1 = Stats(attack: 100, defense: 50, maxHP: 1000)
        let stats2 = Stats(attack: 50, defense: 30, maxHP: 500)

        // When: 執行加法運算
        let result = stats1 + stats2

        // Then: 各屬性正確相加
        XCTAssertEqual(result.attack, 150)
        XCTAssertEqual(result.defense, 80)
        XCTAssertEqual(result.maxHP, 1500)
    }

    func testStatsMultiplicationWhenDoubleMultiplierThenMultipliesCorrectly() {
        // Given: 一個 Stats 實例和倍數
        let stats = Stats(attack: 100, defense: 50, maxHP: 1000)
        let multiplier = 1.5

        // When: 執行乘法運算
        let result = stats * multiplier

        // Then: 各屬性正確相乘
        XCTAssertEqual(result.attack, 150)
        XCTAssertEqual(result.defense, 75)
        XCTAssertEqual(result.maxHP, 1500)
    }

    func testStatsDefaultValuesWhenInitializedThenAllZero() {
        // Given & When: 創建一個默認 Stats
        let stats = Stats()

        // Then: 所有屬性為 0
        XCTAssertEqual(stats.attack, 0)
        XCTAssertEqual(stats.defense, 0)
        XCTAssertEqual(stats.maxHP, 0)
        XCTAssertEqual(stats.maxMP, 0)
        XCTAssertEqual(stats.critRate, 0)
        XCTAssertEqual(stats.critDamage, 0)
        XCTAssertEqual(stats.speed, 0)
    }
}

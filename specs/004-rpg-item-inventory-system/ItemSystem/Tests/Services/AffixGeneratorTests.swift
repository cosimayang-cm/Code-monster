import XCTest
@testable import ItemSystem

final class AffixGeneratorTests: XCTestCase {

    func testAffixGeneratorGenerateMainAffixWhenValidPoolThenReturnsAffix() {
        // Given: 一個有效的主詞條池
        let pool = [
            WeightedAffix(type: .defense, weight: 100, minValue: 10, maxValue: 20, isPercentage: false)
        ]
        let generator = AffixGenerator()

        // When: 生成主詞條
        let affix = generator.generateMainAffix(from: pool)

        // Then: 成功生成詞條
        XCTAssertNotNil(affix)
        XCTAssertEqual(affix?.type, .defense)
        XCTAssertGreaterThanOrEqual(affix?.value ?? 0, 10)
        XCTAssertLessThanOrEqual(affix?.value ?? 0, 20)
        XCTAssertEqual(affix?.isPercentage, false)
    }

    func testAffixGeneratorGenerateSubAffixesWhenCountTwoThenReturnsTwoAffixes() {
        // Given: 一個副詞條池和數量 2
        let pool = [
            WeightedAffix(type: .crit, weight: 50, minValue: 3, maxValue: 8, isPercentage: true),
            WeightedAffix(type: .attack, weight: 50, minValue: 5, maxValue: 15, isPercentage: false)
        ]
        let generator = AffixGenerator()
        let count = 2

        // When: 生成副詞條
        let affixes = generator.generateSubAffixes(from: pool, count: count, excluding: [])

        // Then: 返回 2 個不重複的詞條
        XCTAssertEqual(affixes.count, 2)

        // 確保詞條類型不重複
        let types = affixes.map { $0.type }
        let uniqueTypes = Set(types)
        XCTAssertEqual(types.count, uniqueTypes.count)
    }

    func testAffixGeneratorGenerateSubAffixesWhenExcludingTypeThenDoesNotInclude() {
        // Given: 一個副詞條池，排除主詞條類型
        let pool = [
            WeightedAffix(type: .defense, weight: 30, minValue: 5, maxValue: 10, isPercentage: false),
            WeightedAffix(type: .crit, weight: 30, minValue: 3, maxValue: 8, isPercentage: true),
            WeightedAffix(type: .attack, weight: 40, minValue: 5, maxValue: 15, isPercentage: false)
        ]
        let generator = AffixGenerator()
        let excluding: AffixType = .defense

        // When: 生成 2 個副詞條，排除 defense
        let affixes = generator.generateSubAffixes(from: pool, count: 2, excluding: excluding)

        // Then: 生成的詞條不包含 defense
        XCTAssertEqual(affixes.count, 2)
        for affix in affixes {
            XCTAssertFalse(affix.type.contains(.defense))
        }
    }

    func testAffixGeneratorWeightedSelectionWhenMultipleChoicesThenRespectsWeights() {
        // Given: 一個權重不均的詞條池
        let pool = [
            WeightedAffix(type: .attack, weight: 90, minValue: 10, maxValue: 20, isPercentage: false),
            WeightedAffix(type: .defense, weight: 10, minValue: 10, maxValue: 20, isPercentage: false)
        ]
        let generator = AffixGenerator()

        // When: 生成多次主詞條
        var attackCount = 0
        var defenseCount = 0
        let iterations = 100

        for _ in 0..<iterations {
            if let affix = generator.generateMainAffix(from: pool) {
                if affix.type.contains(.attack) {
                    attackCount += 1
                } else if affix.type.contains(.defense) {
                    defenseCount += 1
                }
            }
        }

        // Then: attack 出現次數顯著多於 defense (容忍一定誤差)
        XCTAssertGreaterThan(attackCount, defenseCount)
        XCTAssertGreaterThan(attackCount, 60) // 期望至少 60% 是 attack
    }
}

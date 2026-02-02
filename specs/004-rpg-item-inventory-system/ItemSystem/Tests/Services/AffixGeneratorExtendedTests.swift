import XCTest
@testable import ItemSystem

final class AffixGeneratorExtendedTests: XCTestCase {

    var sut: AffixGenerator!

    override func setUp() {
        super.setUp()
        sut = AffixGenerator()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - T057: testAffixGeneratorWeightDistributionWhenLargeSampleThenMatchesWeights

    func testAffixGeneratorWeightDistributionWhenLargeSampleThenMatchesWeights() {
        // Given
        let pool = [
            WeightedAffix(type: .attack, weight: 70, minValue: 10, maxValue: 20, isPercentage: false),
            WeightedAffix(type: .defense, weight: 30, minValue: 10, maxValue: 20, isPercentage: false)
        ]

        var attackCount = 0
        var defenseCount = 0
        let sampleSize = 1000

        // When
        for _ in 0..<sampleSize {
            if let affix = sut.generateMainAffix(from: pool) {
                if affix.type == .attack {
                    attackCount += 1
                } else if affix.type == .defense {
                    defenseCount += 1
                }
            }
        }

        // Then
        // 預期比例：attack 70%, defense 30%
        // 允許 10% 誤差
        let attackRatio = Double(attackCount) / Double(sampleSize)
        let defenseRatio = Double(defenseCount) / Double(sampleSize)

        XCTAssertEqual(attackRatio, 0.7, accuracy: 0.1)
        XCTAssertEqual(defenseRatio, 0.3, accuracy: 0.1)
    }

    // MARK: - Test excluding parameter

    func testGenerateSubAffixesExcludesSpecifiedType() {
        // Given
        let pool = [
            WeightedAffix(type: .attack, weight: 50, minValue: 10, maxValue: 20, isPercentage: false),
            WeightedAffix(type: .defense, weight: 50, minValue: 10, maxValue: 20, isPercentage: false),
            WeightedAffix(type: .hp, weight: 50, minValue: 100, maxValue: 200, isPercentage: false)
        ]

        // When
        let affixes = sut.generateSubAffixes(from: pool, count: 2, excluding: .attack)

        // Then
        XCTAssertEqual(affixes.count, 2)
        for affix in affixes {
            XCTAssertFalse(affix.type.contains(.attack))
        }
    }

    func testGenerateSubAffixesDoesNotRepeatTypes() {
        // Given
        let pool = [
            WeightedAffix(type: .attack, weight: 25, minValue: 10, maxValue: 20, isPercentage: false),
            WeightedAffix(type: .defense, weight: 25, minValue: 10, maxValue: 20, isPercentage: false),
            WeightedAffix(type: .hp, weight: 25, minValue: 100, maxValue: 200, isPercentage: false),
            WeightedAffix(type: .crit, weight: 25, minValue: 5, maxValue: 10, isPercentage: true)
        ]

        // When
        let affixes = sut.generateSubAffixes(from: pool, count: 4, excluding: [])

        // Then
        let types = affixes.map { $0.type }
        let uniqueTypes = Set(types.map { $0.rawValue })
        XCTAssertEqual(uniqueTypes.count, affixes.count, "All affix types should be unique")
    }
}

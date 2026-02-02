import XCTest
@testable import ItemSystem

final class ItemFactoryTests: XCTestCase {

    func testItemFactoryCreateItemWhenValidTemplateThenReturnsItem() {
        // Given: 一個有效的物品模板和詞條池
        let template = ItemTemplate(
            templateId: "helmet_iron_001",
            name: "Iron Helmet",
            description: "A basic iron helmet",
            slot: .helmet,
            rarity: .common,
            levelRequirement: 1,
            baseStats: Stats(defense: 10),
            attributes: [],
            setId: nil,
            iconAsset: nil,
            modelAsset: nil
        )

        let mainAffixPool = [
            WeightedAffix(type: .defense, weight: 100, minValue: 5, maxValue: 10, isPercentage: false)
        ]

        let subAffixPool = [
            WeightedAffix(type: .crit, weight: 50, minValue: 2, maxValue: 5, isPercentage: true),
            WeightedAffix(type: .attack, weight: 50, minValue: 5, maxValue: 10, isPercentage: false)
        ]

        let affixPool = AffixPool(slot: .helmet, mainAffixPool: mainAffixPool, subAffixPool: subAffixPool)

        let affixGenerator = AffixGenerator()
        let factory = ItemFactory(affixGenerator: affixGenerator)

        // When: 使用工廠創建物品
        let item = factory.createItem(from: template, affixPool: affixPool)

        // Then: 成功創建物品
        XCTAssertNotNil(item)
        XCTAssertEqual(item?.templateId, template.templateId)
        XCTAssertEqual(item?.level, 1)
        XCTAssertEqual(item?.subAffixes.count, 0) // common 稀有度
    }

    func testItemFactoryCreateItemWhenLegendaryThenGeneratesFourSubAffixes() {
        // Given: 一個 legendary 稀有度的模板
        let template = ItemTemplate(
            templateId: "helmet_legendary_001",
            name: "Legendary Helmet",
            description: "A legendary helmet",
            slot: .helmet,
            rarity: .legendary,
            levelRequirement: 10,
            baseStats: Stats(defense: 50),
            attributes: [],
            setId: nil,
            iconAsset: nil,
            modelAsset: nil
        )

        let mainAffixPool = [
            WeightedAffix(type: .defense, weight: 100, minValue: 20, maxValue: 30, isPercentage: false)
        ]

        let subAffixPool = [
            WeightedAffix(type: .crit, weight: 25, minValue: 3, maxValue: 8, isPercentage: true),
            WeightedAffix(type: .attack, weight: 25, minValue: 10, maxValue: 20, isPercentage: false),
            WeightedAffix(type: .hp, weight: 25, minValue: 50, maxValue: 150, isPercentage: false),
            WeightedAffix(type: .energyRecharge, weight: 25, minValue: 5, maxValue: 12, isPercentage: true)
        ]

        let affixPool = AffixPool(slot: .helmet, mainAffixPool: mainAffixPool, subAffixPool: subAffixPool)

        let affixGenerator = AffixGenerator()
        let factory = ItemFactory(affixGenerator: affixGenerator)

        // When: 創建物品
        let item = factory.createItem(from: template, affixPool: affixPool)

        // Then: 生成 4 個副詞條
        XCTAssertNotNil(item)
        XCTAssertEqual(item?.subAffixes.count, 4)
    }
}

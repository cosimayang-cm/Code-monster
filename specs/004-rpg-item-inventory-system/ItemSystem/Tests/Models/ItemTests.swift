import XCTest
@testable import ItemSystem

final class ItemTests: XCTestCase {

    func testCreateItemWhenCommonRarityThenHasZeroSubAffixes() {
        // Given: 一個 common 稀有度的物品模板
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
        let mainAffix = Affix(type: .defense, value: 5, isPercentage: false)

        // When: 創建物品
        let item = Item(template: template, mainAffix: mainAffix, subAffixes: [])

        // Then: 副詞條數量為 0
        XCTAssertEqual(item.subAffixes.count, 0)
        XCTAssertEqual(item.rarity, .common)
    }

    func testCreateItemWhenLegendaryRarityThenHasFourSubAffixes() {
        // Given: 一個 legendary 稀有度的物品模板和 4 個副詞條
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
        let mainAffix = Affix(type: .defense, value: 20, isPercentage: false)
        let subAffixes = [
            Affix(type: .crit, value: 5, isPercentage: true),
            Affix(type: .attack, value: 10, isPercentage: false),
            Affix(type: .hp, value: 100, isPercentage: false),
            Affix(type: .energyRecharge, value: 8, isPercentage: true)
        ]

        // When: 創建物品
        let item = Item(template: template, mainAffix: mainAffix, subAffixes: subAffixes)

        // Then: 副詞條數量為 4
        XCTAssertEqual(item.subAffixes.count, 4)
        XCTAssertEqual(item.rarity, .legendary)
    }

    func testCreateItemWhenCalledTwiceThenDifferentInstanceIds() {
        // Given: 相同的物品模板
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
        let mainAffix = Affix(type: .defense, value: 5, isPercentage: false)

        // When: 創建兩個物品實例
        let item1 = Item(template: template, mainAffix: mainAffix, subAffixes: [])
        let item2 = Item(template: template, mainAffix: mainAffix, subAffixes: [])

        // Then: 兩個實例的 instanceId 不同
        XCTAssertNotEqual(item1.instanceId, item2.instanceId)
        XCTAssertNotEqual(item1, item2)
    }

    func testItemAffixMaskWhenCreatedThenContainsAllAffixTypes() {
        // Given: 一個物品有主詞條和副詞條
        let template = ItemTemplate(
            templateId: "helmet_rare_001",
            name: "Rare Helmet",
            description: "A rare helmet",
            slot: .helmet,
            rarity: .rare,
            levelRequirement: 5,
            baseStats: Stats(defense: 30),
            attributes: [],
            setId: nil,
            iconAsset: nil,
            modelAsset: nil
        )
        let mainAffix = Affix(type: .defense, value: 15, isPercentage: false)
        let subAffixes = [
            Affix(type: .crit, value: 5, isPercentage: true),
            Affix(type: .attack, value: 10, isPercentage: false)
        ]

        // When: 創建物品
        let item = Item(template: template, mainAffix: mainAffix, subAffixes: subAffixes)

        // Then: affixMask 包含所有詞條類型
        XCTAssertTrue(item.affixMask.contains(.defense))
        XCTAssertTrue(item.affixMask.contains(.crit))
        XCTAssertTrue(item.affixMask.contains(.attack))
        XCTAssertFalse(item.affixMask.contains(.hp))
    }
}

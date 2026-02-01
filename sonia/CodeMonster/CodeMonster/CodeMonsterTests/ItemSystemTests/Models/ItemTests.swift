//
//  ItemTests.swift
//  CodeMonsterTests
//
//  RPG 道具系統 - 物品實例測試
//  Feature: 003-rpg-item-system
//
//  Created by CodeMonster on 2026/2/1.
//

import XCTest
@testable import CodeMonster

final class ItemTests: XCTestCase {
    
    // MARK: - Test Helpers
    
    private func createTestTemplate() -> ItemTemplate {
        ItemTemplate(
            id: "test_helmet",
            name: "測試頭盔",
            description: "用於測試的頭盔",
            slot: .helmet,
            rarity: .rare,
            levelRequirement: 10,
            baseStats: Stats(defense: 20, maxHP: 100),
            iconName: "icon_test_helmet"
        )
    }
    
    // MARK: - T024: testItemInitializationGeneratesUniqueUUID
    
    /// 測試 Item 初始化時是否生成唯一的 UUID
    /// FR-002: 系統 MUST 為每個物品實例生成全域唯一的 UUID
    func testItemInitializationGeneratesUniqueUUID() {
        // Given
        let template = createTestTemplate()
        
        // When
        let item = Item(template: template)
        
        // Then
        XCTAssertNotNil(item.id)
        XCTAssertFalse(item.id.uuidString.isEmpty)
    }
    
    // MARK: - T025: testMultipleItemsFromSameTemplateHaveDifferentUUIDs
    
    /// 測試從同一模板生成的多個物品擁有不同的 UUID
    /// US2-Scenario2: 系統連續生成兩個實例，兩個實例的 UUID 不同，但模板 ID 相同
    func testMultipleItemsFromSameTemplateHaveDifferentUUIDs() {
        // Given
        let template = createTestTemplate()
        
        // When
        let item1 = Item(template: template)
        let item2 = Item(template: template)
        let item3 = Item(template: template)
        
        // Then
        XCTAssertNotEqual(item1.id, item2.id)
        XCTAssertNotEqual(item2.id, item3.id)
        XCTAssertNotEqual(item1.id, item3.id)
        
        // 但模板 ID 相同
        XCTAssertEqual(item1.templateId, item2.templateId)
        XCTAssertEqual(item2.templateId, item3.templateId)
    }
    
    // MARK: - T026: testItemStoresTemplateIdCorrectly
    
    /// 測試 Item 是否正確儲存模板 ID
    /// US2-Scenario1: 該實例擁有唯一的 UUID 且包含模板定義的所有基礎屬性
    func testItemStoresTemplateIdCorrectly() {
        // Given
        let template = createTestTemplate()
        
        // When
        let item = Item(template: template)
        
        // Then
        XCTAssertEqual(item.templateId, template.id)
        XCTAssertEqual(item.name, template.name)
        XCTAssertEqual(item.slot, template.slot)
        XCTAssertEqual(item.rarity, template.rarity)
        XCTAssertEqual(item.levelRequirement, template.levelRequirement)
        XCTAssertEqual(item.baseStats, template.baseStats)
    }
    
    // MARK: - Additional Tests
    
    /// 測試 Item 的初始等級為 1
    func testItemInitialLevelIsOne() {
        // Given
        let template = createTestTemplate()
        
        // When
        let item = Item(template: template)
        
        // Then
        XCTAssertEqual(item.level, 1)
    }
    
    /// 測試 Item 可以正確編碼和解碼
    func testItemCodableEncodesAndDecodes() throws {
        // Given
        let template = createTestTemplate()
        let item = Item(template: template)
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        // When
        let data = try encoder.encode(item)
        let decoded = try decoder.decode(Item.self, from: data)
        
        // Then
        XCTAssertEqual(decoded.id, item.id)
        XCTAssertEqual(decoded.templateId, item.templateId)
        XCTAssertEqual(decoded.level, item.level)
    }
    
    /// 測試 Item 的 setId 從模板繼承
    func testItemInheritsSetIdFromTemplate() {
        // Given
        let templateWithSet = ItemTemplate(
            id: "gladiator_body",
            name: "角鬥士鎧甲",
            description: "角鬥士套裝的鎧甲",
            slot: .body,
            rarity: .epic,
            levelRequirement: 15,
            baseStats: Stats(defense: 50),
            iconName: "icon_gladiator_body",
            setId: "gladiator_set"
        )
        
        // When
        let item = Item(template: templateWithSet)
        
        // Then
        XCTAssertEqual(item.setId, "gladiator_set")
    }
    
    /// 測試大量生成物品時 UUID 唯一性
    func testMassItemGenerationUUIDUniqueness() {
        // Given
        let template = createTestTemplate()
        let count = 1000
        
        // When
        let items = (0..<count).map { _ in Item(template: template) }
        let uniqueIds = Set(items.map { $0.id })
        
        // Then
        XCTAssertEqual(uniqueIds.count, count, "所有 \(count) 個物品的 UUID 應該都是唯一的")
    }
    
    // MARK: - Phase 8: US6 - Bitmask Query Tests
    
    private func createItemWithAffixBitmask(_ bitmask: AffixType) -> Item {
        let template = createTestTemplate()
        let item = Item(template: template)
        item.affixBitmask = bitmask
        return item
    }
    
    // MARK: - T084: testItemHasAffixWhenAffixPresentThenTrue
    
    /// 測試物品擁有特定詞條時 hasAffix 回傳 true
    /// US6-Scenario1: 玩家使用「攻擊力」詞條搜尋，系統透過 Bitmask 找出所有含該詞條的裝備
    func testItemHasAffixWhenAffixPresentThenTrue() {
        // Given - 物品擁有攻擊力和防禦力詞條
        let item = createItemWithAffixBitmask([.attack, .defense])
        
        // When & Then
        XCTAssertTrue(item.hasAffix(.attack), "物品應該擁有攻擊力詞條")
        XCTAssertTrue(item.hasAffix(.defense), "物品應該擁有防禦力詞條")
    }
    
    /// 測試物品沒有特定詞條時 hasAffix 回傳 false
    func testItemHasAffixWhenAffixAbsentThenFalse() {
        // Given - 物品只擁有攻擊力詞條
        let item = createItemWithAffixBitmask([.attack])
        
        // When & Then
        XCTAssertFalse(item.hasAffix(.defense), "物品不應該擁有防禦力詞條")
        XCTAssertFalse(item.hasAffix(.critRate), "物品不應該擁有暴擊率詞條")
    }
    
    // MARK: - T085: testItemHasAllAffixesWhenAllPresentThenTrue
    
    /// 測試物品擁有所有指定詞條時 hasAllAffixes 回傳 true
    /// US6-Scenario2: 玩家使用「攻擊力+暴擊率」組合搜尋，系統透過 Bitmask AND 運算快速找出同時擁有這兩種詞條的裝備
    func testItemHasAllAffixesWhenAllPresentThenTrue() {
        // Given - 物品擁有攻擊力、防禦力、暴擊率詞條
        let item = createItemWithAffixBitmask([.attack, .defense, .critRate])
        
        // When & Then
        XCTAssertTrue(item.hasAllAffixes([.attack, .defense]), "物品應該同時擁有攻擊力和防禦力")
        XCTAssertTrue(item.hasAllAffixes([.attack, .critRate]), "物品應該同時擁有攻擊力和暴擊率")
        XCTAssertTrue(item.hasAllAffixes([.attack, .defense, .critRate]), "物品應該同時擁有三種詞條")
    }
    
    // MARK: - T086: testItemHasAllAffixesWhenSomeMissingThenFalse
    
    /// 測試物品缺少部分指定詞條時 hasAllAffixes 回傳 false
    func testItemHasAllAffixesWhenSomeMissingThenFalse() {
        // Given - 物品只擁有攻擊力詞條
        let item = createItemWithAffixBitmask([.attack])
        
        // When & Then
        XCTAssertFalse(item.hasAllAffixes([.attack, .defense]), "物品缺少防禦力詞條")
        XCTAssertFalse(item.hasAllAffixes([.attack, .critRate]), "物品缺少暴擊率詞條")
    }
    
    // MARK: - T087: testItemHasAnyAffixWhenOnePresentThenTrue
    
    /// 測試物品擁有任一指定詞條時 hasAnyAffix 回傳 true
    func testItemHasAnyAffixWhenOnePresentThenTrue() {
        // Given - 物品只擁有攻擊力詞條
        let item = createItemWithAffixBitmask([.attack])
        
        // When & Then
        XCTAssertTrue(item.hasAnyAffix([.attack, .defense]), "物品擁有攻擊力詞條，滿足任一條件")
        XCTAssertTrue(item.hasAnyAffix([.attack, .critRate, .speed]), "物品擁有攻擊力詞條，滿足任一條件")
    }
    
    /// 測試物品沒有任何指定詞條時 hasAnyAffix 回傳 false
    func testItemHasAnyAffixWhenNonePresentThenFalse() {
        // Given - 物品只擁有攻擊力詞條
        let item = createItemWithAffixBitmask([.attack])
        
        // When & Then
        XCTAssertFalse(item.hasAnyAffix([.defense, .critRate]), "物品沒有防禦力或暴擊率詞條")
    }
    
    /// 測試空 bitmask 的查詢行為
    func testItemBitmaskQueryWithEmptyBitmask() {
        // Given - 物品沒有任何詞條
        let item = createItemWithAffixBitmask([])
        
        // When & Then
        XCTAssertFalse(item.hasAffix(.attack))
        XCTAssertFalse(item.hasAllAffixes([.attack]))
        XCTAssertFalse(item.hasAnyAffix([.attack]))
    }
}

//
//  ItemTemplateTests.swift
//  CodeMonsterTests
//
//  RPG 道具系統 - 物品模板測試
//  Feature: 003-rpg-item-system
//
//  Created by CodeMonster on 2026/2/1.
//

import XCTest
@testable import CodeMonster

final class ItemTemplateTests: XCTestCase {
    
    // MARK: - T020: testItemTemplateInitializationSetsAllProperties
    
    /// 測試 ItemTemplate 初始化是否正確設定所有屬性
    /// FR-003: 系統 MUST 區分物品模板（定義種類）和物品實例（實際存在的物品）
    func testItemTemplateInitializationSetsAllProperties() {
        // Given
        let templateId = "iron_helmet"
        let name = "鐵製頭盔"
        let description = "一頂普通的鐵製頭盔"
        let slot = EquipmentSlot.helmet
        let rarity = Rarity.common
        let levelRequirement = 5
        let baseStats = Stats(defense: 10, maxHP: 50)
        let iconName = "icon_iron_helmet"
        
        // When
        let template = ItemTemplate(
            id: templateId,
            name: name,
            description: description,
            slot: slot,
            rarity: rarity,
            levelRequirement: levelRequirement,
            baseStats: baseStats,
            iconName: iconName
        )
        
        // Then
        XCTAssertEqual(template.id, templateId)
        XCTAssertEqual(template.name, name)
        XCTAssertEqual(template.description, description)
        XCTAssertEqual(template.slot, slot)
        XCTAssertEqual(template.rarity, rarity)
        XCTAssertEqual(template.levelRequirement, levelRequirement)
        XCTAssertEqual(template.baseStats, baseStats)
        XCTAssertEqual(template.iconName, iconName)
    }
    
    // MARK: - T021: testItemTemplateCodableEncodesAndDecodes
    
    /// 測試 ItemTemplate 可以正確編碼和解碼
    /// FR-021: 系統 MUST 支援從 JSON 載入物品模板
    func testItemTemplateCodableEncodesAndDecodes() throws {
        // Given
        let template = ItemTemplate(
            id: "legendary_boots",
            name: "傳說之靴",
            description: "增加移動速度的傳說裝備",
            slot: .boots,
            rarity: .legendary,
            levelRequirement: 20,
            baseStats: Stats(defense: 20, speed: 50),
            iconName: "icon_legendary_boots"
        )
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        // When
        let data = try encoder.encode(template)
        let decoded = try decoder.decode(ItemTemplate.self, from: data)
        
        // Then
        XCTAssertEqual(decoded.id, template.id)
        XCTAssertEqual(decoded.name, template.name)
        XCTAssertEqual(decoded.description, template.description)
        XCTAssertEqual(decoded.slot, template.slot)
        XCTAssertEqual(decoded.rarity, template.rarity)
        XCTAssertEqual(decoded.levelRequirement, template.levelRequirement)
        XCTAssertEqual(decoded.baseStats, template.baseStats)
        XCTAssertEqual(decoded.iconName, template.iconName)
    }
    
    // MARK: - Additional Tests
    
    /// 測試 ItemTemplate 的 setId 屬性（用於套裝）
    func testItemTemplateSetIdIsOptional() {
        // Given
        let templateWithSet = ItemTemplate(
            id: "gladiator_helmet",
            name: "角鬥士頭盔",
            description: "角鬥士套裝的頭盔",
            slot: .helmet,
            rarity: .epic,
            levelRequirement: 15,
            baseStats: Stats(defense: 30),
            iconName: "icon_gladiator_helmet",
            setId: "gladiator_set"
        )
        
        let templateWithoutSet = ItemTemplate(
            id: "random_helmet",
            name: "隨機頭盔",
            description: "不屬於任何套裝",
            slot: .helmet,
            rarity: .rare,
            levelRequirement: 10,
            baseStats: Stats(defense: 20),
            iconName: "icon_random_helmet"
        )
        
        // Then
        XCTAssertEqual(templateWithSet.setId, "gladiator_set")
        XCTAssertNil(templateWithoutSet.setId)
    }
    
    /// 測試預設等級需求為 1
    func testItemTemplateDefaultLevelRequirement() {
        // Given & When
        let template = ItemTemplate(
            id: "basic_gloves",
            name: "基礎手套",
            description: "新手裝備",
            slot: .gloves,
            rarity: .common,
            baseStats: Stats(attack: 5),
            iconName: "icon_basic_gloves"
        )
        
        // Then
        XCTAssertEqual(template.levelRequirement, 1)
    }
}

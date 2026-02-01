//
//  ItemFactoryTests.swift
//  CodeMonsterTests
//
//  RPG 道具系統 - 物品工廠測試
//  Feature: 003-rpg-item-system
//
//  Created by CodeMonster on 2026/2/1.
//

import XCTest
@testable import CodeMonster

final class ItemFactoryTests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: ItemFactory!
    private var testTemplates: [ItemTemplate]!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        testTemplates = [
            ItemTemplate(
                id: "iron_helmet",
                name: "鐵製頭盔",
                description: "基礎防具",
                slot: .helmet,
                rarity: .common,
                levelRequirement: 1,
                baseStats: Stats(defense: 10),
                iconName: "icon_iron_helmet"
            ),
            ItemTemplate(
                id: "steel_body",
                name: "鋼製鎧甲",
                description: "中級防具",
                slot: .body,
                rarity: .uncommon,
                levelRequirement: 10,
                baseStats: Stats(defense: 30, maxHP: 100),
                iconName: "icon_steel_body"
            ),
            ItemTemplate(
                id: "legendary_boots",
                name: "傳說之靴",
                description: "傳說級裝備",
                slot: .boots,
                rarity: .legendary,
                levelRequirement: 20,
                baseStats: Stats(speed: 50),
                iconName: "icon_legendary_boots"
            )
        ]
        sut = ItemFactory(templates: testTemplates)
    }
    
    override func tearDown() {
        sut = nil
        testTemplates = nil
        super.tearDown()
    }
    
    // MARK: - T029: testCreateItemFromTemplateIdWhenTemplateExistsThenReturnsItem
    
    /// 測試從存在的模板 ID 創建物品時回傳物品
    /// US2-Scenario1: 存在「鐵製頭盔」模板, 系統生成一個物品實例, 該實例擁有唯一的 UUID 且包含模板定義的所有基礎屬性
    func testCreateItemFromTemplateIdWhenTemplateExistsThenReturnsItem() throws {
        // Given
        let templateId = "iron_helmet"
        
        // When
        let item = try sut.createItem(templateId: templateId)
        
        // Then
        XCTAssertEqual(item.templateId, templateId)
        XCTAssertEqual(item.name, "鐵製頭盔")
        XCTAssertEqual(item.slot, .helmet)
        XCTAssertEqual(item.rarity, .common)
        XCTAssertNotNil(item.id)
    }
    
    // MARK: - T030: testCreateItemFromTemplateIdWhenTemplateNotFoundThenReturnsError
    
    /// 測試從不存在的模板 ID 創建物品時回傳錯誤
    /// Edge Case: 生成物品時模板不存在會發生什麼？（系統應回傳錯誤或 nil）
    func testCreateItemFromTemplateIdWhenTemplateNotFoundThenReturnsError() {
        // Given
        let nonExistentId = "non_existent_template"
        
        // When & Then
        XCTAssertThrowsError(try sut.createItem(templateId: nonExistentId)) { error in
            guard case ItemSystemError.templateNotFound(let templateId) = error else {
                XCTFail("Expected templateNotFound error, got \(error)")
                return
            }
            XCTAssertEqual(templateId, nonExistentId)
        }
    }
    
    // MARK: - Additional Tests
    
    /// 測試可以獲取所有已註冊的模板
    func testGetAllTemplatesReturnsAllRegistered() {
        // When
        let templates = sut.allTemplates
        
        // Then
        XCTAssertEqual(templates.count, 3)
    }
    
    /// 測試可以根據 ID 獲取模板
    func testGetTemplateByIdWhenExistsThenReturnsTemplate() {
        // Given
        let templateId = "steel_body"
        
        // When
        let template = sut.template(for: templateId)
        
        // Then
        XCTAssertNotNil(template)
        XCTAssertEqual(template?.id, templateId)
        XCTAssertEqual(template?.name, "鋼製鎧甲")
    }
    
    /// 測試獲取不存在的模板時回傳 nil
    func testGetTemplateByIdWhenNotExistsThenReturnsNil() {
        // Given
        let nonExistentId = "non_existent"
        
        // When
        let template = sut.template(for: nonExistentId)
        
        // Then
        XCTAssertNil(template)
    }
    
    /// 測試可以動態註冊新模板
    func testRegisterTemplateAddsNewTemplate() throws {
        // Given
        let newTemplate = ItemTemplate(
            id: "new_gloves",
            name: "新手套",
            description: "新增的手套",
            slot: .gloves,
            rarity: .rare,
            levelRequirement: 5,
            baseStats: Stats(attack: 15),
            iconName: "icon_new_gloves"
        )
        
        // When
        sut.register(template: newTemplate)
        let item = try sut.createItem(templateId: "new_gloves")
        
        // Then
        XCTAssertEqual(item.templateId, "new_gloves")
        XCTAssertEqual(sut.allTemplates.count, 4)
    }
    
    /// 測試連續創建多個同模板物品時 UUID 都不同
    func testCreateMultipleItemsHaveDifferentUUIDs() throws {
        // Given
        let templateId = "legendary_boots"
        
        // When
        let item1 = try sut.createItem(templateId: templateId)
        let item2 = try sut.createItem(templateId: templateId)
        
        // Then
        XCTAssertNotEqual(item1.id, item2.id)
        XCTAssertEqual(item1.templateId, item2.templateId)
    }
    
    /// 測試按欄位過濾模板
    func testFilterTemplatesBySlot() {
        // When
        let helmetTemplates = sut.templates(for: .helmet)
        let bodyTemplates = sut.templates(for: .body)
        let glovesTemplates = sut.templates(for: .gloves)
        
        // Then
        XCTAssertEqual(helmetTemplates.count, 1)
        XCTAssertEqual(helmetTemplates.first?.id, "iron_helmet")
        XCTAssertEqual(bodyTemplates.count, 1)
        XCTAssertEqual(glovesTemplates.count, 0)
    }
}

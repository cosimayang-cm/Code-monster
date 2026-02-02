//
//  EquipmentSlotsTests.swift
//  CodeMonsterTests
//
//  RPG 道具系統 - 裝備欄位容器測試
//  Feature: 003-rpg-item-system
//
//  Created by CodeMonster on 2026/2/1.
//

import XCTest
@testable import CodeMonster

final class EquipmentSlotsTests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: EquipmentSlots!
    
    // MARK: - Test Helpers
    
    private func createTestItem(slot: EquipmentSlot, name: String = "測試裝備") -> Item {
        let template = ItemTemplate(
            id: "test_\(slot.rawValue)_\(UUID().uuidString.prefix(4))",
            name: name,
            description: "測試用裝備",
            slot: slot,
            rarity: .common,
            levelRequirement: 1,
            baseStats: Stats(defense: 10),
            iconName: "icon_test"
        )
        return Item(template: template)
    }
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        sut = EquipmentSlots()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - T033: testEquipItemWhenSlotMatchesThenItemEquipped
    
    /// 測試當物品類型與欄位匹配時，物品成功裝備
    /// US1-Scenario1: 角色有空的頭盔欄位且背包中有一件頭盔, 玩家將頭盔穿戴到頭盔欄位, 頭盔出現在頭盔欄位
    func testEquipItemWhenSlotMatchesThenItemEquipped() throws {
        // Given
        let helmet = createTestItem(slot: .helmet, name: "鐵製頭盔")
        
        // When
        let previousItem = try sut.equip(helmet, to: .helmet)
        
        // Then
        XCTAssertNil(previousItem, "空欄位應回傳 nil")
        XCTAssertEqual(sut.item(at: .helmet)?.id, helmet.id)
    }
    
    // MARK: - T034: testEquipItemWhenSlotMismatchThenSlotMismatchError
    
    /// 測試當物品類型與欄位不匹配時，拋出錯誤
    /// US1-Scenario4: 玩家有一件鞋子, 玩家嘗試將鞋子穿戴到頭盔欄位, 系統拒絕操作並顯示錯誤訊息
    func testEquipItemWhenSlotMismatchThenSlotMismatchError() {
        // Given
        let boots = createTestItem(slot: .boots, name: "皮革靴子")
        
        // When & Then
        XCTAssertThrowsError(try sut.equip(boots, to: .helmet)) { error in
            guard case ItemSystemError.slotMismatch(let itemSlot, let targetSlot) = error else {
                XCTFail("Expected slotMismatch error, got \(error)")
                return
            }
            XCTAssertEqual(itemSlot, .boots)
            XCTAssertEqual(targetSlot, .helmet)
        }
    }
    
    // MARK: - T035: testEquipItemWhenSlotOccupiedThenReturnsPreviousItem
    
    /// 測試當欄位已有裝備時，返回舊裝備
    /// US1-Scenario3: 角色已穿戴一件頭盔且背包中有另一件頭盔, 玩家用新頭盔替換, 舊頭盔回到背包，新頭盔穿戴到欄位
    func testEquipItemWhenSlotOccupiedThenReturnsPreviousItem() throws {
        // Given
        let oldHelmet = createTestItem(slot: .helmet, name: "舊頭盔")
        let newHelmet = createTestItem(slot: .helmet, name: "新頭盔")
        _ = try sut.equip(oldHelmet, to: .helmet)
        
        // When
        let previousItem = try sut.equip(newHelmet, to: .helmet)
        
        // Then
        XCTAssertEqual(previousItem?.id, oldHelmet.id, "應回傳舊裝備")
        XCTAssertEqual(sut.item(at: .helmet)?.id, newHelmet.id, "新裝備應在欄位中")
    }
    
    // MARK: - T036: testUnequipWhenSlotHasItemThenReturnsItem
    
    /// 測試當欄位有裝備時，卸下並回傳該裝備
    /// US1-Scenario2: 角色已穿戴一件頭盔, 玩家卸下頭盔, 頭盔回到背包
    func testUnequipWhenSlotHasItemThenReturnsItem() throws {
        // Given
        let helmet = createTestItem(slot: .helmet, name: "鐵製頭盔")
        _ = try sut.equip(helmet, to: .helmet)
        
        // When
        let unequippedItem = try sut.unequip(from: .helmet)
        
        // Then
        XCTAssertEqual(unequippedItem.id, helmet.id)
        XCTAssertNil(sut.item(at: .helmet), "欄位應為空")
    }
    
    // MARK: - T037: testUnequipWhenSlotEmptyThenSlotEmptyError
    
    /// 測試當欄位為空時，卸下操作拋出錯誤
    func testUnequipWhenSlotEmptyThenSlotEmptyError() {
        // Given - 欄位為空
        
        // When & Then
        XCTAssertThrowsError(try sut.unequip(from: .helmet)) { error in
            guard case ItemSystemError.slotEmpty(let slot) = error else {
                XCTFail("Expected slotEmpty error, got \(error)")
                return
            }
            XCTAssertEqual(slot, .helmet)
        }
    }
    
    // MARK: - Additional Tests
    
    /// 測試可以裝備所有 5 個欄位
    func testEquipAllSlotsSuccessfully() throws {
        // Given
        let helmet = createTestItem(slot: .helmet)
        let body = createTestItem(slot: .body)
        let gloves = createTestItem(slot: .gloves)
        let boots = createTestItem(slot: .boots)
        let belt = createTestItem(slot: .belt)
        
        // When
        _ = try sut.equip(helmet, to: .helmet)
        _ = try sut.equip(body, to: .body)
        _ = try sut.equip(gloves, to: .gloves)
        _ = try sut.equip(boots, to: .boots)
        _ = try sut.equip(belt, to: .belt)
        
        // Then
        XCTAssertNotNil(sut.item(at: .helmet))
        XCTAssertNotNil(sut.item(at: .body))
        XCTAssertNotNil(sut.item(at: .gloves))
        XCTAssertNotNil(sut.item(at: .boots))
        XCTAssertNotNil(sut.item(at: .belt))
    }
    
    /// 測試 allEquippedItems 回傳所有已裝備的物品
    func testAllEquippedItemsReturnsOnlyEquipped() throws {
        // Given
        let helmet = createTestItem(slot: .helmet)
        let boots = createTestItem(slot: .boots)
        _ = try sut.equip(helmet, to: .helmet)
        _ = try sut.equip(boots, to: .boots)
        
        // When
        let equipped = sut.allEquippedItems
        
        // Then
        XCTAssertEqual(equipped.count, 2)
        XCTAssertTrue(equipped.contains { $0.id == helmet.id })
        XCTAssertTrue(equipped.contains { $0.id == boots.id })
    }
    
    /// 測試 isEmpty 屬性
    func testIsEmptyWhenNoItemsEquipped() throws {
        // Given - 初始狀態
        
        // Then
        XCTAssertTrue(sut.isEmpty)
        
        // When - 裝備一件
        let helmet = createTestItem(slot: .helmet)
        _ = try sut.equip(helmet, to: .helmet)
        
        // Then
        XCTAssertFalse(sut.isEmpty)
    }
    
    /// 測試計算所有裝備的總數值
    func testTotalStatsCalculation() throws {
        // Given
        let helmetTemplate = ItemTemplate(
            id: "stats_helmet",
            name: "數值頭盔",
            description: "測試",
            slot: .helmet,
            rarity: .common,
            levelRequirement: 1,
            baseStats: Stats(defense: 10, maxHP: 100),
            iconName: "icon"
        )
        let bootsTemplate = ItemTemplate(
            id: "stats_boots",
            name: "數值鞋子",
            description: "測試",
            slot: .boots,
            rarity: .common,
            levelRequirement: 1,
            baseStats: Stats(defense: 5, speed: 20),
            iconName: "icon"
        )
        let helmet = Item(template: helmetTemplate)
        let boots = Item(template: bootsTemplate)
        
        _ = try sut.equip(helmet, to: .helmet)
        _ = try sut.equip(boots, to: .boots)
        
        // When
        let totalStats = sut.totalStats
        
        // Then
        XCTAssertEqual(totalStats.defense, 15)
        XCTAssertEqual(totalStats.maxHP, 100)
        XCTAssertEqual(totalStats.speed, 20)
    }
}

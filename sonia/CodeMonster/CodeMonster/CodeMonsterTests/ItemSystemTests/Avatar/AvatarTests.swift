//
//  AvatarTests.swift
//  CodeMonsterTests
//
//  RPG 道具系統 - 角色測試
//  Feature: 003-rpg-item-system
//
//  Created by CodeMonster on 2026/2/1.
//

import XCTest
@testable import CodeMonster

final class AvatarTests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: Avatar!
    
    // MARK: - Test Helpers
    
    private func createTestTemplate(
        slot: EquipmentSlot,
        levelRequirement: Int = 1,
        stats: Stats = Stats(defense: 10)
    ) -> ItemTemplate {
        ItemTemplate(
            id: "test_\(slot.rawValue)_\(UUID().uuidString.prefix(4))",
            name: "測試\(slot.displayName)",
            description: "測試用裝備",
            slot: slot,
            rarity: .common,
            levelRequirement: levelRequirement,
            baseStats: stats,
            iconName: "icon_test"
        )
    }
    
    private func createTestItem(
        slot: EquipmentSlot,
        levelRequirement: Int = 1,
        stats: Stats = Stats(defense: 10)
    ) -> Item {
        Item(template: createTestTemplate(slot: slot, levelRequirement: levelRequirement, stats: stats))
    }
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        // 建立等級 10 的角色，基礎數值
        sut = Avatar(
            name: "測試角色",
            level: 10,
            baseStats: Stats(
                attack: 100,
                defense: 50,
                maxHP: 1000,
                maxMP: 200,
                critRate: 0.05,
                critDamage: 0.5,
                speed: 100
            )
        )
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - T040: testAvatarEquipItemWhenValidThenItemEquipped
    
    /// 測試角色裝備合法物品時成功
    /// US1-Scenario1: 角色有空的頭盔欄位且背包中有一件頭盔, 玩家將頭盔穿戴到頭盔欄位
    func testAvatarEquipItemWhenValidThenItemEquipped() throws {
        // Given
        let helmet = createTestItem(slot: .helmet, levelRequirement: 5)
        
        // When
        try sut.equip(helmet)
        
        // Then
        XCTAssertEqual(sut.equippedItem(at: .helmet)?.id, helmet.id)
    }
    
    // MARK: - T041: testAvatarEquipItemWhenLevelTooLowThenLevelRequirementNotMetError
    
    /// 測試角色等級不足時無法裝備
    /// Edge Case: 角色等級不足時嘗試穿戴高等級裝備會發生什麼？（系統應拒絕並提示等級不足）
    func testAvatarEquipItemWhenLevelTooLowThenLevelRequirementNotMetError() {
        // Given
        let lowLevelAvatar = Avatar(name: "新手", level: 5, baseStats: Stats.zero)
        let highLevelItem = createTestItem(slot: .helmet, levelRequirement: 15)
        
        // When & Then
        XCTAssertThrowsError(try lowLevelAvatar.equip(highLevelItem)) { error in
            guard case ItemSystemError.levelRequirementNotMet(let required, let current) = error else {
                XCTFail("Expected levelRequirementNotMet error, got \(error)")
                return
            }
            XCTAssertEqual(required, 15)
            XCTAssertEqual(current, 5)
        }
    }
    
    // MARK: - T042: testAvatarUnequipItemWhenEquippedThenItemReturnsToInventory
    
    /// 測試卸下裝備時物品回傳（背包整合在 Phase 6）
    /// US1-Scenario2: 角色已穿戴一件頭盔, 玩家卸下頭盔, 頭盔回到背包
    func testAvatarUnequipItemWhenEquippedThenItemReturned() throws {
        // Given
        let helmet = createTestItem(slot: .helmet)
        try sut.equip(helmet)
        
        // When
        let unequipped = try sut.unequip(from: .helmet)
        
        // Then
        XCTAssertEqual(unequipped.id, helmet.id)
        XCTAssertNil(sut.equippedItem(at: .helmet))
    }
    
    // MARK: - T043: testAvatarTotalStatsWhenItemsEquippedThenCalculatesCorrectly
    
    /// 測試角色總數值計算
    /// FR-006: 系統 MUST 按公式計算最終數值
    /// FR-007: 系統 MUST 在裝備穿戴/卸下時即時更新角色數值
    func testAvatarTotalStatsWhenItemsEquippedThenCalculatesCorrectly() throws {
        // Given
        let helmetStats = Stats(defense: 20, maxHP: 200)
        let bootsStats = Stats(defense: 10, speed: 30)
        let helmet = createTestItem(slot: .helmet, stats: helmetStats)
        let boots = createTestItem(slot: .boots, stats: bootsStats)
        
        // When
        try sut.equip(helmet)
        try sut.equip(boots)
        let totalStats = sut.totalStats
        
        // Then
        // 基礎數值 + 裝備數值
        XCTAssertEqual(totalStats.attack, 100) // 只有基礎
        XCTAssertEqual(totalStats.defense, 50 + 20 + 10) // 基礎 + 頭盔 + 鞋子
        XCTAssertEqual(totalStats.maxHP, 1000 + 200) // 基礎 + 頭盔
        XCTAssertEqual(totalStats.speed, 100 + 30) // 基礎 + 鞋子
    }
    
    // MARK: - Additional Tests
    
    /// 測試替換裝備時回傳舊裝備
    func testAvatarReplaceEquipmentReturnsPreviousItem() throws {
        // Given
        let oldHelmet = createTestItem(slot: .helmet)
        let newHelmet = createTestItem(slot: .helmet)
        try sut.equip(oldHelmet)
        
        // When
        let previousItem = try sut.equip(newHelmet)
        
        // Then
        XCTAssertEqual(previousItem?.id, oldHelmet.id)
        XCTAssertEqual(sut.equippedItem(at: .helmet)?.id, newHelmet.id)
    }
    
    /// 測試物品類型不匹配欄位時拋出錯誤
    func testAvatarEquipItemToWrongSlotThrowsError() {
        // Given
        let boots = createTestItem(slot: .boots)
        
        // When & Then
        XCTAssertThrowsError(try sut.equip(boots, to: .helmet)) { error in
            guard case ItemSystemError.slotMismatch = error else {
                XCTFail("Expected slotMismatch error, got \(error)")
                return
            }
        }
    }
    
    /// 測試卸下空欄位時拋出錯誤
    func testAvatarUnequipEmptySlotThrowsError() {
        // Given - 欄位為空
        
        // When & Then
        XCTAssertThrowsError(try sut.unequip(from: .helmet)) { error in
            guard case ItemSystemError.slotEmpty = error else {
                XCTFail("Expected slotEmpty error, got \(error)")
                return
            }
        }
    }
    
    /// 測試角色基礎屬性
    func testAvatarBasicProperties() {
        // Then
        XCTAssertEqual(sut.name, "測試角色")
        XCTAssertEqual(sut.level, 10)
        XCTAssertEqual(sut.baseStats.attack, 100)
    }
    
    /// 測試無裝備時總數值等於基礎數值
    func testAvatarTotalStatsEqualsBaseStatsWhenNoEquipment() {
        // When
        let totalStats = sut.totalStats
        
        // Then
        XCTAssertEqual(totalStats, sut.baseStats)
    }
    
    /// 測試卸下裝備後數值正確更新
    func testAvatarStatsUpdateAfterUnequip() throws {
        // Given
        let helmet = createTestItem(slot: .helmet, stats: Stats(defense: 50))
        try sut.equip(helmet)
        let statsWithHelmet = sut.totalStats
        
        // When
        _ = try sut.unequip(from: .helmet)
        let statsWithoutHelmet = sut.totalStats
        
        // Then
        XCTAssertEqual(statsWithHelmet.defense, 50 + 50) // 基礎 50 + 裝備 50
        XCTAssertEqual(statsWithoutHelmet.defense, 50) // 只剩基礎
    }
    
    // MARK: - T071: testAvatarUnequipWhenInventoryFullThenInventoryFullError
    
    /// 測試背包滿時卸下裝備拋出錯誤
    /// Edge Case: 背包滿時卸下裝備：系統拒絕卸下並提示「背包已滿，請先清理空間」
    func testAvatarUnequipWhenInventoryFullThenInventoryFullError() throws {
        // Given - 建立背包容量為 2 的角色
        let smallInventoryAvatar = Avatar(
            name: "小背包角色",
            level: 10,
            baseStats: Stats.zero,
            inventoryCapacity: 2
        )
        
        // 裝備一件頭盔
        let helmet = createTestItem(slot: .helmet)
        try smallInventoryAvatar.equip(helmet)
        
        // 填滿背包
        try smallInventoryAvatar.inventory.add(createTestItem(slot: .boots))
        try smallInventoryAvatar.inventory.add(createTestItem(slot: .gloves))
        
        // When & Then - 嘗試卸下裝備到背包應該失敗
        XCTAssertThrowsError(try smallInventoryAvatar.unequipToInventory(from: .helmet)) { error in
            guard case ItemSystemError.inventoryFull(let capacity) = error else {
                XCTFail("Expected inventoryFull error, got \(error)")
                return
            }
            XCTAssertEqual(capacity, 2)
        }
        
        // 確認裝備仍在身上
        XCTAssertNotNil(smallInventoryAvatar.equippedItem(at: .helmet))
    }
    
    /// 測試從背包裝備物品
    func testAvatarEquipFromInventory() throws {
        // Given
        let helmet = createTestItem(slot: .helmet)
        try sut.inventory.add(helmet)
        
        // When
        try sut.equipFromInventory(itemId: helmet.id)
        
        // Then
        XCTAssertEqual(sut.equippedItem(at: .helmet)?.id, helmet.id)
        XCTAssertFalse(sut.inventory.contains(helmet))
    }
    
    /// 測試從背包裝備時替換舊裝備
    func testAvatarEquipFromInventoryReplacesOldItem() throws {
        // Given
        let oldHelmet = createTestItem(slot: .helmet)
        let newHelmet = createTestItem(slot: .helmet)
        try sut.equip(oldHelmet)
        try sut.inventory.add(newHelmet)
        
        // When
        let previousItem = try sut.equipFromInventory(itemId: newHelmet.id)
        
        // Then
        XCTAssertEqual(previousItem?.id, oldHelmet.id)
        XCTAssertEqual(sut.equippedItem(at: .helmet)?.id, newHelmet.id)
        XCTAssertTrue(sut.inventory.contains(oldHelmet), "舊裝備應在背包中")
        XCTAssertFalse(sut.inventory.contains(newHelmet), "新裝備應已從背包移除")
    }
}

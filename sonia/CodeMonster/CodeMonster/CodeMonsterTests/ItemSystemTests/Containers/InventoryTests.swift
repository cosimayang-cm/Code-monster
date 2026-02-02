//
//  InventoryTests.swift
//  CodeMonsterTests
//
//  RPG 道具系統 - 背包測試
//  Feature: 003-rpg-item-system
//
//  Created by CodeMonster on 2026/2/1.
//

import XCTest
@testable import CodeMonster

final class InventoryTests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: Inventory!
    private let defaultCapacity = 20
    
    // MARK: - Test Helpers
    
    private func createTestItem(name: String = "測試物品") -> Item {
        let template = ItemTemplate(
            id: "test_item_\(UUID().uuidString.prefix(4))",
            name: name,
            description: "測試用物品",
            slot: .helmet,
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
        sut = Inventory(capacity: defaultCapacity)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - T063: testInventoryAddItemWhenNotFullThenSuccess
    
    /// 測試背包未滿時成功添加物品
    /// US4-Scenario1: 背包未滿, 玩家獲得一件物品, 物品成功加入背包
    func testInventoryAddItemWhenNotFullThenSuccess() throws {
        // Given
        let item = createTestItem()
        
        // When
        try sut.add(item)
        
        // Then
        XCTAssertTrue(sut.contains(item))
        XCTAssertEqual(sut.count, 1)
    }
    
    // MARK: - T064: testInventoryAddItemWhenFullThenInventoryFullError
    
    /// 測試背包已滿時添加物品拋出錯誤
    /// US4-Scenario2: 背包已滿, 玩家嘗試獲得新物品, 系統拒絕並提示背包已滿
    func testInventoryAddItemWhenFullThenInventoryFullError() {
        // Given - 填滿背包
        let smallInventory = Inventory(capacity: 3)
        for i in 0..<3 {
            try? smallInventory.add(createTestItem(name: "物品\(i)"))
        }
        let newItem = createTestItem(name: "新物品")
        
        // When & Then
        XCTAssertThrowsError(try smallInventory.add(newItem)) { error in
            guard case ItemSystemError.inventoryFull(let capacity) = error else {
                XCTFail("Expected inventoryFull error, got \(error)")
                return
            }
            XCTAssertEqual(capacity, 3)
        }
    }
    
    // MARK: - T065: testInventoryRemoveItemWhenExistsThenSuccess
    
    /// 測試移除存在的物品成功
    /// US4-Scenario4: 背包中有一件物品, 玩家丟棄該物品, 物品從背包中移除
    func testInventoryRemoveItemWhenExistsThenSuccess() throws {
        // Given
        let item = createTestItem()
        try sut.add(item)
        
        // When
        let removed = try sut.remove(item)
        
        // Then
        XCTAssertEqual(removed.id, item.id)
        XCTAssertFalse(sut.contains(item))
        XCTAssertEqual(sut.count, 0)
    }
    
    // MARK: - T066: testInventoryRemoveItemWhenNotFoundThenItemNotFoundError
    
    /// 測試移除不存在的物品拋出錯誤
    func testInventoryRemoveItemWhenNotFoundThenItemNotFoundError() {
        // Given
        let item = createTestItem()
        // 不添加到背包
        
        // When & Then
        XCTAssertThrowsError(try sut.remove(item)) { error in
            guard case ItemSystemError.itemNotFound(let itemId) = error else {
                XCTFail("Expected itemNotFound error, got \(error)")
                return
            }
            XCTAssertEqual(itemId, item.id)
        }
    }
    
    // MARK: - T067: testInventoryContainsWhenItemExistsThenTrue
    
    /// 測試 contains 方法在物品存在時回傳 true
    func testInventoryContainsWhenItemExistsThenTrue() throws {
        // Given
        let item = createTestItem()
        try sut.add(item)
        
        // When & Then
        XCTAssertTrue(sut.contains(item))
        XCTAssertTrue(sut.contains(itemId: item.id))
    }
    
    // MARK: - T068: testInventoryItemWithIdWhenExistsThenReturnsItem
    
    /// 測試根據 ID 查詢物品
    /// US2-Scenario3: 一個物品實例的 UUID, 系統查詢該 UUID, 能快速找到對應的物品實例
    func testInventoryItemWithIdWhenExistsThenReturnsItem() throws {
        // Given
        let item = createTestItem()
        try sut.add(item)
        
        // When
        let found = sut.item(withId: item.id)
        
        // Then
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.id, item.id)
    }
    
    // MARK: - Additional Tests
    
    /// 測試查詢不存在的物品回傳 nil
    func testInventoryItemWithIdWhenNotExistsThenReturnsNil() {
        // Given
        let nonExistentId = UUID()
        
        // When
        let found = sut.item(withId: nonExistentId)
        
        // Then
        XCTAssertNil(found)
    }
    
    /// 測試 allItems 回傳所有物品
    func testInventoryAllItemsReturnsAllItems() throws {
        // Given
        let item1 = createTestItem(name: "物品1")
        let item2 = createTestItem(name: "物品2")
        let item3 = createTestItem(name: "物品3")
        try sut.add(item1)
        try sut.add(item2)
        try sut.add(item3)
        
        // When
        let allItems = sut.allItems
        
        // Then
        XCTAssertEqual(allItems.count, 3)
        XCTAssertTrue(allItems.contains { $0.id == item1.id })
        XCTAssertTrue(allItems.contains { $0.id == item2.id })
        XCTAssertTrue(allItems.contains { $0.id == item3.id })
    }
    
    /// 測試 isEmpty 屬性
    func testInventoryIsEmptyProperty() throws {
        // Given - 初始狀態
        XCTAssertTrue(sut.isEmpty)
        
        // When
        let item = createTestItem()
        try sut.add(item)
        
        // Then
        XCTAssertFalse(sut.isEmpty)
    }
    
    /// 測試 isFull 屬性
    func testInventoryIsFullProperty() throws {
        // Given
        let smallInventory = Inventory(capacity: 2)
        XCTAssertFalse(smallInventory.isFull)
        
        // When
        try smallInventory.add(createTestItem())
        try smallInventory.add(createTestItem())
        
        // Then
        XCTAssertTrue(smallInventory.isFull)
    }
    
    /// 測試 availableSpace 屬性
    func testInventoryAvailableSpace() throws {
        // Given
        XCTAssertEqual(sut.availableSpace, defaultCapacity)
        
        // When
        try sut.add(createTestItem())
        try sut.add(createTestItem())
        
        // Then
        XCTAssertEqual(sut.availableSpace, defaultCapacity - 2)
    }
    
    /// 測試根據 ID 移除物品
    func testInventoryRemoveByIdWhenExistsThenSuccess() throws {
        // Given
        let item = createTestItem()
        try sut.add(item)
        
        // When
        let removed = try sut.remove(itemId: item.id)
        
        // Then
        XCTAssertEqual(removed.id, item.id)
        XCTAssertFalse(sut.contains(itemId: item.id))
    }
    
    /// 測試清空背包
    func testInventoryClearRemovesAllItems() throws {
        // Given
        for i in 0..<5 {
            try sut.add(createTestItem(name: "物品\(i)"))
        }
        XCTAssertEqual(sut.count, 5)
        
        // When
        let cleared = sut.clear()
        
        // Then
        XCTAssertEqual(cleared.count, 5)
        XCTAssertTrue(sut.isEmpty)
    }
    
    /// 測試按欄位類型過濾物品
    func testInventoryFilterBySlot() throws {
        // Given
        let helmetTemplate = ItemTemplate(
            id: "helmet_1", name: "頭盔", description: "", slot: .helmet,
            rarity: .common, baseStats: Stats.zero, iconName: ""
        )
        let bootsTemplate = ItemTemplate(
            id: "boots_1", name: "鞋子", description: "", slot: .boots,
            rarity: .common, baseStats: Stats.zero, iconName: ""
        )
        
        let helmet1 = Item(template: helmetTemplate)
        let helmet2 = Item(template: helmetTemplate)
        let boots = Item(template: bootsTemplate)
        
        try sut.add(helmet1)
        try sut.add(helmet2)
        try sut.add(boots)
        
        // When
        let helmets = sut.items(for: .helmet)
        let bootsList = sut.items(for: .boots)
        let gloves = sut.items(for: .gloves)
        
        // Then
        XCTAssertEqual(helmets.count, 2)
        XCTAssertEqual(bootsList.count, 1)
        XCTAssertEqual(gloves.count, 0)
    }
}

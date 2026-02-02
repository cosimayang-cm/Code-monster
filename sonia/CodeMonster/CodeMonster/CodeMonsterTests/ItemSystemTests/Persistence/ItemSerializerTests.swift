//
//  ItemSerializerTests.swift
//  CodeMonsterTests
//
//  RPG 道具系統 - 物品序列化器測試
//  Feature: 003-rpg-item-system
//
//  Created by CodeMonster on 2026/2/1.
//

import XCTest
@testable import CodeMonster

final class ItemSerializerTests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: ItemSerializer!
    
    // MARK: - Test Helpers
    
    private func createTestItem() -> Item {
        let template = ItemTemplate(
            id: "test_helmet",
            name: "測試頭盔",
            description: "用於測試的頭盔",
            slot: .helmet,
            rarity: .rare,
            levelRequirement: 10,
            baseStats: Stats(defense: 20, maxHP: 100),
            iconName: "icon_test_helmet",
            setId: "test_set"
        )
        let item = Item(template: template)
        item.level = 5
        item.affixBitmask = [.attack, .defense]
        return item
    }
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        sut = ItemSerializer()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - T094: testSerializeItemThenDeserializeReturnsEqualItem
    
    /// 測試物品序列化後反序列化資料一致
    /// US7-Scenario2: 系統儲存玩家的物品資料, 物品有各種屬性（詞條、等級等）, 資料成功序列化為 JSON 且可正確反序列化還原
    func testSerializeItemThenDeserializeReturnsEqualItem() throws {
        // Given
        let originalItem = createTestItem()
        
        // When
        let data = try sut.serialize(item: originalItem)
        let deserializedItem = try sut.deserialize(itemData: data)
        
        // Then
        XCTAssertEqual(deserializedItem.id, originalItem.id)
        XCTAssertEqual(deserializedItem.templateId, originalItem.templateId)
        XCTAssertEqual(deserializedItem.name, originalItem.name)
        XCTAssertEqual(deserializedItem.slot, originalItem.slot)
        XCTAssertEqual(deserializedItem.rarity, originalItem.rarity)
        XCTAssertEqual(deserializedItem.level, originalItem.level)
        XCTAssertEqual(deserializedItem.baseStats, originalItem.baseStats)
        XCTAssertEqual(deserializedItem.setId, originalItem.setId)
        XCTAssertEqual(deserializedItem.affixBitmask, originalItem.affixBitmask)
    }
    
    // MARK: - T095: testSerializeInventoryThenDeserializeReturnsEqualInventory
    
    /// 測試背包序列化後反序列化資料一致
    func testSerializeInventoryThenDeserializeReturnsEqualInventory() throws {
        // Given
        let inventory = Inventory(capacity: 50)
        let item1 = createTestItem()
        let item2 = createTestItem()
        try inventory.add(item1)
        try inventory.add(item2)
        
        // When
        let data = try sut.serialize(inventory: inventory)
        let deserializedInventory = try sut.deserialize(inventoryData: data)
        
        // Then
        XCTAssertEqual(deserializedInventory.capacity, inventory.capacity)
        XCTAssertEqual(deserializedInventory.count, inventory.count)
        XCTAssertTrue(deserializedInventory.contains(itemId: item1.id))
        XCTAssertTrue(deserializedInventory.contains(itemId: item2.id))
    }
    
    // MARK: - T096: testDeserializeFromInvalidDataThenReturnsError
    
    /// 測試從無效資料反序列化時拋出錯誤
    func testDeserializeFromInvalidDataThenReturnsError() {
        // Given
        let invalidData = "{ invalid }".data(using: .utf8)!
        
        // When & Then
        XCTAssertThrowsError(try sut.deserialize(itemData: invalidData))
        XCTAssertThrowsError(try sut.deserialize(inventoryData: invalidData))
    }
    
    /// 測試序列化多個物品
    func testSerializeItemsThenDeserializeReturnsEqualItems() throws {
        // Given
        let items = [createTestItem(), createTestItem(), createTestItem()]
        
        // When
        let data = try sut.serialize(items: items)
        let deserializedItems = try sut.deserialize(itemsData: data)
        
        // Then
        XCTAssertEqual(deserializedItems.count, items.count)
        for (original, deserialized) in zip(items, deserializedItems) {
            XCTAssertEqual(original.id, deserialized.id)
        }
    }
    
    /// 測試序列化空背包
    func testSerializeEmptyInventoryThenDeserializeReturnsEmptyInventory() throws {
        // Given
        let inventory = Inventory(capacity: 100)
        
        // When
        let data = try sut.serialize(inventory: inventory)
        let deserializedInventory = try sut.deserialize(inventoryData: data)
        
        // Then
        XCTAssertEqual(deserializedInventory.capacity, 100)
        XCTAssertEqual(deserializedInventory.count, 0)
    }
    
    /// 測試物品的 JSON 輸出是否可讀
    func testSerializedItemIsValidJSON() throws {
        // Given
        let item = createTestItem()
        
        // When
        let data = try sut.serialize(item: item, prettyPrinted: true)
        let jsonString = String(data: data, encoding: .utf8)
        
        // Then
        XCTAssertNotNil(jsonString)
        XCTAssertTrue(jsonString?.contains("\"templateId\"") ?? false)
        XCTAssertTrue(jsonString?.contains("\"test_helmet\"") ?? false)
    }
}

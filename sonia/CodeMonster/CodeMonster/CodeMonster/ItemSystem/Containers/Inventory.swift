//
//  Inventory.swift
//  CodeMonster
//
//  RPG 道具系統 - 背包
//  Feature: 003-rpg-item-system
//
//  存放未穿戴物品的容器，有容量限制
//  FR-015: 背包 MUST 有容量上限
//  FR-016: 系統 MUST 在背包滿時拒絕添加新物品
//  FR-017: 使用者 MUST 能夠從背包中移除/丟棄物品
//
//  Created by CodeMonster on 2026/2/1.
//

import Foundation

/// 背包
/// 存放未穿戴物品的容器
final class Inventory {
    
    // MARK: - Properties
    
    /// 背包容量上限
    let capacity: Int
    
    /// 物品存儲（使用 Dictionary 以 O(1) 查詢）
    private var items: [UUID: Item] = [:]
    
    // MARK: - Initialization
    
    /// 建立背包
    /// - Parameter capacity: 容量上限（預設 100）
    init(capacity: Int = 100) {
        self.capacity = capacity
    }
    
    // MARK: - Computed Properties
    
    /// 當前物品數量
    var count: Int {
        items.count
    }
    
    /// 背包是否為空
    var isEmpty: Bool {
        items.isEmpty
    }
    
    /// 背包是否已滿
    var isFull: Bool {
        count >= capacity
    }
    
    /// 剩餘空間
    var availableSpace: Int {
        capacity - count
    }
    
    /// 所有物品陣列
    var allItems: [Item] {
        Array(items.values)
    }
    
    // MARK: - Add Operations
    
    /// 添加物品到背包
    /// - Parameter item: 要添加的物品
    /// - Throws: `ItemSystemError.inventoryFull` 若背包已滿
    func add(_ item: Item) throws {
        guard !isFull else {
            throw ItemSystemError.inventoryFull(capacity: capacity)
        }
        items[item.id] = item
    }
    
    /// 批次添加物品
    /// - Parameter itemsToAdd: 要添加的物品陣列
    /// - Throws: `ItemSystemError.inventoryFull` 若空間不足
    func add(_ itemsToAdd: [Item]) throws {
        guard availableSpace >= itemsToAdd.count else {
            throw ItemSystemError.inventoryFull(capacity: capacity)
        }
        for item in itemsToAdd {
            items[item.id] = item
        }
    }
    
    // MARK: - Remove Operations
    
    /// 從背包移除物品
    /// - Parameter item: 要移除的物品
    /// - Returns: 被移除的物品
    /// - Throws: `ItemSystemError.itemNotFound` 若物品不存在
    @discardableResult
    func remove(_ item: Item) throws -> Item {
        try remove(itemId: item.id)
    }
    
    /// 根據 ID 從背包移除物品
    /// - Parameter itemId: 物品 ID
    /// - Returns: 被移除的物品
    /// - Throws: `ItemSystemError.itemNotFound` 若物品不存在
    @discardableResult
    func remove(itemId: UUID) throws -> Item {
        guard let item = items.removeValue(forKey: itemId) else {
            throw ItemSystemError.itemNotFound(itemId: itemId)
        }
        return item
    }
    
    /// 清空背包
    /// - Returns: 所有被移除的物品
    @discardableResult
    func clear() -> [Item] {
        let allItems = self.allItems
        items.removeAll()
        return allItems
    }
    
    // MARK: - Query Operations
    
    /// 檢查物品是否在背包中
    /// - Parameter item: 要檢查的物品
    /// - Returns: 是否存在
    func contains(_ item: Item) -> Bool {
        contains(itemId: item.id)
    }
    
    /// 檢查物品 ID 是否在背包中
    /// - Parameter itemId: 物品 ID
    /// - Returns: 是否存在
    func contains(itemId: UUID) -> Bool {
        items[itemId] != nil
    }
    
    /// 根據 ID 取得物品
    /// - Parameter id: 物品 ID
    /// - Returns: 對應的物品，若不存在則回傳 nil
    func item(withId id: UUID) -> Item? {
        items[id]
    }
    
    /// 根據欄位類型過濾物品
    /// - Parameter slot: 裝備欄位
    /// - Returns: 該欄位類型的所有物品
    func items(for slot: EquipmentSlot) -> [Item] {
        allItems.filter { $0.slot == slot }
    }
    
    /// 根據稀有度過濾物品
    /// - Parameter rarity: 稀有度
    /// - Returns: 該稀有度的所有物品
    func items(for rarity: Rarity) -> [Item] {
        allItems.filter { $0.rarity == rarity }
    }
}

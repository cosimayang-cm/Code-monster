// MARK: - Inventory
// Feature: 004-rpg-inventory-system
// Task: TASK-019

import Foundation

/// 背包管理器
public final class Inventory {
    
    // MARK: - Properties
    
    /// 物品儲存
    private var items: [Item]
    
    /// 背包容量
    public let capacity: Int
    
    // MARK: - Initialization
    
    public init(capacity: Int) {
        self.capacity = max(1, capacity)
        self.items = []
    }
    
    // MARK: - Computed Properties
    
    /// 目前物品數量
    public var count: Int {
        items.count
    }
    
    /// 是否已滿
    public var isFull: Bool {
        items.count >= capacity
    }
    
    /// 剩餘空間
    public var remainingSpace: Int {
        max(0, capacity - items.count)
    }
    
    /// 是否為空
    public var isEmpty: Bool {
        items.isEmpty
    }
    
    // MARK: - CRUD Operations
    
    /// 新增物品
    /// - Parameter item: 要新增的物品
    /// - Throws: `InventoryError.full` 如果背包已滿
    public func add(_ item: Item) throws {
        guard !isFull else {
            throw InventoryError.full(capacity: capacity)
        }
        
        items.append(item)
    }
    
    /// 批量新增物品
    /// - Parameter newItems: 要新增的物品列表
    /// - Returns: 成功新增的物品列表
    /// - Throws: `InventoryError.full` 如果空間不足
    public func add(_ newItems: [Item]) throws -> [Item] {
        guard newItems.count <= remainingSpace else {
            throw InventoryError.full(capacity: capacity)
        }
        
        items.append(contentsOf: newItems)
        return newItems
    }
    
    /// 移除物品
    /// - Parameter id: 物品 UUID
    /// - Returns: 被移除的物品
    /// - Throws: `InventoryError.itemNotFound` 如果物品不存在
    public func remove(byId id: UUID) throws -> Item {
        guard let index = items.firstIndex(where: { $0.instanceId == id }) else {
            throw InventoryError.itemNotFound(id: id)
        }
        
        return items.remove(at: index)
    }
    
    /// 檢查物品是否存在
    /// - Parameter id: 物品 UUID
    /// - Returns: 是否存在
    public func contains(id: UUID) -> Bool {
        items.contains { $0.instanceId == id }
    }
    
    /// 取得物品
    /// - Parameter id: 物品 UUID
    /// - Returns: 物品或 nil
    public func getItem(byId id: UUID) -> Item? {
        items.first { $0.instanceId == id }
    }
    
    /// 清空背包
    /// - Returns: 所有被移除的物品
    @discardableResult
    public func clear() -> [Item] {
        let removed = items
        items.removeAll()
        return removed
    }
    
    // MARK: - Filter Operations
    
    /// 根據裝備欄位篩選
    /// - Parameter slot: 裝備欄位
    /// - Returns: 符合的物品列表
    public func filter(by slot: EquipmentSlot) -> [Item] {
        items.filter { $0.slot == slot }
    }
    
    /// 根據稀有度篩選
    /// - Parameter rarity: 稀有度
    /// - Returns: 符合的物品列表
    public func filter(by rarity: Rarity) -> [Item] {
        items.filter { $0.rarity == rarity }
    }
    
    /// 根據詞條類型篩選
    /// - Parameter type: 詞條類型
    /// - Returns: 符合的物品列表
    public func filter(hasAffix type: AffixType) -> [Item] {
        items.filter { $0.hasAffix(type) }
    }
    
    /// 根據套裝 ID 篩選
    /// - Parameter setId: 套裝 ID
    /// - Returns: 符合的物品列表
    public func filter(bySetId setId: String) -> [Item] {
        items.filter { $0.setId == setId }
    }
    
    /// 多條件篩選
    /// - Parameter predicate: 篩選條件
    /// - Returns: 符合的物品列表
    public func filter(_ predicate: (Item) -> Bool) -> [Item] {
        items.filter(predicate)
    }
    
    // MARK: - Sort Operations
    
    /// 根據稀有度排序
    /// - Parameter ascending: 是否升序
    /// - Returns: 排序後的物品列表
    public func sortedByRarity(ascending: Bool = false) -> [Item] {
        items.sorted {
            ascending ? $0.rarity < $1.rarity : $0.rarity > $1.rarity
        }
    }
    
    /// 根據等級排序
    /// - Parameter ascending: 是否升序
    /// - Returns: 排序後的物品列表
    public func sortedByLevel(ascending: Bool = false) -> [Item] {
        items.sorted {
            ascending ? $0.level < $1.level : $0.level > $1.level
        }
    }
    
    /// 根據裝備欄位排序
    /// - Returns: 排序後的物品列表
    public func sortedBySlot() -> [Item] {
        items.sorted { $0.slot < $1.slot }
    }
    
    // MARK: - Access
    
    /// 取得所有物品（唯讀）
    public var allItems: [Item] {
        items
    }
    
    /// 使用索引取得物品
    public subscript(index: Int) -> Item? {
        guard index >= 0 && index < items.count else { return nil }
        return items[index]
    }
}

// MARK: - Sequence

extension Inventory: Sequence {
    public func makeIterator() -> IndexingIterator<[Item]> {
        items.makeIterator()
    }
}

// MARK: - Collection

extension Inventory: Collection {
    public var startIndex: Int { items.startIndex }
    public var endIndex: Int { items.endIndex }
    
    public func index(after i: Int) -> Int {
        items.index(after: i)
    }
    
    public subscript(position: Int) -> Item {
        items[position]
    }
}

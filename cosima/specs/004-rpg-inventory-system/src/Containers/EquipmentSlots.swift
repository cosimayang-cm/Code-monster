// MARK: - EquipmentSlots
// Feature: 004-rpg-inventory-system
// Task: TASK-020

import Foundation

/// 裝備欄管理器
public final class EquipmentSlots {
    
    // MARK: - Properties
    
    /// 裝備欄儲存
    private var slots: [EquipmentSlot: Item]
    
    // MARK: - Initialization
    
    public init() {
        self.slots = [:]
    }
    
    // MARK: - Computed Properties
    
    /// 已裝備的物品列表
    public var equippedItems: [Item] {
        Array(slots.values)
    }
    
    /// 已裝備數量
    public var equippedCount: Int {
        slots.count
    }
    
    /// 總欄位數
    public var totalSlots: Int {
        EquipmentSlot.allCases.count
    }
    
    /// 空的欄位
    public var emptySlots: [EquipmentSlot] {
        EquipmentSlot.allCases.filter { slots[$0] == nil }
    }
    
    /// 已使用的欄位
    public var usedSlots: [EquipmentSlot] {
        EquipmentSlot.allCases.filter { slots[$0] != nil }
    }
    
    /// 是否全部裝備
    public var isFullyEquipped: Bool {
        equippedCount == totalSlots
    }
    
    // MARK: - Equip Operations
    
    /// 裝備物品
    /// - Parameters:
    ///   - item: 要裝備的物品
    ///   - characterLevel: 角色等級
    /// - Returns: 被替換的物品（如有）
    /// - Throws: `EquipmentError` 如果裝備失敗
    public func equip(_ item: Item, characterLevel: Int) throws -> Item? {
        // 檢查等級需求
        guard item.canEquip(characterLevel: characterLevel) else {
            throw EquipmentError.levelRequirementNotMet(
                required: item.levelRequirement,
                current: characterLevel
            )
        }
        
        let slot = item.slot
        let replaced = slots[slot]
        slots[slot] = item
        
        return replaced
    }
    
    /// 卸除裝備
    /// - Parameter slot: 裝備欄位
    /// - Returns: 被卸除的物品
    /// - Throws: `EquipmentError.slotEmpty` 如果欄位為空
    public func unequip(slot: EquipmentSlot) throws -> Item {
        guard let item = slots.removeValue(forKey: slot) else {
            throw EquipmentError.slotEmpty(slot: slot)
        }
        
        return item
    }
    
    /// 卸除所有裝備
    /// - Returns: 所有被卸除的物品
    @discardableResult
    public func unequipAll() -> [Item] {
        let items = equippedItems
        slots.removeAll()
        return items
    }
    
    // MARK: - Query Operations
    
    /// 取得特定欄位的裝備
    /// - Parameter slot: 裝備欄位
    /// - Returns: 裝備或 nil
    public func getItem(at slot: EquipmentSlot) -> Item? {
        slots[slot]
    }
    
    /// 檢查欄位是否已裝備
    /// - Parameter slot: 裝備欄位
    /// - Returns: 是否已裝備
    public func isEquipped(slot: EquipmentSlot) -> Bool {
        slots[slot] != nil
    }
    
    /// 檢查物品是否已裝備
    /// - Parameter itemId: 物品 UUID
    /// - Returns: 是否已裝備
    public func isEquipped(itemId: UUID) -> Bool {
        slots.values.contains { $0.instanceId == itemId }
    }
    
    /// 取得物品所在的欄位
    /// - Parameter itemId: 物品 UUID
    /// - Returns: 欄位或 nil
    public func getSlot(for itemId: UUID) -> EquipmentSlot? {
        for (slot, item) in slots {
            if item.instanceId == itemId {
                return slot
            }
        }
        return nil
    }
    
    // MARK: - Stats Calculation
    
    /// 計算所有裝備的總數值
    /// - Parameter characterBaseStats: 角色基礎數值
    /// - Returns: 總數值
    public func calculateTotalStats(characterBaseStats: Stats = .zero) -> Stats {
        var total = Stats.zero
        
        for item in equippedItems {
            total += item.calculateTotalStats(characterBaseStats: characterBaseStats)
        }
        
        return total
    }
    
    // MARK: - Set Tracking
    
    /// 統計各套裝的裝備件數
    /// - Returns: 套裝 ID 與件數的對應
    public func getSetCounts() -> [String: Int] {
        var counts: [String: Int] = [:]
        
        for item in equippedItems {
            if let setId = item.setId {
                counts[setId, default: 0] += 1
            }
        }
        
        return counts
    }
}

// MARK: - Subscript

extension EquipmentSlots {
    
    /// 使用欄位取得裝備
    public subscript(slot: EquipmentSlot) -> Item? {
        get { slots[slot] }
    }
}

// MARK: - Sequence

extension EquipmentSlots: Sequence {
    public func makeIterator() -> Dictionary<EquipmentSlot, Item>.Iterator {
        slots.makeIterator()
    }
}

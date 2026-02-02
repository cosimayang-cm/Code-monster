//
//  EquipmentSlots.swift
//  CodeMonster
//
//  RPG 道具系統 - 裝備欄位容器
//  Feature: 003-rpg-item-system
//
//  管理角色的 5 個裝備欄位，處理裝備的穿戴和卸下
//  FR-001: 系統 MUST 支援 5 個裝備欄位
//  FR-012: 系統 MUST 驗證物品只能裝備到對應的欄位
//  FR-014: 系統 MUST 在更換裝備時自動將舊裝備放回背包
//
//  Created by CodeMonster on 2026/2/1.
//

import Foundation

/// 裝備欄位容器
/// 管理角色身上的 5 個裝備欄位
final class EquipmentSlots {
    
    // MARK: - Properties
    
    /// 各欄位的裝備（slot -> Item）
    private var slots: [EquipmentSlot: Item] = [:]
    
    // MARK: - Initialization
    
    /// 建立空的裝備欄位容器
    init() {}
    
    // MARK: - Query
    
    /// 取得指定欄位的裝備
    /// - Parameter slot: 裝備欄位
    /// - Returns: 該欄位的裝備，若為空則回傳 nil
    func item(at slot: EquipmentSlot) -> Item? {
        slots[slot]
    }
    
    /// 所有已裝備的物品
    var allEquippedItems: [Item] {
        Array(slots.values)
    }
    
    /// 是否所有欄位都為空
    var isEmpty: Bool {
        slots.isEmpty
    }
    
    /// 已裝備的欄位數量
    var equippedCount: Int {
        slots.count
    }
    
    // MARK: - Equipment Operations
    
    /// 將物品裝備到指定欄位
    /// - Parameters:
    ///   - item: 要裝備的物品
    ///   - slot: 目標欄位
    /// - Returns: 被替換的舊裝備（如果有的話）
    /// - Throws: `ItemSystemError.slotMismatch` 若物品類型與欄位不匹配
    @discardableResult
    func equip(_ item: Item, to slot: EquipmentSlot) throws -> Item? {
        // 驗證物品類型與欄位匹配
        guard item.slot == slot else {
            throw ItemSystemError.slotMismatch(itemSlot: item.slot, targetSlot: slot)
        }
        
        // 取出舊裝備（如果有）
        let previousItem = slots[slot]
        
        // 裝備新物品
        slots[slot] = item
        
        return previousItem
    }
    
    /// 從指定欄位卸下裝備
    /// - Parameter slot: 要卸下的欄位
    /// - Returns: 卸下的裝備
    /// - Throws: `ItemSystemError.slotEmpty` 若欄位為空
    func unequip(from slot: EquipmentSlot) throws -> Item {
        guard let item = slots[slot] else {
            throw ItemSystemError.slotEmpty(slot: slot)
        }
        
        slots[slot] = nil
        return item
    }
    
    /// 清空所有裝備欄位
    /// - Returns: 所有被卸下的裝備
    func unequipAll() -> [Item] {
        let items = allEquippedItems
        slots.removeAll()
        return items
    }
    
    // MARK: - Stats Calculation
    
    /// 計算所有裝備提供的總數值
    var totalStats: Stats {
        allEquippedItems.reduce(Stats.zero) { result, item in
            result + item.totalStats
        }
    }
}

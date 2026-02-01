//
//  Avatar.swift
//  CodeMonster
//
//  RPG 道具系統 - 角色
//  Feature: 003-rpg-item-system
//
//  玩家控制的角色，擁有基礎數值、裝備欄位、背包
//  FR-007: 系統 MUST 在裝備穿戴/卸下時即時更新角色數值
//  FR-013: 系統 MUST 驗證角色等級滿足裝備的等級需求
//
//  Created by CodeMonster on 2026/2/1.
//

import Foundation

/// 角色
/// 玩家控制的角色，擁有基礎數值和裝備欄位
final class Avatar {
    
    // MARK: - Properties
    
    /// 角色名稱
    let name: String
    
    /// 角色等級
    var level: Int
    
    /// 角色基礎數值
    var baseStats: Stats
    
    /// 裝備欄位
    private let equipmentSlots: EquipmentSlots
    
    // MARK: - Initialization
    
    /// 建立角色
    /// - Parameters:
    ///   - name: 角色名稱
    ///   - level: 角色等級
    ///   - baseStats: 基礎數值
    init(name: String, level: Int, baseStats: Stats) {
        self.name = name
        self.level = level
        self.baseStats = baseStats
        self.equipmentSlots = EquipmentSlots()
    }
    
    // MARK: - Equipment Query
    
    /// 取得指定欄位的裝備
    /// - Parameter slot: 裝備欄位
    /// - Returns: 該欄位的裝備，若為空則回傳 nil
    func equippedItem(at slot: EquipmentSlot) -> Item? {
        equipmentSlots.item(at: slot)
    }
    
    /// 所有已裝備的物品
    var allEquippedItems: [Item] {
        equipmentSlots.allEquippedItems
    }
    
    // MARK: - Equipment Operations
    
    /// 裝備物品到對應欄位（自動判斷欄位）
    /// - Parameter item: 要裝備的物品
    /// - Returns: 被替換的舊裝備（如果有的話）
    /// - Throws: `ItemSystemError.levelRequirementNotMet` 若等級不足
    @discardableResult
    func equip(_ item: Item) throws -> Item? {
        try equip(item, to: item.slot)
    }
    
    /// 裝備物品到指定欄位
    /// - Parameters:
    ///   - item: 要裝備的物品
    ///   - slot: 目標欄位
    /// - Returns: 被替換的舊裝備（如果有的話）
    /// - Throws: `ItemSystemError.levelRequirementNotMet` 若等級不足
    /// - Throws: `ItemSystemError.slotMismatch` 若物品類型與欄位不匹配
    @discardableResult
    func equip(_ item: Item, to slot: EquipmentSlot) throws -> Item? {
        // 驗證等級需求
        guard level >= item.levelRequirement else {
            throw ItemSystemError.levelRequirementNotMet(
                required: item.levelRequirement,
                current: level
            )
        }
        
        // 裝備物品（EquipmentSlots 會驗證欄位匹配）
        return try equipmentSlots.equip(item, to: slot)
    }
    
    /// 從指定欄位卸下裝備
    /// - Parameter slot: 要卸下的欄位
    /// - Returns: 卸下的裝備
    /// - Throws: `ItemSystemError.slotEmpty` 若欄位為空
    func unequip(from slot: EquipmentSlot) throws -> Item {
        try equipmentSlots.unequip(from: slot)
    }
    
    // MARK: - Stats Calculation
    
    /// 計算角色總數值（基礎數值 + 裝備數值）
    /// FR-006: 最終值 = (基礎值 + Σ固定加成) × (1 + Σ百分比加成)
    /// 注意：目前只實作固定加成，百分比加成在詞條系統實作
    var totalStats: Stats {
        baseStats + equipmentSlots.totalStats
    }
}

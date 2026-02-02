//
//  ItemTemplate.swift
//  CodeMonster
//
//  RPG 道具系統 - 物品模板
//  Feature: 003-rpg-item-system
//
//  定義物品種類的藍圖，包含模板 ID、名稱、描述、欄位類型、稀有度、等級需求、基礎數值等
//  FR-003: 系統 MUST 區分物品模板（定義種類）和物品實例（實際存在的物品）
//
//  Created by CodeMonster on 2026/2/1.
//

import Foundation

/// 物品模板
/// 定義物品種類的藍圖，用於生成物品實例
struct ItemTemplate: Codable, Equatable, Hashable, Identifiable {
    
    // MARK: - Properties
    
    /// 模板唯一識別碼
    let id: String
    
    /// 物品名稱
    let name: String
    
    /// 物品描述
    let description: String
    
    /// 裝備欄位類型
    let slot: EquipmentSlot
    
    /// 物品稀有度
    let rarity: Rarity
    
    /// 等級需求（預設為 1）
    let levelRequirement: Int
    
    /// 基礎數值
    let baseStats: Stats
    
    /// 圖示資源名稱
    let iconName: String
    
    /// 所屬套裝 ID（可選）
    let setId: String?
    
    // MARK: - Initialization
    
    /// 建立物品模板
    /// - Parameters:
    ///   - id: 模板唯一識別碼
    ///   - name: 物品名稱
    ///   - description: 物品描述
    ///   - slot: 裝備欄位類型
    ///   - rarity: 物品稀有度
    ///   - levelRequirement: 等級需求（預設為 1）
    ///   - baseStats: 基礎數值
    ///   - iconName: 圖示資源名稱
    ///   - setId: 所屬套裝 ID（可選）
    init(
        id: String,
        name: String,
        description: String,
        slot: EquipmentSlot,
        rarity: Rarity,
        levelRequirement: Int = 1,
        baseStats: Stats,
        iconName: String,
        setId: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.slot = slot
        self.rarity = rarity
        self.levelRequirement = levelRequirement
        self.baseStats = baseStats
        self.iconName = iconName
        self.setId = setId
    }
}

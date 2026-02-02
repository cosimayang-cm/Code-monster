//
//  Item.swift
//  CodeMonster
//
//  RPG 道具系統 - 物品實例
//  Feature: 003-rpg-item-system
//
//  實際存在的物品，包含實例 UUID、所屬模板 ID、當前等級、主詞條、副詞條列表、詞條 Bitmask
//  FR-002: 系統 MUST 為每個物品實例生成全域唯一的 UUID
//  FR-003: 系統 MUST 區分物品模板（定義種類）和物品實例（實際存在的物品）
//
//  Created by CodeMonster on 2026/2/1.
//

import Foundation

/// 物品實例
/// 實際存在於遊戲中的物品，由模板生成
final class Item: Codable, Equatable, Hashable, Identifiable {
    
    // MARK: - Properties
    
    /// 物品唯一識別碼（UUID v4）
    let id: UUID
    
    /// 所屬模板 ID
    let templateId: String
    
    /// 物品名稱（從模板繼承）
    let name: String
    
    /// 物品描述（從模板繼承）
    let description: String
    
    /// 裝備欄位類型（從模板繼承）
    let slot: EquipmentSlot
    
    /// 物品稀有度（從模板繼承）
    let rarity: Rarity
    
    /// 等級需求（從模板繼承）
    let levelRequirement: Int
    
    /// 基礎數值（從模板繼承）
    let baseStats: Stats
    
    /// 圖示資源名稱（從模板繼承）
    let iconName: String
    
    /// 所屬套裝 ID（從模板繼承，可選）
    let setId: String?
    
    /// 當前等級（預設為 1，最大為 20）
    var level: Int
    
    /// 詞條 Bitmask（用於 O(1) 複雜度的快速查詢）
    /// FR-011: 系統 MUST 使用 Bitmask 支援詞條的快速查詢和組合判斷
    var affixBitmask: AffixType
    
    // MARK: - Initialization
    
    /// 從模板建立物品實例
    /// - Parameter template: 物品模板
    init(template: ItemTemplate) {
        self.id = UUID()
        self.templateId = template.id
        self.name = template.name
        self.description = template.description
        self.slot = template.slot
        self.rarity = template.rarity
        self.levelRequirement = template.levelRequirement
        self.baseStats = template.baseStats
        self.iconName = template.iconName
        self.setId = template.setId
        self.level = 1
        self.affixBitmask = []
    }
    
    // MARK: - Equatable
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Stats Calculation

extension Item {
    
    /// 計算物品提供的總數值（基礎數值）
    /// 注意：此處只計算基礎數值，詞條加成在 Phase 5 實作
    var totalStats: Stats {
        // 目前只回傳基礎數值，後續會加上詞條加成
        return baseStats
    }
}

// MARK: - Affix Bitmask Query

extension Item {
    
    /// 檢查物品是否擁有指定的詞條類型
    /// - Parameter affixType: 要檢查的詞條類型
    /// - Returns: 是否擁有該詞條
    /// - Complexity: O(1)
    func hasAffix(_ affixType: AffixType) -> Bool {
        affixBitmask.contains(affixType)
    }
    
    /// 檢查物品是否同時擁有所有指定的詞條類型
    /// - Parameter affixTypes: 要檢查的詞條類型組合
    /// - Returns: 是否同時擁有所有指定詞條
    /// - Complexity: O(1)
    func hasAllAffixes(_ affixTypes: AffixType) -> Bool {
        affixBitmask.contains(affixTypes)
    }
    
    /// 檢查物品是否擁有任一指定的詞條類型
    /// - Parameter affixTypes: 要檢查的詞條類型組合
    /// - Returns: 是否擁有任一指定詞條
    /// - Complexity: O(1)
    func hasAnyAffix(_ affixTypes: AffixType) -> Bool {
        !affixBitmask.intersection(affixTypes).isEmpty
    }
}

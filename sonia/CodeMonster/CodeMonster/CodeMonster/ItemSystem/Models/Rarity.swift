//
//  Rarity.swift
//  CodeMonster
//
//  RPG 道具系統 - 物品稀有度
//  Feature: 003-rpg-item-system
//
//  定義物品的 5 種稀有度等級及其對應的副詞條數量規則
//  FR-004: 系統 MUST 支援 5 種稀有度：普通、優良、稀有、史詩、傳說
//  FR-009: 副詞條數量 MUST 根據稀有度決定
//
//  Created by CodeMonster on 2026/2/1.
//

import Foundation

/// 物品稀有度等級
/// 決定物品的品質和副詞條數量
enum Rarity: Int, CaseIterable, Codable, Comparable, Hashable {
    /// 普通品質 - 0 條副詞條
    case common = 0
    
    /// 優良品質 - 1-2 條副詞條
    case uncommon = 1
    
    /// 稀有品質 - 2-3 條副詞條
    case rare = 2
    
    /// 史詩品質 - 3-4 條副詞條
    case epic = 3
    
    /// 傳說品質 - 4 條副詞條
    case legendary = 4
    
    // MARK: - Sub Affix Count
    
    /// 最小副詞條數量
    var minSubAffixCount: Int {
        switch self {
        case .common: return 0
        case .uncommon: return 1
        case .rare: return 2
        case .epic: return 3
        case .legendary: return 4
        }
    }
    
    /// 最大副詞條數量
    var maxSubAffixCount: Int {
        switch self {
        case .common: return 0
        case .uncommon: return 2
        case .rare: return 3
        case .epic: return 4
        case .legendary: return 4
        }
    }
    
    /// 初始副詞條數量（生成時使用最小值）
    var initialSubAffixCount: Int {
        return minSubAffixCount
    }
    
    // MARK: - Comparable
    
    static func < (lhs: Rarity, rhs: Rarity) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    // MARK: - Display
    
    /// 稀有度的顯示名稱
    var displayName: String {
        switch self {
        case .common: return "普通"
        case .uncommon: return "優良"
        case .rare: return "稀有"
        case .epic: return "史詩"
        case .legendary: return "傳說"
        }
    }
}

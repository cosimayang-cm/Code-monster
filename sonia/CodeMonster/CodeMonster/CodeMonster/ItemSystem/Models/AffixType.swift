//
//  AffixType.swift
//  CodeMonster
//
//  RPG 道具系統 - 詞條類型（OptionSet）
//  Feature: 003-rpg-item-system
//
//  使用 Bitmask 實作詞條類型，支援快速查詢和組合判斷
//  FR-011: 系統 MUST 使用 Bitmask 支援詞條的快速查詢和組合判斷
//
//  Created by CodeMonster on 2026/2/1.
//

import Foundation

/// 詞條類型（OptionSet）
/// 使用 Bitmask 實作，支援 O(1) 複雜度的查詢和組合判斷
struct AffixType: OptionSet, Codable, Hashable {
    
    let rawValue: UInt32
    
    // MARK: - Fixed Stat Types (固定加成)
    
    /// 攻擊力（固定加成）
    static let attack = AffixType(rawValue: 1 << 0)
    
    /// 防禦力（固定加成）
    static let defense = AffixType(rawValue: 1 << 1)
    
    /// 最大生命值（固定加成）
    static let maxHP = AffixType(rawValue: 1 << 2)
    
    /// 最大魔力值（固定加成）
    static let maxMP = AffixType(rawValue: 1 << 3)
    
    /// 暴擊率（固定加成，數值為小數如 0.1 = 10%）
    static let critRate = AffixType(rawValue: 1 << 4)
    
    /// 暴擊傷害（固定加成，數值為小數如 0.5 = 50%）
    static let critDamage = AffixType(rawValue: 1 << 5)
    
    /// 速度（固定加成）
    static let speed = AffixType(rawValue: 1 << 6)
    
    // MARK: - Percentage Stat Types (百分比加成)
    
    /// 攻擊力百分比
    static let attackPercent = AffixType(rawValue: 1 << 7)
    
    /// 防禦力百分比
    static let defensePercent = AffixType(rawValue: 1 << 8)
    
    /// 最大生命值百分比
    static let maxHPPercent = AffixType(rawValue: 1 << 9)
    
    /// 最大魔力值百分比
    static let maxMPPercent = AffixType(rawValue: 1 << 10)
    
    /// 速度百分比
    static let speedPercent = AffixType(rawValue: 1 << 11)
    
    // MARK: - Type Groups
    
    /// 所有固定加成類型
    static let allFlat: AffixType = [.attack, .defense, .maxHP, .maxMP, .critRate, .critDamage, .speed]
    
    /// 所有百分比加成類型
    static let allPercent: AffixType = [.attackPercent, .defensePercent, .maxHPPercent, .maxMPPercent, .speedPercent]
    
    /// 所有攻擊相關類型
    static let offensive: AffixType = [.attack, .attackPercent, .critRate, .critDamage]
    
    /// 所有防禦相關類型
    static let defensive: AffixType = [.defense, .defensePercent, .maxHP, .maxHPPercent]
    
    // MARK: - Display
    
    /// 詞條類型的顯示名稱
    var displayName: String {
        switch self {
        case .attack: return "攻擊力"
        case .defense: return "防禦力"
        case .maxHP: return "生命值"
        case .maxMP: return "魔力值"
        case .critRate: return "暴擊率"
        case .critDamage: return "暴擊傷害"
        case .speed: return "速度"
        case .attackPercent: return "攻擊力%"
        case .defensePercent: return "防禦力%"
        case .maxHPPercent: return "生命值%"
        case .maxMPPercent: return "魔力值%"
        case .speedPercent: return "速度%"
        default: return "未知"
        }
    }
}

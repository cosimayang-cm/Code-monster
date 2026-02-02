//
//  Affix.swift
//  CodeMonster
//
//  RPG 道具系統 - 詞條
//  Feature: 003-rpg-item-system
//
//  裝備上的屬性加成，包含類型、數值、是否為百分比
//  FR-008: 每件裝備 MUST 擁有一個主詞條，數值隨裝備等級成長
//
//  Created by CodeMonster on 2026/2/1.
//

import Foundation

/// 詞條
/// 裝備上的屬性加成
struct Affix: Codable, Equatable, Hashable {
    
    // MARK: - Properties
    
    /// 詞條類型
    let type: AffixType
    
    /// 詞條數值
    var value: Double
    
    /// 是否為百分比加成
    let isPercentage: Bool
    
    // MARK: - Initialization
    
    /// 建立詞條
    /// - Parameters:
    ///   - type: 詞條類型
    ///   - value: 詞條數值
    ///   - isPercentage: 是否為百分比加成
    init(type: AffixType, value: Double, isPercentage: Bool) {
        self.type = type
        self.value = value
        self.isPercentage = isPercentage
    }
    
    // MARK: - Stats Conversion
    
    /// 將詞條轉換為 Stats
    /// - Returns: 對應的 Stats 結構
    func toStats() -> Stats {
        var stats = Stats.zero
        
        // 根據詞條類型設定對應數值
        switch type {
        case .attack, .attackPercent:
            stats.attack = value
        case .defense, .defensePercent:
            stats.defense = value
        case .maxHP, .maxHPPercent:
            stats.maxHP = value
        case .maxMP, .maxMPPercent:
            stats.maxMP = value
        case .critRate:
            stats.critRate = value
        case .critDamage:
            stats.critDamage = value
        case .speed, .speedPercent:
            stats.speed = value
        default:
            break
        }
        
        return stats
    }
    
    // MARK: - Display
    
    /// 詞條的顯示字串
    var displayString: String {
        if isPercentage {
            let percentValue = value * 100
            return "\(type.displayName) +\(String(format: "%.1f", percentValue))%"
        } else {
            if value == floor(value) {
                return "\(type.displayName) +\(Int(value))"
            } else {
                return "\(type.displayName) +\(String(format: "%.1f", value))"
            }
        }
    }
}

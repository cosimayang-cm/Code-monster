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
enum Rarity: Int, CaseIterable, Comparable, Hashable {
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
    
    // MARK: - String Mapping
    
    /// 用於 JSON 序列化的字串識別碼
    var stringValue: String {
        switch self {
        case .common: return "common"
        case .uncommon: return "uncommon"
        case .rare: return "rare"
        case .epic: return "epic"
        case .legendary: return "legendary"
        }
    }
    
    /// 從字串建立稀有度
    init?(stringValue: String) {
        switch stringValue.lowercased() {
        case "common": self = .common
        case "uncommon": self = .uncommon
        case "rare": self = .rare
        case "epic": self = .epic
        case "legendary": self = .legendary
        default: return nil
        }
    }
    
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

// MARK: - Codable

extension Rarity: Codable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        // 嘗試從字串解碼
        if let stringValue = try? container.decode(String.self) {
            guard let rarity = Rarity(stringValue: stringValue) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid rarity string: \(stringValue)"
                )
            }
            self = rarity
            return
        }
        
        // 嘗試從整數解碼
        if let intValue = try? container.decode(Int.self) {
            guard let rarity = Rarity(rawValue: intValue) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid rarity value: \(intValue)"
                )
            }
            self = rarity
            return
        }
        
        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Expected String or Int for Rarity"
        )
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stringValue)
    }
}

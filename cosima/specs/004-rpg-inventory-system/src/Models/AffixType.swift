// MARK: - AffixType (Bitmask)
// Feature: 004-rpg-inventory-system
// Task: TASK-004

import Foundation

/// 詞條類型 - 使用 OptionSet 實現 O(1) 查詢
public struct AffixType: OptionSet, Hashable {
    public let rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    // MARK: - Type Definitions
    
    /// 暴擊率
    public static let crit             = AffixType(rawValue: 1 << 0)
    
    /// 充能效率
    public static let energyRecharge   = AffixType(rawValue: 1 << 1)
    
    /// 攻擊力
    public static let attack           = AffixType(rawValue: 1 << 2)
    
    /// 防禦力
    public static let defense          = AffixType(rawValue: 1 << 3)
    
    /// 生命值
    public static let hp               = AffixType(rawValue: 1 << 4)
    
    /// 元素精通
    public static let elementalMastery = AffixType(rawValue: 1 << 5)
    
    /// 元素傷害
    public static let elementalDamage  = AffixType(rawValue: 1 << 6)
    
    /// 治療加成
    public static let healingBonus     = AffixType(rawValue: 1 << 7)
    
    /// 暴擊傷害
    public static let critDamage       = AffixType(rawValue: 1 << 8)
    
    /// 魔力值
    public static let mp               = AffixType(rawValue: 1 << 9)
    
    /// 速度
    public static let speed            = AffixType(rawValue: 1 << 10)
    
    // MARK: - All Types
    
    /// 所有詞條類型
    public static let allTypes: [AffixType] = [
        .crit, .energyRecharge, .attack, .defense, .hp,
        .elementalMastery, .elementalDamage, .healingBonus,
        .critDamage, .mp, .speed
    ]
    
    /// 空集合
    public static let none = AffixType([])
}

// MARK: - String Key Mapping

extension AffixType {
    
    /// 字串鍵值對應表
    private static let stringKeyMap: [String: AffixType] = [
        "crit": .crit,
        "energyRecharge": .energyRecharge,
        "attack": .attack,
        "defense": .defense,
        "hp": .hp,
        "elementalMastery": .elementalMastery,
        "elementalDamage": .elementalDamage,
        "healingBonus": .healingBonus,
        "critDamage": .critDamage,
        "mp": .mp,
        "speed": .speed
    ]
    
    /// 取得字串鍵值
    public var stringKey: String? {
        // 只有單一類型才有對應的字串鍵
        for (key, type) in Self.stringKeyMap {
            if self == type {
                return key
            }
        }
        return nil
    }
    
    /// 取得所有包含類型的字串鍵值
    public var stringKeys: [String] {
        Self.stringKeyMap.compactMap { key, type in
            self.contains(type) ? key : nil
        }
    }
    
    /// 從字串鍵值初始化
    /// - Parameter stringKey: 字串鍵值
    public init?(stringKey: String) {
        guard let type = Self.stringKeyMap[stringKey] else {
            return nil
        }
        self = type
    }
    
    /// 從多個字串鍵值初始化
    /// - Parameter stringKeys: 字串鍵值陣列
    public init(stringKeys: [String]) {
        var result = AffixType.none
        for key in stringKeys {
            if let type = Self.stringKeyMap[key] {
                result.insert(type)
            }
        }
        self = result
    }
}

// MARK: - Display Properties

extension AffixType {
    
    /// 顯示名稱（繁體中文）- 僅單一類型有效
    public var displayName: String? {
        guard let key = stringKey else { return nil }
        
        switch key {
        case "crit": return "暴擊率"
        case "energyRecharge": return "充能效率"
        case "attack": return "攻擊力"
        case "defense": return "防禦力"
        case "hp": return "生命值"
        case "elementalMastery": return "元素精通"
        case "elementalDamage": return "元素傷害"
        case "healingBonus": return "治療加成"
        case "critDamage": return "暴擊傷害"
        case "mp": return "魔力值"
        case "speed": return "速度"
        default: return nil
        }
    }
}

// MARK: - Codable

extension AffixType: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        // 嘗試解碼為字串陣列
        if let stringKeys = try? container.decode([String].self) {
            self.init(stringKeys: stringKeys)
            return
        }
        
        // 嘗試解碼為單一字串
        if let stringKey = try? container.decode(String.self) {
            if let type = AffixType(stringKey: stringKey) {
                self = type
                return
            }
        }
        
        // 嘗試解碼為原始數值
        if let rawValue = try? container.decode(UInt32.self) {
            self.init(rawValue: rawValue)
            return
        }
        
        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Invalid AffixType format"
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        // 如果是單一類型，編碼為字串
        if let key = stringKey {
            try container.encode(key)
            return
        }
        
        // 如果是多重類型，編碼為字串陣列
        let keys = stringKeys
        if !keys.isEmpty {
            try container.encode(keys)
            return
        }
        
        // 否則編碼為原始數值
        try container.encode(rawValue)
    }
}

// MARK: - CustomStringConvertible

extension AffixType: CustomStringConvertible {
    public var description: String {
        if let name = displayName {
            return name
        }
        let keys = stringKeys
        if keys.isEmpty {
            return "AffixType(none)"
        }
        return "AffixType(\(keys.joined(separator: ", ")))"
    }
}

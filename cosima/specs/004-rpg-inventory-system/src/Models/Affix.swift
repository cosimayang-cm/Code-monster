// MARK: - Affix
// Feature: 004-rpg-inventory-system
// Task: TASK-005

import Foundation

/// 詞條實例
public struct Affix: Codable, Equatable, Hashable {
    
    // MARK: - Properties
    
    /// 詞條類型
    public let type: AffixType
    
    /// 數值
    public var value: Double
    
    /// 是否為百分比加成
    public let isPercentage: Bool
    
    // MARK: - Initialization
    
    public init(type: AffixType, value: Double, isPercentage: Bool = false) {
        self.type = type
        self.value = value
        self.isPercentage = isPercentage
    }
}

// MARK: - Display Properties

extension Affix {
    
    /// 顯示文字
    public var displayText: String {
        let typeName = type.displayName ?? "未知"
        if isPercentage {
            return "\(typeName) +\(String(format: "%.1f", value))%"
        } else {
            return "\(typeName) +\(Int(value))"
        }
    }
    
    /// 簡短顯示文字（不含類型名稱）
    public var shortDisplayText: String {
        if isPercentage {
            return "+\(String(format: "%.1f", value))%"
        } else {
            return "+\(Int(value))"
        }
    }
}

// MARK: - Value Calculation

extension Affix {
    
    /// 升級後的數值（+10%）
    /// - Returns: 升級後的新詞條
    public func upgraded() -> Affix {
        Affix(
            type: type,
            value: value * 1.1,
            isPercentage: isPercentage
        )
    }
    
    /// 執行升級
    public mutating func upgrade() {
        value *= 1.1
    }
    
    /// 轉換為 Stats 加成
    /// - Parameter baseStats: 基礎數值（用於計算百分比）
    /// - Returns: Stats 加成
    public func toStats(baseStats: Stats = .zero) -> Stats {
        var result = Stats.zero
        
        guard let key = type.stringKey else { return result }
        
        let actualValue: Double
        if isPercentage {
            // 百分比需要根據基礎值計算
            actualValue = value / 100.0
        } else {
            actualValue = value
        }
        
        switch key {
        case "attack":
            if isPercentage {
                result.attack = baseStats.attack * actualValue
            } else {
                result.attack = actualValue
            }
        case "defense":
            if isPercentage {
                result.defense = baseStats.defense * actualValue
            } else {
                result.defense = actualValue
            }
        case "hp":
            if isPercentage {
                result.maxHP = baseStats.maxHP * actualValue
            } else {
                result.maxHP = actualValue
            }
        case "mp":
            if isPercentage {
                result.maxMP = baseStats.maxMP * actualValue
            } else {
                result.maxMP = actualValue
            }
        case "crit":
            result.critRate = actualValue
        case "critDamage":
            result.critDamage = actualValue
        case "speed":
            if isPercentage {
                result.speed = baseStats.speed * actualValue
            } else {
                result.speed = actualValue
            }
        default:
            break
        }
        
        return result
    }
}

// MARK: - Factory Methods

extension Affix {
    
    /// 建立攻擊力詞條
    public static func attack(_ value: Double, isPercentage: Bool = false) -> Affix {
        Affix(type: .attack, value: value, isPercentage: isPercentage)
    }
    
    /// 建立防禦力詞條
    public static func defense(_ value: Double, isPercentage: Bool = false) -> Affix {
        Affix(type: .defense, value: value, isPercentage: isPercentage)
    }
    
    /// 建立生命值詞條
    public static func hp(_ value: Double, isPercentage: Bool = false) -> Affix {
        Affix(type: .hp, value: value, isPercentage: isPercentage)
    }
    
    /// 建立暴擊率詞條
    public static func crit(_ value: Double) -> Affix {
        Affix(type: .crit, value: value, isPercentage: true)
    }
    
    /// 建立暴擊傷害詞條
    public static func critDamage(_ value: Double) -> Affix {
        Affix(type: .critDamage, value: value, isPercentage: true)
    }
    
    /// 建立速度詞條
    public static func speed(_ value: Double, isPercentage: Bool = false) -> Affix {
        Affix(type: .speed, value: value, isPercentage: isPercentage)
    }
}

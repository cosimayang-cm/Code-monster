// MARK: - ItemAttribute
// Feature: 004-rpg-inventory-system
// 補充：完整屬性系統

import Foundation

/// 物品屬性 - 裝備上的特殊效果
public enum ItemAttributeType: Codable, Equatable, Hashable {
    
    /// A. 數值加成型 / B. 百分比加成型
    case statBonus(StatBonusAttribute)
    
    /// C. 元素附加型
    case element(ElementAttribute)
    
    /// D. 特殊效果型
    case special(SpecialEffectAttribute)
}

// MARK: - Stat Bonus Attribute

/// 數值加成屬性
public struct StatBonusAttribute: Codable, Equatable, Hashable {
    /// 加成的數值類型
    public let stat: String  // attack, defense, maxHP, etc.
    
    /// 加成數值
    public let value: Double
    
    /// 是否為百分比
    public let isPercentage: Bool
    
    public init(stat: String, value: Double, isPercentage: Bool = false) {
        self.stat = stat
        self.value = value
        self.isPercentage = isPercentage
    }
    
    /// 顯示文字
    public var displayText: String {
        let statName = statDisplayName
        if isPercentage {
            return "\(statName) +\(String(format: "%.1f", value))%"
        } else {
            return "\(statName) +\(Int(value))"
        }
    }
    
    private var statDisplayName: String {
        switch stat {
        case "attack": return "攻擊力"
        case "defense": return "防禦力"
        case "maxHP": return "生命值"
        case "maxMP": return "魔力值"
        case "critRate": return "暴擊率"
        case "critDamage": return "暴擊傷害"
        case "speed": return "速度"
        default: return stat
        }
    }
}

// MARK: - Element Attribute

/// 元素附加屬性
public struct ElementAttribute: Codable, Equatable, Hashable {
    /// 元素類型
    public let element: Element
    
    /// 元素傷害值
    public let value: Double
    
    public init(element: Element, value: Double) {
        self.element = element
        self.value = value
    }
    
    /// 顯示文字
    public var displayText: String {
        "附加 \(element.displayName)元素傷害 +\(Int(value))"
    }
}

// MARK: - Special Effect Attribute

/// 特殊效果屬性
public struct SpecialEffectAttribute: Codable, Equatable, Hashable {
    /// 效果類型
    public let effect: SpecialEffectType
    
    /// 效果數值
    public let value: Double
    
    public init(effect: SpecialEffectType, value: Double) {
        self.effect = effect
        self.value = value
    }
    
    /// 顯示文字
    public var displayText: String {
        "\(effect.displayName) \(Int(value))%"
    }
}

// MARK: - ItemAttributeType Extensions

extension ItemAttributeType {
    
    /// 顯示文字
    public var displayText: String {
        switch self {
        case .statBonus(let attr):
            return attr.displayText
        case .element(let attr):
            return attr.displayText
        case .special(let attr):
            return attr.displayText
        }
    }
    
    /// 類型名稱
    public var typeName: String {
        switch self {
        case .statBonus: return "stat_bonus"
        case .element: return "element"
        case .special: return "special"
        }
    }
}

// MARK: - Factory Methods

extension ItemAttributeType {
    
    /// 建立數值加成屬性
    public static func statBonus(_ stat: String, value: Double, isPercentage: Bool = false) -> ItemAttributeType {
        .statBonus(StatBonusAttribute(stat: stat, value: value, isPercentage: isPercentage))
    }
    
    /// 建立元素屬性
    public static func element(_ element: Element, value: Double) -> ItemAttributeType {
        .element(ElementAttribute(element: element, value: value))
    }
    
    /// 建立特殊效果屬性
    public static func special(_ effect: SpecialEffectType, value: Double) -> ItemAttributeType {
        .special(SpecialEffectAttribute(effect: effect, value: value))
    }
}

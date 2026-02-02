// MARK: - SpecialEffect
// Feature: 004-rpg-inventory-system
// 補充：特殊效果類型

import Foundation

/// 特殊效果類型
public enum SpecialEffectType: String, Codable, CaseIterable, Hashable {
    /// 吸血 - 造成傷害時回復生命
    case lifesteal
    
    /// 反傷 - 受到傷害時反彈部分傷害
    case reflect
    
    /// 荊棘 - 被攻擊時對攻擊者造成傷害
    case thorns
}

// MARK: - Display Properties

extension SpecialEffectType {
    
    /// 顯示名稱
    public var displayName: String {
        switch self {
        case .lifesteal: return "吸血"
        case .reflect: return "反傷"
        case .thorns: return "荊棘"
        }
    }
    
    /// 效果描述模板
    public var descriptionTemplate: String {
        switch self {
        case .lifesteal: return "造成傷害的%d%%轉換為生命值"
        case .reflect: return "反彈受到傷害的%d%%"
        case .thorns: return "被攻擊時對攻擊者造成%d點傷害"
        }
    }
}

/// 特殊效果實例
public struct SpecialEffect: Codable, Equatable, Hashable {
    /// 效果類型
    public let effectType: SpecialEffectType
    
    /// 效果數值
    public let value: Double
    
    /// 是否為百分比
    public let isPercentage: Bool
    
    public init(effectType: SpecialEffectType, value: Double, isPercentage: Bool = true) {
        self.effectType = effectType
        self.value = value
        self.isPercentage = isPercentage
    }
    
    /// 效果描述
    public var description: String {
        let valueStr = isPercentage ? "\(Int(value))%" : "\(Int(value))"
        return "\(effectType.displayName) \(valueStr)"
    }
}

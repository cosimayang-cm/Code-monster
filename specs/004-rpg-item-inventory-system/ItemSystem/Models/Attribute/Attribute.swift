import Foundation

/// 屬性協議（用於裝備的特殊屬性）
public protocol Attribute: Codable {
    /// 屬性類型標識
    var attributeType: String { get }

    /// 將屬性效果套用到數值
    func apply(to stats: inout Stats)
}

/// 屬性類型列舉（用於 JSON 解碼）
public enum AttributeType: String, Codable {
    case statBonus = "stat_bonus"
    case element = "element"
    case special = "special"
}

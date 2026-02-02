import Foundation

/// 數值類型
public enum StatType: String, Codable, CaseIterable, Sendable {
    case attack = "attack"
    case defense = "defense"
    case maxHP = "maxHP"
    case maxMP = "maxMP"
    case critRate = "critRate"
    case critDamage = "critDamage"
    case speed = "speed"
}

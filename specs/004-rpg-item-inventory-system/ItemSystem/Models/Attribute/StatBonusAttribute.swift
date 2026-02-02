import Foundation

/// 數值加成屬性
public struct StatBonusAttribute: Attribute, Equatable {
    public let attributeType: String = "stat_bonus"
    public let stat: StatType
    public let value: Double
    public let isPercentage: Bool

    public init(stat: StatType, value: Double, isPercentage: Bool) {
        self.stat = stat
        self.value = value
        self.isPercentage = isPercentage
    }

    /// 將數值加成套用到 Stats
    public func apply(to stats: inout Stats) {
        let bonus = isPercentage ? getStatValue(from: stats) * (value / 100) : value

        switch stat {
        case .attack:
            stats.attack += bonus
        case .defense:
            stats.defense += bonus
        case .maxHP:
            stats.maxHP += bonus
        case .maxMP:
            stats.maxMP += bonus
        case .critRate:
            stats.critRate += bonus
        case .critDamage:
            stats.critDamage += bonus
        case .speed:
            stats.speed += bonus
        }
    }

    private func getStatValue(from stats: Stats) -> Double {
        switch stat {
        case .attack: return stats.attack
        case .defense: return stats.defense
        case .maxHP: return stats.maxHP
        case .maxMP: return stats.maxMP
        case .critRate: return stats.critRate
        case .critDamage: return stats.critDamage
        case .speed: return stats.speed
        }
    }
}

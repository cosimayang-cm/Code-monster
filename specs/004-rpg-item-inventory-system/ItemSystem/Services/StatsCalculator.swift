import Foundation

/// 數值計算服務
public class StatsCalculator: StatsCalculating {

    public init() {}

    /// 計算角色總數值
    /// 公式：(基礎數值 + 固定加成) × (1 + 百分比加成總和)
    public func calculateTotalStats(for avatar: Avatar) -> Stats {
        var flatBonuses = Stats()
        var percentBonuses = Stats()

        // 累加所有裝備的加成
        for item in avatar.equipment.allEquipped {
            let (flat, percent) = calculateItemBonuses(item)
            flatBonuses = flatBonuses + flat
            percentBonuses = percentBonuses + percent
        }

        // 計算最終數值
        let baseStats = avatar.baseStats
        return Stats(
            attack: (baseStats.attack + flatBonuses.attack) * (1 + percentBonuses.attack / 100),
            defense: (baseStats.defense + flatBonuses.defense) * (1 + percentBonuses.defense / 100),
            maxHP: (baseStats.maxHP + flatBonuses.maxHP) * (1 + percentBonuses.maxHP / 100),
            maxMP: (baseStats.maxMP + flatBonuses.maxMP) * (1 + percentBonuses.maxMP / 100),
            critRate: baseStats.critRate + flatBonuses.critRate + percentBonuses.critRate,
            critDamage: baseStats.critDamage + flatBonuses.critDamage + percentBonuses.critDamage,
            speed: (baseStats.speed + flatBonuses.speed) * (1 + percentBonuses.speed / 100)
        )
    }

    /// 計算單件裝備的數值貢獻
    public func calculateItemStats(_ item: Item) -> Stats {
        var stats = item.template.baseStats

        // 加上主詞條
        let mainValue = calculateMainAffixValue(affix: item.mainAffix, level: item.level)
        stats = applyAffix(to: stats, affix: item.mainAffix, value: mainValue)

        // 加上副詞條
        for subAffix in item.subAffixes {
            stats = applyAffix(to: stats, affix: subAffix, value: subAffix.value)
        }

        return stats
    }

    /// 計算主詞條數值（含等級成長）
    /// 公式：基礎值 × (1 + (等級 - 1) × 0.1)
    public func calculateMainAffixValue(affix: Affix, level: Int) -> Double {
        let growthMultiplier = 1.0 + Double(level - 1) * 0.1
        return affix.value * growthMultiplier
    }

    // MARK: - Private Helpers

    /// 計算單件裝備的固定加成和百分比加成
    private func calculateItemBonuses(_ item: Item) -> (flat: Stats, percent: Stats) {
        var flat = item.template.baseStats
        var percent = Stats()

        // 主詞條
        let mainValue = calculateMainAffixValue(affix: item.mainAffix, level: item.level)
        if item.mainAffix.isPercentage {
            percent = applyAffixToStats(percent, type: item.mainAffix.type, value: mainValue)
        } else {
            flat = applyAffixToStats(flat, type: item.mainAffix.type, value: mainValue)
        }

        // 副詞條
        for subAffix in item.subAffixes {
            if subAffix.isPercentage {
                percent = applyAffixToStats(percent, type: subAffix.type, value: subAffix.value)
            } else {
                flat = applyAffixToStats(flat, type: subAffix.type, value: subAffix.value)
            }
        }

        return (flat, percent)
    }

    /// 將詞條加成套用到 Stats
    private func applyAffix(to stats: Stats, affix: Affix, value: Double) -> Stats {
        return applyAffixToStats(stats, type: affix.type, value: value)
    }

    /// 根據詞條類型更新對應的 Stats 欄位
    private func applyAffixToStats(_ stats: Stats, type: AffixType, value: Double) -> Stats {
        var result = stats

        if type.contains(.attack) {
            result.attack += value
        }
        if type.contains(.defense) {
            result.defense += value
        }
        if type.contains(.hp) {
            result.maxHP += value
        }
        if type.contains(.crit) {
            result.critRate += value
        }
        if type.contains(.energyRecharge) {
            result.maxMP += value
        }

        return result
    }
}

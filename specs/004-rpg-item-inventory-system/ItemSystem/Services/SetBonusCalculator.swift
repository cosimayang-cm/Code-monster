import Foundation

/// 套裝效果計算服務
public class SetBonusCalculator: SetBonusCalculating {

    public init() {}

    /// 計算角色穿戴裝備觸發的套裝效果
    public func calculateSetBonuses(for avatar: Avatar, sets: [EquipmentSet]) -> [ActiveSetBonus] {
        var activeBonuses: [ActiveSetBonus] = []

        // 統計每個套裝穿戴的件數
        let setCountMap = countEquippedSets(avatar: avatar, sets: sets)

        // 檢查每個套裝是否達到觸發條件
        for set in sets {
            let equippedCount = setCountMap[set.setId] ?? 0
            let triggeredBonuses = set.getActiveBonuses(equippedCount: equippedCount)

            for bonus in triggeredBonuses {
                activeBonuses.append(ActiveSetBonus(
                    set: set,
                    bonus: bonus,
                    equippedCount: equippedCount
                ))
            }
        }

        return activeBonuses
    }

    /// 統計每個套裝穿戴的件數
    private func countEquippedSets(avatar: Avatar, sets: [EquipmentSet]) -> [String: Int] {
        var countMap: [String: Int] = [:]

        for item in avatar.equipment.allEquipped {
            if let setId = item.setId {
                countMap[setId, default: 0] += 1
            }
        }

        return countMap
    }

    /// 將套裝效果轉換為 Stats 加成
    public func applySetBonusesToStats(bonuses: [ActiveSetBonus], baseStats: Stats) -> Stats {
        var flatBonus = Stats()
        var percentBonus = Stats()

        for activeBonus in bonuses {
            switch activeBonus.bonus.effect {
            case .statBonus(let stat, let value, let isPercentage):
                if isPercentage {
                    percentBonus = applyStatBonus(to: percentBonus, stat: stat, value: value)
                } else {
                    flatBonus = applyStatBonus(to: flatBonus, stat: stat, value: value)
                }
            default:
                // 其他效果類型需要特殊處理，這裡先跳過
                break
            }
        }

        // 套用公式：(基礎 + 固定) × (1 + 百分比)
        return Stats(
            attack: (baseStats.attack + flatBonus.attack) * (1 + percentBonus.attack / 100),
            defense: (baseStats.defense + flatBonus.defense) * (1 + percentBonus.defense / 100),
            maxHP: (baseStats.maxHP + flatBonus.maxHP) * (1 + percentBonus.maxHP / 100),
            maxMP: (baseStats.maxMP + flatBonus.maxMP) * (1 + percentBonus.maxMP / 100),
            critRate: baseStats.critRate + flatBonus.critRate + percentBonus.critRate,
            critDamage: baseStats.critDamage + flatBonus.critDamage + percentBonus.critDamage,
            speed: (baseStats.speed + flatBonus.speed) * (1 + percentBonus.speed / 100)
        )
    }

    private func applyStatBonus(to stats: Stats, stat: StatType, value: Double) -> Stats {
        var result = stats
        switch stat {
        case .attack:
            result.attack += value
        case .defense:
            result.defense += value
        case .maxHP:
            result.maxHP += value
        case .maxMP:
            result.maxMP += value
        case .critRate:
            result.critRate += value
        case .critDamage:
            result.critDamage += value
        case .speed:
            result.speed += value
        }
        return result
    }
}

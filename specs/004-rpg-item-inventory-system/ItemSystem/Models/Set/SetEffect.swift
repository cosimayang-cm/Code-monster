import Foundation

/// 套裝效果類型
public enum SetEffect: Codable, Equatable {
    /// 數值加成：如「HP +20%」
    case statBonus(stat: StatType, value: Double, isPercentage: Bool)

    /// 團隊增益：如「隊伍攻擊力 +20% 持續 12 秒」
    case teamBuff(stat: StatType, value: Double, isPercentage: Bool, duration: Int, trigger: String)

    /// 條件觸發：如「對火元素敵人傷害 +35%」
    case conditional(condition: String, effect: String)

    /// 元素反應加成
    case elementalReaction(element: Element, bonus: Double)
}

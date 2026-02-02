import Foundation

/// 稀有度
public enum Rarity: String, Codable, CaseIterable, Sendable {
    case common = "common"
    case uncommon = "uncommon"
    case rare = "rare"
    case epic = "epic"
    case legendary = "legendary"

    /// 初始副詞條數量
    public var subAffixCount: Int {
        switch self {
        case .common: return 0
        case .uncommon: return 1
        case .rare: return 2
        case .epic: return 3
        case .legendary: return 4
        }
    }

    /// 最大副詞條數量
    public var maxSubAffixCount: Int {
        switch self {
        case .common: return 0
        case .uncommon: return 2
        case .rare: return 3
        case .epic: return 4
        case .legendary: return 4
        }
    }
}

import Foundation

/// 詞條類型（Bitmask 實作）
public struct AffixType: OptionSet, Codable, Hashable, Sendable {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    // 基礎詞條類型
    public static let crit             = AffixType(rawValue: 1 << 0)  // 0b0000_0001
    public static let energyRecharge   = AffixType(rawValue: 1 << 1)  // 0b0000_0010
    public static let attack           = AffixType(rawValue: 1 << 2)  // 0b0000_0100
    public static let defense          = AffixType(rawValue: 1 << 3)  // 0b0000_1000
    public static let hp               = AffixType(rawValue: 1 << 4)  // 0b0001_0000
    public static let elementalMastery = AffixType(rawValue: 1 << 5)  // 0b0010_0000
    public static let elementalDamage  = AffixType(rawValue: 1 << 6)  // 0b0100_0000
    public static let healingBonus     = AffixType(rawValue: 1 << 7)  // 0b1000_0000

    // 複合類型
    public static let offensive: AffixType = [.crit, .attack, .elementalDamage]
    public static let defensive: AffixType = [.defense, .hp, .healingBonus]
}

import Foundation

/// 詞條（主詞條/副詞條）
public struct Affix: Codable, Equatable, Sendable {
    public let type: AffixType
    public let value: Double
    public let isPercentage: Bool

    public init(type: AffixType, value: Double, isPercentage: Bool) {
        self.type = type
        self.value = value
        self.isPercentage = isPercentage
    }

    /// 計算實際加成值
    /// - Parameter baseValue: 基礎數值
    /// - Returns: 實際加成值
    public func calculateBonus(baseValue: Double) -> Double {
        if isPercentage {
            return baseValue * (value / 100.0)
        } else {
            return value
        }
    }
}

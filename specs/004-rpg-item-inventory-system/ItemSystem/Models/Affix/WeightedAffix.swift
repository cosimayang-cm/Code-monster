import Foundation

/// 帶權重的詞條配置（用於隨機生成）
public struct WeightedAffix: Codable, Sendable {
    public let type: AffixType
    public let weight: Int
    public let minValue: Double
    public let maxValue: Double
    public let isPercentage: Bool

    public init(type: AffixType, weight: Int, minValue: Double, maxValue: Double, isPercentage: Bool) {
        self.type = type
        self.weight = weight
        self.minValue = minValue
        self.maxValue = maxValue
        self.isPercentage = isPercentage
    }
}

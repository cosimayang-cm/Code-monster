import Foundation

/// 特殊效果屬性
public struct SpecialAttribute: Attribute, Equatable {
    public let attributeType: String = "special"
    public let effect: SpecialEffect
    public let value: Double

    public init(effect: SpecialEffect, value: Double) {
        self.effect = effect
        self.value = value
    }

    /// 特殊效果目前不直接影響基礎數值
    /// 實際效果需在戰鬥系統中處理
    public func apply(to stats: inout Stats) {
        // 特殊效果（吸血、反傷等）需要戰鬥系統計算
        // 這裡保留空實作
    }
}

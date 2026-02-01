import Foundation

/// 詞條池（定義特定裝備欄位的詞條配置）
public struct AffixPool: Codable, Sendable {
    public let slot: EquipmentSlot
    public let mainAffixPool: [WeightedAffix]
    public let subAffixPool: [WeightedAffix]

    public init(slot: EquipmentSlot, mainAffixPool: [WeightedAffix], subAffixPool: [WeightedAffix]) {
        self.slot = slot
        self.mainAffixPool = mainAffixPool
        self.subAffixPool = subAffixPool
    }
}

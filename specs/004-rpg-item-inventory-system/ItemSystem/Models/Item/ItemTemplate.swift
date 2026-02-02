import Foundation

/// 物品模板（定義物品基礎屬性）
public struct ItemTemplate: Codable, Identifiable, Sendable {
    public let templateId: String
    public let name: String
    public let description: String
    public let slot: EquipmentSlot
    public let rarity: Rarity
    public let levelRequirement: Int
    public let baseStats: Stats
    public let attributes: [String] // 簡化實作，暫時使用 String array
    public let setId: String?
    public let iconAsset: String?
    public let modelAsset: String?

    public var id: String { templateId }

    public init(
        templateId: String,
        name: String,
        description: String,
        slot: EquipmentSlot,
        rarity: Rarity,
        levelRequirement: Int,
        baseStats: Stats,
        attributes: [String] = [],
        setId: String? = nil,
        iconAsset: String? = nil,
        modelAsset: String? = nil
    ) {
        self.templateId = templateId
        self.name = name
        self.description = description
        self.slot = slot
        self.rarity = rarity
        self.levelRequirement = levelRequirement
        self.baseStats = baseStats
        self.attributes = attributes
        self.setId = setId
        self.iconAsset = iconAsset
        self.modelAsset = modelAsset
    }
}

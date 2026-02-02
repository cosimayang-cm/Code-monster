import Foundation

/// 物品實例（每個實例有唯一 UUID）
public final class Item: Codable, Identifiable, Equatable, @unchecked Sendable {
    public let instanceId: UUID
    public let templateId: String
    public private(set) var level: Int
    public let mainAffix: Affix
    public let subAffixes: [Affix]
    public private(set) var affixMask: AffixType

    // Computed properties (simplified without TemplateRegistry for now)
    public var id: UUID { instanceId }

    public init(template: ItemTemplate, mainAffix: Affix, subAffixes: [Affix]) {
        self.instanceId = UUID()
        self.templateId = template.templateId
        self.level = 1
        self.mainAffix = mainAffix
        self.subAffixes = subAffixes
        self.affixMask = Self.calculateMask(mainAffix: mainAffix, subAffixes: subAffixes)
        self._cachedTemplate = template
    }

    // Cache template for testing (in real implementation, use TemplateRegistry)
    private var _cachedTemplate: ItemTemplate?

    public var template: ItemTemplate {
        _cachedTemplate!
    }

    public var name: String { template.name }
    public var slot: EquipmentSlot { template.slot }
    public var rarity: Rarity { template.rarity }
    public var setId: String? { template.setId }

    /// 升級物品
    public func levelUp() {
        level += 1
    }

    /// 計算詞條 Bitmask
    private static func calculateMask(mainAffix: Affix, subAffixes: [Affix]) -> AffixType {
        var mask = mainAffix.type
        for affix in subAffixes {
            mask.insert(affix.type)
        }
        return mask
    }

    public static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.instanceId == rhs.instanceId
    }

    // Codable support
    enum CodingKeys: String, CodingKey {
        case instanceId, templateId, level, mainAffix, subAffixes, affixMask
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.instanceId = try container.decode(UUID.self, forKey: .instanceId)
        self.templateId = try container.decode(String.self, forKey: .templateId)
        self.level = try container.decode(Int.self, forKey: .level)
        self.mainAffix = try container.decode(Affix.self, forKey: .mainAffix)
        self.subAffixes = try container.decode([Affix].self, forKey: .subAffixes)
        self.affixMask = try container.decode(AffixType.self, forKey: .affixMask)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(instanceId, forKey: .instanceId)
        try container.encode(templateId, forKey: .templateId)
        try container.encode(level, forKey: .level)
        try container.encode(mainAffix, forKey: .mainAffix)
        try container.encode(subAffixes, forKey: .subAffixes)
        try container.encode(affixMask, forKey: .affixMask)
    }
}

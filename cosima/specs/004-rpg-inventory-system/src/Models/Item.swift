// MARK: - Item
// Feature: 004-rpg-inventory-system
// Task: TASK-012, TASK-014

import Foundation

/// 物品實例 - 從模板生成的實際物品
public final class Item: AffixContainer {
    
    // MARK: - Properties
    
    /// 實例唯一識別碼 (UUID v4)
    public let instanceId: UUID
    
    /// 模板 ID
    public let templateId: String
    
    /// 顯示名稱
    public let name: String
    
    /// 物品描述
    public let description: String
    
    /// 裝備欄位
    public let slot: EquipmentSlot
    
    /// 稀有度
    public let rarity: Rarity
    
    /// 當前等級
    public private(set) var level: Int
    
    /// 最大等級
    public let maxLevel: Int
    
    /// 等級需求
    public let levelRequirement: Int
    
    /// 套裝 ID（可選）
    public let setId: String?
    
    /// 基礎數值
    public let baseStats: Stats
    
    /// 特殊屬性
    public let attributes: [ItemAttribute]
    
    /// 主詞條
    public let mainAffix: Affix
    
    /// 副詞條列表
    public private(set) var subAffixes: [Affix]
    
    /// 詞條 Bitmask
    public private(set) var affixMask: AffixType
    
    // MARK: - Initialization
    
    public init(
        instanceId: UUID = UUID(),
        templateId: String,
        name: String,
        description: String,
        slot: EquipmentSlot,
        rarity: Rarity,
        level: Int = 1,
        maxLevel: Int = 20,
        levelRequirement: Int = 1,
        setId: String? = nil,
        baseStats: Stats = .zero,
        attributes: [ItemAttribute] = [],
        mainAffix: Affix,
        subAffixes: [Affix] = []
    ) {
        self.instanceId = instanceId
        self.templateId = templateId
        self.name = name
        self.description = description
        self.slot = slot
        self.rarity = rarity
        self.level = level
        self.maxLevel = maxLevel
        self.levelRequirement = levelRequirement
        self.setId = setId
        self.baseStats = baseStats
        self.attributes = attributes
        self.mainAffix = mainAffix
        self.subAffixes = subAffixes
        self.affixMask = buildAffixMask(mainAffix: mainAffix, subAffixes: subAffixes)
    }
    
    /// 從模板建立
    public convenience init(
        template: ItemTemplate,
        mainAffix: Affix,
        subAffixes: [Affix] = []
    ) {
        self.init(
            templateId: template.templateId,
            name: template.name,
            description: template.description,
            slot: template.slot,
            rarity: template.rarity,
            maxLevel: template.maxLevel,
            levelRequirement: template.levelRequirement,
            setId: template.setId,
            baseStats: template.baseStats,
            attributes: template.attributes,
            mainAffix: mainAffix,
            subAffixes: subAffixes
        )
    }
}

// MARK: - Identifiable

extension Item: Identifiable {
    public var id: UUID { instanceId }
}

// MARK: - Equatable & Hashable

extension Item: Equatable {
    public static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.instanceId == rhs.instanceId
    }
}

extension Item: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(instanceId)
    }
}

// MARK: - Upgradable

extension Item {
    
    /// 是否可升級
    public var canUpgrade: Bool {
        level < maxLevel
    }
    
    /// 執行升級
    /// - Throws: `ItemError.maxLevelReached` 如果已達最大等級
    public func upgrade() throws {
        guard canUpgrade else {
            throw ItemError.maxLevelReached(current: level, max: maxLevel)
        }
        
        level += 1
        
        // 每 4 級處理副詞條
        if level % 4 == 0 {
            handleSubAffixUpgrade()
        }
    }
    
    /// 處理副詞條升級
    private func handleSubAffixUpgrade() {
        let maxSubAffixes = rarity.maxSubAffixCount
        
        if subAffixes.count < maxSubAffixes {
            // 新增副詞條
            addRandomSubAffix()
        } else {
            // 強化現有副詞條
            upgradeRandomSubAffix()
        }
    }
    
    /// 新增隨機副詞條
    private func addRandomSubAffix() {
        let newTypes = AffixPool.shared.randomSubAffixes(
            count: 1,
            excludingMask: affixMask
        )
        
        guard let newType = newTypes.first,
              let newAffix = AffixValueCalculator.generateSubAffix(type: newType) else {
            return
        }
        
        subAffixes.append(newAffix)
        affixMask.insert(newType)
    }
    
    /// 強化隨機副詞條
    private func upgradeRandomSubAffix() {
        guard let index = AffixValueCalculator.selectSubAffixToUpgrade(from: subAffixes) else {
            return
        }
        
        subAffixes[index] = AffixValueCalculator.upgradeSubAffix(subAffixes[index])
    }
}

// MARK: - Equippable

extension Item {
    
    /// 檢查角色是否可裝備
    /// - Parameter characterLevel: 角色等級
    /// - Returns: 是否可裝備
    public func canEquip(characterLevel: Int) -> Bool {
        characterLevel >= levelRequirement
    }
}

// MARK: - StatProvider

extension Item {
    
    /// 計算總數值（基礎 + 詞條 + 等級加成）
    /// - Parameter characterBaseStats: 角色基礎數值
    /// - Returns: 總數值
    public func calculateTotalStats(characterBaseStats: Stats = .zero) -> Stats {
        // 基礎數值乘以等級係數
        let levelMultiplier = 1.0 + (Double(level - 1) * 0.1)
        var total = baseStats * levelMultiplier
        
        // 加上詞條數值
        total += calculateAffixStats(baseStats: characterBaseStats)
        
        return total
    }
}

// MARK: - Computed Properties

extension Item {
    
    /// 是否為套裝物品
    public var isSetItem: Bool {
        setId != nil
    }
    
    /// 是否為滿級
    public var isMaxLevel: Bool {
        level >= maxLevel
    }
    
    /// 升級進度 (0.0 ~ 1.0)
    public var upgradeProgress: Double {
        Double(level - 1) / Double(maxLevel - 1)
    }
    
    /// 當前等級的主詞條數值
    public var currentMainAffix: Affix {
        AffixValueCalculator.calculateMainAffixAtLevel(mainAffix, itemLevel: level)
    }
}

// MARK: - Sub-Affix Management

extension Item {
    
    /// 手動新增副詞條
    /// - Parameter affix: 要新增的詞條
    /// - Throws: `ItemError` 如果副詞條已滿或類型重複
    public func addSubAffix(_ affix: Affix) throws {
        guard subAffixes.count < rarity.maxSubAffixCount else {
            throw ItemError.maxSubAffixesReached(
                current: subAffixes.count,
                max: rarity.maxSubAffixCount
            )
        }
        
        guard !affixMask.contains(affix.type) else {
            throw ItemError.duplicateAffixType(type: affix.type)
        }
        
        subAffixes.append(affix)
        affixMask.insert(affix.type)
    }
}

// MARK: - Codable

extension Item: Codable {
    
    enum CodingKeys: String, CodingKey {
        case instanceId, templateId, name, description
        case slot, rarity, level, maxLevel, levelRequirement
        case setId, baseStats, attributes
        case mainAffix, subAffixes, affixMask
    }
    
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let instanceId = try container.decode(UUID.self, forKey: .instanceId)
        let templateId = try container.decode(String.self, forKey: .templateId)
        let name = try container.decode(String.self, forKey: .name)
        let description = try container.decode(String.self, forKey: .description)
        let slot = try container.decode(EquipmentSlot.self, forKey: .slot)
        let rarity = try container.decode(Rarity.self, forKey: .rarity)
        let level = try container.decode(Int.self, forKey: .level)
        let maxLevel = try container.decode(Int.self, forKey: .maxLevel)
        let levelRequirement = try container.decode(Int.self, forKey: .levelRequirement)
        let setId = try container.decodeIfPresent(String.self, forKey: .setId)
        let baseStats = try container.decode(Stats.self, forKey: .baseStats)
        let attributes = try container.decode([ItemAttribute].self, forKey: .attributes)
        let mainAffix = try container.decode(Affix.self, forKey: .mainAffix)
        let subAffixes = try container.decode([Affix].self, forKey: .subAffixes)
        
        self.init(
            instanceId: instanceId,
            templateId: templateId,
            name: name,
            description: description,
            slot: slot,
            rarity: rarity,
            level: level,
            maxLevel: maxLevel,
            levelRequirement: levelRequirement,
            setId: setId,
            baseStats: baseStats,
            attributes: attributes,
            mainAffix: mainAffix,
            subAffixes: subAffixes
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(instanceId, forKey: .instanceId)
        try container.encode(templateId, forKey: .templateId)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(slot, forKey: .slot)
        try container.encode(rarity, forKey: .rarity)
        try container.encode(level, forKey: .level)
        try container.encode(maxLevel, forKey: .maxLevel)
        try container.encode(levelRequirement, forKey: .levelRequirement)
        try container.encodeIfPresent(setId, forKey: .setId)
        try container.encode(baseStats, forKey: .baseStats)
        try container.encode(attributes, forKey: .attributes)
        try container.encode(mainAffix, forKey: .mainAffix)
        try container.encode(subAffixes, forKey: .subAffixes)
        try container.encode(affixMask, forKey: .affixMask)
    }
}

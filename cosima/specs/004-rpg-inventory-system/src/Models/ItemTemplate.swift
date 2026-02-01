// MARK: - ItemTemplate
// Feature: 004-rpg-inventory-system
// Task: TASK-011

import Foundation

/// 物品屬性定義
public enum ItemAttribute: String, Codable, Equatable {
    /// 不可交易
    case untradeable
    
    /// 不可分解
    case indestructible
    
    /// 限時物品
    case timeLimited
    
    /// 活動限定
    case eventExclusive
}

/// 物品模板 - 作為生成物品實例的藍圖
public struct ItemTemplate: Codable, Equatable {
    
    // MARK: - Properties
    
    /// 模板唯一識別碼
    public let templateId: String
    
    /// 顯示名稱
    public let name: String
    
    /// 物品描述
    public let description: String
    
    /// 裝備欄位
    public let slot: EquipmentSlot
    
    /// 稀有度
    public let rarity: Rarity
    
    /// 等級需求
    public let levelRequirement: Int
    
    /// 基礎數值
    public let baseStats: Stats
    
    /// 特殊屬性
    public let attributes: [ItemAttribute]
    
    /// 套裝 ID（可選）
    public let setId: String?
    
    /// 圖示資源名稱
    public let iconAsset: String?
    
    /// 3D 模型資源名稱
    public let modelAsset: String?
    
    /// 最大等級
    public let maxLevel: Int
    
    // MARK: - Initialization
    
    public init(
        templateId: String,
        name: String,
        description: String,
        slot: EquipmentSlot,
        rarity: Rarity,
        levelRequirement: Int = 1,
        baseStats: Stats = .zero,
        attributes: [ItemAttribute] = [],
        setId: String? = nil,
        iconAsset: String? = nil,
        modelAsset: String? = nil,
        maxLevel: Int = 20
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
        self.maxLevel = maxLevel
    }
}

// MARK: - Identifiable

extension ItemTemplate: Identifiable {
    public var id: String { templateId }
}

// MARK: - Validation

extension ItemTemplate {
    
    /// 驗證模板是否有效
    /// - Returns: 驗證結果
    public func validate() -> ValidationResult {
        var errors: [String] = []
        
        if templateId.isEmpty {
            errors.append("模板 ID 不能為空")
        }
        
        if name.isEmpty {
            errors.append("名稱不能為空")
        }
        
        if levelRequirement < 1 {
            errors.append("等級需求必須 >= 1")
        }
        
        if maxLevel < 1 {
            errors.append("最大等級必須 >= 1")
        }
        
        return errors.isEmpty ? .valid : .invalid(errors)
    }
    
    /// 驗證結果
    public enum ValidationResult: Equatable {
        case valid
        case invalid([String])
        
        public var isValid: Bool {
            if case .valid = self { return true }
            return false
        }
    }
}

// MARK: - Computed Properties

extension ItemTemplate {
    
    /// 是否為套裝物品
    public var isSetItem: Bool {
        setId != nil
    }
    
    /// 初始副詞條數量
    public var initialSubAffixCount: Int {
        rarity.initialSubAffixCount
    }
    
    /// 最大副詞條數量
    public var maxSubAffixCount: Int {
        rarity.maxSubAffixCount
    }
    
    /// 是否可擁有副詞條
    public var canHaveSubAffixes: Bool {
        rarity.canHaveSubAffixes
    }
    
    /// 是否不可交易
    public var isUntradeable: Bool {
        attributes.contains(.untradeable)
    }
    
    /// 是否不可分解
    public var isIndestructible: Bool {
        attributes.contains(.indestructible)
    }
}

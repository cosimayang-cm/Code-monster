// MARK: - SetBonus
// Feature: 004-rpg-inventory-system
// Task: TASK-017

import Foundation

/// 套裝效果
public struct SetBonus: Codable, Equatable {
    
    // MARK: - Properties
    
    /// 所需件數
    public let requiredPieces: Int
    
    /// 效果內容
    public let effect: SetBonusEffect
    
    /// 效果描述
    public let description: String
    
    // MARK: - Initialization
    
    public init(
        requiredPieces: Int,
        effect: SetBonusEffect,
        description: String
    ) {
        self.requiredPieces = requiredPieces
        self.effect = effect
        self.description = description
    }
}

// MARK: - SetBonusEffect

/// 套裝效果類型
public enum SetBonusEffect: Codable, Equatable {
    
    /// 數值加成
    case statBonus(StatBonusEffect)
    
    /// 隊伍增益
    case teamBuff(TeamBuffEffect)
    
    /// 條件觸發
    case conditional(ConditionalEffect)
    
    /// 元素反應增強
    case elementalReaction(ElementalReactionEffect)
    
    /// 特殊效果
    case specialEffect(SpecialEffect)
    
    // MARK: - Stat Bonus Effect
    
    /// 數值加成效果
    public struct StatBonusEffect: Codable, Equatable {
        /// 加成的數值類型
        public let stat: StatType
        
        /// 加成數值
        public let value: Double
        
        /// 是否為百分比
        public let isPercentage: Bool
        
        public init(stat: StatType, value: Double, isPercentage: Bool = false) {
            self.stat = stat
            self.value = value
            self.isPercentage = isPercentage
        }
    }
    
    /// 數值類型
    public enum StatType: String, Codable {
        case attack
        case defense
        case hp
        case mp
        case critRate
        case critDamage
        case speed
        case elementalDamage
        case healingBonus
    }
    
    // MARK: - Special Effect
    
    /// 特殊效果
    public struct SpecialEffect: Codable, Equatable {
        /// 效果 ID
        public let effectId: String
        
        /// 效果參數
        public let parameters: [String: Double]
        
        public init(effectId: String, parameters: [String: Double] = [:]) {
            self.effectId = effectId
            self.parameters = parameters
        }
    }
    
    // MARK: - Team Buff Effect (新增)
    
    /// 隊伍增益效果
    public struct TeamBuffEffect: Codable, Equatable {
        /// 加成的數值類型
        public let stat: StatType
        
        /// 加成數值
        public let value: Double
        
        /// 是否為百分比
        public let isPercentage: Bool
        
        /// 持續時間（秒）
        public let duration: Double
        
        /// 觸發條件
        public let trigger: TriggerType
        
        public init(stat: StatType, value: Double, isPercentage: Bool = true, duration: Double, trigger: TriggerType) {
            self.stat = stat
            self.value = value
            self.isPercentage = isPercentage
            self.duration = duration
            self.trigger = trigger
        }
    }
    
    /// 觸發類型
    public enum TriggerType: String, Codable {
        case onElementalBurst = "onElementalBurst"
        case onElementalSkill = "onElementalSkill"
        case onNormalAttack = "onNormalAttack"
        case onTakeDamage = "onTakeDamage"
        case onHeal = "onHeal"
        case always = "always"
    }
    
    // MARK: - Conditional Effect (新增)
    
    /// 條件觸發效果
    public struct ConditionalEffect: Codable, Equatable {
        /// 觸發條件
        public let condition: ConditionType
        
        /// 條件閾值
        public let threshold: Double
        
        /// 效果類型
        public let stat: StatType
        
        /// 效果數值
        public let value: Double
        
        /// 是否為百分比
        public let isPercentage: Bool
        
        public init(condition: ConditionType, threshold: Double, stat: StatType, value: Double, isPercentage: Bool = true) {
            self.condition = condition
            self.threshold = threshold
            self.stat = stat
            self.value = value
            self.isPercentage = isPercentage
        }
    }
    
    /// 條件類型
    public enum ConditionType: String, Codable {
        case hpBelow = "hpBelow"
        case hpAbove = "hpAbove"
        case enemyCount = "enemyCount"
        case criticalHit = "criticalHit"
        case elementalReaction = "elementalReaction"
    }
    
    // MARK: - Elemental Reaction Effect (新增)
    
    /// 元素反應增強效果
    public struct ElementalReactionEffect: Codable, Equatable {
        /// 反應類型
        public let reactionType: ReactionType
        
        /// 傷害加成
        public let damageBonus: Double
        
        /// 是否為百分比
        public let isPercentage: Bool
        
        public init(reactionType: ReactionType, damageBonus: Double, isPercentage: Bool = true) {
            self.reactionType = reactionType
            self.damageBonus = damageBonus
            self.isPercentage = isPercentage
        }
    }
    
    /// 元素反應類型
    public enum ReactionType: String, Codable {
        case vaporize = "vaporize"       // 蒸發
        case melt = "melt"               // 融化
        case overloaded = "overloaded"   // 超載
        case superconduct = "superconduct" // 超導
        case electroCharged = "electroCharged" // 感電
        case frozen = "frozen"           // 冰凍
        case swirl = "swirl"             // 擴散
    }
}

// MARK: - Stats Conversion

extension SetBonusEffect {
    
    /// 轉換為 Stats（僅適用於 statBonus）
    /// - Parameter baseStats: 基礎數值（用於百分比計算）
    /// - Returns: Stats 加成
    public func toStats(baseStats: Stats = .zero) -> Stats {
        switch self {
        case .statBonus(let effect):
            return calculateStatBonus(effect, baseStats: baseStats)
        case .teamBuff(let effect):
            return calculateTeamBuff(effect, baseStats: baseStats)
        case .conditional(let effect):
            return calculateConditional(effect, baseStats: baseStats)
        case .elementalReaction, .specialEffect:
            return .zero
        }
    }
    
    private func calculateStatBonus(_ effect: StatBonusEffect, baseStats: Stats) -> Stats {
        var stats = Stats.zero
        let value = effect.isPercentage ? effect.value / 100.0 : effect.value
        
        switch effect.stat {
        case .attack:
            stats.attack = effect.isPercentage ? baseStats.attack * value : value
        case .defense:
            stats.defense = effect.isPercentage ? baseStats.defense * value : value
        case .hp:
            stats.maxHP = effect.isPercentage ? baseStats.maxHP * value : value
        case .mp:
            stats.maxMP = effect.isPercentage ? baseStats.maxMP * value : value
        case .critRate:
            stats.critRate = value
        case .critDamage:
            stats.critDamage = value
        case .speed:
            stats.speed = effect.isPercentage ? baseStats.speed * value : value
        case .elementalDamage, .healingBonus:
            break
        }
        
        return stats
    }
    
    private func calculateTeamBuff(_ effect: TeamBuffEffect, baseStats: Stats) -> Stats {
        // 隊伍 Buff 的數值計算（簡化版，實際需考慮觸發條件）
        var stats = Stats.zero
        let value = effect.isPercentage ? effect.value / 100.0 : effect.value
        
        switch effect.stat {
        case .attack:
            stats.attack = effect.isPercentage ? baseStats.attack * value : value
        case .defense:
            stats.defense = effect.isPercentage ? baseStats.defense * value : value
        default:
            break
        }
        
        return stats
    }
    
    private func calculateConditional(_ effect: ConditionalEffect, baseStats: Stats) -> Stats {
        // 條件效果需要遊戲狀態判斷，這裡返回零值
        // 實際使用時需要額外的狀態管理
        return .zero
    }
}

// MARK: - Factory Methods

extension SetBonus {
    
    /// 建立攻擊力加成效果
    public static func attackBonus(
        requiredPieces: Int,
        value: Double,
        isPercentage: Bool = true
    ) -> SetBonus {
        let effect = SetBonusEffect.statBonus(
            .init(stat: .attack, value: value, isPercentage: isPercentage)
        )
        let desc = isPercentage ? "攻擊力提升\(Int(value))%" : "攻擊力+\(Int(value))"
        return SetBonus(requiredPieces: requiredPieces, effect: effect, description: desc)
    }
    
    /// 建立暴擊率加成效果
    public static func critRateBonus(requiredPieces: Int, value: Double) -> SetBonus {
        let effect = SetBonusEffect.statBonus(
            .init(stat: .critRate, value: value, isPercentage: true)
        )
        return SetBonus(
            requiredPieces: requiredPieces,
            effect: effect,
            description: "暴擊率提升\(Int(value))%"
        )
    }
    
    /// 建立暴擊傷害加成效果
    public static func critDamageBonus(requiredPieces: Int, value: Double) -> SetBonus {
        let effect = SetBonusEffect.statBonus(
            .init(stat: .critDamage, value: value, isPercentage: true)
        )
        return SetBonus(
            requiredPieces: requiredPieces,
            effect: effect,
            description: "暴擊傷害提升\(Int(value))%"
        )
    }
    
    /// 建立生命值加成效果
    public static func hpBonus(
        requiredPieces: Int,
        value: Double,
        isPercentage: Bool = true
    ) -> SetBonus {
        let effect = SetBonusEffect.statBonus(
            .init(stat: .hp, value: value, isPercentage: isPercentage)
        )
        let desc = isPercentage ? "生命值提升\(Int(value))%" : "生命值+\(Int(value))"
        return SetBonus(requiredPieces: requiredPieces, effect: effect, description: desc)
    }
}

// MARK: - ActiveSetBonus

/// 已啟動的套裝效果
public struct ActiveSetBonus: Equatable {
    /// 套裝 ID
    public let setId: String
    
    /// 套裝名稱
    public let setName: String
    
    /// 已裝備件數
    public let equippedPieces: Int
    
    /// 啟動的效果門檻
    public let requiredPieces: Int
    
    /// 效果內容
    public let effect: SetBonusEffect
    
    /// 效果描述
    public let description: String
    
    public init(
        setId: String,
        setName: String,
        equippedPieces: Int,
        requiredPieces: Int,
        effect: SetBonusEffect,
        description: String
    ) {
        self.setId = setId
        self.setName = setName
        self.equippedPieces = equippedPieces
        self.requiredPieces = requiredPieces
        self.effect = effect
        self.description = description
    }
}

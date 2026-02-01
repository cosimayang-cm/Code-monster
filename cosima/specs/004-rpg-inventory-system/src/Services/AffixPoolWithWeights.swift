// MARK: - AffixPoolWithWeights
// Feature: 004-rpg-inventory-system
// 補充：詞條權重系統

import Foundation

/// 詞條權重條目
public struct AffixWeightEntry: Codable, Equatable {
    /// 詞條類型
    public let type: AffixType
    
    /// 權重值
    public let weight: Int
    
    public init(type: AffixType, weight: Int) {
        self.type = type
        self.weight = weight
    }
}

/// 帶權重的詞條池
public struct WeightedAffixPool: Codable {
    /// 主詞條池
    public let mainAffixPool: [AffixWeightEntry]
    
    /// 副詞條池
    public let subAffixPool: [AffixWeightEntry]
    
    public init(mainAffixPool: [AffixWeightEntry], subAffixPool: [AffixWeightEntry]) {
        self.mainAffixPool = mainAffixPool
        self.subAffixPool = subAffixPool
    }
    
    /// 主詞條總權重
    public var mainAffixTotalWeight: Int {
        mainAffixPool.reduce(0) { $0 + $1.weight }
    }
    
    /// 副詞條總權重
    public var subAffixTotalWeight: Int {
        subAffixPool.reduce(0) { $0 + $1.weight }
    }
    
    /// 根據權重隨機選取主詞條
    public func randomMainAffix() -> AffixType? {
        randomSelectByWeight(from: mainAffixPool)
    }
    
    /// 根據權重隨機選取副詞條
    /// - Parameter excluding: 要排除的類型
    public func randomSubAffix(excluding: AffixType = .none) -> AffixType? {
        let filtered = subAffixPool.filter { !excluding.contains($0.type) }
        return randomSelectByWeight(from: filtered)
    }
    
    /// 根據權重隨機選取多個副詞條
    /// - Parameters:
    ///   - count: 需要的數量
    ///   - excluding: 要排除的類型
    public func randomSubAffixes(count: Int, excluding: AffixType = .none) -> [AffixType] {
        var result: [AffixType] = []
        var excludeMask = excluding
        
        for _ in 0..<count {
            guard let selected = randomSubAffix(excluding: excludeMask) else { break }
            result.append(selected)
            excludeMask.insert(selected)
        }
        
        return result
    }
    
    /// 計算特定詞條的出現機率
    /// - Parameters:
    ///   - type: 詞條類型
    ///   - isMain: 是否為主詞條
    public func probability(of type: AffixType, isMain: Bool) -> Double {
        let pool = isMain ? mainAffixPool : subAffixPool
        let totalWeight = isMain ? mainAffixTotalWeight : subAffixTotalWeight
        
        guard totalWeight > 0 else { return 0 }
        
        let typeWeight = pool.first { $0.type == type }?.weight ?? 0
        return Double(typeWeight) / Double(totalWeight)
    }
    
    // MARK: - Private
    
    private func randomSelectByWeight(from pool: [AffixWeightEntry]) -> AffixType? {
        let totalWeight = pool.reduce(0) { $0 + $1.weight }
        guard totalWeight > 0 else { return nil }
        
        var random = Int.random(in: 0..<totalWeight)
        
        for entry in pool {
            random -= entry.weight
            if random < 0 {
                return entry.type
            }
        }
        
        return pool.last?.type
    }
}

// MARK: - Slot-based Affix Pool

/// 各欄位的詞條池配置
public final class SlotAffixPoolConfig {
    
    public static let shared = SlotAffixPoolConfig()
    
    /// 各欄位的詞條池
    private var pools: [EquipmentSlot: WeightedAffixPool] = [:]
    
    private init() {
        setupDefaultPools()
    }
    
    /// 設定預設詞條池
    private func setupDefaultPools() {
        // 頭盔詞條池
        pools[.helmet] = WeightedAffixPool(
            mainAffixPool: [
                AffixWeightEntry(type: .hp, weight: 30),
                AffixWeightEntry(type: .attack, weight: 30),
                AffixWeightEntry(type: .defense, weight: 20),
                AffixWeightEntry(type: .crit, weight: 10),
                AffixWeightEntry(type: .critDamage, weight: 10)
            ],
            subAffixPool: [
                AffixWeightEntry(type: .hp, weight: 15),
                AffixWeightEntry(type: .attack, weight: 15),
                AffixWeightEntry(type: .defense, weight: 15),
                AffixWeightEntry(type: .crit, weight: 10),
                AffixWeightEntry(type: .critDamage, weight: 10),
                AffixWeightEntry(type: .energyRecharge, weight: 10),
                AffixWeightEntry(type: .elementalMastery, weight: 25)
            ]
        )
        
        // 身體詞條池
        pools[.body] = WeightedAffixPool(
            mainAffixPool: [
                AffixWeightEntry(type: .hp, weight: 25),
                AffixWeightEntry(type: .attack, weight: 25),
                AffixWeightEntry(type: .defense, weight: 25),
                AffixWeightEntry(type: .elementalDamage, weight: 15),
                AffixWeightEntry(type: .energyRecharge, weight: 10)
            ],
            subAffixPool: [
                AffixWeightEntry(type: .hp, weight: 15),
                AffixWeightEntry(type: .attack, weight: 15),
                AffixWeightEntry(type: .defense, weight: 15),
                AffixWeightEntry(type: .crit, weight: 12),
                AffixWeightEntry(type: .critDamage, weight: 12),
                AffixWeightEntry(type: .energyRecharge, weight: 11),
                AffixWeightEntry(type: .elementalMastery, weight: 20)
            ]
        )
        
        // 手套詞條池
        pools[.gloves] = WeightedAffixPool(
            mainAffixPool: [
                AffixWeightEntry(type: .hp, weight: 20),
                AffixWeightEntry(type: .attack, weight: 20),
                AffixWeightEntry(type: .defense, weight: 20),
                AffixWeightEntry(type: .crit, weight: 20),
                AffixWeightEntry(type: .critDamage, weight: 20)
            ],
            subAffixPool: [
                AffixWeightEntry(type: .hp, weight: 15),
                AffixWeightEntry(type: .attack, weight: 15),
                AffixWeightEntry(type: .defense, weight: 15),
                AffixWeightEntry(type: .crit, weight: 15),
                AffixWeightEntry(type: .critDamage, weight: 15),
                AffixWeightEntry(type: .elementalMastery, weight: 25)
            ]
        )
        
        // 鞋子詞條池
        pools[.boots] = WeightedAffixPool(
            mainAffixPool: [
                AffixWeightEntry(type: .hp, weight: 25),
                AffixWeightEntry(type: .attack, weight: 25),
                AffixWeightEntry(type: .defense, weight: 25),
                AffixWeightEntry(type: .speed, weight: 25)
            ],
            subAffixPool: [
                AffixWeightEntry(type: .hp, weight: 15),
                AffixWeightEntry(type: .attack, weight: 15),
                AffixWeightEntry(type: .defense, weight: 15),
                AffixWeightEntry(type: .crit, weight: 12),
                AffixWeightEntry(type: .critDamage, weight: 12),
                AffixWeightEntry(type: .speed, weight: 11),
                AffixWeightEntry(type: .elementalMastery, weight: 20)
            ]
        )
        
        // 腰帶詞條池
        pools[.belt] = WeightedAffixPool(
            mainAffixPool: [
                AffixWeightEntry(type: .hp, weight: 30),
                AffixWeightEntry(type: .attack, weight: 25),
                AffixWeightEntry(type: .defense, weight: 25),
                AffixWeightEntry(type: .energyRecharge, weight: 10),
                AffixWeightEntry(type: .elementalMastery, weight: 10)
            ],
            subAffixPool: [
                AffixWeightEntry(type: .hp, weight: 20),
                AffixWeightEntry(type: .attack, weight: 15),
                AffixWeightEntry(type: .defense, weight: 15),
                AffixWeightEntry(type: .crit, weight: 10),
                AffixWeightEntry(type: .critDamage, weight: 10),
                AffixWeightEntry(type: .energyRecharge, weight: 15),
                AffixWeightEntry(type: .elementalMastery, weight: 15)
            ]
        )
    }
    
    /// 取得特定欄位的詞條池
    public func getPool(for slot: EquipmentSlot) -> WeightedAffixPool? {
        pools[slot]
    }
    
    /// 設定特定欄位的詞條池
    public func setPool(_ pool: WeightedAffixPool, for slot: EquipmentSlot) {
        pools[slot] = pool
    }
    
    /// 從 JSON 載入詞條池配置
    public func loadFromJSON(_ data: Data) throws {
        let decoder = JSONDecoder()
        let config = try decoder.decode([String: WeightedAffixPool].self, from: data)
        
        for (slotString, pool) in config {
            if let slot = EquipmentSlot(rawValue: slotString) {
                pools[slot] = pool
            }
        }
    }
}

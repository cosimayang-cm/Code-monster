// MARK: - AffixPool
// Feature: 004-rpg-inventory-system
// Task: TASK-007

import Foundation

/// 詞條池 - 管理可用的詞條類型
public final class AffixPool {
    
    // MARK: - Singleton
    
    public static let shared = AffixPool()
    
    // MARK: - Main Affix Pool (by Slot)
    
    /// 各欄位可用的主詞條類型
    private let mainAffixPool: [EquipmentSlot: [AffixType]] = [
        .helmet: [.hp, .attack, .defense, .crit, .critDamage, .healingBonus],
        .body: [.hp, .attack, .defense, .elementalDamage, .energyRecharge],
        .gloves: [.hp, .attack, .defense, .crit, .critDamage, .elementalMastery],
        .boots: [.hp, .attack, .defense, .speed, .elementalMastery],
        .belt: [.hp, .attack, .defense, .energyRecharge, .elementalMastery]
    ]
    
    /// 副詞條池
    private let subAffixPool: [AffixType] = [
        .crit, .critDamage, .attack, .defense, .hp, .mp, .speed, .elementalMastery
    ]
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Query Methods
    
    /// 取得指定欄位的可用主詞條類型
    /// - Parameter slot: 裝備欄位
    /// - Returns: 可用的主詞條類型陣列
    public func availableMainAffixes(for slot: EquipmentSlot) -> [AffixType] {
        mainAffixPool[slot] ?? []
    }
    
    /// 取得可用的副詞條類型
    /// - Returns: 副詞條類型陣列
    public func availableSubAffixes() -> [AffixType] {
        subAffixPool
    }
    
    /// 隨機選取主詞條類型
    /// - Parameter slot: 裝備欄位
    /// - Returns: 隨機選取的主詞條類型，如果池為空則返回 nil
    public func randomMainAffix(for slot: EquipmentSlot) -> AffixType? {
        availableMainAffixes(for: slot).randomElement()
    }
    
    /// 隨機選取副詞條類型（排除指定類型）
    /// - Parameters:
    ///   - count: 需要的數量
    ///   - excluding: 要排除的類型
    /// - Returns: 隨機選取的副詞條類型陣列
    public func randomSubAffixes(count: Int, excluding: [AffixType] = []) -> [AffixType] {
        let available = subAffixPool.filter { type in
            !excluding.contains(type)
        }
        
        guard count > 0, !available.isEmpty else { return [] }
        
        var result: [AffixType] = []
        var remaining = available
        
        for _ in 0..<min(count, available.count) {
            guard let index = remaining.indices.randomElement() else { break }
            result.append(remaining.remove(at: index))
        }
        
        return result
    }
    
    /// 隨機選取副詞條類型（排除已有的 Bitmask）
    /// - Parameters:
    ///   - count: 需要的數量
    ///   - existingMask: 已有的詞條 Bitmask
    /// - Returns: 隨機選取的副詞條類型陣列
    public func randomSubAffixes(count: Int, excludingMask existingMask: AffixType) -> [AffixType] {
        let available = subAffixPool.filter { type in
            !existingMask.contains(type)
        }
        
        guard count > 0, !available.isEmpty else { return [] }
        
        var result: [AffixType] = []
        var remaining = available
        
        for _ in 0..<min(count, available.count) {
            guard let index = remaining.indices.randomElement() else { break }
            result.append(remaining.remove(at: index))
        }
        
        return result
    }
    
    /// 檢查詞條類型是否為有效的主詞條
    /// - Parameters:
    ///   - type: 詞條類型
    ///   - slot: 裝備欄位
    /// - Returns: 是否有效
    public func isValidMainAffix(_ type: AffixType, for slot: EquipmentSlot) -> Bool {
        availableMainAffixes(for: slot).contains(type)
    }
    
    /// 檢查詞條類型是否為有效的副詞條
    /// - Parameter type: 詞條類型
    /// - Returns: 是否有效
    public func isValidSubAffix(_ type: AffixType) -> Bool {
        subAffixPool.contains(type)
    }
}

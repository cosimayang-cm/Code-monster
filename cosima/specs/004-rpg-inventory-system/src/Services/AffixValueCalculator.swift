// MARK: - AffixValueCalculator
// Feature: 004-rpg-inventory-system
// Task: TASK-008

import Foundation

/// 詞條數值計算器
public struct AffixValueCalculator {
    
    // MARK: - Value Ranges
    
    /// 詞條數值範圍定義
    public struct ValueRange {
        let min: Double
        let max: Double
        let isPercentage: Bool
        
        public init(min: Double, max: Double, isPercentage: Bool) {
            self.min = min
            self.max = max
            self.isPercentage = isPercentage
        }
        
        /// 隨機生成數值
        public func randomValue() -> Double {
            Double.random(in: min...max)
        }
    }
    
    // MARK: - Main Affix Ranges
    
    /// 主詞條數值範圍
    private static let mainAffixRanges: [AffixType: ValueRange] = [
        .hp: ValueRange(min: 7.0, max: 14.0, isPercentage: true),
        .attack: ValueRange(min: 7.0, max: 14.0, isPercentage: true),
        .defense: ValueRange(min: 8.75, max: 17.5, isPercentage: true),
        .crit: ValueRange(min: 4.7, max: 9.3, isPercentage: true),
        .critDamage: ValueRange(min: 9.3, max: 18.6, isPercentage: true),
        .elementalMastery: ValueRange(min: 28, max: 56, isPercentage: false),
        .elementalDamage: ValueRange(min: 7.0, max: 14.0, isPercentage: true),
        .energyRecharge: ValueRange(min: 7.8, max: 15.5, isPercentage: true),
        .healingBonus: ValueRange(min: 5.4, max: 10.8, isPercentage: true),
        .speed: ValueRange(min: 5.0, max: 10.0, isPercentage: true),
        .mp: ValueRange(min: 7.0, max: 14.0, isPercentage: true)
    ]
    
    // MARK: - Sub Affix Ranges
    
    /// 副詞條數值範圍（基礎值較低）
    private static let subAffixRanges: [AffixType: ValueRange] = [
        .hp: ValueRange(min: 4.1, max: 5.8, isPercentage: true),
        .attack: ValueRange(min: 4.1, max: 5.8, isPercentage: true),
        .defense: ValueRange(min: 5.1, max: 7.3, isPercentage: true),
        .crit: ValueRange(min: 2.7, max: 3.9, isPercentage: true),
        .critDamage: ValueRange(min: 5.4, max: 7.8, isPercentage: true),
        .elementalMastery: ValueRange(min: 16, max: 23, isPercentage: false),
        .speed: ValueRange(min: 2.5, max: 4.0, isPercentage: true),
        .mp: ValueRange(min: 4.1, max: 5.8, isPercentage: true)
    ]
    
    // MARK: - Flat Value Ranges
    
    /// 固定數值副詞條範圍
    private static let flatSubAffixRanges: [AffixType: ValueRange] = [
        .hp: ValueRange(min: 209, max: 299, isPercentage: false),
        .attack: ValueRange(min: 14, max: 19, isPercentage: false),
        .defense: ValueRange(min: 16, max: 23, isPercentage: false),
        .speed: ValueRange(min: 10, max: 15, isPercentage: false),
        .mp: ValueRange(min: 50, max: 80, isPercentage: false)
    ]
    
    // MARK: - Generation Methods
    
    /// 生成主詞條
    /// - Parameter type: 詞條類型
    /// - Returns: 生成的詞條，如果類型無效則返回 nil
    public static func generateMainAffix(type: AffixType) -> Affix? {
        guard let range = mainAffixRanges[type] else { return nil }
        
        return Affix(
            type: type,
            value: range.randomValue(),
            isPercentage: range.isPercentage
        )
    }
    
    /// 生成副詞條
    /// - Parameters:
    ///   - type: 詞條類型
    ///   - preferFlat: 是否優先使用固定數值
    /// - Returns: 生成的詞條，如果類型無效則返回 nil
    public static func generateSubAffix(type: AffixType, preferFlat: Bool = false) -> Affix? {
        // 決定使用百分比還是固定數值
        let useFlat = preferFlat || Bool.random()
        
        if useFlat, let flatRange = flatSubAffixRanges[type] {
            return Affix(
                type: type,
                value: flatRange.randomValue(),
                isPercentage: flatRange.isPercentage
            )
        }
        
        guard let range = subAffixRanges[type] else { return nil }
        
        return Affix(
            type: type,
            value: range.randomValue(),
            isPercentage: range.isPercentage
        )
    }
    
    /// 批量生成副詞條
    /// - Parameter types: 詞條類型陣列
    /// - Returns: 生成的詞條陣列
    public static func generateSubAffixes(types: [AffixType]) -> [Affix] {
        types.compactMap { generateSubAffix(type: $0) }
    }
    
    // MARK: - Upgrade Calculation
    
    /// 升級係數（每級 +10%）
    public static let upgradeMultiplier: Double = 1.10
    
    /// 計算升級後的數值
    /// - Parameters:
    ///   - value: 原始數值
    ///   - levels: 升級次數
    /// - Returns: 升級後的數值
    public static func calculateUpgradedValue(_ value: Double, levels: Int) -> Double {
        value * pow(upgradeMultiplier, Double(levels))
    }
    
    /// 計算物品升級後的主詞條數值
    /// - Parameters:
    ///   - affix: 原始詞條
    ///   - itemLevel: 物品等級
    /// - Returns: 升級後的詞條
    public static func calculateMainAffixAtLevel(_ affix: Affix, itemLevel: Int) -> Affix {
        Affix(
            type: affix.type,
            value: calculateUpgradedValue(affix.value, levels: itemLevel - 1),
            isPercentage: affix.isPercentage
        )
    }
    
    // MARK: - Upgrade Sub-Affix Selection
    
    /// 選擇要強化的副詞條索引
    /// - Parameter subAffixes: 副詞條陣列
    /// - Returns: 隨機選取的索引
    public static func selectSubAffixToUpgrade(from subAffixes: [Affix]) -> Int? {
        guard !subAffixes.isEmpty else { return nil }
        return Int.random(in: 0..<subAffixes.count)
    }
    
    /// 強化副詞條
    /// - Parameter affix: 要強化的詞條
    /// - Returns: 強化後的詞條
    public static func upgradeSubAffix(_ affix: Affix) -> Affix {
        Affix(
            type: affix.type,
            value: affix.value * upgradeMultiplier,
            isPercentage: affix.isPercentage
        )
    }
}

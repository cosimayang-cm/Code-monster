// MARK: - AffixContainer Protocol
// Feature: 004-rpg-inventory-system
// Task: TASK-009

import Foundation

/// 詞條容器協定
public protocol AffixContainer {
    /// 主詞條
    var mainAffix: Affix { get }
    
    /// 副詞條列表
    var subAffixes: [Affix] { get }
    
    /// 詞條類型 Bitmask（用於 O(1) 查詢）
    var affixMask: AffixType { get }
}

// MARK: - Default Implementation

extension AffixContainer {
    
    /// 檢查是否擁有特定類型詞條
    /// - Parameter type: 詞條類型
    /// - Returns: 是否擁有
    /// - Complexity: O(1)
    public func hasAffix(_ type: AffixType) -> Bool {
        affixMask.contains(type)
    }
    
    /// 檢查是否擁有任一指定類型詞條
    /// - Parameter types: 詞條類型集合
    /// - Returns: 是否擁有任一
    /// - Complexity: O(1)
    public func hasAnyAffix(_ types: AffixType) -> Bool {
        !affixMask.intersection(types).isEmpty
    }
    
    /// 檢查是否擁有所有指定類型詞條
    /// - Parameter types: 詞條類型集合
    /// - Returns: 是否全部擁有
    /// - Complexity: O(1)
    public func hasAllAffixes(_ types: AffixType) -> Bool {
        affixMask.isSuperset(of: types)
    }
    
    /// 取得特定類型的所有詞條
    /// - Parameter type: 詞條類型
    /// - Returns: 符合的詞條列表
    public func getAffixes(of type: AffixType) -> [Affix] {
        var result: [Affix] = []
        
        if mainAffix.type == type {
            result.append(mainAffix)
        }
        
        result.append(contentsOf: subAffixes.filter { $0.type == type })
        
        return result
    }
    
    /// 取得所有詞條
    public var allAffixes: [Affix] {
        [mainAffix] + subAffixes
    }
    
    /// 詞條總數
    public var affixCount: Int {
        1 + subAffixes.count
    }
    
    /// 副詞條數量
    public var subAffixCount: Int {
        subAffixes.count
    }
    
    /// 計算所有詞條的總數值加成
    /// - Parameter baseStats: 基礎數值（用於百分比計算）
    /// - Returns: 總數值加成
    public func calculateAffixStats(baseStats: Stats = .zero) -> Stats {
        var total = Stats.zero
        
        for affix in allAffixes {
            total += affix.toStats(baseStats: baseStats)
        }
        
        return total
    }
}

// MARK: - Bitmask Builder

/// 從詞條列表建立 Bitmask
/// - Parameters:
///   - mainAffix: 主詞條
///   - subAffixes: 副詞條列表
/// - Returns: 合併的 Bitmask
public func buildAffixMask(mainAffix: Affix, subAffixes: [Affix]) -> AffixType {
    var mask = mainAffix.type
    for affix in subAffixes {
        mask.insert(affix.type)
    }
    return mask
}

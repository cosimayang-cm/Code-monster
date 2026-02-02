// MARK: - SetBonusCalculator
// Feature: 004-rpg-inventory-system
// Task: TASK-018

import Foundation

/// 套裝效果計算器
public final class SetBonusCalculator {
    
    // MARK: - Dependencies
    
    private let setService: EquipmentSetService
    
    // MARK: - Initialization
    
    public init(setService: EquipmentSetService) {
        self.setService = setService
    }
    
    // MARK: - Calculation Methods
    
    /// 計算已裝備物品啟動的套裝效果
    /// - Parameter equippedItems: 已裝備物品列表
    /// - Returns: 已啟動的套裝效果列表
    public func calculateSetBonuses(for equippedItems: [Item]) -> [ActiveSetBonus] {
        // 統計各套裝的裝備件數
        let setCounter = countSetPieces(equippedItems)
        
        var activeBonuses: [ActiveSetBonus] = []
        
        for (setId, count) in setCounter {
            // 取得套裝定義
            guard let set = setService.getSet(byId: setId) else {
                continue
            }
            
            // 取得可啟動的效果
            let bonuses = set.activeBonuses(for: count)
            
            for bonus in bonuses {
                let activeBonus = ActiveSetBonus(
                    setId: setId,
                    setName: set.name,
                    equippedPieces: count,
                    requiredPieces: bonus.requiredPieces,
                    effect: bonus.effect,
                    description: bonus.description
                )
                activeBonuses.append(activeBonus)
            }
        }
        
        return activeBonuses
    }
    
    /// 計算套裝效果的總數值加成
    /// - Parameters:
    ///   - activeBonuses: 已啟動的套裝效果
    ///   - baseStats: 基礎數值
    /// - Returns: 總數值加成
    public func calculateBonusStats(
        _ activeBonuses: [ActiveSetBonus],
        baseStats: Stats = .zero
    ) -> Stats {
        var total = Stats.zero
        
        for bonus in activeBonuses {
            total += bonus.effect.toStats(baseStats: baseStats)
        }
        
        return total
    }
    
    /// 一站式計算：從裝備列表到總數值加成
    /// - Parameters:
    ///   - equippedItems: 已裝備物品列表
    ///   - baseStats: 基礎數值
    /// - Returns: (已啟動效果, 總數值加成)
    public func calculate(
        for equippedItems: [Item],
        baseStats: Stats = .zero
    ) -> (bonuses: [ActiveSetBonus], stats: Stats) {
        let activeBonuses = calculateSetBonuses(for: equippedItems)
        let stats = calculateBonusStats(activeBonuses, baseStats: baseStats)
        return (activeBonuses, stats)
    }
    
    // MARK: - Helper Methods
    
    /// 統計各套裝的裝備件數
    private func countSetPieces(_ items: [Item]) -> [String: Int] {
        var counter: [String: Int] = [:]
        
        for item in items {
            if let setId = item.setId {
                counter[setId, default: 0] += 1
            }
        }
        
        return counter
    }
    
    /// 取得套裝進度資訊
    /// - Parameter equippedItems: 已裝備物品列表
    /// - Returns: 套裝進度列表
    public func getSetProgress(for equippedItems: [Item]) -> [SetProgress] {
        let setCounter = countSetPieces(equippedItems)
        var progress: [SetProgress] = []
        
        for (setId, count) in setCounter {
            guard let set = setService.getSet(byId: setId) else {
                continue
            }
            
            let nextThreshold = set.bonusThresholds.first { $0 > count }
            
            progress.append(SetProgress(
                setId: setId,
                setName: set.name,
                currentPieces: count,
                totalPieces: set.pieceCount,
                nextBonusThreshold: nextThreshold,
                activeBonusCount: set.activeBonuses(for: count).count,
                totalBonusCount: set.bonuses.count
            ))
        }
        
        return progress.sorted { $0.currentPieces > $1.currentPieces }
    }
}

// MARK: - SetProgress

/// 套裝進度資訊
public struct SetProgress: Equatable {
    /// 套裝 ID
    public let setId: String
    
    /// 套裝名稱
    public let setName: String
    
    /// 目前裝備件數
    public let currentPieces: Int
    
    /// 套裝總件數
    public let totalPieces: Int
    
    /// 下一個效果門檻（nil 表示已達最高）
    public let nextBonusThreshold: Int?
    
    /// 已啟動的效果數量
    public let activeBonusCount: Int
    
    /// 總效果數量
    public let totalBonusCount: Int
    
    /// 進度百分比
    public var progressPercent: Double {
        guard totalPieces > 0 else { return 0 }
        return Double(currentPieces) / Double(totalPieces)
    }
    
    /// 是否已達最高效果
    public var isMaxBonus: Bool {
        nextBonusThreshold == nil
    }
}

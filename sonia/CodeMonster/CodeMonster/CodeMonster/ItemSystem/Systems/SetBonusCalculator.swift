//
//  SetBonusCalculator.swift
//  CodeMonster
//
//  RPG 道具系統 - 套裝效果計算器
//  Feature: 003-rpg-item-system
//
//  FR-020: 系統 MUST 在計算角色屬性時自動計算套裝效果
//  FR-021: 系統 MUST 支援多套裝混搭，正確計算各套裝的生效效果
//
//  Created by CodeMonster on 2026/2/1.
//

import Foundation

/// 套裝效果計算器
/// 負責計算當前裝備組合的套裝效果加成
final class SetBonusCalculator {
    
    // MARK: - Properties
    
    /// 已註冊的套裝定義（key: setId）
    private var registeredSets: [String: EquipmentSet]
    
    // MARK: - Initialization
    
    /// 建立套裝效果計算器
    /// - Parameter sets: 初始套裝定義列表
    init(sets: [EquipmentSet] = []) {
        self.registeredSets = Dictionary(uniqueKeysWithValues: sets.map { ($0.id, $0) })
    }
    
    // MARK: - Public Methods
    
    /// 註冊套裝定義
    /// - Parameter set: 套裝定義
    func register(set: EquipmentSet) {
        registeredSets[set.id] = set
    }
    
    /// 移除套裝定義
    /// - Parameter setId: 套裝 ID
    func unregister(setId: String) {
        registeredSets.removeValue(forKey: setId)
    }
    
    /// 計算裝備組合的套裝效果加成數值
    /// - Parameter items: 已裝備的物品列表
    /// - Returns: 總套裝效果加成數值
    func calculateBonusStats(for items: [Item]) -> Stats {
        let activeBonuses = getActiveBonuses(for: items)
        
        return activeBonuses.reduce(Stats.zero) { result, bonus in
            result + bonus.bonusStats
        }
    }
    
    /// 取得裝備組合中所有生效的套裝效果
    /// - Parameter items: 已裝備的物品列表
    /// - Returns: 所有生效的套裝效果列表
    func getActiveBonuses(for items: [Item]) -> [SetBonus] {
        // 統計各套裝的穿戴件數
        let setCounts = countSetPieces(items: items)
        
        // 收集所有生效的套裝效果
        var activeBonuses: [SetBonus] = []
        
        for (setId, count) in setCounts {
            guard let set = registeredSets[setId] else { continue }
            activeBonuses.append(contentsOf: set.activeBonuses(forEquippedCount: count))
        }
        
        return activeBonuses
    }
    
    /// 取得裝備組合中各套裝的穿戴件數
    /// - Parameter items: 已裝備的物品列表
    /// - Returns: 各套裝的穿戴件數（key: setId, value: 件數）
    func getSetCounts(for items: [Item]) -> [String: Int] {
        countSetPieces(items: items)
    }
    
    // MARK: - Private Methods
    
    /// 統計各套裝的穿戴件數
    private func countSetPieces(items: [Item]) -> [String: Int] {
        var setCounts: [String: Int] = [:]
        
        for item in items {
            guard let setId = item.setId else { continue }
            setCounts[setId, default: 0] += 1
        }
        
        return setCounts
    }
}

//
//  AffixGenerator.swift
//  CodeMonster
//
//  RPG 道具系統 - 詞條生成器
//  Feature: 003-rpg-item-system
//
//  根據詞條池和稀有度生成主詞條和副詞條
//  FR-009: 副詞條數量 MUST 根據稀有度決定
//  FR-010: 系統 MUST 根據詞條池權重隨機生成副詞條
//
//  Created by CodeMonster on 2026/2/1.
//

import Foundation

/// 詞條生成器
/// 負責根據詞條池隨機生成詞條
final class AffixGenerator {
    
    // MARK: - Properties
    
    /// 詞條池
    private let pool: AffixPool
    
    /// 隨機數生成器
    private var randomGenerator: RandomNumberGenerator
    
    // MARK: - Initialization
    
    /// 建立詞條生成器
    /// - Parameters:
    ///   - pool: 詞條池
    ///   - seed: 隨機種子（可選，用於可重現的測試）
    init(pool: AffixPool, seed: UInt64? = nil) {
        self.pool = pool
        if let seed = seed {
            self.randomGenerator = SeededRandomGenerator(seed: seed)
        } else {
            self.randomGenerator = SystemRandomNumberGenerator()
        }
    }
    
    // MARK: - Main Affix Generation
    
    /// 生成主詞條
    /// - Returns: 隨機生成的主詞條，若池為空則回傳 nil
    func generateMainAffix() -> Affix? {
        guard !pool.mainAffixes.isEmpty else { return nil }
        
        let weighted = selectWeighted(from: pool.mainAffixes)
        return createAffix(from: weighted)
    }
    
    // MARK: - Sub Affix Generation
    
    /// 根據稀有度生成副詞條
    /// - Parameter rarity: 物品稀有度
    /// - Returns: 生成的副詞條陣列
    func generateSubAffixes(for rarity: Rarity) -> [Affix] {
        guard !pool.subAffixes.isEmpty else { return [] }
        
        let count = calculateSubAffixCount(for: rarity)
        guard count > 0 else { return [] }
        
        var result: [Affix] = []
        var usedTypes: Set<AffixType> = []
        var availableAffixes = pool.subAffixes
        
        for _ in 0..<count {
            // 過濾掉已使用的類型
            let filtered = availableAffixes.filter { !usedTypes.contains($0.type) }
            guard !filtered.isEmpty else { break }
            
            let weighted = selectWeighted(from: filtered)
            let affix = createAffix(from: weighted)
            result.append(affix)
            usedTypes.insert(weighted.type)
        }
        
        return result
    }
    
    // MARK: - Private Methods
    
    /// 計算副詞條數量
    private func calculateSubAffixCount(for rarity: Rarity) -> Int {
        let min = rarity.minSubAffixCount
        let max = rarity.maxSubAffixCount
        
        if min == max {
            return min
        }
        
        // 在範圍內隨機選擇
        return Int.random(in: min...max, using: &randomGenerator)
    }
    
    /// 根據權重選擇詞條定義
    private func selectWeighted(from affixes: [WeightedAffix]) -> WeightedAffix {
        let totalWeight = affixes.reduce(0) { $0 + $1.weight }
        var randomValue = Int.random(in: 0..<totalWeight, using: &randomGenerator)
        
        for affix in affixes {
            randomValue -= affix.weight
            if randomValue < 0 {
                return affix
            }
        }
        
        // 理論上不會執行到這裡，但作為安全措施
        return affixes.last!
    }
    
    /// 從權重詞條定義建立實際詞條
    private func createAffix(from weighted: WeightedAffix) -> Affix {
        let value = Double.random(
            in: weighted.minValue...weighted.maxValue,
            using: &randomGenerator
        )
        
        return Affix(
            type: weighted.type,
            value: value,
            isPercentage: weighted.isPercentage
        )
    }
}

// MARK: - Seeded Random Generator

/// 可設定種子的隨機數生成器（用於測試）
struct SeededRandomGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: UInt64) {
        self.state = seed
    }
    
    mutating func next() -> UInt64 {
        // 簡單的線性同餘生成器
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

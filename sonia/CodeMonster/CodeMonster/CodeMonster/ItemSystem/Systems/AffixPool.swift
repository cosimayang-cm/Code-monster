//
//  AffixPool.swift
//  CodeMonster
//
//  RPG 道具系統 - 詞條池
//  Feature: 003-rpg-item-system
//
//  定義各欄位可出現的主副詞條及其權重
//  FR-010: 系統 MUST 根據詞條池權重隨機生成副詞條
//
//  Created by CodeMonster on 2026/2/1.
//

import Foundation

/// 權重詞條定義
/// 用於詞條池中定義可生成的詞條及其權重和數值範圍
struct WeightedAffix: Codable, Equatable {
    
    /// 詞條類型
    let type: AffixType
    
    /// 最小數值
    let minValue: Double
    
    /// 最大數值
    let maxValue: Double
    
    /// 權重（影響出現機率）
    let weight: Int
    
    /// 是否為百分比加成
    let isPercentage: Bool
    
    /// 建立權重詞條定義
    /// - Parameters:
    ///   - type: 詞條類型
    ///   - minValue: 最小數值
    ///   - maxValue: 最大數值
    ///   - weight: 權重
    ///   - isPercentage: 是否為百分比
    init(type: AffixType, minValue: Double, maxValue: Double, weight: Int, isPercentage: Bool) {
        self.type = type
        self.minValue = minValue
        self.maxValue = maxValue
        self.weight = weight
        self.isPercentage = isPercentage
    }
}

/// 詞條池
/// 定義可生成的主詞條和副詞條
struct AffixPool: Codable {
    
    // MARK: - Properties
    
    /// 主詞條列表（通常為百分比類型）
    let mainAffixes: [WeightedAffix]
    
    /// 副詞條列表（通常為固定加成類型）
    let subAffixes: [WeightedAffix]
    
    // MARK: - Initialization
    
    /// 建立詞條池
    /// - Parameters:
    ///   - mainAffixes: 主詞條列表
    ///   - subAffixes: 副詞條列表
    init(mainAffixes: [WeightedAffix], subAffixes: [WeightedAffix]) {
        self.mainAffixes = mainAffixes
        self.subAffixes = subAffixes
    }
    
    // MARK: - Computed Properties
    
    /// 主詞條總權重
    var mainTotalWeight: Int {
        mainAffixes.reduce(0) { $0 + $1.weight }
    }
    
    /// 副詞條總權重
    var subTotalWeight: Int {
        subAffixes.reduce(0) { $0 + $1.weight }
    }
    
    /// 是否為空池
    var isEmpty: Bool {
        mainAffixes.isEmpty && subAffixes.isEmpty
    }
}

// MARK: - Default Pools

extension AffixPool {
    
    /// 頭盔欄位的預設詞條池
    static var helmet: AffixPool {
        AffixPool(
            mainAffixes: [
                WeightedAffix(type: .maxHPPercent, minValue: 0.05, maxValue: 0.20, weight: 40, isPercentage: true),
                WeightedAffix(type: .attackPercent, minValue: 0.05, maxValue: 0.15, weight: 30, isPercentage: true),
                WeightedAffix(type: .defensePercent, minValue: 0.05, maxValue: 0.15, weight: 30, isPercentage: true)
            ],
            subAffixes: defaultSubAffixes
        )
    }
    
    /// 身體欄位的預設詞條池
    static var body: AffixPool {
        AffixPool(
            mainAffixes: [
                WeightedAffix(type: .defensePercent, minValue: 0.05, maxValue: 0.20, weight: 40, isPercentage: true),
                WeightedAffix(type: .maxHPPercent, minValue: 0.05, maxValue: 0.15, weight: 35, isPercentage: true),
                WeightedAffix(type: .attackPercent, minValue: 0.05, maxValue: 0.10, weight: 25, isPercentage: true)
            ],
            subAffixes: defaultSubAffixes
        )
    }
    
    /// 預設副詞條列表
    private static var defaultSubAffixes: [WeightedAffix] {
        [
            WeightedAffix(type: .attack, minValue: 10, maxValue: 50, weight: 20, isPercentage: false),
            WeightedAffix(type: .defense, minValue: 10, maxValue: 40, weight: 20, isPercentage: false),
            WeightedAffix(type: .maxHP, minValue: 50, maxValue: 200, weight: 20, isPercentage: false),
            WeightedAffix(type: .critRate, minValue: 0.02, maxValue: 0.08, weight: 15, isPercentage: false),
            WeightedAffix(type: .critDamage, minValue: 0.05, maxValue: 0.20, weight: 15, isPercentage: false),
            WeightedAffix(type: .speed, minValue: 5, maxValue: 20, weight: 10, isPercentage: false)
        ]
    }
}

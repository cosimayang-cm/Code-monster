//
//  Stats.swift
//  CodeMonster
//
//  RPG 道具系統 - 角色數值結構
//  Feature: 003-rpg-item-system
//
//  定義角色的各項能力數值，支援加法和乘法運算
//  FR-005: 系統 MUST 支援以下角色數值：攻擊力、防禦力、最大生命、最大魔力、暴擊率、暴擊傷害、速度
//  FR-006: 系統 MUST 按公式計算最終數值
//
//  Created by CodeMonster on 2026/2/1.
//

import Foundation

/// 角色數值結構
/// 包含所有角色能力數值的容器
struct Stats: Equatable, Codable, Hashable {
    
    // MARK: - Properties
    
    /// 攻擊力
    var attack: Double
    
    /// 防禦力
    var defense: Double
    
    /// 最大生命值
    var maxHP: Double
    
    /// 最大魔力值
    var maxMP: Double
    
    /// 暴擊率 (0.0 ~ 1.0)
    var critRate: Double
    
    /// 暴擊傷害 (例如 0.5 表示 +50% 傷害)
    var critDamage: Double
    
    /// 速度
    var speed: Double
    
    // MARK: - Static Properties
    
    /// 全零的數值實例
    static var zero: Stats {
        Stats(
            attack: 0,
            defense: 0,
            maxHP: 0,
            maxMP: 0,
            critRate: 0,
            critDamage: 0,
            speed: 0
        )
    }
    
    // MARK: - Initialization
    
    /// 建立數值實例
    /// - Parameters:
    ///   - attack: 攻擊力
    ///   - defense: 防禦力
    ///   - maxHP: 最大生命值
    ///   - maxMP: 最大魔力值
    ///   - critRate: 暴擊率
    ///   - critDamage: 暴擊傷害
    ///   - speed: 速度
    init(
        attack: Double = 0,
        defense: Double = 0,
        maxHP: Double = 0,
        maxMP: Double = 0,
        critRate: Double = 0,
        critDamage: Double = 0,
        speed: Double = 0
    ) {
        self.attack = attack
        self.defense = defense
        self.maxHP = maxHP
        self.maxMP = maxMP
        self.critRate = critRate
        self.critDamage = critDamage
        self.speed = speed
    }
}

// MARK: - Operators

extension Stats {
    
    /// 加法運算：合併兩個數值
    static func + (lhs: Stats, rhs: Stats) -> Stats {
        Stats(
            attack: lhs.attack + rhs.attack,
            defense: lhs.defense + rhs.defense,
            maxHP: lhs.maxHP + rhs.maxHP,
            maxMP: lhs.maxMP + rhs.maxMP,
            critRate: lhs.critRate + rhs.critRate,
            critDamage: lhs.critDamage + rhs.critDamage,
            speed: lhs.speed + rhs.speed
        )
    }
    
    /// 加法賦值運算
    static func += (lhs: inout Stats, rhs: Stats) {
        lhs = lhs + rhs
    }
    
    /// 乘法運算：縮放數值
    static func * (lhs: Stats, rhs: Double) -> Stats {
        Stats(
            attack: lhs.attack * rhs,
            defense: lhs.defense * rhs,
            maxHP: lhs.maxHP * rhs,
            maxMP: lhs.maxMP * rhs,
            critRate: lhs.critRate * rhs,
            critDamage: lhs.critDamage * rhs,
            speed: lhs.speed * rhs
        )
    }
    
    /// 乘法運算（數值在左）
    static func * (lhs: Double, rhs: Stats) -> Stats {
        rhs * lhs
    }
}

// MARK: - Calculation Helper

extension Stats {
    
    /// 計算最終數值
    /// FR-006: 最終值 = (基礎值 + Σ固定加成) × (1 + Σ百分比加成)
    /// - Parameters:
    ///   - baseStats: 基礎數值
    ///   - flatBonus: 固定加成總和
    ///   - percentBonus: 百分比加成總和 (例如 0.3 表示 +30%)
    /// - Returns: 計算後的最終數值
    static func calculateFinal(
        baseStats: Stats,
        flatBonus: Stats,
        percentBonus: Stats
    ) -> Stats {
        let combined = baseStats + flatBonus
        return Stats(
            attack: combined.attack * (1 + percentBonus.attack),
            defense: combined.defense * (1 + percentBonus.defense),
            maxHP: combined.maxHP * (1 + percentBonus.maxHP),
            maxMP: combined.maxMP * (1 + percentBonus.maxMP),
            critRate: combined.critRate + percentBonus.critRate, // 暴擊率直接加
            critDamage: combined.critDamage + percentBonus.critDamage, // 暴擊傷害直接加
            speed: combined.speed * (1 + percentBonus.speed)
        )
    }
}

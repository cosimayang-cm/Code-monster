// MARK: - Stats
// Feature: 004-rpg-inventory-system
// Task: TASK-001

import Foundation

/// 角色/裝備的數值集合
public struct Stats: Codable, Equatable, Hashable {
    
    // MARK: - Properties
    
    /// 攻擊力
    public var attack: Double
    
    /// 防禦力
    public var defense: Double
    
    /// 最大生命值
    public var maxHP: Double
    
    /// 最大魔力值
    public var maxMP: Double
    
    /// 暴擊率 (0.0~1.0)
    public var critRate: Double
    
    /// 暴擊傷害倍率
    public var critDamage: Double
    
    /// 速度
    public var speed: Double
    
    // MARK: - Initialization
    
    public init(
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
    
    // MARK: - Static Properties
    
    /// 零值初始化
    public static var zero: Stats {
        Stats()
    }
}

// MARK: - Operators

extension Stats {
    
    /// 數值相加
    public static func + (lhs: Stats, rhs: Stats) -> Stats {
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
    
    /// 數值相加並賦值
    public static func += (lhs: inout Stats, rhs: Stats) {
        lhs = lhs + rhs
    }
    
    /// 數值乘以倍率
    public static func * (lhs: Stats, rhs: Double) -> Stats {
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
    
    /// 倍率乘以數值
    public static func * (lhs: Double, rhs: Stats) -> Stats {
        rhs * lhs
    }
}

// MARK: - Utility Methods

extension Stats {
    
    /// 套用百分比加成
    /// - Parameter percentages: 百分比數值 (例如 0.1 = 10%)
    /// - Returns: 套用後的數值
    public func applying(percentages: Stats) -> Stats {
        Stats(
            attack: attack * (1 + percentages.attack),
            defense: defense * (1 + percentages.defense),
            maxHP: maxHP * (1 + percentages.maxHP),
            maxMP: maxMP * (1 + percentages.maxMP),
            critRate: critRate + percentages.critRate, // 暴擊率直接加算
            critDamage: critDamage + percentages.critDamage, // 暴擊傷害直接加算
            speed: speed * (1 + percentages.speed)
        )
    }
    
    /// 檢查是否為零值
    public var isZero: Bool {
        self == .zero
    }
}

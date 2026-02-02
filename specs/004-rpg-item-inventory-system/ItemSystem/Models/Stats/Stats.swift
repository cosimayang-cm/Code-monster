import Foundation

/// 角色/裝備數值結構
public struct Stats: Codable, Equatable, Sendable {
    public var attack: Double
    public var defense: Double
    public var maxHP: Double
    public var maxMP: Double
    public var critRate: Double
    public var critDamage: Double
    public var speed: Double

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

    /// 數值相加運算子
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

    /// 數值相乘運算子（用於百分比加成）
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
}

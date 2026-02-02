import Foundation

/// 套裝效果計算協議
public protocol SetBonusCalculating {
    /// 計算角色穿戴裝備觸發的套裝效果
    func calculateSetBonuses(for avatar: Avatar, sets: [EquipmentSet]) -> [ActiveSetBonus]
}

/// 啟用的套裝效果
public struct ActiveSetBonus: Equatable {
    public let set: EquipmentSet
    public let bonus: SetBonus
    public let equippedCount: Int

    public init(set: EquipmentSet, bonus: SetBonus, equippedCount: Int) {
        self.set = set
        self.bonus = bonus
        self.equippedCount = equippedCount
    }
}

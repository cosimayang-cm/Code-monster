import Foundation

/// 物品服務協議
public protocol ItemServicing {
    /// 從背包裝備物品到指定欄位
    func equip(_ item: Item, to slot: EquipmentSlot, avatar: Avatar) -> EquipResult

    /// 從指定欄位卸下裝備到背包
    func unequip(slot: EquipmentSlot, avatar: Avatar) -> UnequipResult

    /// 交換背包物品與裝備欄位物品
    func swap(_ item: Item, with slot: EquipmentSlot, avatar: Avatar) -> EquipResult
}

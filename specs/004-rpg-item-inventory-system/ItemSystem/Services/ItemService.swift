import Foundation

/// 物品服務（處理裝備穿戴與卸下）
public class ItemService: ItemServicing {

    public init() {}

    /// 從背包裝備物品到指定欄位
    public func equip(_ item: Item, to slot: EquipmentSlot, avatar: Avatar) -> EquipResult {
        // 檢查物品是否在背包中
        guard avatar.inventory.contains(item) else {
            return .itemNotInInventory
        }

        // 檢查欄位是否匹配
        guard item.slot == slot else {
            return .slotMismatch
        }

        // 檢查等級需求
        guard avatar.canEquip(item) else {
            return .levelTooLow(required: item.template.levelRequirement, current: avatar.level)
        }

        // 從背包移除物品
        avatar.inventory.remove(item)

        // 裝備物品（可能會替換舊裝備）
        let replacedItem = avatar.equipment.equip(item)

        // 如果有舊裝備，放回背包
        if let oldItem = replacedItem {
            avatar.inventory.add(oldItem)
        }

        return .success(replacedItem: replacedItem)
    }

    /// 從指定欄位卸下裝備到背包
    public func unequip(slot: EquipmentSlot, avatar: Avatar) -> UnequipResult {
        // 檢查欄位是否有裝備
        guard let item = avatar.equipment.getItem(at: slot) else {
            return .slotEmpty
        }

        // 檢查背包是否有空間
        guard !avatar.inventory.isFull else {
            return .inventoryFull
        }

        // 卸下裝備
        let unequippedItem = avatar.equipment.unequip(slot: slot)!

        // 放入背包
        avatar.inventory.add(unequippedItem)

        return .success(item: unequippedItem)
    }

    /// 交換背包物品與裝備欄位物品
    public func swap(_ item: Item, with slot: EquipmentSlot, avatar: Avatar) -> EquipResult {
        // 直接使用 equip，它會處理交換邏輯
        return equip(item, to: slot, avatar: avatar)
    }
}

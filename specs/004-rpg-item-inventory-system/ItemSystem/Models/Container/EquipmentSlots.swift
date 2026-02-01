import Foundation

/// 裝備欄位管理（5 個欄位）
public class EquipmentSlots: Codable {
    private var slots: [EquipmentSlot: Item] = [:]

    public init() {}

    /// 取得特定欄位的裝備
    public func getItem(at slot: EquipmentSlot) -> Item? {
        slots[slot]
    }

    /// 裝備物品（回傳被替換的舊裝備）
    public func equip(_ item: Item) -> Item? {
        let slot = item.slot
        let oldItem = slots[slot]
        slots[slot] = item
        return oldItem
    }

    /// 卸下裝備
    public func unequip(slot: EquipmentSlot) -> Item? {
        let item = slots[slot]
        slots[slot] = nil
        return item
    }

    /// 取得所有已裝備物品
    public var allEquipped: [Item] {
        Array(slots.values)
    }

    /// 檢查是否為空
    public var isEmpty: Bool {
        slots.isEmpty
    }

    /// 已裝備數量
    public var count: Int {
        slots.count
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case slots
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let slotsArray = try container.decode([SlotItemPair].self, forKey: .slots)
        self.slots = Dictionary(uniqueKeysWithValues: slotsArray.map { ($0.slot, $0.item) })
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let slotsArray = slots.map { SlotItemPair(slot: $0.key, item: $0.value) }
        try container.encode(slotsArray, forKey: .slots)
    }

    private struct SlotItemPair: Codable {
        let slot: EquipmentSlot
        let item: Item
    }
}

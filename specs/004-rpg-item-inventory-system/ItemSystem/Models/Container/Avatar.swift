import Foundation

/// 角色（整合裝備欄位與背包）
public class Avatar: Codable {
    public let id: UUID
    public var name: String
    public private(set) var level: Int
    public var baseStats: Stats
    public let equipment: EquipmentSlots
    public let inventory: Inventory

    public init(name: String, level: Int = 1, baseStats: Stats = Stats(), inventoryCapacity: Int = 50) {
        self.id = UUID()
        self.name = name
        self.level = level
        self.baseStats = baseStats
        self.equipment = EquipmentSlots()
        self.inventory = Inventory(capacity: inventoryCapacity)
    }

    /// 升級
    public func levelUp() {
        level += 1
    }

    /// 檢查是否可裝備（等級需求）
    public func canEquip(_ item: Item) -> Bool {
        level >= item.template.levelRequirement
    }
}

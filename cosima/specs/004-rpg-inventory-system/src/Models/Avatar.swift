// MARK: - Avatar
// Feature: 004-rpg-inventory-system
// Task: TASK-021

import Foundation

/// 角色 - 整合裝備欄與背包系統
public final class Avatar {
    
    // MARK: - Properties
    
    /// 角色名稱
    public let name: String
    
    /// 角色等級
    public private(set) var level: Int
    
    /// 基礎數值
    public var baseStats: Stats
    
    /// 裝備欄
    public let equipmentSlots: EquipmentSlots
    
    /// 背包
    public let inventory: Inventory
    
    /// 套裝效果計算器（可選注入）
    private var setBonusCalculator: SetBonusCalculator?
    
    // MARK: - Initialization
    
    public init(
        name: String,
        level: Int = 1,
        baseStats: Stats = .zero,
        inventoryCapacity: Int = 100,
        setBonusCalculator: SetBonusCalculator? = nil
    ) {
        self.name = name
        self.level = max(1, level)
        self.baseStats = baseStats
        self.equipmentSlots = EquipmentSlots()
        self.inventory = Inventory(capacity: inventoryCapacity)
        self.setBonusCalculator = setBonusCalculator
    }
    
    // MARK: - Level Management
    
    /// 設定等級
    /// - Parameter newLevel: 新等級
    public func setLevel(_ newLevel: Int) {
        level = max(1, newLevel)
    }
    
    /// 升級
    public func levelUp() {
        level += 1
    }
    
    // MARK: - Equipment Operations
    
    /// 已裝備的物品列表
    public var equippedItems: [Item] {
        equipmentSlots.equippedItems
    }
    
    /// 裝備物品（從背包）
    /// - Parameter item: 要裝備的物品
    /// - Returns: 被替換的物品（如有）
    /// - Throws: `EquipmentError` 或 `InventoryError`
    @discardableResult
    public func equip(_ item: Item) throws -> Item? {
        // 裝備物品
        let replaced = try equipmentSlots.equip(item, characterLevel: level)
        
        // 如果有被替換的物品，放入背包
        if let replacedItem = replaced {
            try? inventory.add(replacedItem)
        }
        
        return replaced
    }
    
    /// 從背包裝備物品
    /// - Parameter itemId: 背包中物品的 UUID
    /// - Returns: 被替換的物品（如有）
    /// - Throws: `EquipmentError` 或 `InventoryError`
    @discardableResult
    public func equipFromInventory(itemId: UUID) throws -> Item? {
        // 從背包取出物品
        let item = try inventory.remove(byId: itemId)
        
        do {
            // 嘗試裝備
            let replaced = try equipmentSlots.equip(item, characterLevel: level)
            
            // 被替換的物品放回背包
            if let replacedItem = replaced {
                try? inventory.add(replacedItem)
            }
            
            return replaced
        } catch {
            // 裝備失敗，物品放回背包
            try? inventory.add(item)
            throw error
        }
    }
    
    /// 卸除裝備到背包
    /// - Parameter slot: 裝備欄位
    /// - Throws: `EquipmentError` 或 `InventoryError`
    public func unequipToInventory(slot: EquipmentSlot) throws {
        let item = try equipmentSlots.unequip(slot: slot)
        try inventory.add(item)
    }
    
    /// 卸除所有裝備到背包
    /// - Returns: 因背包空間不足而無法放入的物品
    @discardableResult
    public func unequipAllToInventory() -> [Item] {
        var failedItems: [Item] = []
        
        for item in equipmentSlots.unequipAll() {
            do {
                try inventory.add(item)
            } catch {
                failedItems.append(item)
            }
        }
        
        return failedItems
    }
    
    // MARK: - Stats Calculation
    
    /// 計算最終數值
    public var finalStats: Stats {
        // 基礎數值
        var total = baseStats
        
        // 加上裝備數值
        total += equipmentSlots.calculateTotalStats(characterBaseStats: baseStats)
        
        // 加上套裝效果
        if let calculator = setBonusCalculator {
            let (_, setBonusStats) = calculator.calculate(
                for: equippedItems,
                baseStats: baseStats
            )
            total += setBonusStats
        }
        
        return total
    }
    
    /// 計算裝備提供的數值
    public var equipmentStats: Stats {
        equipmentSlots.calculateTotalStats(characterBaseStats: baseStats)
    }
    
    // MARK: - Set Bonus
    
    /// 設定套裝效果計算器
    public func setSetBonusCalculator(_ calculator: SetBonusCalculator) {
        self.setBonusCalculator = calculator
    }
    
    /// 已啟動的套裝效果
    public var activeSetBonuses: [ActiveSetBonus] {
        setBonusCalculator?.calculateSetBonuses(for: equippedItems) ?? []
    }
    
    /// 套裝進度
    public var setProgress: [SetProgress] {
        setBonusCalculator?.getSetProgress(for: equippedItems) ?? []
    }
}

// MARK: - Convenience Methods

extension Avatar {
    
    /// 取得特定欄位的裝備
    /// - Parameter slot: 裝備欄位
    /// - Returns: 裝備或 nil
    public func getEquipment(at slot: EquipmentSlot) -> Item? {
        equipmentSlots.getItem(at: slot)
    }
    
    /// 檢查是否可裝備物品
    /// - Parameter item: 物品
    /// - Returns: 是否可裝備
    public func canEquip(_ item: Item) -> Bool {
        item.canEquip(characterLevel: level)
    }
    
    /// 取得背包中特定欄位的物品
    /// - Parameter slot: 裝備欄位
    /// - Returns: 物品列表
    public func getInventoryItems(for slot: EquipmentSlot) -> [Item] {
        inventory.filter(by: slot)
    }
    
    /// 取得背包中有特定詞條的物品
    /// - Parameter type: 詞條類型
    /// - Returns: 物品列表
    public func getInventoryItems(withAffix type: AffixType) -> [Item] {
        inventory.filter(hasAffix: type)
    }
}

// MARK: - Statistics

extension Avatar {
    
    /// 角色統計資訊
    public var statistics: AvatarStatistics {
        AvatarStatistics(
            name: name,
            level: level,
            equippedCount: equipmentSlots.equippedCount,
            totalSlots: equipmentSlots.totalSlots,
            inventoryCount: inventory.count,
            inventoryCapacity: inventory.capacity,
            activeSetBonusCount: activeSetBonuses.count
        )
    }
}

/// 角色統計資訊
public struct AvatarStatistics {
    public let name: String
    public let level: Int
    public let equippedCount: Int
    public let totalSlots: Int
    public let inventoryCount: Int
    public let inventoryCapacity: Int
    public let activeSetBonusCount: Int
    
    public var equipmentProgress: Double {
        guard totalSlots > 0 else { return 0 }
        return Double(equippedCount) / Double(totalSlots)
    }
    
    public var inventoryUsage: Double {
        guard inventoryCapacity > 0 else { return 0 }
        return Double(inventoryCount) / Double(inventoryCapacity)
    }
}

// MARK: - Item Protocol Contract
// Feature: 004-rpg-inventory-system
// Date: 2026-02-01

import Foundation

// MARK: - Core Protocols

/// 可識別的實體協定
public protocol Identifiable {
    associatedtype ID: Hashable
    var id: ID { get }
}

/// 詞條容器協定
public protocol AffixContainer {
    /// 主詞條
    var mainAffix: Affix { get }
    
    /// 副詞條列表
    var subAffixes: [Affix] { get }
    
    /// 詞條類型 Bitmask
    var affixMask: AffixType { get }
    
    /// 檢查是否擁有特定類型詞條
    /// - Parameter type: 詞條類型
    /// - Returns: 是否擁有
    /// - Complexity: O(1)
    func hasAffix(_ type: AffixType) -> Bool
    
    /// 取得特定類型的所有詞條
    /// - Parameter type: 詞條類型
    /// - Returns: 符合的詞條列表
    func getAffixes(of type: AffixType) -> [Affix]
}

/// 可升級的實體協定
public protocol Upgradable {
    /// 當前等級
    var level: Int { get }
    
    /// 最大等級
    var maxLevel: Int { get }
    
    /// 是否可升級
    var canUpgrade: Bool { get }
    
    /// 執行升級
    /// - Throws: 升級失敗時拋出錯誤
    mutating func upgrade() throws
}

/// 可裝備的物品協定
public protocol Equippable {
    /// 裝備欄位
    var slot: EquipmentSlot { get }
    
    /// 等級需求
    var levelRequirement: Int { get }
    
    /// 檢查角色是否可裝備
    /// - Parameter characterLevel: 角色等級
    /// - Returns: 是否可裝備
    func canEquip(characterLevel: Int) -> Bool
}

/// 提供數值加成的協定
public protocol StatProvider {
    /// 基礎數值
    var baseStats: Stats { get }
    
    /// 計算總數值加成
    /// - Returns: 總數值
    func calculateTotalStats() -> Stats
}

// MARK: - Container Protocols

/// 物品容器協定
public protocol ItemContainer: Sequence where Element == Item {
    /// 容器容量
    var capacity: Int { get }
    
    /// 當前物品數量
    var count: Int { get }
    
    /// 是否已滿
    var isFull: Bool { get }
    
    /// 剩餘空間
    var remainingSpace: Int { get }
    
    /// 新增物品
    /// - Parameter item: 要新增的物品
    /// - Throws: 容量不足時拋出錯誤
    func add(_ item: Item) throws
    
    /// 移除物品
    /// - Parameter id: 物品 UUID
    /// - Returns: 被移除的物品
    /// - Throws: 物品不存在時拋出錯誤
    func remove(byId id: UUID) throws -> Item
    
    /// 檢查物品是否存在
    /// - Parameter id: 物品 UUID
    /// - Returns: 是否存在
    func contains(id: UUID) -> Bool
    
    /// 取得物品
    /// - Parameter id: 物品 UUID
    /// - Returns: 物品或 nil
    func getItem(byId id: UUID) -> Item?
}

/// 裝備欄協定
public protocol EquipmentSlotContainer {
    /// 已裝備的物品列表
    var equippedItems: [Item] { get }
    
    /// 已裝備數量
    var equippedCount: Int { get }
    
    /// 空的欄位
    var emptySlots: [EquipmentSlot] { get }
    
    /// 裝備物品
    /// - Parameters:
    ///   - item: 要裝備的物品
    ///   - characterLevel: 角色等級
    /// - Returns: 被替換的物品（如有）
    /// - Throws: 裝備失敗時拋出錯誤
    func equip(_ item: Item, characterLevel: Int) throws -> Item?
    
    /// 卸除裝備
    /// - Parameter slot: 裝備欄位
    /// - Returns: 被卸除的物品
    /// - Throws: 欄位為空時拋出錯誤
    func unequip(slot: EquipmentSlot) throws -> Item
    
    /// 取得特定欄位的裝備
    /// - Parameter slot: 裝備欄位
    /// - Returns: 裝備或 nil
    func getItem(at slot: EquipmentSlot) -> Item?
}

// MARK: - Service Protocols

/// 物品模板服務協定
public protocol ItemTemplateServiceProtocol {
    /// 根據 ID 取得模板
    /// - Parameter id: 模板 ID
    /// - Returns: 模板或 nil
    func getTemplate(byId id: String) -> ItemTemplate?
    
    /// 取得所有模板
    /// - Returns: 模板列表
    func getAllTemplates() -> [ItemTemplate]
    
    /// 根據欄位篩選模板
    /// - Parameter slot: 裝備欄位
    /// - Returns: 符合的模板列表
    func getTemplates(for slot: EquipmentSlot) -> [ItemTemplate]
    
    /// 根據稀有度篩選模板
    /// - Parameter rarity: 稀有度
    /// - Returns: 符合的模板列表
    func getTemplates(withRarity rarity: Rarity) -> [ItemTemplate]
    
    /// 載入模板資料
    /// - Parameter filename: JSON 檔名
    /// - Throws: 載入失敗時拋出錯誤
    func loadTemplates(from filename: String) throws
}

/// 套裝服務協定
public protocol EquipmentSetServiceProtocol {
    /// 根據 ID 取得套裝
    /// - Parameter id: 套裝 ID
    /// - Returns: 套裝或 nil
    func getSet(byId id: String) -> EquipmentSet?
    
    /// 取得所有套裝
    /// - Returns: 套裝列表
    func getAllSets() -> [EquipmentSet]
    
    /// 計算套裝效果
    /// - Parameter equippedItems: 已裝備物品列表
    /// - Returns: 啟動的套裝效果
    func calculateSetBonuses(for equippedItems: [Item]) -> [ActiveSetBonus]
    
    /// 載入套裝資料
    /// - Parameter filename: JSON 檔名
    /// - Throws: 載入失敗時拋出錯誤
    func loadSets(from filename: String) throws
}

/// 物品工廠協定
public protocol ItemFactoryProtocol {
    /// 從模板建立物品
    /// - Parameters:
    ///   - templateId: 模板 ID
    ///   - mainAffixType: 主詞條類型
    ///   - subAffixTypes: 副詞條類型列表
    /// - Returns: 新建立的物品
    /// - Throws: 建立失敗時拋出錯誤
    func createItem(
        templateId: String,
        mainAffixType: AffixType,
        subAffixTypes: [AffixType]
    ) throws -> Item
    
    /// 從模板隨機建立物品
    /// - Parameter templateId: 模板 ID
    /// - Returns: 新建立的物品
    /// - Throws: 建立失敗時拋出錯誤
    func createRandomItem(templateId: String) throws -> Item
}

// MARK: - Type Stubs (for compilation)

public struct Stats: Codable, Equatable {
    public var attack: Double
    public var defense: Double
    public var maxHP: Double
    public var maxMP: Double
    public var critRate: Double
    public var critDamage: Double
    public var speed: Double
    
    public static var zero: Stats {
        Stats(attack: 0, defense: 0, maxHP: 0, maxMP: 0, 
              critRate: 0, critDamage: 0, speed: 0)
    }
}

public struct AffixType: OptionSet, Codable, Hashable {
    public let rawValue: UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    
    public static let crit             = AffixType(rawValue: 1 << 0)
    public static let attack           = AffixType(rawValue: 1 << 2)
    public static let defense          = AffixType(rawValue: 1 << 3)
    public static let hp               = AffixType(rawValue: 1 << 4)
}

public struct Affix: Codable, Equatable {
    public let type: AffixType
    public var value: Double
    public let isPercentage: Bool
}

public enum EquipmentSlot: String, Codable, CaseIterable {
    case helmet, body, gloves, boots, belt
}

public enum Rarity: String, Codable, CaseIterable {
    case common, uncommon, rare, epic, legendary
}

public struct ItemTemplate: Codable {}
public struct EquipmentSet: Codable {}
public struct ActiveSetBonus {}
public class Item: Identifiable {
    public var id: UUID { UUID() }
}

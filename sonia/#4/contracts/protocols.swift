// MARK: - RPG Item System Protocols
// Feature: 003-rpg-item-system
// Date: 2026-01-30
//
// 這些協定定義了系統的公開介面契約。
// 實作類別必須遵循這些協定以確保可測試性和模組化。

import Foundation

// MARK: - Random Number Generator Protocol

/// 隨機數生成器協定，用於依賴注入以支援測試
protocol RandomNumberGenerating {
    /// 生成指定範圍內的隨機整數
    func randomInt(in range: Range<Int>) -> Int

    /// 生成指定範圍內的隨機浮點數
    func randomDouble(in range: ClosedRange<Double>) -> Double
}

// MARK: - Affix Generation Protocol

/// 詞條生成器協定
protocol AffixGenerating {
    /// 為指定欄位生成主詞條
    /// - Parameter slot: 裝備欄位
    /// - Returns: 生成的主詞條或錯誤
    func generateMainAffix(for slot: EquipmentSlot) -> Result<Affix, ItemSystemError>

    /// 為指定欄位生成副詞條
    /// - Parameters:
    ///   - slot: 裝備欄位
    ///   - rarity: 稀有度（決定副詞條數量）
    ///   - excluding: 要排除的詞條類型（避免重複）
    /// - Returns: 生成的副詞條列表或錯誤
    func generateSubAffixes(
        for slot: EquipmentSlot,
        rarity: Rarity,
        excluding: AffixType
    ) -> Result<[Affix], ItemSystemError>
}

// MARK: - Item Factory Protocol

/// 物品工廠協定
protocol ItemFactoryProtocol {
    /// 根據模板 ID 創建物品實例
    /// - Parameter templateId: 模板識別碼
    /// - Returns: 創建的物品實例或錯誤
    func createItem(from templateId: String) -> Result<Item, ItemSystemError>

    /// 根據模板創建物品實例
    /// - Parameter template: 物品模板
    /// - Returns: 創建的物品實例
    func createItem(from template: ItemTemplate) -> Item
}

// MARK: - Set Bonus Calculation Protocol

/// 套裝效果計算器協定
protocol SetBonusCalculating {
    /// 計算已裝備物品的套裝效果
    /// - Parameter equippedItems: 已裝備的物品列表
    /// - Returns: 生效的套裝效果列表
    func calculateBonuses(for equippedItems: [Item]) -> [SetBonus]

    /// 取得物品所屬的套裝 ID
    /// - Parameter templateId: 物品模板 ID
    /// - Returns: 套裝 ID（如果物品屬於某套裝）
    func setId(for templateId: String) -> String?
}

// MARK: - Template Loading Protocol

/// 模板載入器協定
protocol ItemTemplateLoading {
    /// 從 JSON 資料載入模板
    /// - Parameter jsonData: JSON 格式的資料
    /// - Returns: 模板列表或錯誤
    func load(from jsonData: Data) -> Result<[ItemTemplate], Error>

    /// 從 URL 載入模板
    /// - Parameter url: 檔案 URL
    /// - Returns: 模板列表或錯誤
    func load(from url: URL) -> Result<[ItemTemplate], Error>
}

// MARK: - Serialization Protocol

/// 物品序列化協定
protocol ItemSerializing {
    /// 序列化物品為 JSON 資料
    /// - Parameter item: 物品實例
    /// - Returns: JSON 資料或錯誤
    func serialize(_ item: Item) -> Result<Data, Error>

    /// 從 JSON 資料反序列化物品
    /// - Parameter data: JSON 資料
    /// - Returns: 物品實例或錯誤
    func deserialize(from data: Data) -> Result<Item, Error>
}

// MARK: - Inventory Protocol

/// 背包協定
protocol InventoryProtocol {
    /// 背包容量
    var capacity: Int { get }

    /// 當前物品數量
    var count: Int { get }

    /// 背包是否已滿
    var isFull: Bool { get }

    /// 背包是否為空
    var isEmpty: Bool { get }

    /// 添加物品到背包
    /// - Parameter item: 要添加的物品
    /// - Returns: 成功或錯誤
    func add(_ item: Item) -> Result<Void, ItemSystemError>

    /// 從背包移除物品
    /// - Parameter item: 要移除的物品
    /// - Returns: 移除的物品或錯誤
    func remove(_ item: Item) -> Result<Item, ItemSystemError>

    /// 檢查背包是否包含指定物品
    /// - Parameter item: 要檢查的物品
    /// - Returns: 是否包含
    func contains(_ item: Item) -> Bool

    /// 根據 ID 查詢物品
    /// - Parameter id: 物品實例 ID
    /// - Returns: 物品（如果存在）
    func item(withId id: UUID) -> Item?

    /// 取得所有物品
    /// - Returns: 物品列表
    func allItems() -> [Item]
}

// MARK: - Equipment Slots Protocol

/// 裝備欄協定
protocol EquipmentSlotsProtocol {
    /// 裝備物品到指定欄位
    /// - Parameters:
    ///   - item: 要裝備的物品
    ///   - slot: 目標欄位
    /// - Returns: 被替換的舊裝備（如有）或錯誤
    func equip(_ item: Item, to slot: EquipmentSlot) -> Result<Item?, ItemSystemError>

    /// 從指定欄位卸下裝備
    /// - Parameter slot: 目標欄位
    /// - Returns: 卸下的裝備或錯誤
    func unequip(from slot: EquipmentSlot) -> Result<Item, ItemSystemError>

    /// 取得指定欄位的裝備
    /// - Parameter slot: 目標欄位
    /// - Returns: 裝備（如果存在）
    func item(at slot: EquipmentSlot) -> Item?

    /// 取得所有已裝備的物品
    /// - Returns: 已裝備物品列表
    func allEquippedItems() -> [Item]

    /// 計算指定套裝的已裝備件數
    /// - Parameter setId: 套裝 ID
    /// - Returns: 已裝備件數
    func equippedCount(forSetId setId: String) -> Int
}

// MARK: - Avatar Protocol

/// 角色協定
protocol AvatarProtocol {
    /// 角色 ID
    var id: UUID { get }

    /// 角色名稱
    var name: String { get }

    /// 角色等級
    var level: Int { get }

    /// 基礎數值
    var baseStats: Stats { get }

    /// 計算穿戴所有裝備後的總數值
    var totalStats: Stats { get }

    /// 當前生效的套裝效果
    var activeSetBonuses: [SetBonus] { get }

    /// 裝備物品
    /// - Parameters:
    ///   - item: 要裝備的物品
    ///   - slot: 目標欄位
    /// - Returns: 成功或錯誤
    func equip(_ item: Item, to slot: EquipmentSlot) -> Result<Void, ItemSystemError>

    /// 卸下裝備
    /// - Parameter slot: 目標欄位
    /// - Returns: 成功或錯誤
    func unequip(from slot: EquipmentSlot) -> Result<Void, ItemSystemError>

    /// 檢查是否可以裝備指定物品
    /// - Parameter item: 要檢查的物品
    /// - Returns: 是否可以裝備
    func canEquip(_ item: Item) -> Bool
}

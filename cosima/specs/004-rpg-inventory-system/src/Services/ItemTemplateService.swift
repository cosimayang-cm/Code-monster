// MARK: - ItemTemplateService
// Feature: 004-rpg-inventory-system
// Task: TASK-023

import Foundation

/// 物品模板服務
public class ItemTemplateService {
    
    // MARK: - Properties
    
    /// 模板快取
    internal var templates: [String: ItemTemplate] = [:]
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - Load Methods
    
    /// 從 JSON 檔案載入模板
    /// - Parameter filename: JSON 檔名（不含副檔名）
    /// - Throws: 載入或解碼錯誤
    public func loadTemplates(from filename: String) throws {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw ItemError.serializationFailed(reason: "找不到檔案：\(filename).json")
        }
        
        let data = try Data(contentsOf: url)
        try loadTemplates(from: data)
    }
    
    /// 從 Data 載入模板
    /// - Parameter data: JSON Data
    /// - Throws: 解碼錯誤
    public func loadTemplates(from data: Data) throws {
        let decoder = JSONDecoder()
        let templateList = try decoder.decode([ItemTemplate].self, from: data)
        
        for template in templateList {
            templates[template.templateId] = template
        }
    }
    
    /// 直接註冊模板
    /// - Parameter template: 物品模板
    public func register(_ template: ItemTemplate) {
        templates[template.templateId] = template
    }
    
    /// 批量註冊模板
    /// - Parameter templateList: 模板列表
    public func register(_ templateList: [ItemTemplate]) {
        for template in templateList {
            templates[template.templateId] = template
        }
    }
    
    // MARK: - Query Methods
    
    /// 根據 ID 取得模板
    /// - Parameter id: 模板 ID
    /// - Returns: 模板或 nil
    public func getTemplate(byId id: String) -> ItemTemplate? {
        templates[id]
    }
    
    /// 取得所有模板
    /// - Returns: 模板列表
    public func getAllTemplates() -> [ItemTemplate] {
        Array(templates.values)
    }
    
    /// 根據欄位篩選模板
    /// - Parameter slot: 裝備欄位
    /// - Returns: 符合的模板列表
    public func getTemplates(for slot: EquipmentSlot) -> [ItemTemplate] {
        templates.values.filter { $0.slot == slot }
    }
    
    /// 根據稀有度篩選模板
    /// - Parameter rarity: 稀有度
    /// - Returns: 符合的模板列表
    public func getTemplates(withRarity rarity: Rarity) -> [ItemTemplate] {
        templates.values.filter { $0.rarity == rarity }
    }
    
    /// 根據套裝 ID 篩選模板
    /// - Parameter setId: 套裝 ID
    /// - Returns: 符合的模板列表
    public func getTemplates(forSet setId: String) -> [ItemTemplate] {
        templates.values.filter { $0.setId == setId }
    }
    
    /// 搜尋模板（根據名稱）
    /// - Parameter keyword: 關鍵字
    /// - Returns: 符合的模板列表
    public func searchTemplates(keyword: String) -> [ItemTemplate] {
        let lowercased = keyword.lowercased()
        return templates.values.filter {
            $0.name.lowercased().contains(lowercased) ||
            $0.description.lowercased().contains(lowercased)
        }
    }
    
    // MARK: - Statistics
    
    /// 模板總數
    public var count: Int {
        templates.count
    }
    
    /// 是否有模板
    public var isEmpty: Bool {
        templates.isEmpty
    }
    
    /// 清除所有模板
    public func clear() {
        templates.removeAll()
    }
}

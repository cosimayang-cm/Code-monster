// MARK: - EquipmentSetService
// Feature: 004-rpg-inventory-system
// Task: TASK-024

import Foundation

/// 套裝服務
public final class EquipmentSetService {
    
    // MARK: - Properties
    
    /// 套裝快取
    private var sets: [String: EquipmentSet] = [:]
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - Load Methods
    
    /// 從 JSON 檔案載入套裝
    /// - Parameter filename: JSON 檔名（不含副檔名）
    /// - Throws: 載入或解碼錯誤
    public func loadSets(from filename: String) throws {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw ItemError.serializationFailed(reason: "找不到檔案：\(filename).json")
        }
        
        let data = try Data(contentsOf: url)
        try loadSets(from: data)
    }
    
    /// 從 Data 載入套裝
    /// - Parameter data: JSON Data
    /// - Throws: 解碼錯誤
    public func loadSets(from data: Data) throws {
        let decoder = JSONDecoder()
        let setList = try decoder.decode([EquipmentSet].self, from: data)
        
        for set in setList {
            sets[set.setId] = set
        }
    }
    
    /// 直接註冊套裝
    /// - Parameter set: 套裝
    public func register(_ set: EquipmentSet) {
        sets[set.setId] = set
    }
    
    /// 批量註冊套裝
    /// - Parameter setList: 套裝列表
    public func register(_ setList: [EquipmentSet]) {
        for set in setList {
            sets[set.setId] = set
        }
    }
    
    // MARK: - Query Methods
    
    /// 根據 ID 取得套裝
    /// - Parameter id: 套裝 ID
    /// - Returns: 套裝或 nil
    public func getSet(byId id: String) -> EquipmentSet? {
        sets[id]
    }
    
    /// 取得所有套裝
    /// - Returns: 套裝列表
    public func getAllSets() -> [EquipmentSet] {
        Array(sets.values)
    }
    
    /// 搜尋套裝（根據名稱）
    /// - Parameter keyword: 關鍵字
    /// - Returns: 符合的套裝列表
    public func searchSets(keyword: String) -> [EquipmentSet] {
        let lowercased = keyword.lowercased()
        return sets.values.filter {
            $0.name.lowercased().contains(lowercased) ||
            $0.description.lowercased().contains(lowercased)
        }
    }
    
    /// 取得包含特定模板的套裝
    /// - Parameter templateId: 模板 ID
    /// - Returns: 符合的套裝列表
    public func getSets(containingTemplate templateId: String) -> [EquipmentSet] {
        sets.values.filter { $0.pieces.contains(templateId) }
    }
    
    // MARK: - Statistics
    
    /// 套裝總數
    public var count: Int {
        sets.count
    }
    
    /// 是否有套裝
    public var isEmpty: Bool {
        sets.isEmpty
    }
    
    /// 清除所有套裝
    public func clear() {
        sets.removeAll()
    }
}

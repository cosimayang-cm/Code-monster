// MARK: - ItemFactory
// Feature: 004-rpg-inventory-system
// Task: TASK-013

import Foundation

/// 物品工廠 - 負責從模板建立物品實例
public final class ItemFactory {
    
    // MARK: - Dependencies
    
    private let templateService: ItemTemplateService
    
    // MARK: - Initialization
    
    public init(templateService: ItemTemplateService) {
        self.templateService = templateService
    }
    
    // MARK: - Factory Methods
    
    /// 從模板建立物品（指定詞條）
    /// - Parameters:
    ///   - templateId: 模板 ID
    ///   - mainAffixType: 主詞條類型
    ///   - subAffixTypes: 副詞條類型列表
    /// - Returns: 新建立的物品
    /// - Throws: `ItemError` 如果模板不存在或詞條無效
    public func createItem(
        templateId: String,
        mainAffixType: AffixType,
        subAffixTypes: [AffixType] = []
    ) throws -> Item {
        // 取得模板
        guard let template = templateService.getTemplate(byId: templateId) else {
            throw ItemError.templateNotFound(id: templateId)
        }
        
        // 驗證主詞條
        guard AffixPool.shared.isValidMainAffix(mainAffixType, for: template.slot) else {
            throw ItemError.invalidAffixType(reason: "無效的主詞條類型：\(mainAffixType)")
        }
        
        // 生成主詞條
        guard let mainAffix = AffixValueCalculator.generateMainAffix(type: mainAffixType) else {
            throw ItemError.invalidAffixType(reason: "無法生成主詞條：\(mainAffixType)")
        }
        
        // 驗證並生成副詞條
        let validSubAffixTypes = validateSubAffixTypes(
            subAffixTypes,
            mainAffixType: mainAffixType,
            rarity: template.rarity
        )
        
        let subAffixes = AffixValueCalculator.generateSubAffixes(types: validSubAffixTypes)
        
        // 建立物品
        return Item(
            template: template,
            mainAffix: mainAffix,
            subAffixes: subAffixes
        )
    }
    
    /// 從模板隨機建立物品
    /// - Parameter templateId: 模板 ID
    /// - Returns: 新建立的物品
    /// - Throws: `ItemError` 如果模板不存在
    public func createRandomItem(templateId: String) throws -> Item {
        // 取得模板
        guard let template = templateService.getTemplate(byId: templateId) else {
            throw ItemError.templateNotFound(id: templateId)
        }
        
        // 隨機選取主詞條
        guard let mainAffixType = AffixPool.shared.randomMainAffix(for: template.slot),
              let mainAffix = AffixValueCalculator.generateMainAffix(type: mainAffixType) else {
            throw ItemError.invalidAffixType(reason: "無法生成隨機主詞條")
        }
        
        // 隨機選取副詞條
        let subAffixCount = template.initialSubAffixCount
        let subAffixTypes = AffixPool.shared.randomSubAffixes(
            count: subAffixCount,
            excluding: [mainAffixType]
        )
        
        let subAffixes = AffixValueCalculator.generateSubAffixes(types: subAffixTypes)
        
        // 建立物品
        return Item(
            template: template,
            mainAffix: mainAffix,
            subAffixes: subAffixes
        )
    }
    
    /// 批量隨機建立物品
    /// - Parameters:
    ///   - templateId: 模板 ID
    ///   - count: 數量
    /// - Returns: 物品陣列
    /// - Throws: `ItemError` 如果模板不存在
    public func createRandomItems(templateId: String, count: Int) throws -> [Item] {
        try (0..<count).map { _ in
            try createRandomItem(templateId: templateId)
        }
    }
    
    // MARK: - Private Methods
    
    /// 驗證並調整副詞條類型
    private func validateSubAffixTypes(
        _ types: [AffixType],
        mainAffixType: AffixType,
        rarity: Rarity
    ) -> [AffixType] {
        var validTypes: [AffixType] = []
        var usedMask = mainAffixType
        
        for type in types {
            // 檢查是否重複
            if usedMask.contains(type) {
                continue
            }
            
            // 檢查是否為有效的副詞條
            if !AffixPool.shared.isValidSubAffix(type) {
                continue
            }
            
            // 檢查是否超過上限
            if validTypes.count >= rarity.initialSubAffixCount {
                break
            }
            
            validTypes.append(type)
            usedMask.insert(type)
        }
        
        return validTypes
    }
}

// MARK: - Convenience Methods

extension ItemFactory {
    
    /// 建立測試用物品（使用內建測試模板）
    /// - Parameters:
    ///   - slot: 裝備欄位
    ///   - rarity: 稀有度
    ///   - level: 等級
    /// - Returns: 測試物品
    public func createTestItem(
        slot: EquipmentSlot = .helmet,
        rarity: Rarity = .rare,
        level: Int = 1
    ) -> Item {
        // 隨機選取主詞條
        let mainAffixType = AffixPool.shared.randomMainAffix(for: slot) ?? .hp
        let mainAffix = AffixValueCalculator.generateMainAffix(type: mainAffixType)
            ?? Affix(type: .hp, value: 10.0, isPercentage: true)
        
        // 隨機選取副詞條
        let subAffixTypes = AffixPool.shared.randomSubAffixes(
            count: rarity.initialSubAffixCount,
            excluding: [mainAffixType]
        )
        let subAffixes = AffixValueCalculator.generateSubAffixes(types: subAffixTypes)
        
        let item = Item(
            templateId: "test_\(slot.rawValue)_\(rarity.rawValue)",
            name: "測試\(slot.displayName)",
            description: "用於測試的\(rarity.displayName)\(slot.displayName)",
            slot: slot,
            rarity: rarity,
            level: level,
            maxLevel: 20,
            levelRequirement: 1,
            mainAffix: mainAffix,
            subAffixes: subAffixes
        )
        
        return item
    }
}

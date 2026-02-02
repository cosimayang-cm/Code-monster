//
//  ItemFactory.swift
//  CodeMonster
//
//  RPG 道具系統 - 物品工廠
//  Feature: 003-rpg-item-system
//
//  負責根據物品模板生成物品實例，管理所有已註冊的模板
//  US2: 系統可以根據物品模板生成物品實例，每個實例擁有全域唯一的識別碼
//
//  Created by CodeMonster on 2026/2/1.
//

import Foundation

/// 物品工廠
/// 負責管理物品模板並生成物品實例
final class ItemFactory {
    
    // MARK: - Properties
    
    /// 已註冊的模板字典（templateId -> ItemTemplate）
    private var templates: [String: ItemTemplate]
    
    // MARK: - Initialization
    
    /// 建立物品工廠
    /// - Parameter templates: 初始模板列表
    init(templates: [ItemTemplate] = []) {
        self.templates = Dictionary(uniqueKeysWithValues: templates.map { ($0.id, $0) })
    }
    
    // MARK: - Template Management
    
    /// 所有已註冊的模板
    var allTemplates: [ItemTemplate] {
        Array(templates.values)
    }
    
    /// 根據 ID 獲取模板
    /// - Parameter id: 模板 ID
    /// - Returns: 對應的模板，若不存在則回傳 nil
    func template(for id: String) -> ItemTemplate? {
        templates[id]
    }
    
    /// 根據裝備欄位過濾模板
    /// - Parameter slot: 裝備欄位
    /// - Returns: 該欄位的所有模板
    func templates(for slot: EquipmentSlot) -> [ItemTemplate] {
        templates.values.filter { $0.slot == slot }
    }
    
    /// 註冊新模板
    /// - Parameter template: 要註冊的模板
    func register(template: ItemTemplate) {
        templates[template.id] = template
    }
    
    /// 批次註冊模板
    /// - Parameter templatesArray: 要註冊的模板列表
    func register(templates templatesArray: [ItemTemplate]) {
        for template in templatesArray {
            templates[template.id] = template
        }
    }
    
    // MARK: - Item Creation
    
    /// 根據模板 ID 創建物品實例
    /// - Parameter templateId: 模板 ID
    /// - Returns: 新建立的物品實例
    /// - Throws: `ItemSystemError.templateNotFound` 若模板不存在
    func createItem(templateId: String) throws -> Item {
        guard let template = templates[templateId] else {
            throw ItemSystemError.templateNotFound(templateId: templateId)
        }
        return Item(template: template)
    }
    
    /// 根據模板創建物品實例
    /// - Parameter template: 物品模板
    /// - Returns: 新建立的物品實例
    func createItem(from template: ItemTemplate) -> Item {
        // 同時註冊模板（如果尚未註冊）
        if templates[template.id] == nil {
            register(template: template)
        }
        return Item(template: template)
    }
}

//
//  ItemSystemError.swift
//  CodeMonster
//
//  RPG 道具系統 - 錯誤類型定義
//  Feature: 003-rpg-item-system
//
//  定義物品系統中可能發生的所有錯誤類型
//
//  Created by CodeMonster on 2026/2/1.
//

import Foundation

/// 物品系統錯誤類型
enum ItemSystemError: Error, Equatable {
    
    // MARK: - Template Errors
    
    /// 模板不存在
    case templateNotFound(templateId: String)
    
    // MARK: - Equipment Errors
    
    /// 欄位不匹配（物品類型與欄位不符）
    case slotMismatch(itemSlot: EquipmentSlot, targetSlot: EquipmentSlot)
    
    /// 欄位為空（嘗試從空欄位卸下裝備）
    case slotEmpty(slot: EquipmentSlot)
    
    /// 等級需求不足
    case levelRequirementNotMet(required: Int, current: Int)
    
    // MARK: - Inventory Errors
    
    /// 背包已滿
    case inventoryFull(capacity: Int)
    
    /// 物品不存在於背包中
    case itemNotFound(itemId: UUID)
    
    // MARK: - Affix Errors
    
    /// 詞條池為空
    case emptyAffixPool
    
    // MARK: - Serialization Errors
    
    /// 序列化失敗
    case serializationFailed(reason: String)
    
    /// 反序列化失敗
    case deserializationFailed(reason: String)
}

// MARK: - LocalizedError

extension ItemSystemError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .templateNotFound(let templateId):
            return "找不到模板：\(templateId)"
            
        case .slotMismatch(let itemSlot, let targetSlot):
            return "裝備類型不匹配：\(itemSlot.displayName) 無法裝備到 \(targetSlot.displayName) 欄位"
            
        case .slotEmpty(let slot):
            return "\(slot.displayName) 欄位為空"
            
        case .levelRequirementNotMet(let required, let current):
            return "等級不足：需要 \(required) 級，目前 \(current) 級"
            
        case .inventoryFull(let capacity):
            return "背包已滿（容量：\(capacity)），請先清理空間"
            
        case .itemNotFound(let itemId):
            return "找不到物品：\(itemId)"
            
        case .emptyAffixPool:
            return "詞條池為空，無法生成詞條"
            
        case .serializationFailed(let reason):
            return "序列化失敗：\(reason)"
            
        case .deserializationFailed(let reason):
            return "反序列化失敗：\(reason)"
        }
    }
}

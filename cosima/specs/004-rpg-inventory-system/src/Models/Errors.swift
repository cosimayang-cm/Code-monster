// MARK: - Errors
// Feature: 004-rpg-inventory-system
// Task: TASK-006

import Foundation

// MARK: - Inventory Errors

/// 背包相關錯誤
public enum InventoryError: Error, Equatable {
    /// 背包已滿
    case full(capacity: Int)
    
    /// 物品不存在
    case itemNotFound(id: UUID)
    
    /// 無效的操作
    case invalidOperation(reason: String)
}

extension InventoryError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .full(let capacity):
            return "背包已滿（容量：\(capacity)）"
        case .itemNotFound(let id):
            return "找不到物品（ID：\(id)）"
        case .invalidOperation(let reason):
            return "無效的操作：\(reason)"
        }
    }
}

// MARK: - Equipment Errors

/// 裝備相關錯誤
public enum EquipmentError: Error, Equatable {
    /// 等級需求不足
    case levelRequirementNotMet(required: Int, current: Int)
    
    /// 欄位為空
    case slotEmpty(slot: EquipmentSlot)
    
    /// 欄位類型不符
    case slotMismatch(expected: EquipmentSlot, actual: EquipmentSlot)
    
    /// 物品無法裝備
    case notEquippable(reason: String)
}

extension EquipmentError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .levelRequirementNotMet(let required, let current):
            return "等級需求不足（需要：\(required)，目前：\(current)）"
        case .slotEmpty(let slot):
            return "裝備欄位為空（\(slot.displayName)）"
        case .slotMismatch(let expected, let actual):
            return "欄位類型不符（預期：\(expected.displayName)，實際：\(actual.displayName)）"
        case .notEquippable(let reason):
            return "物品無法裝備：\(reason)"
        }
    }
}

// MARK: - Item Errors

/// 物品相關錯誤
public enum ItemError: Error, Equatable {
    /// 模板不存在
    case templateNotFound(id: String)
    
    /// 已達最大等級
    case maxLevelReached(current: Int, max: Int)
    
    /// 副詞條已滿
    case maxSubAffixesReached(current: Int, max: Int)
    
    /// 詞條類型重複
    case duplicateAffixType(type: AffixType)
    
    /// 無效的詞條類型
    case invalidAffixType(reason: String)
    
    /// 序列化錯誤
    case serializationFailed(reason: String)
}

extension ItemError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .templateNotFound(let id):
            return "找不到物品模板（ID：\(id)）"
        case .maxLevelReached(let current, let max):
            return "已達最大等級（目前：\(current)，上限：\(max)）"
        case .maxSubAffixesReached(let current, let max):
            return "副詞條已滿（目前：\(current)，上限：\(max)）"
        case .duplicateAffixType(let type):
            return "詞條類型重複（\(type.displayName ?? "未知")）"
        case .invalidAffixType(let reason):
            return "無效的詞條類型：\(reason)"
        case .serializationFailed(let reason):
            return "序列化失敗：\(reason)"
        }
    }
}

// MARK: - Set Bonus Errors

/// 套裝效果相關錯誤
public enum SetBonusError: Error, Equatable {
    /// 套裝不存在
    case setNotFound(id: String)
    
    /// 件數不足
    case insufficientPieces(required: Int, current: Int)
}

extension SetBonusError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .setNotFound(let id):
            return "找不到套裝（ID：\(id)）"
        case .insufficientPieces(let required, let current):
            return "套裝件數不足（需要：\(required)，目前：\(current)）"
        }
    }
}

// MARK: - EquipmentSlot
// Feature: 004-rpg-inventory-system
// Task: TASK-002

import Foundation

/// 裝備欄位定義
public enum EquipmentSlot: String, Codable, CaseIterable, Hashable {
    /// 頭盔
    case helmet
    
    /// 身體護甲
    case body
    
    /// 手套
    case gloves
    
    /// 鞋子
    case boots
    
    /// 腰帶
    case belt
}

// MARK: - Display Properties

extension EquipmentSlot {
    
    /// 顯示名稱（繁體中文）
    public var displayName: String {
        switch self {
        case .helmet: return "頭盔"
        case .body: return "身體"
        case .gloves: return "手套"
        case .boots: return "鞋子"
        case .belt: return "腰帶"
        }
    }
    
    /// 圖示名稱
    public var iconName: String {
        switch self {
        case .helmet: return "icon_slot_helmet"
        case .body: return "icon_slot_body"
        case .gloves: return "icon_slot_gloves"
        case .boots: return "icon_slot_boots"
        case .belt: return "icon_slot_belt"
        }
    }
    
    /// 欄位索引（用於排序）
    public var sortIndex: Int {
        switch self {
        case .helmet: return 0
        case .body: return 1
        case .gloves: return 2
        case .boots: return 3
        case .belt: return 4
        }
    }
}

// MARK: - Comparable

extension EquipmentSlot: Comparable {
    public static func < (lhs: EquipmentSlot, rhs: EquipmentSlot) -> Bool {
        lhs.sortIndex < rhs.sortIndex
    }
}

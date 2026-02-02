// MARK: - Element
// Feature: 004-rpg-inventory-system
// 補充：元素類型

import Foundation

/// 元素類型
public enum Element: String, Codable, CaseIterable, Hashable {
    /// 火元素
    case fire
    
    /// 冰元素
    case ice
    
    /// 雷元素
    case lightning
    
    /// 毒元素
    case poison
}

// MARK: - Display Properties

extension Element {
    
    /// 顯示名稱
    public var displayName: String {
        switch self {
        case .fire: return "火"
        case .ice: return "冰"
        case .lightning: return "雷"
        case .poison: return "毒"
        }
    }
    
    /// 顯示顏色 (Hex)
    public var displayColorHex: String {
        switch self {
        case .fire: return "#FF4500"
        case .ice: return "#00BFFF"
        case .lightning: return "#9932CC"
        case .poison: return "#32CD32"
        }
    }
    
    /// 圖示名稱
    public var iconName: String {
        "icon_element_\(rawValue)"
    }
}

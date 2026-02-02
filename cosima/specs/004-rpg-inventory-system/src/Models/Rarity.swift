// MARK: - Rarity
// Feature: 004-rpg-inventory-system
// Task: TASK-003

import Foundation

/// 稀有度定義
public enum Rarity: String, Codable, CaseIterable, Hashable {
    /// 普通（白色）
    case common
    
    /// 優良（綠色）
    case uncommon
    
    /// 稀有（藍色）
    case rare
    
    /// 史詩（紫色）
    case epic
    
    /// 傳說（橘色）
    case legendary
}

// MARK: - Comparable

extension Rarity: Comparable {
    
    /// 稀有度排序值
    private var sortValue: Int {
        switch self {
        case .common: return 0
        case .uncommon: return 1
        case .rare: return 2
        case .epic: return 3
        case .legendary: return 4
        }
    }
    
    public static func < (lhs: Rarity, rhs: Rarity) -> Bool {
        lhs.sortValue < rhs.sortValue
    }
}

// MARK: - Sub-Affix Configuration

extension Rarity {
    
    /// 初始副詞條數量
    public var initialSubAffixCount: Int {
        switch self {
        case .common: return 0
        case .uncommon: return 1
        case .rare: return 2
        case .epic: return 3
        case .legendary: return 4
        }
    }
    
    /// 最大副詞條數量
    public var maxSubAffixCount: Int {
        switch self {
        case .common: return 0
        case .uncommon: return 2
        case .rare: return 3
        case .epic: return 4
        case .legendary: return 4
        }
    }
    
    /// 是否可擁有副詞條
    public var canHaveSubAffixes: Bool {
        maxSubAffixCount > 0
    }
}

// MARK: - Display Properties

extension Rarity {
    
    /// 顯示名稱（繁體中文）
    public var displayName: String {
        switch self {
        case .common: return "普通"
        case .uncommon: return "優良"
        case .rare: return "稀有"
        case .epic: return "史詩"
        case .legendary: return "傳說"
        }
    }
    
    /// 顯示顏色（Hex）
    public var displayColorHex: String {
        switch self {
        case .common: return "#FFFFFF"      // 白色
        case .uncommon: return "#00FF00"    // 綠色
        case .rare: return "#0080FF"        // 藍色
        case .epic: return "#A335EE"        // 紫色
        case .legendary: return "#FF8000"   // 橘色
        }
    }
    
    /// 星級（用於 UI 顯示）
    public var starCount: Int {
        switch self {
        case .common: return 1
        case .uncommon: return 2
        case .rare: return 3
        case .epic: return 4
        case .legendary: return 5
        }
    }
}

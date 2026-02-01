// MARK: - EquipmentSet
// Feature: 004-rpg-inventory-system
// Task: TASK-016

import Foundation

/// 套裝定義
public struct EquipmentSet: Codable, Equatable {
    
    // MARK: - Properties
    
    /// 套裝唯一識別碼
    public let setId: String
    
    /// 套裝名稱
    public let name: String
    
    /// 套裝描述
    public let description: String
    
    /// 包含的模板 ID 列表
    public let pieces: [String]
    
    /// 套裝效果列表
    public let bonuses: [SetBonus]
    
    // MARK: - Initialization
    
    public init(
        setId: String,
        name: String,
        description: String = "",
        pieces: [String],
        bonuses: [SetBonus]
    ) {
        self.setId = setId
        self.name = name
        self.description = description
        self.pieces = pieces
        self.bonuses = bonuses
    }
}

// MARK: - Identifiable

extension EquipmentSet: Identifiable {
    public var id: String { setId }
}

// MARK: - Computed Properties

extension EquipmentSet {
    
    /// 套裝件數
    public var pieceCount: Int {
        pieces.count
    }
    
    /// 可用的套裝效果門檻
    public var bonusThresholds: [Int] {
        bonuses.map { $0.requiredPieces }.sorted()
    }
    
    /// 最高套裝效果所需件數
    public var maxBonusThreshold: Int {
        bonusThresholds.max() ?? 0
    }
    
    /// 取得指定件數可啟動的效果
    /// - Parameter equippedCount: 已裝備件數
    /// - Returns: 可啟動的套裝效果列表
    public func activeBonuses(for equippedCount: Int) -> [SetBonus] {
        bonuses.filter { $0.requiredPieces <= equippedCount }
    }
}

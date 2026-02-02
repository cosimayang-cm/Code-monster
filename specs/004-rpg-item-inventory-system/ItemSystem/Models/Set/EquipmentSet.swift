import Foundation

/// 套裝定義
public struct EquipmentSet: Codable, Identifiable, Equatable {
    /// 套裝 ID
    public let setId: String

    /// 套裝名稱
    public let name: String

    /// 屬於此套裝的物品模板 ID 列表
    public let pieces: [String]

    /// 套裝效果（2 件套、4 件套）
    public let bonuses: [SetBonus]

    public var id: String { setId }

    public init(setId: String, name: String, pieces: [String], bonuses: [SetBonus]) {
        self.setId = setId
        self.name = name
        self.pieces = pieces
        self.bonuses = bonuses
    }

    /// 根據穿戴件數取得啟用的套裝效果
    public func getActiveBonuses(equippedCount: Int) -> [SetBonus] {
        bonuses.filter { $0.requiredPieces <= equippedCount }
    }
}

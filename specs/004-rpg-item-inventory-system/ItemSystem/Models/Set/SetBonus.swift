import Foundation

/// 套裝效果（2 件套或 4 件套）
public struct SetBonus: Codable, Equatable {
    /// 需要的套裝件數（2 或 4）
    public let requiredPieces: Int

    /// 效果
    public let effect: SetEffect

    /// 效果描述
    public let description: String

    public init(requiredPieces: Int, effect: SetEffect, description: String) {
        self.requiredPieces = requiredPieces
        self.effect = effect
        self.description = description
    }
}

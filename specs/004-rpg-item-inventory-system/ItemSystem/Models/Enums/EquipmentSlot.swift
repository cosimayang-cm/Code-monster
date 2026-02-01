import Foundation

/// 裝備欄位類型
public enum EquipmentSlot: String, Codable, CaseIterable, Sendable {
    case helmet = "helmet"
    case body = "body"
    case gloves = "gloves"
    case boots = "boots"
    case belt = "belt"
}

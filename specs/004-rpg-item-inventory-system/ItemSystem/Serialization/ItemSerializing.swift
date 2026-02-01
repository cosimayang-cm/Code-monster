import Foundation

/// 物品序列化協議
public protocol ItemSerializing {
    /// 將物品編碼為 JSON Data
    func encode(_ item: Item) throws -> Data

    /// 從 JSON Data 解碼物品
    func decode(_ data: Data) throws -> Item

    /// 將物品編碼為 JSON 字串
    func encodeToString(_ item: Item) throws -> String

    /// 從 JSON 字串解碼物品
    func decodeFromString(_ jsonString: String) throws -> Item
}

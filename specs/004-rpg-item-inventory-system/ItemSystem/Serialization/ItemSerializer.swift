import Foundation

/// 物品序列化服務
public class ItemSerializer: ItemSerializing {
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init() {
        self.encoder = JSONEncoder()
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.decoder = JSONDecoder()
    }

    /// 將物品編碼為 JSON Data
    public func encode(_ item: Item) throws -> Data {
        try encoder.encode(item)
    }

    /// 從 JSON Data 解碼物品
    public func decode(_ data: Data) throws -> Item {
        try decoder.decode(Item.self, from: data)
    }

    /// 將物品編碼為 JSON 字串
    public func encodeToString(_ item: Item) throws -> String {
        let data = try encode(item)
        guard let string = String(data: data, encoding: .utf8) else {
            throw SerializationError.encodingFailed
        }
        return string
    }

    /// 從 JSON 字串解碼物品
    public func decodeFromString(_ jsonString: String) throws -> Item {
        guard let data = jsonString.data(using: .utf8) else {
            throw SerializationError.decodingFailed
        }
        return try decode(data)
    }
}

/// 序列化錯誤
public enum SerializationError: Error {
    case encodingFailed
    case decodingFailed
    case fileNotFound
    case invalidFormat
}

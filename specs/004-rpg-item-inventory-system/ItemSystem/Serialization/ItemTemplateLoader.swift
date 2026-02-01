import Foundation

/// 物品模板載入器
public class ItemTemplateLoader {
    private let decoder: JSONDecoder

    public init() {
        self.decoder = JSONDecoder()
    }

    /// 從 JSON Data 載入模板列表
    public func load(from data: Data) throws -> [ItemTemplate] {
        try decoder.decode([ItemTemplate].self, from: data)
    }

    /// 從 JSON 字串載入模板列表
    public func load(from jsonString: String) throws -> [ItemTemplate] {
        guard let data = jsonString.data(using: .utf8) else {
            throw SerializationError.decodingFailed
        }
        return try load(from: data)
    }

    /// 從檔案路徑載入模板列表
    public func load(fromFile path: String) throws -> [ItemTemplate] {
        guard let data = FileManager.default.contents(atPath: path) else {
            throw SerializationError.fileNotFound
        }
        return try load(from: data)
    }
}

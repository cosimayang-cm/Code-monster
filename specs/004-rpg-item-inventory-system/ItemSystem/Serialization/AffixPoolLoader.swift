import Foundation

/// 詞條池載入器
public class AffixPoolLoader {
    private let decoder: JSONDecoder

    public init() {
        self.decoder = JSONDecoder()
    }

    /// 從 JSON Data 載入詞條池列表
    public func load(from data: Data) throws -> [AffixPool] {
        try decoder.decode([AffixPool].self, from: data)
    }

    /// 從 JSON 字串載入詞條池列表
    public func load(from jsonString: String) throws -> [AffixPool] {
        guard let data = jsonString.data(using: .utf8) else {
            throw SerializationError.decodingFailed
        }
        return try load(from: data)
    }

    /// 從檔案路徑載入詞條池列表
    public func load(fromFile path: String) throws -> [AffixPool] {
        guard let data = FileManager.default.contents(atPath: path) else {
            throw SerializationError.fileNotFound
        }
        return try load(from: data)
    }
}

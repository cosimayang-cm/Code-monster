//
//  ItemTemplateLoader.swift
//  CodeMonster
//
//  RPG 道具系統 - 物品模板載入器
//  Feature: 003-rpg-item-system
//
//  FR-022: 系統 MUST 支援從 JSON 檔案載入物品模板定義
//
//  Created by CodeMonster on 2026/2/1.
//

import Foundation

/// 物品模板載入器
/// 負責從 JSON 資料或 Bundle 資源載入物品模板
final class ItemTemplateLoader {
    
    // MARK: - Properties
    
    private let decoder: JSONDecoder
    
    // MARK: - Initialization
    
    /// 建立模板載入器
    /// - Parameter decoder: 自訂 JSONDecoder（可選）
    init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }
    
    // MARK: - Public Methods
    
    /// 從 JSON 資料載入物品模板
    /// - Parameter data: JSON 格式的資料
    /// - Returns: 物品模板陣列
    /// - Throws: 解碼失敗時拋出錯誤
    func load(from data: Data) throws -> [ItemTemplate] {
        do {
            return try decoder.decode([ItemTemplate].self, from: data)
        } catch {
            throw error
        }
    }
    
    /// 從 Bundle 資源載入物品模板
    /// - Parameters:
    ///   - resourceName: 資源檔案名稱（不含副檔名）
    ///   - extension: 檔案副檔名（預設為 "json"）
    ///   - bundle: Bundle（預設為 main bundle）
    /// - Returns: 物品模板陣列
    /// - Throws: 找不到資源或解碼失敗時拋出錯誤
    func load(
        fromResource resourceName: String,
        extension fileExtension: String = "json",
        bundle: Bundle = .main
    ) throws -> [ItemTemplate] {
        guard let url = bundle.url(forResource: resourceName, withExtension: fileExtension) else {
            throw ItemSystemError.resourceNotFound(name: "\(resourceName).\(fileExtension)")
        }
        
        let data = try Data(contentsOf: url)
        return try load(from: data)
    }
    
    /// 從 JSON 字串載入物品模板
    /// - Parameter jsonString: JSON 格式的字串
    /// - Returns: 物品模板陣列
    /// - Throws: 轉換或解碼失敗時拋出錯誤
    func load(fromString jsonString: String) throws -> [ItemTemplate] {
        guard let data = jsonString.data(using: .utf8) else {
            throw ItemSystemError.deserializationFailed(reason: "無法將字串轉換為 UTF-8 資料")
        }
        return try load(from: data)
    }
}

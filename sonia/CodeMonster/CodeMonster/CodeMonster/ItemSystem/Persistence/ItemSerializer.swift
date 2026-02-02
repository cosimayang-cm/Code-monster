//
//  ItemSerializer.swift
//  CodeMonster
//
//  RPG 道具系統 - 物品序列化器
//  Feature: 003-rpg-item-system
//
//  FR-023: 系統 MUST 支援物品實例的序列化和反序列化
//
//  Created by CodeMonster on 2026/2/1.
//

import Foundation

/// 物品序列化器
/// 負責物品和背包的序列化與反序列化
final class ItemSerializer {
    
    // MARK: - Properties
    
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    // MARK: - Initialization
    
    /// 建立序列化器
    /// - Parameters:
    ///   - encoder: 自訂 JSONEncoder（可選）
    ///   - decoder: 自訂 JSONDecoder（可選）
    init(encoder: JSONEncoder = JSONEncoder(), decoder: JSONDecoder = JSONDecoder()) {
        self.encoder = encoder
        self.decoder = decoder
    }
    
    // MARK: - Item Serialization
    
    /// 序列化單一物品
    /// - Parameters:
    ///   - item: 要序列化的物品
    ///   - prettyPrinted: 是否使用美化格式（預設為 false）
    /// - Returns: JSON 格式的資料
    /// - Throws: 序列化失敗時拋出錯誤
    func serialize(item: Item, prettyPrinted: Bool = false) throws -> Data {
        let encoder = self.encoder
        if prettyPrinted {
            encoder.outputFormatting = .prettyPrinted
        }
        return try encoder.encode(item)
    }
    
    /// 反序列化單一物品
    /// - Parameter data: JSON 格式的資料
    /// - Returns: 物品實例
    /// - Throws: 反序列化失敗時拋出錯誤
    func deserialize(itemData data: Data) throws -> Item {
        return try decoder.decode(Item.self, from: data)
    }
    
    // MARK: - Items Array Serialization
    
    /// 序列化物品陣列
    /// - Parameters:
    ///   - items: 要序列化的物品陣列
    ///   - prettyPrinted: 是否使用美化格式（預設為 false）
    /// - Returns: JSON 格式的資料
    /// - Throws: 序列化失敗時拋出錯誤
    func serialize(items: [Item], prettyPrinted: Bool = false) throws -> Data {
        let encoder = self.encoder
        if prettyPrinted {
            encoder.outputFormatting = .prettyPrinted
        }
        return try encoder.encode(items)
    }
    
    /// 反序列化物品陣列
    /// - Parameter data: JSON 格式的資料
    /// - Returns: 物品陣列
    /// - Throws: 反序列化失敗時拋出錯誤
    func deserialize(itemsData data: Data) throws -> [Item] {
        return try decoder.decode([Item].self, from: data)
    }
    
    // MARK: - Inventory Serialization
    
    /// 序列化背包
    /// - Parameters:
    ///   - inventory: 要序列化的背包
    ///   - prettyPrinted: 是否使用美化格式（預設為 false）
    /// - Returns: JSON 格式的資料
    /// - Throws: 序列化失敗時拋出錯誤
    func serialize(inventory: Inventory, prettyPrinted: Bool = false) throws -> Data {
        let encoder = self.encoder
        if prettyPrinted {
            encoder.outputFormatting = .prettyPrinted
        }
        return try encoder.encode(inventory)
    }
    
    /// 反序列化背包
    /// - Parameter data: JSON 格式的資料
    /// - Returns: 背包實例
    /// - Throws: 反序列化失敗時拋出錯誤
    func deserialize(inventoryData data: Data) throws -> Inventory {
        return try decoder.decode(Inventory.self, from: data)
    }
}

//
//  EquipmentSet.swift
//  CodeMonster
//
//  RPG 道具系統 - 套裝定義
//  Feature: 003-rpg-item-system
//
//  FR-018: 系統 MUST 支援套裝定義，包含所屬物品和套裝效果
//  FR-019: 系統 MUST 支援不同件數的套裝效果（如 2 件套、4 件套）
//
//  Created by CodeMonster on 2026/2/1.
//

import Foundation

// MARK: - SetBonus

/// 套裝效果
/// 定義達到特定穿戴件數時獲得的加成
struct SetBonus: Codable, Equatable {
    
    /// 觸發效果所需的最低穿戴件數
    let requiredPieces: Int
    
    /// 效果加成數值
    let bonusStats: Stats
    
    /// 效果描述（用於 UI 顯示）
    let description: String
    
    /// 建立套裝效果
    /// - Parameters:
    ///   - requiredPieces: 觸發效果所需的最低穿戴件數
    ///   - bonusStats: 效果加成數值
    ///   - description: 效果描述
    init(requiredPieces: Int, bonusStats: Stats, description: String) {
        self.requiredPieces = requiredPieces
        self.bonusStats = bonusStats
        self.description = description
    }
}

// MARK: - EquipmentSet

/// 套裝定義
/// 包含套裝所屬物品和各階段套裝效果
struct EquipmentSet: Codable, Equatable, Identifiable {
    
    // MARK: - Properties
    
    /// 套裝唯一識別碼
    let id: String
    
    /// 套裝名稱
    let name: String
    
    /// 套裝所包含的物品模板 ID 列表
    let pieceTemplateIds: [String]
    
    /// 套裝效果列表（依 requiredPieces 排序）
    let bonuses: [SetBonus]
    
    // MARK: - Initialization
    
    /// 建立套裝定義
    /// - Parameters:
    ///   - id: 套裝唯一識別碼
    ///   - name: 套裝名稱
    ///   - pieceTemplateIds: 套裝所包含的物品模板 ID 列表
    ///   - bonuses: 套裝效果列表
    init(id: String, name: String, pieceTemplateIds: [String], bonuses: [SetBonus]) {
        self.id = id
        self.name = name
        self.pieceTemplateIds = pieceTemplateIds
        self.bonuses = bonuses.sorted { $0.requiredPieces < $1.requiredPieces }
    }
    
    // MARK: - Public Methods
    
    /// 檢查指定模板 ID 是否屬於此套裝
    /// - Parameter templateId: 物品模板 ID
    /// - Returns: 是否屬於此套裝
    func contains(templateId: String) -> Bool {
        pieceTemplateIds.contains(templateId)
    }
    
    /// 取得指定穿戴件數下生效的套裝效果
    /// - Parameter equippedCount: 已穿戴的套裝件數
    /// - Returns: 所有生效的套裝效果
    func activeBonuses(forEquippedCount equippedCount: Int) -> [SetBonus] {
        bonuses.filter { $0.requiredPieces <= equippedCount }
    }
}

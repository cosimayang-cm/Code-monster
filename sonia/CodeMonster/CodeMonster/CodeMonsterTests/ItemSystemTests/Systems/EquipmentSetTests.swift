//
//  EquipmentSetTests.swift
//  CodeMonsterTests
//
//  RPG 道具系統 - 套裝測試
//  Feature: 003-rpg-item-system
//
//  Created by CodeMonster on 2026/2/1.
//

import XCTest
@testable import CodeMonster

final class EquipmentSetTests: XCTestCase {
    
    // MARK: - T074: testSetBonusInitializationSetsProperties
    
    /// 測試 SetBonus 初始化是否正確設定屬性
    /// FR-018: 系統 MUST 支援套裝定義，包含所屬物品和套裝效果
    func testSetBonusInitializationSetsProperties() {
        // Given
        let requiredPieces = 2
        let bonusStats = Stats(attack: 100, critRate: 0.1)
        let description = "攻擊力 +100, 暴擊率 +10%"
        
        // When
        let bonus = SetBonus(
            requiredPieces: requiredPieces,
            bonusStats: bonusStats,
            description: description
        )
        
        // Then
        XCTAssertEqual(bonus.requiredPieces, requiredPieces)
        XCTAssertEqual(bonus.bonusStats, bonusStats)
        XCTAssertEqual(bonus.description, description)
    }
    
    // MARK: - T075: testEquipmentSetContainsPiecesCorrectly
    
    /// 測試 EquipmentSet 是否正確包含套裝物品
    func testEquipmentSetContainsPiecesCorrectly() {
        // Given
        let setId = "gladiator_set"
        let pieceIds = ["gladiator_helmet", "gladiator_body", "gladiator_gloves", "gladiator_boots"]
        let twoPieceBonus = SetBonus(
            requiredPieces: 2,
            bonusStats: Stats(attack: 50),
            description: "攻擊力 +50"
        )
        let fourPieceBonus = SetBonus(
            requiredPieces: 4,
            bonusStats: Stats(critDamage: 0.3),
            description: "暴擊傷害 +30%"
        )
        
        // When
        let set = EquipmentSet(
            id: setId,
            name: "角鬥士套裝",
            pieceTemplateIds: pieceIds,
            bonuses: [twoPieceBonus, fourPieceBonus]
        )
        
        // Then
        XCTAssertEqual(set.id, setId)
        XCTAssertEqual(set.pieceTemplateIds.count, 4)
        XCTAssertTrue(set.pieceTemplateIds.contains("gladiator_helmet"))
        XCTAssertTrue(set.pieceTemplateIds.contains("gladiator_body"))
        XCTAssertEqual(set.bonuses.count, 2)
    }
    
    // MARK: - Additional Tests
    
    /// 測試套裝是否包含特定模板 ID
    func testEquipmentSetContainsTemplateId() {
        // Given
        let set = EquipmentSet(
            id: "test_set",
            name: "測試套裝",
            pieceTemplateIds: ["piece_a", "piece_b", "piece_c"],
            bonuses: []
        )
        
        // When & Then
        XCTAssertTrue(set.contains(templateId: "piece_a"))
        XCTAssertTrue(set.contains(templateId: "piece_b"))
        XCTAssertFalse(set.contains(templateId: "piece_d"))
    }
    
    /// 測試根據穿戴數量獲取生效的套裝效果
    func testEquipmentSetActiveBonuses() {
        // Given
        let twoPieceBonus = SetBonus(requiredPieces: 2, bonusStats: Stats(attack: 50), description: "2件套")
        let fourPieceBonus = SetBonus(requiredPieces: 4, bonusStats: Stats(attack: 100), description: "4件套")
        let set = EquipmentSet(
            id: "test_set",
            name: "測試套裝",
            pieceTemplateIds: ["a", "b", "c", "d"],
            bonuses: [twoPieceBonus, fourPieceBonus]
        )
        
        // When & Then
        XCTAssertEqual(set.activeBonuses(forEquippedCount: 1).count, 0)
        XCTAssertEqual(set.activeBonuses(forEquippedCount: 2).count, 1)
        XCTAssertEqual(set.activeBonuses(forEquippedCount: 3).count, 1)
        XCTAssertEqual(set.activeBonuses(forEquippedCount: 4).count, 2)
    }
    
    /// 測試 EquipmentSet 可以正確編碼和解碼
    func testEquipmentSetCodableEncodesAndDecodes() throws {
        // Given
        let bonus = SetBonus(requiredPieces: 2, bonusStats: Stats(defense: 30), description: "防禦 +30")
        let set = EquipmentSet(
            id: "test_set",
            name: "測試套裝",
            pieceTemplateIds: ["piece_1", "piece_2"],
            bonuses: [bonus]
        )
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        // When
        let data = try encoder.encode(set)
        let decoded = try decoder.decode(EquipmentSet.self, from: data)
        
        // Then
        XCTAssertEqual(decoded.id, set.id)
        XCTAssertEqual(decoded.name, set.name)
        XCTAssertEqual(decoded.pieceTemplateIds, set.pieceTemplateIds)
        XCTAssertEqual(decoded.bonuses.count, set.bonuses.count)
    }
}

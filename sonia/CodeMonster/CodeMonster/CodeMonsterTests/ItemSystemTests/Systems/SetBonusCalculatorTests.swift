//
//  SetBonusCalculatorTests.swift
//  CodeMonsterTests
//
//  RPG 道具系統 - 套裝效果計算器測試
//  Feature: 003-rpg-item-system
//
//  Created by CodeMonster on 2026/2/1.
//

import XCTest
@testable import CodeMonster

final class SetBonusCalculatorTests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: SetBonusCalculator!
    private var gladiatorSet: EquipmentSet!
    private var defenderSet: EquipmentSet!
    
    // MARK: - Test Helpers
    
    private func createTestItem(templateId: String, slot: EquipmentSlot, setId: String?) -> Item {
        let template = ItemTemplate(
            id: templateId,
            name: "測試裝備",
            description: "測試用",
            slot: slot,
            rarity: .epic,
            levelRequirement: 1,
            baseStats: Stats(defense: 10),
            iconName: "icon",
            setId: setId
        )
        return Item(template: template)
    }
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        
        // 角鬥士套裝（攻擊型）
        gladiatorSet = EquipmentSet(
            id: "gladiator_set",
            name: "角鬥士套裝",
            pieceTemplateIds: ["gladiator_helmet", "gladiator_body", "gladiator_gloves", "gladiator_boots"],
            bonuses: [
                SetBonus(requiredPieces: 2, bonusStats: Stats(attack: 50), description: "攻擊力 +50"),
                SetBonus(requiredPieces: 4, bonusStats: Stats(critDamage: 0.3), description: "暴擊傷害 +30%")
            ]
        )
        
        // 守護者套裝（防禦型）
        defenderSet = EquipmentSet(
            id: "defender_set",
            name: "守護者套裝",
            pieceTemplateIds: ["defender_helmet", "defender_body", "defender_gloves", "defender_boots"],
            bonuses: [
                SetBonus(requiredPieces: 2, bonusStats: Stats(defense: 30, maxHP: 200), description: "防禦 +30, 生命 +200"),
                SetBonus(requiredPieces: 4, bonusStats: Stats(maxHP: 500), description: "生命 +500")
            ]
        )
        
        sut = SetBonusCalculator(sets: [gladiatorSet, defenderSet])
    }
    
    override func tearDown() {
        sut = nil
        gladiatorSet = nil
        defenderSet = nil
        super.tearDown()
    }
    
    // MARK: - T078: testCalculateBonusesWhenTwoPiecesEquippedThenTwoPieceBonusActive
    
    /// 測試穿戴 2 件同套裝備時，2 件套效果生效
    /// US5-Scenario1: 玩家穿戴了 2 件同套裝備, 計算角色屬性, 2 件套效果生效並加成到角色數值
    func testCalculateBonusesWhenTwoPiecesEquippedThenTwoPieceBonusActive() {
        // Given
        let items = [
            createTestItem(templateId: "gladiator_helmet", slot: .helmet, setId: "gladiator_set"),
            createTestItem(templateId: "gladiator_body", slot: .body, setId: "gladiator_set")
        ]
        
        // When
        let bonusStats = sut.calculateBonusStats(for: items)
        
        // Then
        XCTAssertEqual(bonusStats.attack, 50, "2 件套效果應生效")
        XCTAssertEqual(bonusStats.critDamage, 0, "4 件套效果不應生效")
    }
    
    // MARK: - T079: testCalculateBonusesWhenFourPiecesEquippedThenBothBonusesActive
    
    /// 測試穿戴 4 件同套裝備時，2 件套和 4 件套效果都生效
    /// US5-Scenario2: 玩家穿戴了 4 件同套裝備, 計算角色屬性, 2 件套和 4 件套效果都生效
    func testCalculateBonusesWhenFourPiecesEquippedThenBothBonusesActive() {
        // Given
        let items = [
            createTestItem(templateId: "gladiator_helmet", slot: .helmet, setId: "gladiator_set"),
            createTestItem(templateId: "gladiator_body", slot: .body, setId: "gladiator_set"),
            createTestItem(templateId: "gladiator_gloves", slot: .gloves, setId: "gladiator_set"),
            createTestItem(templateId: "gladiator_boots", slot: .boots, setId: "gladiator_set")
        ]
        
        // When
        let bonusStats = sut.calculateBonusStats(for: items)
        
        // Then
        XCTAssertEqual(bonusStats.attack, 50, "2 件套效果應生效")
        XCTAssertEqual(bonusStats.critDamage, 0.3, accuracy: 0.001, "4 件套效果應生效")
    }
    
    // MARK: - T080: testCalculateBonusesWhenMixedSetsThenCorrectBonusesActive
    
    /// 測試穿戴混合套裝時，各自的套裝效果正確生效
    /// US5-Scenario3: 玩家穿戴了 2 件 A 套裝和 2 件 B 套裝, 計算角色屬性, A 和 B 的 2 件套效果都生效
    func testCalculateBonusesWhenMixedSetsThenCorrectBonusesActive() {
        // Given - 2 件角鬥士 + 2 件守護者
        let items = [
            createTestItem(templateId: "gladiator_helmet", slot: .helmet, setId: "gladiator_set"),
            createTestItem(templateId: "gladiator_body", slot: .body, setId: "gladiator_set"),
            createTestItem(templateId: "defender_gloves", slot: .gloves, setId: "defender_set"),
            createTestItem(templateId: "defender_boots", slot: .boots, setId: "defender_set")
        ]
        
        // When
        let bonusStats = sut.calculateBonusStats(for: items)
        
        // Then
        XCTAssertEqual(bonusStats.attack, 50, "角鬥士 2 件套效果應生效")
        XCTAssertEqual(bonusStats.defense, 30, "守護者 2 件套效果應生效")
        XCTAssertEqual(bonusStats.maxHP, 200, "守護者 2 件套生命加成應生效")
    }
    
    // MARK: - T081: testCalculateBonusesWhenBelowThresholdThenNoBonuses
    
    /// 測試穿戴數量低於門檻時，套裝效果不生效
    /// US5-Scenario4: 玩家卸下一件套裝裝備使同套數量低於門檻, 計算角色屬性, 對應的套裝效果消失
    func testCalculateBonusesWhenBelowThresholdThenNoBonuses() {
        // Given - 只穿 1 件
        let items = [
            createTestItem(templateId: "gladiator_helmet", slot: .helmet, setId: "gladiator_set")
        ]
        
        // When
        let bonusStats = sut.calculateBonusStats(for: items)
        
        // Then
        XCTAssertEqual(bonusStats, Stats.zero, "只穿 1 件時不應有套裝效果")
    }
    
    // MARK: - Additional Tests
    
    /// 測試空裝備列表
    func testCalculateBonusesWithEmptyItems() {
        // When
        let bonusStats = sut.calculateBonusStats(for: [])
        
        // Then
        XCTAssertEqual(bonusStats, Stats.zero)
    }
    
    /// 測試非套裝物品
    func testCalculateBonusesWithNonSetItems() {
        // Given - 物品沒有 setId
        let items = [
            createTestItem(templateId: "random_helmet", slot: .helmet, setId: nil),
            createTestItem(templateId: "random_body", slot: .body, setId: nil)
        ]
        
        // When
        let bonusStats = sut.calculateBonusStats(for: items)
        
        // Then
        XCTAssertEqual(bonusStats, Stats.zero)
    }
    
    /// 測試獲取當前生效的套裝效果列表
    func testGetActiveBonuses() {
        // Given
        let items = [
            createTestItem(templateId: "gladiator_helmet", slot: .helmet, setId: "gladiator_set"),
            createTestItem(templateId: "gladiator_body", slot: .body, setId: "gladiator_set"),
            createTestItem(templateId: "gladiator_gloves", slot: .gloves, setId: "gladiator_set"),
            createTestItem(templateId: "gladiator_boots", slot: .boots, setId: "gladiator_set")
        ]
        
        // When
        let activeBonuses = sut.getActiveBonuses(for: items)
        
        // Then
        XCTAssertEqual(activeBonuses.count, 2) // 2件套 + 4件套
    }
    
    /// 測試穿 3 件套裝（介於 2 和 4 之間）
    func testCalculateBonusesWithThreePieces() {
        // Given
        let items = [
            createTestItem(templateId: "gladiator_helmet", slot: .helmet, setId: "gladiator_set"),
            createTestItem(templateId: "gladiator_body", slot: .body, setId: "gladiator_set"),
            createTestItem(templateId: "gladiator_gloves", slot: .gloves, setId: "gladiator_set")
        ]
        
        // When
        let bonusStats = sut.calculateBonusStats(for: items)
        
        // Then
        XCTAssertEqual(bonusStats.attack, 50, "2 件套效果應生效")
        XCTAssertEqual(bonusStats.critDamage, 0, "4 件套效果不應生效（只有 3 件）")
    }
    
    /// 測試註冊新套裝
    func testRegisterNewSet() {
        // Given
        let newSet = EquipmentSet(
            id: "new_set",
            name: "新套裝",
            pieceTemplateIds: ["new_helmet", "new_body"],
            bonuses: [
                SetBonus(requiredPieces: 2, bonusStats: Stats(speed: 50), description: "速度 +50")
            ]
        )
        
        // When
        sut.register(set: newSet)
        let items = [
            createTestItem(templateId: "new_helmet", slot: .helmet, setId: "new_set"),
            createTestItem(templateId: "new_body", slot: .body, setId: "new_set")
        ]
        let bonusStats = sut.calculateBonusStats(for: items)
        
        // Then
        XCTAssertEqual(bonusStats.speed, 50)
    }
}

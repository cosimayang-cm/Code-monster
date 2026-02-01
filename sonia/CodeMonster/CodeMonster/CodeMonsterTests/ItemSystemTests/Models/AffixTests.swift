//
//  AffixTests.swift
//  CodeMonsterTests
//
//  RPG 道具系統 - 詞條測試
//  Feature: 003-rpg-item-system
//
//  Created by CodeMonster on 2026/2/1.
//

import XCTest
@testable import CodeMonster

final class AffixTests: XCTestCase {
    
    // MARK: - T052: testAffixInitializationSetsProperties
    
    /// 測試 Affix 初始化是否正確設定所有屬性
    /// FR-008: 每件裝備 MUST 擁有一個主詞條，數值隨裝備等級成長
    func testAffixInitializationSetsProperties() {
        // Given
        let type = AffixType.attack
        let value: Double = 50
        let isPercentage = false
        
        // When
        let affix = Affix(type: type, value: value, isPercentage: isPercentage)
        
        // Then
        XCTAssertEqual(affix.type, type)
        XCTAssertEqual(affix.value, value)
        XCTAssertEqual(affix.isPercentage, isPercentage)
    }
    
    // MARK: - T053: testAffixToStatsConvertsCorrectly
    
    /// 測試 Affix 轉換為 Stats 是否正確
    func testAffixToStatsConvertsCorrectly() {
        // Given - 固定加成詞條
        let attackAffix = Affix(type: .attack, value: 100, isPercentage: false)
        let defenseAffix = Affix(type: .defense, value: 50, isPercentage: false)
        let critRateAffix = Affix(type: .critRate, value: 0.1, isPercentage: false)
        
        // When
        let attackStats = attackAffix.toStats()
        let defenseStats = defenseAffix.toStats()
        let critRateStats = critRateAffix.toStats()
        
        // Then
        XCTAssertEqual(attackStats.attack, 100)
        XCTAssertEqual(attackStats.defense, 0)
        
        XCTAssertEqual(defenseStats.defense, 50)
        XCTAssertEqual(defenseStats.attack, 0)
        
        XCTAssertEqual(critRateStats.critRate, 0.1, accuracy: 0.001)
    }
    
    // MARK: - Additional Tests
    
    /// 測試百分比詞條
    func testPercentageAffix() {
        // Given
        let affix = Affix(type: .attackPercent, value: 0.2, isPercentage: true)
        
        // Then
        XCTAssertTrue(affix.isPercentage)
        XCTAssertEqual(affix.value, 0.2)
    }
    
    /// 測試所有固定加成詞條類型的轉換
    func testAllFlatAffixTypesToStats() {
        // Given
        let affixes: [(AffixType, Double, KeyPath<Stats, Double>)] = [
            (.attack, 100, \.attack),
            (.defense, 50, \.defense),
            (.maxHP, 500, \.maxHP),
            (.maxMP, 200, \.maxMP),
            (.critRate, 0.1, \.critRate),
            (.critDamage, 0.5, \.critDamage),
            (.speed, 30, \.speed)
        ]
        
        // When & Then
        for (type, value, keyPath) in affixes {
            let affix = Affix(type: type, value: value, isPercentage: false)
            let stats = affix.toStats()
            XCTAssertEqual(stats[keyPath: keyPath], value, "詞條類型 \(type) 轉換失敗")
        }
    }
    
    /// 測試 Affix 可以正確編碼和解碼
    func testAffixCodableEncodesAndDecodes() throws {
        // Given
        let affix = Affix(type: .critDamage, value: 0.5, isPercentage: false)
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        // When
        let data = try encoder.encode(affix)
        let decoded = try decoder.decode(Affix.self, from: data)
        
        // Then
        XCTAssertEqual(decoded.type, affix.type)
        XCTAssertEqual(decoded.value, affix.value)
        XCTAssertEqual(decoded.isPercentage, affix.isPercentage)
    }
    
    /// 測試詞條顯示名稱
    func testAffixDisplayName() {
        // Given
        let flatAffix = Affix(type: .attack, value: 100, isPercentage: false)
        let percentAffix = Affix(type: .attackPercent, value: 0.2, isPercentage: true)
        
        // When
        let flatDisplay = flatAffix.displayString
        let percentDisplay = percentAffix.displayString
        
        // Then
        XCTAssertTrue(flatDisplay.contains("100"), "固定加成應顯示數值")
        XCTAssertTrue(percentDisplay.contains("%"), "百分比加成應顯示百分比符號")
    }
}

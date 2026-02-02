//
//  AffixTypeTests.swift
//  CodeMonsterTests
//
//  RPG 道具系統 - 詞條類型測試
//  Feature: 003-rpg-item-system
//
//  Created by CodeMonster on 2026/2/1.
//

import XCTest
@testable import CodeMonster

final class AffixTypeTests: XCTestCase {
    
    // MARK: - T047: testAffixTypeContainsSingleType
    
    /// 測試 AffixType 可以包含單一類型
    /// FR-011: 系統 MUST 使用 Bitmask 支援詞條的快速查詢和組合判斷
    func testAffixTypeContainsSingleType() {
        // Given
        let attackType = AffixType.attack
        
        // When & Then
        XCTAssertTrue(attackType.contains(.attack))
        XCTAssertFalse(attackType.contains(.defense))
        XCTAssertFalse(attackType.contains(.critRate))
    }
    
    // MARK: - T048: testAffixTypeContainsMultipleTypes
    
    /// 測試 AffixType 可以包含多個類型
    func testAffixTypeContainsMultipleTypes() {
        // Given
        let combined: AffixType = [.attack, .critRate, .critDamage]
        
        // When & Then
        XCTAssertTrue(combined.contains(.attack))
        XCTAssertTrue(combined.contains(.critRate))
        XCTAssertTrue(combined.contains(.critDamage))
        XCTAssertFalse(combined.contains(.defense))
        XCTAssertFalse(combined.contains(.maxHP))
    }
    
    // MARK: - T049: testAffixTypeIsDisjointWithNoOverlap
    
    /// 測試 AffixType 的 isDisjoint 方法
    func testAffixTypeIsDisjointWithNoOverlap() {
        // Given
        let offensive: AffixType = [.attack, .critRate, .critDamage]
        let defensive: AffixType = [.defense, .maxHP]
        let mixed: AffixType = [.attack, .defense]
        
        // When & Then
        XCTAssertTrue(offensive.isDisjoint(with: defensive), "攻擊詞條和防禦詞條應該不重疊")
        XCTAssertFalse(offensive.isDisjoint(with: mixed), "攻擊詞條和混合詞條應該有重疊")
    }
    
    // MARK: - Additional Tests
    
    /// 測試所有基本詞條類型都已定義
    func testAllBasicAffixTypesAreDefined() {
        // 根據 FR-005 的數值類型
        XCTAssertNotEqual(AffixType.attack.rawValue, 0)
        XCTAssertNotEqual(AffixType.defense.rawValue, 0)
        XCTAssertNotEqual(AffixType.maxHP.rawValue, 0)
        XCTAssertNotEqual(AffixType.maxMP.rawValue, 0)
        XCTAssertNotEqual(AffixType.critRate.rawValue, 0)
        XCTAssertNotEqual(AffixType.critDamage.rawValue, 0)
        XCTAssertNotEqual(AffixType.speed.rawValue, 0)
    }
    
    /// 測試百分比版本的詞條類型
    func testPercentageAffixTypes() {
        XCTAssertNotEqual(AffixType.attackPercent.rawValue, 0)
        XCTAssertNotEqual(AffixType.defensePercent.rawValue, 0)
        XCTAssertNotEqual(AffixType.maxHPPercent.rawValue, 0)
        XCTAssertNotEqual(AffixType.speedPercent.rawValue, 0)
    }
    
    /// 測試各詞條類型的 rawValue 互不相同
    func testAffixTypeRawValuesAreUnique() {
        let allTypes: [AffixType] = [
            .attack, .defense, .maxHP, .maxMP,
            .critRate, .critDamage, .speed,
            .attackPercent, .defensePercent, .maxHPPercent, .speedPercent
        ]
        
        let uniqueRawValues = Set(allTypes.map { $0.rawValue })
        XCTAssertEqual(uniqueRawValues.count, allTypes.count, "所有詞條類型的 rawValue 應該互不相同")
    }
    
    /// 測試 union 操作
    func testAffixTypeUnion() {
        // Given
        let type1: AffixType = [.attack, .defense]
        let type2: AffixType = [.defense, .maxHP]
        
        // When
        let union = type1.union(type2)
        
        // Then
        XCTAssertTrue(union.contains(.attack))
        XCTAssertTrue(union.contains(.defense))
        XCTAssertTrue(union.contains(.maxHP))
    }
    
    /// 測試 intersection 操作
    func testAffixTypeIntersection() {
        // Given
        let type1: AffixType = [.attack, .defense, .maxHP]
        let type2: AffixType = [.defense, .maxHP, .speed]
        
        // When
        let intersection = type1.intersection(type2)
        
        // Then
        XCTAssertFalse(intersection.contains(.attack))
        XCTAssertTrue(intersection.contains(.defense))
        XCTAssertTrue(intersection.contains(.maxHP))
        XCTAssertFalse(intersection.contains(.speed))
    }
}

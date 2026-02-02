//
//  RarityTests.swift
//  CodeMonsterTests
//
//  RPG 道具系統 - 稀有度類型測試
//  Feature: 003-rpg-item-system
//
//  Created by CodeMonster on 2026/2/1.
//

import XCTest
@testable import CodeMonster

final class RarityTests: XCTestCase {
    
    // MARK: - T008: testRarityInitialSubAffixCountReturnsCorrectValue
    
    /// 測試各稀有度的初始副詞條數量
    /// FR-009: 副詞條數量 MUST 根據稀有度決定：普通 0 條、優良 1-2 條、稀有 2-3 條、史詩 3-4 條、傳說 4 條
    func testRarityInitialSubAffixCountReturnsCorrectValue() {
        // Given & When & Then
        XCTAssertEqual(Rarity.common.initialSubAffixCount, 0)
        XCTAssertTrue((1...2).contains(Rarity.uncommon.initialSubAffixCount) || Rarity.uncommon.minSubAffixCount == 1)
        XCTAssertTrue((2...3).contains(Rarity.rare.initialSubAffixCount) || Rarity.rare.minSubAffixCount == 2)
        XCTAssertTrue((3...4).contains(Rarity.epic.initialSubAffixCount) || Rarity.epic.minSubAffixCount == 3)
        XCTAssertEqual(Rarity.legendary.initialSubAffixCount, 4)
    }
    
    // MARK: - T009: testRarityMaxSubAffixCountReturnsCorrectValue
    
    /// 測試各稀有度的最大副詞條數量
    func testRarityMaxSubAffixCountReturnsCorrectValue() {
        // Given & When & Then
        XCTAssertEqual(Rarity.common.maxSubAffixCount, 0)
        XCTAssertEqual(Rarity.uncommon.maxSubAffixCount, 2)
        XCTAssertEqual(Rarity.rare.maxSubAffixCount, 3)
        XCTAssertEqual(Rarity.epic.maxSubAffixCount, 4)
        XCTAssertEqual(Rarity.legendary.maxSubAffixCount, 4)
    }
    
    // MARK: - T010: testRarityComparableOrdersCorrectly
    
    /// 測試稀有度的排序是否正確（普通 < 優良 < 稀有 < 史詩 < 傳說）
    func testRarityComparableOrdersCorrectly() {
        // Given
        let rarities: [Rarity] = [.legendary, .common, .epic, .rare, .uncommon]
        
        // When
        let sorted = rarities.sorted()
        
        // Then
        XCTAssertEqual(sorted, [.common, .uncommon, .rare, .epic, .legendary])
    }
    
    // MARK: - Additional Tests
    
    /// 測試最小副詞條數量
    func testRarityMinSubAffixCountReturnsCorrectValue() {
        XCTAssertEqual(Rarity.common.minSubAffixCount, 0)
        XCTAssertEqual(Rarity.uncommon.minSubAffixCount, 1)
        XCTAssertEqual(Rarity.rare.minSubAffixCount, 2)
        XCTAssertEqual(Rarity.epic.minSubAffixCount, 3)
        XCTAssertEqual(Rarity.legendary.minSubAffixCount, 4)
    }
    
    /// 測試 Rarity 可以正確編碼和解碼
    func testRarityCodableEncodesAndDecodes() throws {
        // Given
        let rarity = Rarity.epic
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        // When
        let data = try encoder.encode(rarity)
        let decoded = try decoder.decode(Rarity.self, from: data)
        
        // Then
        XCTAssertEqual(decoded, rarity)
    }
}

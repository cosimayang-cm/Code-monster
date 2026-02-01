//
//  StatsTests.swift
//  CodeMonsterTests
//
//  RPG 道具系統 - 數值結構測試
//  Feature: 003-rpg-item-system
//
//  Created by CodeMonster on 2026/2/1.
//

import XCTest
@testable import CodeMonster

final class StatsTests: XCTestCase {
    
    // MARK: - T013: testStatsAdditionCombinesValues
    
    /// 測試 Stats 加法運算是否正確合併數值
    /// FR-005: 系統 MUST 支援以下角色數值：攻擊力、防禦力、最大生命、最大魔力、暴擊率、暴擊傷害、速度
    func testStatsAdditionCombinesValues() {
        // Given
        let stats1 = Stats(
            attack: 100,
            defense: 50,
            maxHP: 1000,
            maxMP: 200,
            critRate: 0.1,
            critDamage: 0.5,
            speed: 100
        )
        let stats2 = Stats(
            attack: 50,
            defense: 30,
            maxHP: 500,
            maxMP: 100,
            critRate: 0.05,
            critDamage: 0.2,
            speed: 20
        )
        
        // When
        let result = stats1 + stats2
        
        // Then
        XCTAssertEqual(result.attack, 150)
        XCTAssertEqual(result.defense, 80)
        XCTAssertEqual(result.maxHP, 1500)
        XCTAssertEqual(result.maxMP, 300)
        XCTAssertEqual(result.critRate, 0.15, accuracy: 0.001)
        XCTAssertEqual(result.critDamage, 0.7, accuracy: 0.001)
        XCTAssertEqual(result.speed, 120)
    }
    
    // MARK: - T014: testStatsMultiplicationScalesValues
    
    /// 測試 Stats 乘法運算是否正確縮放數值
    func testStatsMultiplicationScalesValues() {
        // Given
        let stats = Stats(
            attack: 100,
            defense: 50,
            maxHP: 1000,
            maxMP: 200,
            critRate: 0.1,
            critDamage: 0.5,
            speed: 100
        )
        let multiplier = 1.5
        
        // When
        let result = stats * multiplier
        
        // Then
        XCTAssertEqual(result.attack, 150)
        XCTAssertEqual(result.defense, 75)
        XCTAssertEqual(result.maxHP, 1500)
        XCTAssertEqual(result.maxMP, 300)
        XCTAssertEqual(result.critRate, 0.15, accuracy: 0.001)
        XCTAssertEqual(result.critDamage, 0.75, accuracy: 0.001)
        XCTAssertEqual(result.speed, 150)
    }
    
    // MARK: - T015: testStatsZeroReturnsAllZeros
    
    /// 測試 Stats.zero 是否回傳全零的數值
    func testStatsZeroReturnsAllZeros() {
        // Given & When
        let zeroStats = Stats.zero
        
        // Then
        XCTAssertEqual(zeroStats.attack, 0)
        XCTAssertEqual(zeroStats.defense, 0)
        XCTAssertEqual(zeroStats.maxHP, 0)
        XCTAssertEqual(zeroStats.maxMP, 0)
        XCTAssertEqual(zeroStats.critRate, 0)
        XCTAssertEqual(zeroStats.critDamage, 0)
        XCTAssertEqual(zeroStats.speed, 0)
    }
    
    // MARK: - Additional Tests
    
    /// 測試 Stats 與零相加後不變
    func testStatsAdditionWithZeroReturnsOriginal() {
        // Given
        let stats = Stats(
            attack: 100,
            defense: 50,
            maxHP: 1000,
            maxMP: 200,
            critRate: 0.1,
            critDamage: 0.5,
            speed: 100
        )
        
        // When
        let result = stats + Stats.zero
        
        // Then
        XCTAssertEqual(result, stats)
    }
    
    /// 測試 Stats 乘以 1 後不變
    func testStatsMultiplicationByOneReturnsOriginal() {
        // Given
        let stats = Stats(
            attack: 100,
            defense: 50,
            maxHP: 1000,
            maxMP: 200,
            critRate: 0.1,
            critDamage: 0.5,
            speed: 100
        )
        
        // When
        let result = stats * 1.0
        
        // Then
        XCTAssertEqual(result.attack, stats.attack)
        XCTAssertEqual(result.defense, stats.defense)
        XCTAssertEqual(result.maxHP, stats.maxHP)
        XCTAssertEqual(result.maxMP, stats.maxMP)
    }
    
    /// 測試 Stats 可以正確編碼和解碼
    func testStatsCodableEncodesAndDecodes() throws {
        // Given
        let stats = Stats(
            attack: 100,
            defense: 50,
            maxHP: 1000,
            maxMP: 200,
            critRate: 0.1,
            critDamage: 0.5,
            speed: 100
        )
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        // When
        let data = try encoder.encode(stats)
        let decoded = try decoder.decode(Stats.self, from: data)
        
        // Then
        XCTAssertEqual(decoded, stats)
    }
    
    /// 測試 += 運算子
    func testStatsAddAssignOperator() {
        // Given
        var stats = Stats(attack: 100, defense: 50, maxHP: 1000, maxMP: 200, critRate: 0.1, critDamage: 0.5, speed: 100)
        let bonus = Stats(attack: 20, defense: 10, maxHP: 200, maxMP: 50, critRate: 0.05, critDamage: 0.1, speed: 10)
        
        // When
        stats += bonus
        
        // Then
        XCTAssertEqual(stats.attack, 120)
        XCTAssertEqual(stats.defense, 60)
    }
}

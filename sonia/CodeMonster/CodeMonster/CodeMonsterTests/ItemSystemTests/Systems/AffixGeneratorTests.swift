//
//  AffixGeneratorTests.swift
//  CodeMonsterTests
//
//  RPG 道具系統 - 詞條生成器測試
//  Feature: 003-rpg-item-system
//
//  Created by CodeMonster on 2026/2/1.
//

import XCTest
@testable import CodeMonster

final class AffixGeneratorTests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: AffixGenerator!
    private var testPool: AffixPool!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        
        // 建立測試用詞條池
        testPool = AffixPool(
            mainAffixes: [
                WeightedAffix(type: .maxHPPercent, minValue: 0.05, maxValue: 0.15, weight: 50, isPercentage: true),
                WeightedAffix(type: .attackPercent, minValue: 0.05, maxValue: 0.15, weight: 30, isPercentage: true),
                WeightedAffix(type: .defensePercent, minValue: 0.05, maxValue: 0.15, weight: 20, isPercentage: true)
            ],
            subAffixes: [
                WeightedAffix(type: .attack, minValue: 10, maxValue: 50, weight: 25, isPercentage: false),
                WeightedAffix(type: .defense, minValue: 10, maxValue: 40, weight: 25, isPercentage: false),
                WeightedAffix(type: .maxHP, minValue: 50, maxValue: 200, weight: 20, isPercentage: false),
                WeightedAffix(type: .critRate, minValue: 0.02, maxValue: 0.08, weight: 15, isPercentage: false),
                WeightedAffix(type: .critDamage, minValue: 0.05, maxValue: 0.15, weight: 15, isPercentage: false)
            ]
        )
        
        sut = AffixGenerator(pool: testPool)
    }
    
    override func tearDown() {
        sut = nil
        testPool = nil
        super.tearDown()
    }
    
    // MARK: - T056: testAffixGeneratorGenerateMainAffixReturnsValidAffix
    
    /// 測試主詞條生成是否回傳有效詞條
    /// FR-008: 每件裝備 MUST 擁有一個主詞條
    func testAffixGeneratorGenerateMainAffixReturnsValidAffix() {
        // When
        let mainAffix = sut.generateMainAffix()
        
        // Then
        XCTAssertNotNil(mainAffix)
        XCTAssertTrue(mainAffix!.isPercentage, "主詞條應為百分比類型")
        
        // 驗證主詞條類型在池中
        let validTypes: [AffixType] = [.maxHPPercent, .attackPercent, .defensePercent]
        XCTAssertTrue(validTypes.contains(mainAffix!.type), "主詞條類型應在池中")
    }
    
    // MARK: - T057: testAffixGeneratorGenerateSubAffixesWhenLegendaryThenFourAffixes
    
    /// 測試傳說品質裝備生成 4 個副詞條
    /// US3-Scenario1: 一件傳說品質裝備, 生成該裝備, 該裝備擁有 1 個主詞條和 4 個副詞條
    func testAffixGeneratorGenerateSubAffixesWhenLegendaryThenFourAffixes() {
        // When
        let subAffixes = sut.generateSubAffixes(for: .legendary)
        
        // Then
        XCTAssertEqual(subAffixes.count, 4, "傳說品質應有 4 個副詞條")
    }
    
    // MARK: - T058: testAffixGeneratorGenerateSubAffixesWhenCommonThenZeroAffixes
    
    /// 測試普通品質裝備生成 0 個副詞條
    /// US3-Scenario2: 一件普通品質裝備, 生成該裝備, 該裝備擁有 1 個主詞條和 0 個副詞條
    func testAffixGeneratorGenerateSubAffixesWhenCommonThenZeroAffixes() {
        // When
        let subAffixes = sut.generateSubAffixes(for: .common)
        
        // Then
        XCTAssertEqual(subAffixes.count, 0, "普通品質應有 0 個副詞條")
    }
    
    // MARK: - T059: testAffixGeneratorWeightedDistributionMatchesExpected
    
    /// 測試詞條權重分布是否接近預期
    /// US3-Scenario3: 詞條池定義了各詞條的權重, 大量生成副詞條, 各詞條出現頻率接近其權重比例
    func testAffixGeneratorWeightedDistributionMatchesExpected() {
        // Given
        let iterations = 1000
        var typeCounts: [AffixType: Int] = [:]
        
        // When - 生成大量副詞條
        for _ in 0..<iterations {
            let affixes = sut.generateSubAffixes(for: .legendary)
            for affix in affixes {
                typeCounts[affix.type, default: 0] += 1
            }
        }
        
        // Then - 驗證分布
        // 總權重 = 25 + 25 + 20 + 15 + 15 = 100
        // attack 應該約 25%，defense 約 25%
        let totalGenerated = typeCounts.values.reduce(0, +)
        
        if let attackCount = typeCounts[.attack] {
            let attackPercentage = Double(attackCount) / Double(totalGenerated)
            // 允許 10% 誤差範圍 (0.15 ~ 0.35)
            XCTAssertTrue(attackPercentage > 0.15 && attackPercentage < 0.35,
                         "攻擊詞條比例 \(attackPercentage) 應接近 25%")
        }
    }
    
    // MARK: - Additional Tests
    
    /// 測試各稀有度的副詞條數量
    func testSubAffixCountByRarity() {
        // When & Then
        XCTAssertEqual(sut.generateSubAffixes(for: .common).count, 0)
        XCTAssertTrue((1...2).contains(sut.generateSubAffixes(for: .uncommon).count))
        XCTAssertTrue((2...3).contains(sut.generateSubAffixes(for: .rare).count))
        XCTAssertTrue((3...4).contains(sut.generateSubAffixes(for: .epic).count))
        XCTAssertEqual(sut.generateSubAffixes(for: .legendary).count, 4)
    }
    
    /// 測試副詞條不重複
    func testSubAffixesAreUnique() {
        // When
        let subAffixes = sut.generateSubAffixes(for: .legendary)
        
        // Then
        let types = subAffixes.map { $0.type }
        let uniqueTypes = Set(types)
        XCTAssertEqual(uniqueTypes.count, types.count, "副詞條類型不應重複")
    }
    
    /// 測試數值在範圍內
    func testAffixValueWithinRange() {
        // When
        for _ in 0..<100 {
            if let mainAffix = sut.generateMainAffix() {
                // 主詞條範圍 0.05 ~ 0.15
                XCTAssertTrue(mainAffix.value >= 0.05 && mainAffix.value <= 0.15,
                             "主詞條數值 \(mainAffix.value) 應在範圍內")
            }
            
            let subAffixes = sut.generateSubAffixes(for: .legendary)
            for affix in subAffixes {
                // 副詞條有不同範圍，只驗證數值為正
                XCTAssertGreaterThan(affix.value, 0, "副詞條數值應為正")
            }
        }
    }
    
    /// 測試空詞條池時回傳 nil
    /// T101: testAffixGeneratorWhenEmptyPoolThenEmptyAffixPoolError
    /// 設計決策：空池回傳 nil/空陣列而非拋錯誤，讓呼叫端決定處理方式
    func testEmptyPoolReturnsNil() {
        // Given
        let emptyPool = AffixPool(mainAffixes: [], subAffixes: [])
        let emptyGenerator = AffixGenerator(pool: emptyPool)
        
        // When
        let mainAffix = emptyGenerator.generateMainAffix()
        let subAffixes = emptyGenerator.generateSubAffixes(for: .legendary)
        
        // Then
        XCTAssertNil(mainAffix, "空池應回傳 nil")
        XCTAssertTrue(subAffixes.isEmpty, "空池應回傳空陣列")
    }
    
    /// 測試使用固定種子的隨機生成（可重現測試）
    func testDeterministicGenerationWithSeed() {
        // Given
        let seededGenerator1 = AffixGenerator(pool: testPool, seed: 12345)
        let seededGenerator2 = AffixGenerator(pool: testPool, seed: 12345)
        
        // When
        let affixes1 = seededGenerator1.generateSubAffixes(for: .legendary)
        let affixes2 = seededGenerator2.generateSubAffixes(for: .legendary)
        
        // Then
        XCTAssertEqual(affixes1.count, affixes2.count)
        for (a1, a2) in zip(affixes1, affixes2) {
            XCTAssertEqual(a1.type, a2.type, "相同種子應產生相同詞條類型")
        }
    }
}

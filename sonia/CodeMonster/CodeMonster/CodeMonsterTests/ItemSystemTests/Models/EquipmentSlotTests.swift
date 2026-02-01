//
//  EquipmentSlotTests.swift
//  CodeMonsterTests
//
//  RPG 道具系統 - 裝備欄位類型測試
//  Feature: 003-rpg-item-system
//
//  Created by CodeMonster on 2026/2/1.
//

import XCTest
@testable import CodeMonster

final class EquipmentSlotTests: XCTestCase {
    
    // MARK: - T004: testEquipmentSlotRawValuesAreCorrect
    
    /// 測試 EquipmentSlot 的原始值是否正確
    /// FR-001: 系統 MUST 支援 5 個裝備欄位：頭盔(helmet)、身體(body)、手套(gloves)、鞋子(boots)、腰帶(belt)
    func testEquipmentSlotRawValuesAreCorrect() {
        // Given & When & Then
        XCTAssertEqual(EquipmentSlot.helmet.rawValue, "helmet")
        XCTAssertEqual(EquipmentSlot.body.rawValue, "body")
        XCTAssertEqual(EquipmentSlot.gloves.rawValue, "gloves")
        XCTAssertEqual(EquipmentSlot.boots.rawValue, "boots")
        XCTAssertEqual(EquipmentSlot.belt.rawValue, "belt")
    }
    
    // MARK: - T005: testEquipmentSlotCaseIterableReturnsAllCases
    
    /// 測試 EquipmentSlot 的 CaseIterable 是否回傳所有 5 個欄位
    func testEquipmentSlotCaseIterableReturnsAllCases() {
        // Given
        let expectedCount = 5
        
        // When
        let allCases = EquipmentSlot.allCases
        
        // Then
        XCTAssertEqual(allCases.count, expectedCount)
        XCTAssertTrue(allCases.contains(.helmet))
        XCTAssertTrue(allCases.contains(.body))
        XCTAssertTrue(allCases.contains(.gloves))
        XCTAssertTrue(allCases.contains(.boots))
        XCTAssertTrue(allCases.contains(.belt))
    }
    
    // MARK: - Codable Tests
    
    /// 測試 EquipmentSlot 可以正確編碼和解碼
    func testEquipmentSlotCodableEncodesAndDecodes() throws {
        // Given
        let slot = EquipmentSlot.helmet
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        // When
        let data = try encoder.encode(slot)
        let decoded = try decoder.decode(EquipmentSlot.self, from: data)
        
        // Then
        XCTAssertEqual(decoded, slot)
    }
}

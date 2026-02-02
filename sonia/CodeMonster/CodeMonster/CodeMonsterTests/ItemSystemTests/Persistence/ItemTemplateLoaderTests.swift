//
//  ItemTemplateLoaderTests.swift
//  CodeMonsterTests
//
//  RPG 道具系統 - 物品模板載入器測試
//  Feature: 003-rpg-item-system
//
//  Created by CodeMonster on 2026/2/1.
//

import XCTest
@testable import CodeMonster

final class ItemTemplateLoaderTests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: ItemTemplateLoader!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        sut = ItemTemplateLoader()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - T090: testLoadFromJsonDataWhenValidThenReturnsTemplates
    
    /// 測試從有效 JSON 資料載入物品模板
    /// US7-Scenario1: 系統從 JSON 檔案載入物品模板定義, JSON 格式正確, 所有模板成功載入並可被 ItemFactory 使用
    func testLoadFromJsonDataWhenValidThenReturnsTemplates() throws {
        // Given
        let jsonString = """
        [
            {
                "id": "iron_helmet",
                "name": "鐵頭盔",
                "description": "普通的鐵製頭盔",
                "slot": "helmet",
                "rarity": "common",
                "levelRequirement": 1,
                "baseStats": {
                    "attack": 0,
                    "defense": 10,
                    "maxHP": 50,
                    "maxMP": 0,
                    "critRate": 0,
                    "critDamage": 0,
                    "speed": 0
                },
                "iconName": "icon_iron_helmet"
            },
            {
                "id": "steel_body",
                "name": "鋼鎧甲",
                "description": "堅固的鋼製鎧甲",
                "slot": "body",
                "rarity": "rare",
                "levelRequirement": 10,
                "baseStats": {
                    "attack": 0,
                    "defense": 30,
                    "maxHP": 100,
                    "maxMP": 0,
                    "critRate": 0,
                    "critDamage": 0,
                    "speed": 0
                },
                "iconName": "icon_steel_body",
                "setId": "steel_set"
            }
        ]
        """
        let jsonData = jsonString.data(using: .utf8)!
        
        // When
        let templates = try sut.load(from: jsonData)
        
        // Then
        XCTAssertEqual(templates.count, 2)
        
        let helmet = templates.first { $0.id == "iron_helmet" }
        XCTAssertNotNil(helmet)
        XCTAssertEqual(helmet?.name, "鐵頭盔")
        XCTAssertEqual(helmet?.slot, .helmet)
        XCTAssertEqual(helmet?.rarity, .common)
        XCTAssertEqual(helmet?.baseStats.defense, 10)
        XCTAssertNil(helmet?.setId)
        
        let body = templates.first { $0.id == "steel_body" }
        XCTAssertNotNil(body)
        XCTAssertEqual(body?.slot, .body)
        XCTAssertEqual(body?.rarity, .rare)
        XCTAssertEqual(body?.setId, "steel_set")
    }
    
    // MARK: - T091: testLoadFromJsonDataWhenInvalidThenReturnsError
    
    /// 測試從無效 JSON 資料載入時拋出錯誤
    func testLoadFromJsonDataWhenInvalidThenReturnsError() {
        // Given
        let invalidJson = "{ invalid json }"
        let jsonData = invalidJson.data(using: .utf8)!
        
        // When & Then
        XCTAssertThrowsError(try sut.load(from: jsonData)) { error in
            XCTAssertTrue(error is ItemSystemError || error is DecodingError)
        }
    }
    
    /// 測試從空陣列 JSON 載入
    func testLoadFromJsonDataWhenEmptyArrayThenReturnsEmptyList() throws {
        // Given
        let jsonData = "[]".data(using: .utf8)!
        
        // When
        let templates = try sut.load(from: jsonData)
        
        // Then
        XCTAssertTrue(templates.isEmpty)
    }
    
    /// 測試缺少必要欄位時拋出錯誤
    func testLoadFromJsonDataWhenMissingRequiredFieldThenThrowsError() {
        // Given - 缺少 slot 欄位
        let jsonString = """
        [
            {
                "id": "test",
                "name": "測試",
                "description": "描述",
                "rarity": "common",
                "levelRequirement": 1,
                "baseStats": {
                    "attack": 0,
                    "defense": 0,
                    "maxHP": 0,
                    "maxMP": 0,
                    "critRate": 0,
                    "critDamage": 0,
                    "speed": 0
                },
                "iconName": "icon"
            }
        ]
        """
        let jsonData = jsonString.data(using: .utf8)!
        
        // When & Then
        XCTAssertThrowsError(try sut.load(from: jsonData))
    }
    
    /// 測試無效的 slot 值時拋出錯誤
    func testLoadFromJsonDataWhenInvalidSlotThenThrowsError() {
        // Given
        let jsonString = """
        [
            {
                "id": "test",
                "name": "測試",
                "description": "描述",
                "slot": "invalid_slot",
                "rarity": "common",
                "levelRequirement": 1,
                "baseStats": {
                    "attack": 0,
                    "defense": 0,
                    "maxHP": 0,
                    "maxMP": 0,
                    "critRate": 0,
                    "critDamage": 0,
                    "speed": 0
                },
                "iconName": "icon"
            }
        ]
        """
        let jsonData = jsonString.data(using: .utf8)!
        
        // When & Then
        XCTAssertThrowsError(try sut.load(from: jsonData))
    }
    
    /// 測試從 Bundle 載入 JSON 檔案（模擬）
    func testLoadFromBundleResourceWhenNotFoundThenThrowsError() {
        // When & Then
        XCTAssertThrowsError(try sut.load(fromResource: "nonexistent", extension: "json")) { error in
            if case ItemSystemError.resourceNotFound = error {
                // Expected
            } else {
                XCTFail("Expected resourceNotFound error")
            }
        }
    }
}

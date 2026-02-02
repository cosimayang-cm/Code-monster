//
//  EquipmentSlot.swift
//  CodeMonster
//
//  RPG 道具系統 - 裝備欄位類型
//  Feature: 003-rpg-item-system
//
//  定義角色可穿戴裝備的 5 個欄位：頭盔、身體、手套、鞋子、腰帶
//  FR-001: 系統 MUST 支援 5 個裝備欄位
//
//  Created by CodeMonster on 2026/2/1.
//

import Foundation

/// 裝備欄位類型
/// 定義角色身上可以穿戴裝備的 5 個位置
enum EquipmentSlot: String, CaseIterable, Codable, Hashable {
    /// 頭盔欄位
    case helmet = "helmet"
    
    /// 身體欄位
    case body = "body"
    
    /// 手套欄位
    case gloves = "gloves"
    
    /// 鞋子欄位
    case boots = "boots"
    
    /// 腰帶欄位
    case belt = "belt"
    
    /// 欄位的顯示名稱
    var displayName: String {
        switch self {
        case .helmet: return "頭盔"
        case .body: return "身體"
        case .gloves: return "手套"
        case .boots: return "鞋子"
        case .belt: return "腰帶"
        }
    }
}

//
//  ComponentType.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/9.
//

import Foundation

/// 必要元件類型
enum ComponentType {
    case wheel
    case engine
    case battery
    case centralComputer
    
    var displayName: String {
        switch self {
        case .wheel:
            return "Wheel"
        case .engine:
            return "Engine"
        case .battery:
            return "Battery"
        case .centralComputer:
            return "Central Computer"
        }
    }
}

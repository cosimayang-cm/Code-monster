//
//  CarComponent.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/8.
//

import Foundation

/// 車輛元件的基礎 Protocol
protocol CarComponent {
    var name: String { get }
    var isRequired: Bool { get }
}

/// 有開關狀態的元件（如引擎、中控電腦）
protocol StatefulComponent: CarComponent {
    var isActive: Bool { get }
    func turnOn()
    func turnOff()
}

/// 可啟用/停用功能的元件（Feature Toggle）
protocol FeatureToggleComponent: CarComponent {
    var feature: Feature { get }
    var isEnabled: Bool { get set }
}

extension FeatureToggleComponent {
    var name: String { feature.displayName }
    var isRequired: Bool { false }
}

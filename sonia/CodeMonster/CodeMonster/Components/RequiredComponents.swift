//
//  RequiredComponents.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/8.
//

import Foundation

// MARK: - 必要元件

/// 車輪
class Wheel: CarComponent {
    let componentType = ComponentType.wheel
    var name: String { componentType.displayName }
    var isRequired: Bool { true }
}

/// 引擎
class Engine: StatefulComponent {
    let componentType = ComponentType.engine
    var name: String { componentType.displayName }
    var isRequired: Bool { true }
    private(set) var isActive = false
    
    func turnOn() {
        isActive = true
        // 移除 print，讓 Car 的 Logger 負責記錄
    }
    
    func turnOff() {
        isActive = false
        // 移除 print，讓 Car 的 Logger 負責記錄
    }
}

/// 電池
class Battery: CarComponent {
    let componentType = ComponentType.battery
    var name: String { componentType.displayName }
    var isRequired: Bool { true }
}

/// 中控電腦
class CentralComputer: StatefulComponent {
    let componentType = ComponentType.centralComputer
    var name: String { componentType.displayName }
    var isRequired: Bool { true }
    private(set) var isActive = false
    
    func turnOn() {
        isActive = true
        // 移除 print，讓 Car 的 Logger 負責記錄
    }
    
    func turnOff() {
        isActive = false
        // 移除 print，讓 Car 的 Logger 負責記錄
    }
}

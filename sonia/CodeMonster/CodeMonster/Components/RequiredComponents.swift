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
        print("🚗 Engine started")
    }
    
    func turnOff() {
        isActive = false
        print("🚗 Engine stopped")
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
        print("💻 Central Computer powered on")
    }
    
    func turnOff() {
        isActive = false
        print("💻 Central Computer powered off")
    }
}

//
//  RequiredComponents.swift
//  CarSystem 必要元件
//
//  Created by Claude on 2026/1/11.
//


import Foundation
import Combine

// MARK: - 車輪

/// 車輪（必要元件 #1）
class Wheel: CarComponent {
    let name = "車輪"
    let description = "支撐車身與行駛"
    let isRequired = true
}

// MARK: - 引擎

/// 引擎（必要元件 #2）- 有 start/stop 狀態
class Engine: CarComponent {
    let name = "引擎"
    let description = "提供車輛動力"
    let isRequired = true
    
    @Published private(set) var isRunning = false
    
    func start() {
        isRunning = true
    }
    
    func stop() {
        isRunning = false
    }
}

// MARK: - 電池

/// 電池（必要元件 #3）
class Battery: CarComponent {
    let name = "電池"
    let description = "儲存與供應電力"
    let isRequired = true
}

// MARK: - 中控電腦

/// 中控電腦（必要元件 #4）- 有 on/off 狀態
class CentralComputer: CarComponent {
    let name = "中控電腦"
    let description = "控制所有電子系統"
    let isRequired = true
    
    @Published private(set) var isOn = false
    
    func turnOn() {
        isOn = true
    }
    
    func turnOff() {
        isOn = false
    }
}

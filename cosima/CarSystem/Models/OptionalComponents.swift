//
//  OptionalComponents.swift
//  CarSystem 選配元件
//
//  Created by Claude on 2026/1/11.
//

import Foundation

// MARK: - 空調系統

/// 空調系統（選配元件 #5）
class AirConditioner: ToggleableComponent {
    let name = "空調系統"
    let description = "冷暖氣控制"
    let isRequired = false
    
    let feature: Feature = .airConditioner
    let dependencies: [Feature] = []
    let requiresCentralComputer = true
    let requiresEngineRunning = false
}

// MARK: - 導航系統

/// 導航系統（選配元件 #6）
class NavigationSystem: ToggleableComponent {
    let name = "導航系統"
    let description = "GPS 導航"
    let isRequired = false
    
    let feature: Feature = .navigation
    let dependencies: [Feature] = []
    let requiresCentralComputer = true
    let requiresEngineRunning = false
}

// MARK: - 娛樂系統

/// 娛樂系統（選配元件 #7）
class EntertainmentSystem: ToggleableComponent {
    let name = "娛樂系統"
    let description = "音樂影片播放"
    let isRequired = false
    
    let feature: Feature = .entertainment
    let dependencies: [Feature] = []
    let requiresCentralComputer = true
    let requiresEngineRunning = false
}

// MARK: - 藍牙系統

/// 藍牙系統（選配元件 #8）
class BluetoothSystem: ToggleableComponent {
    let name = "藍牙系統"
    let description = "藍牙連接裝置"
    let isRequired = false
    
    let feature: Feature = .bluetooth
    let dependencies: [Feature] = []
    let requiresCentralComputer = true
    let requiresEngineRunning = false
}

// MARK: - 倒車鏡頭

/// 倒車鏡頭（選配元件 #9）
class RearCamera: ToggleableComponent {
    let name = "倒車鏡頭"
    let description = "倒車影像顯示"
    let isRequired = false
    
    let feature: Feature = .rearCamera
    let dependencies: [Feature] = []
    let requiresCentralComputer = true
    let requiresEngineRunning = false
}

// MARK: - 環景攝影

/// 環景攝影（選配元件 #10）
class SurroundViewCamera: ToggleableComponent {
    let name = "環景攝影"
    let description = "360度環景影像"
    let isRequired = false
    
    let feature: Feature = .surroundView
    let dependencies: [Feature] = [.rearCamera]  // 依賴倒車鏡頭
    let requiresCentralComputer = true
    let requiresEngineRunning = false
}

// MARK: - 盲點偵測

/// 盲點偵測（選配元件 #11）
class BlindSpotDetection: ToggleableComponent {
    let name = "盲點偵測"
    let description = "偵測兩側盲點"
    let isRequired = false
    
    let feature: Feature = .blindSpotDetection
    let dependencies: [Feature] = []
    let requiresCentralComputer = true
    let requiresEngineRunning = false
}

// MARK: - 前方雷達

/// 前方雷達（選配元件 #12）
class FrontRadar: ToggleableComponent {
    let name = "前方雷達"
    let description = "前方障礙物偵測"
    let isRequired = false
    
    let feature: Feature = .frontRadar
    let dependencies: [Feature] = []
    let requiresCentralComputer = true
    let requiresEngineRunning = false
}

// MARK: - 停車輔助

/// 停車輔助（選配元件 #13）
class ParkingAssist: ToggleableComponent {
    let name = "停車輔助"
    let description = "自動停車輔助"
    let isRequired = false
    
    let feature: Feature = .parkingAssist
    let dependencies: [Feature] = [.surroundView, .blindSpotDetection]  // 依賴環景+盲點
    let requiresCentralComputer = true
    let requiresEngineRunning = false
}

// MARK: - 車道維持

/// 車道維持（選配元件 #14）
class LaneKeeping: ToggleableComponent {
    let name = "車道維持"
    let description = "自動維持車道"
    let isRequired = false
    
    let feature: Feature = .laneKeeping
    let dependencies: [Feature] = [.navigation, .frontRadar]  // 依賴導航+雷達
    let requiresCentralComputer = true
    let requiresEngineRunning = true  // 需要引擎運行
}

// MARK: - 緊急煞車

/// 緊急煞車（選配元件 #15）
class EmergencyBraking: ToggleableComponent {
    let name = "緊急煞車"
    let description = "自動緊急煞車"
    let isRequired = false
    
    let feature: Feature = .emergencyBraking
    let dependencies: [Feature] = [.frontRadar]  // 依賴前方雷達
    let requiresCentralComputer = true
    let requiresEngineRunning = true  // 需要引擎運行
}

// MARK: - 自動駕駛

/// 自動駕駛（選配元件 #16）
class AutoPilot: ToggleableComponent {
    let name = "自動駕駛"
    let description = "全自動駕駛模式"
    let isRequired = false
    
    let feature: Feature = .autoPilot
    let dependencies: [Feature] = [.laneKeeping, .emergencyBraking, .surroundView]  // 依賴多個系統
    let requiresCentralComputer = true
    let requiresEngineRunning = false
}

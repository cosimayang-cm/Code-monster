//
//  ComponentFactory.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/11.
//

import Foundation

/// 元件工廠 (Factory Pattern)
/// 根據 Feature 創建對應的 Component
class ComponentFactory {
    
    /// 創建功能對應的元件
    static func create(_ feature: Feature) -> FeatureToggleComponent {
        switch feature {
        case .airConditioner:
            return AirConditioner()
        case .navigation:
            return NavigationSystem()
        case .entertainment:
            return EntertainmentSystem()
        case .bluetooth:
            return BluetoothSystem()
        case .rearCamera:
            return RearCamera()
        case .surroundView:
            return SurroundViewCamera()
        case .blindSpotDetection:
            return BlindSpotDetection()
        case .frontRadar:
            return FrontRadar()
        case .parkingAssist:
            return ParkingAssist()
        case .laneKeeping:
            return LaneKeeping()
        case .emergencyBraking:
            return EmergencyBraking()
        case .autoPilot:
            return AutoPilot()
        }
    }
}

//
//  OptionalComponents.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/8.
//

import Foundation

// MARK: - 選配元件（可 Toggle 的功能）

/// 空調系統
class AirConditioner: FeatureToggleComponent {
    let feature = Feature.airConditioner
    var isEnabled = false
}

/// 導航系統
class NavigationSystem: FeatureToggleComponent {
    let feature = Feature.navigation
    var isEnabled = false
}

/// 娛樂系統
class EntertainmentSystem: FeatureToggleComponent {
    let feature = Feature.entertainment
    var isEnabled = false
}

/// 藍牙系統
class BluetoothSystem: FeatureToggleComponent {
    let feature = Feature.bluetooth
    var isEnabled = false
}

/// 倒車鏡頭
class RearCamera: FeatureToggleComponent {
    let feature = Feature.rearCamera
    var isEnabled = false
}

/// 環景攝影
class SurroundViewCamera: FeatureToggleComponent {
    let feature = Feature.surroundView
    var isEnabled = false
}

/// 盲點偵測
class BlindSpotDetection: FeatureToggleComponent {
    let feature = Feature.blindSpotDetection
    var isEnabled = false
}

/// 前方雷達
class FrontRadar: FeatureToggleComponent {
    let feature = Feature.frontRadar
    var isEnabled = false
}

/// 停車輔助
class ParkingAssist: FeatureToggleComponent {
    let feature = Feature.parkingAssist
    var isEnabled = false
}

/// 車道維持
class LaneKeeping: FeatureToggleComponent {
    let feature = Feature.laneKeeping
    var isEnabled = false
}

/// 緊急煞車
class EmergencyBraking: FeatureToggleComponent {
    let feature = Feature.emergencyBraking
    var isEnabled = false
}

/// 自動駕駛
class AutoPilot: FeatureToggleComponent {
    let feature = Feature.autoPilot
    var isEnabled = false
}

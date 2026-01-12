//
//  CarComponent.swift
//  CarSystem 元件協議與功能列舉
//
//  Created by Claude on 2026/1/11.
//

import Foundation

// MARK: - CarComponent Protocol

/// 車輛元件協議 - 所有元件都需實作此協議
protocol CarComponent {
    /// 元件名稱
    var name: String { get }
    /// 元件描述
    var description: String { get }
    /// 是否為必要元件
    var isRequired: Bool { get }
}

// MARK: - ToggleableComponent Protocol

/// 可切換功能的選配元件協議
protocol ToggleableComponent: CarComponent {
    /// 對應的功能類型
    var feature: Feature { get }
    /// 相依的功能（需先啟用）
    var dependencies: [Feature] { get }
    /// 是否需要中控電腦
    var requiresCentralComputer: Bool { get }
    /// 是否需要引擎運行中
    var requiresEngineRunning: Bool { get }
}

// MARK: - Feature 列舉

/// 可 Toggle 的功能列舉（共 12 個）
enum Feature: String, CaseIterable {
    case airConditioner
    case navigation
    case entertainment
    case bluetooth
    case rearCamera
    case surroundView
    case blindSpotDetection
    case frontRadar
    case parkingAssist
    case laneKeeping
    case emergencyBraking
    case autoPilot
}

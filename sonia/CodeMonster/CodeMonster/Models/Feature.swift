//
//  Feature.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/8.
//

import Foundation

/// 可 Toggle 的功能列舉
enum Feature: CaseIterable {
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
    
    var displayName: String {
        switch self {
        case .airConditioner:
            return "Air Conditioner"
        case .navigation:
            return "Navigation System"
        case .entertainment:
            return "Entertainment System"
        case .bluetooth:
            return "Bluetooth System"
        case .rearCamera:
            return "Rear Camera"
        case .surroundView:
            return "Surround View Camera"
        case .blindSpotDetection:
            return "Blind Spot Detection"
        case .frontRadar:
            return "Front Radar"
        case .parkingAssist:
            return "Parking Assist"
        case .laneKeeping:
            return "Lane Keeping"
        case .emergencyBraking:
            return "Emergency Braking"
        case .autoPilot:
            return "Auto Pilot"
        }
    }
}

/// Feature Toggle 相關錯誤
enum FeatureError: Error, LocalizedError {
    case dependencyNotMet(feature: Feature, missingDependencies: [String])
    case cannotDisable(feature: Feature, dependentFeatures: [Feature])
    case componentNotAvailable(component: String)
    case centralComputerOff
    case engineNotRunning
    
    var errorDescription: String? {
        switch self {
        case .dependencyNotMet(let feature, let dependencies):
            return "Cannot enable \(feature.displayName): missing dependencies - \(dependencies.joined(separator: ", "))"
        case .cannotDisable(let feature, let dependents):
            return "Cannot disable \(feature.displayName): required by - \(dependents.map { $0.displayName }.joined(separator: ", "))"
        case .componentNotAvailable(let component):
            return "Component not available: \(component)"
        case .centralComputerOff:
            return "Central Computer is off"
        case .engineNotRunning:
            return "Engine is not running"
        }
    }
}

//
//  InMemoryDependencyRepository.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/11.
//

import Foundation

/// 記憶體內依賴規則儲存庫
class InMemoryDependencyRepository: DependencyRepository {
    
    /// 依賴規則資料
    private let dependencies: [Feature: DependencyRule] = [
        .airConditioner: DependencyRule(
            requiredCentralComputer: true,
            requiredEngine: false,
            requiredFeatures: []
        ),
        .navigation: DependencyRule(
            requiredCentralComputer: true,
            requiredEngine: false,
            requiredFeatures: []
        ),
        .entertainment: DependencyRule(
            requiredCentralComputer: true,
            requiredEngine: false,
            requiredFeatures: []
        ),
        .bluetooth: DependencyRule(
            requiredCentralComputer: true,
            requiredEngine: false,
            requiredFeatures: []
        ),
        .rearCamera: DependencyRule(
            requiredCentralComputer: true,
            requiredEngine: false,
            requiredFeatures: []
        ),
        .surroundView: DependencyRule(
            requiredCentralComputer: true,
            requiredEngine: false,
            requiredFeatures: [.rearCamera]
        ),
        .blindSpotDetection: DependencyRule(
            requiredCentralComputer: true,
            requiredEngine: false,
            requiredFeatures: []
        ),
        .frontRadar: DependencyRule(
            requiredCentralComputer: true,
            requiredEngine: false,
            requiredFeatures: []
        ),
        .parkingAssist: DependencyRule(
            requiredCentralComputer: true,
            requiredEngine: false,
            requiredFeatures: [.surroundView, .blindSpotDetection]
        ),
        .laneKeeping: DependencyRule(
            requiredCentralComputer: true,
            requiredEngine: true,
            requiredFeatures: [.navigation, .frontRadar]
        ),
        .emergencyBraking: DependencyRule(
            requiredCentralComputer: true,
            requiredEngine: true,
            requiredFeatures: [.frontRadar]
        ),
        .autoPilot: DependencyRule(
            requiredCentralComputer: true,
            requiredEngine: false,
            requiredFeatures: [.laneKeeping, .emergencyBraking, .surroundView]
        )
    ]
    
    func getDependencyRule(for feature: Feature) -> DependencyRule? {
        return dependencies[feature]
    }
    
    func getAllDependencyRules() -> [Feature: DependencyRule] {
        return dependencies
    }
}

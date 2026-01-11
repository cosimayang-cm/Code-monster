//
//  DependencyValidator.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/8.
//

import Foundation

/// 功能相依性驗證器
class DependencyValidator: DependencyValidating {
    
    /// 定義每個功能的相依條件
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
    
    /// 驗證功能是否可以啟用
    func validateEnable(
        feature: Feature,
        centralComputerOn: Bool,
        engineRunning: Bool,
        enabledFeatures: Set<Feature>
    ) -> Result<Void, FeatureError> {
        guard let rule = dependencies[feature] else {
            return .success(())
        }
        
        var missing: [String] = []
        
        // 檢查中控電腦
        if rule.requiredCentralComputer && !centralComputerOn {
            missing.append("Central Computer (must be ON)")
        }
        
        // 檢查引擎
        if rule.requiredEngine && !engineRunning {
            missing.append("Engine (must be running)")
        }
        
        // 檢查相依功能
        for requiredFeature in rule.requiredFeatures {
            if !enabledFeatures.contains(requiredFeature) {
                missing.append(requiredFeature.displayName)
            }
        }
        
        if missing.isEmpty {
            return .success(())
        } else {
            return .failure(.dependencyNotMet(feature: feature, missingDependencies: missing))
        }
    }
    
    /// 取得依賴指定功能的所有功能
    func getDependentFeatures(
        of feature: Feature,
        from enabledFeatures: Set<Feature>
    ) -> [Feature] {
        return enabledFeatures.filter { enabledFeature in
            guard let rule = dependencies[enabledFeature] else { return false }
            return rule.requiredFeatures.contains(feature)
        }
    }
    
    /// 取得需要引擎運行的所有功能
    func getEngineRequiredFeatures() -> [Feature] {
        return dependencies.compactMap { feature, rule in
            rule.requiredEngine ? feature : nil
        }
    }
}

// MARK: - 相依規則

struct DependencyRule {
    let requiredCentralComputer: Bool
    let requiredEngine: Bool
    let requiredFeatures: [Feature]
}

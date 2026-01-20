//
//  DependencyValidating.swift
//  CodeMonster
//
//  Created by Copilot on 2026/1/11.
//

import Foundation

/// 功能相依性驗證協議
/// 符合 Dependency Inversion Principle (DIP)
protocol DependencyValidating {
    /// 驗證功能是否可以啟用
    /// - Parameters:
    ///   - feature: 要啟用的功能
    ///   - centralComputerOn: 中控電腦是否開啟
    ///   - engineRunning: 引擎是否運行中
    ///   - enabledFeatures: 當前已啟用的功能集合
    /// - Returns: 成功或包含錯誤訊息的結果
    func validateEnable(
        feature: Feature,
        centralComputerOn: Bool,
        engineRunning: Bool,
        enabledFeatures: Set<Feature>
    ) -> Result<Void, FeatureError>
    
    /// 取得依賴指定功能的所有功能
    /// - Parameters:
    ///   - feature: 被依賴的功能
    ///   - enabledFeatures: 當前已啟用的功能集合
    /// - Returns: 依賴該功能的所有功能列表
    func getDependentFeatures(
        of feature: Feature,
        from enabledFeatures: Set<Feature>
    ) -> [Feature]
    
    /// 取得需要引擎運行的所有功能
    /// - Returns: 需要引擎運行的功能列表
    func getEngineRequiredFeatures() -> [Feature]
}

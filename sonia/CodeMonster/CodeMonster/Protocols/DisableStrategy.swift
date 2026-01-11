//
//  DisableStrategy.swift
//  CodeMonster
//
//  Created by Copilot on 2026/1/11.
//

import Foundation

/// 功能停用策略協議
/// 符合 Strategy Pattern 和 Open/Closed Principle
protocol DisableStrategy {
    /// 停用指定功能
    /// - Parameters:
    ///   - feature: 要停用的功能
    ///   - context: 功能上下文（提供狀態查詢與修改介面）
    /// - Returns: 成功停用的功能列表（包含連鎖停用的功能）或錯誤
    func disable(
        _ feature: Feature,
        context: FeatureContext
    ) -> Result<[Feature], FeatureError>
}

/// 功能上下文協議
/// 提供策略所需的狀態查詢與修改能力
protocol FeatureContext {
    /// 查詢功能是否已啟用
    func isEnabled(_ feature: Feature) -> Bool
    
    /// 設定功能啟用狀態
    func setEnabled(_ feature: Feature, _ enabled: Bool)
    
    /// 取得依賴指定功能的所有已啟用功能
    func getDependents(of feature: Feature) -> [Feature]
}

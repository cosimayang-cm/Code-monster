//
//  CascadeDisableStrategy.swift
//  CodeMonster
//
//  Created by Copilot on 2026/1/11.
//

import Foundation

/// 連鎖停用策略
/// 停用功能時，自動遞迴停用所有依賴它的功能
class CascadeDisableStrategy: DisableStrategy {
    
    func disable(
        _ feature: Feature,
        context: FeatureContext
    ) -> Result<[Feature], FeatureError> {
        
        // 如果功能已經停用，直接返回成功
        guard context.isEnabled(feature) else {
            return .success([])
        }
        
        var disabledFeatures: [Feature] = []
        
        // 先遞迴停用所有依賴此功能的功能（深度優先）
        let dependents = context.getDependents(of: feature)
        for dependent in dependents {
            let result = disable(dependent, context: context)
            switch result {
            case .success(let features):
                disabledFeatures.append(contentsOf: features)
            case .failure(let error):
                return .failure(error)
            }
        }
        
        // 最後停用自己
        context.setEnabled(feature, false)
        disabledFeatures.append(feature)
        
        return .success(disabledFeatures)
    }
}

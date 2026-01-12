//
//  FeatureError.swift
//  CarSystem 功能錯誤定義
//
//  Created by Claude on 2026/1/11.
//

import Foundation

/// 功能操作錯誤
enum FeatureError: Error, LocalizedError {
    case centralComputerOff
    case engineNotRunning
    case dependencyNotEnabled(Feature)
    case featureHasDependents([Feature])
    case featureAlreadyEnabled
    case featureAlreadyDisabled
    
    var errorDescription: String? {
        switch self {
        case .centralComputerOff:
            return "中控電腦未開啟"
        case .engineNotRunning:
            return "引擎未運行"
        case .dependencyNotEnabled(let feature):
            return "相依功能未啟用"
        case .featureHasDependents(let features):
            return "有其他功能依賴此功能"
        case .featureAlreadyEnabled:
            return "功能已啟用"
        case .featureAlreadyDisabled:
            return "功能已停用"
        }
    }
}

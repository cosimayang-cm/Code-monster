//
//  CarConfiguration.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/11.
//

import Foundation

/// 車輛配置（定義車輛擁有哪些功能）
struct CarConfiguration {
    let features: [Feature]
    
    init(features: [Feature]) {
        self.features = features
    }
}

// MARK: - Factory Methods (預設車型配置)

extension CarConfiguration {
    /// 基本款車型
    static func basic() -> CarConfiguration {
        CarConfigurationBuilder()
            .addAll([
                .airConditioner,
                .bluetooth,
                .rearCamera
            ])
            .build()
    }
    
    /// 豪華款車型
    static func luxury() -> CarConfiguration {
        CarConfigurationBuilder()
            .addAll([
                .airConditioner,
                .navigation,
                .bluetooth,
                .entertainment,
                .rearCamera,
                .surroundView,
                .blindSpotDetection,
                .frontRadar,
                .parkingAssist
            ])
            .build()
    }
    
    /// 全配車型（包含所有功能）
    static func full() -> CarConfiguration {
        CarConfigurationBuilder()
            .addAll(Feature.allCases)
            .build()
    }
}

//
//  CarConfigurationBuilder.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/11.
//

import Foundation

/// 車輛配置建造器 (Builder Pattern)
class CarConfigurationBuilder {
    
    private var features: Set<Feature> = []
    
    /// 加入單一功能
    @discardableResult
    func add(_ feature: Feature) -> Self {
        features.insert(feature)
        return self
    }
    
    /// 加入多個功能
    @discardableResult
    func addAll(_ features: [Feature]) -> Self {
        self.features.formUnion(features)
        return self
    }
    
    /// 移除功能
    @discardableResult
    func remove(_ feature: Feature) -> Self {
        features.remove(feature)
        return self
    }
    
    /// 建構配置
    func build() -> CarConfiguration {
        CarConfiguration(features: Array(features))
    }
}

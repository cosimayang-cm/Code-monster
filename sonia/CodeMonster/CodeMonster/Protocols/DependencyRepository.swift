//
//  DependencyRepository.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/11.
//

import Foundation

/// 依賴規則儲存庫協定 (Repository Pattern)
protocol DependencyRepository {
    /// 取得指定功能的依賴規則
    func getDependencyRule(for feature: Feature) -> DependencyRule?
    
    /// 取得所有依賴規則
    func getAllDependencyRules() -> [Feature: DependencyRule]
}

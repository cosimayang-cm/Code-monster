//
//  ResultExtensions.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/11.
//

import Foundation

/// Result 類型擴展
extension Result {
    /// 判斷結果是否成功
    var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }
    
    /// 判斷結果是否失敗
    var isFailure: Bool {
        if case .failure = self {
            return true
        }
        return false
    }
}

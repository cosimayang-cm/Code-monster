//
//  PopupResult.swift
//  CarSystem
//
//  Created by PopupChain Feature
//  彈窗連鎖顯示機制 (Popup Response Chain)
//

import Foundation

/// 彈窗顯示結果
enum PopupResult {
    /// 用戶完成彈窗互動（如完成教學、完成簽到）
    case completed

    /// 用戶關閉彈窗（點擊關閉按鈕、點擊背景等）
    case dismissed

    /// 彈窗顯示失敗（FR-011: 跳過不重試）
    case failed(Error)

    /// 是否為成功結果（completed 或 dismissed 都算成功）
    var isSuccess: Bool {
        switch self {
        case .completed, .dismissed:
            return true
        case .failed:
            return false
        }
    }
}

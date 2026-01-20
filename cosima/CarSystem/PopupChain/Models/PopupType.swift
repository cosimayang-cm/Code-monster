//
//  PopupType.swift
//  CarSystem
//
//  Created by PopupChain Feature
//  彈窗連鎖顯示機制 (Popup Response Chain)
//

import Foundation

/// 彈窗類型枚舉
/// Priority order (FR-002) 由 handlers 陣列順序決定，無需數字屬性
enum PopupType: String, CaseIterable {
    case tutorial = "tutorial"
    case interstitialAd = "interstitial_ad"
    case newFeature = "new_feature"
    case dailyCheckIn = "daily_check_in"
    case predictionResult = "prediction_result"

    /// 彈窗顯示名稱（用於 UI 或 Debug）
    var displayName: String {
        switch self {
        case .tutorial:
            return "新手教學"
        case .interstitialAd:
            return "插頁式廣告"
        case .newFeature:
            return "新功能公告"
        case .dailyCheckIn:
            return "每日簽到"
        case .predictionResult:
            return "猜多空結果"
        }
    }
}

//
//  PopupUserState.swift
//  CarSystem
//
//  Created by PopupChain Feature
//  彈窗連鎖顯示機制 (Popup Response Chain)
//

import Foundation

/// 用戶彈窗狀態（UserDefaults 持久化）
struct PopupUserState: Codable, Equatable {

    // MARK: - Properties

    /// 用戶是否看過新手教學（永久狀態，不會重置）
    var hasSeenTutorial: Bool = false

    /// 上次簽到日期（每日重置判斷）
    var lastCheckInDate: Date?

    /// 上次顯示廣告日期（每日重置判斷，FR-012）
    var lastAdShownDate: Date?

    /// 已看過的新功能公告 ID
    var seenFeatureAnnouncements: Set<String> = []

    /// 已通知的猜多空結果 ID
    var notifiedPredictionResults: Set<String> = []

    // MARK: - Helper Methods

    /// 檢查今日是否已簽到
    func hasCheckedInToday() -> Bool {
        guard let date = lastCheckInDate else { return false }
        return Calendar.current.isDateInToday(date)
    }

    /// 檢查今日是否已顯示廣告 (FR-012)
    func hasShownAdToday() -> Bool {
        guard let date = lastAdShownDate else { return false }
        return Calendar.current.isDateInToday(date)
    }

    /// 檢查是否已看過指定的新功能公告
    func hasSeenFeature(id: String) -> Bool {
        return seenFeatureAnnouncements.contains(id)
    }

    /// 檢查是否已通知指定的預測結果
    func hasNotifiedPrediction(id: String) -> Bool {
        return notifiedPredictionResults.contains(id)
    }
}

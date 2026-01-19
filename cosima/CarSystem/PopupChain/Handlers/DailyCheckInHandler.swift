//
//  DailyCheckInHandler.swift
//  CarSystem
//
//  Created by PopupChain Feature
//  彈窗連鎖顯示機制 (Popup Response Chain)
//
//  User Story 2: 老用戶每日簽到流程
//

import UIKit

/// 每日簽到彈窗處理器
/// 用戶今日尚未簽到時顯示
final class DailyCheckInHandler: PopupHandler {

    // MARK: - PopupHandler

    let popupType: PopupType = .dailyCheckIn

    func shouldDisplay(state: PopupUserState) -> Bool {
        // 今日尚未簽到才顯示
        return !state.hasCheckedInToday()
    }

    func display(on viewController: UIViewController, completion: @escaping (PopupResult) -> Void) {
        let alert = UIAlertController(
            title: "每日簽到",
            message: "點擊簽到領取今日獎勵！",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "簽到", style: .default) { _ in
            // TODO: 執行簽到邏輯，發放獎勵
            completion(.completed)
        })

        alert.addAction(UIAlertAction(title: "關閉", style: .cancel) { _ in
            completion(.dismissed)
        })

        DispatchQueue.main.async {
            viewController.present(alert, animated: true)
        }
    }

    func updateState(storage: PopupStateStorage) {
        storage.markDailyCheckIn()
    }
}

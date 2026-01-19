//
//  InterstitialAdHandler.swift
//  CarSystem
//
//  Created by PopupChain Feature
//  彈窗連鎖顯示機制 (Popup Response Chain)
//
//  User Story 5: 插頁式廣告展示
//

import UIKit

/// 插頁式廣告彈窗處理器
/// 每日最多顯示 1 次 (FR-012)
/// 單機模式：不依賴外部廣告 SDK，直接顯示內建廣告
final class InterstitialAdHandler: PopupHandler {

    // MARK: - Properties

    /// 廣告內容（單機模式使用內建廣告）
    var adTitle: String = "特別優惠"
    var adMessage: String = "限時優惠活動進行中！點擊查看更多精彩內容。"

    // MARK: - PopupHandler

    let popupType: PopupType = .interstitialAd

    func shouldDisplay(state: PopupUserState) -> Bool {
        // FR-012: 每日最多顯示 1 次
        // 單機模式：廣告永遠可用，只檢查今日是否已顯示
        return !state.hasShownAdToday()
    }

    func display(on viewController: UIViewController, completion: @escaping (PopupResult) -> Void) {
        let alert = UIAlertController(
            title: adTitle,
            message: adMessage,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "查看詳情", style: .default) { _ in
            // TODO: 導航到廣告目標頁面
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
        storage.markAdShown()
    }
}

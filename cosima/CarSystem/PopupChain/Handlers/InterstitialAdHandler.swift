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
final class InterstitialAdHandler: PopupHandler {

    // MARK: - Properties

    /// 是否有可用的廣告（由外部設定，例如廣告 SDK）
    var hasAvailableAd: Bool = false

    /// 廣告內容（簡化版，實際應用可能使用廣告 SDK）
    var adTitle: String = "特別優惠"
    var adMessage: String = "限時優惠活動進行中！"

    // MARK: - PopupHandler

    let popupType: PopupType = .interstitialAd

    func shouldDisplay(state: PopupUserState) -> Bool {
        // FR-012: 每日最多顯示 1 次，且必須有可用廣告
        return hasAvailableAd && !state.hasShownAdToday()
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

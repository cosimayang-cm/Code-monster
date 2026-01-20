//
//  NewFeaturePopupHandler.swift
//  CarSystem
//
//  Created by PopupChain Feature
//  彈窗連鎖顯示機制 (Popup Response Chain)
//
//  User Story 4: 新功能公告推送
//

import UIKit

/// 新功能公告資料結構
struct FeatureAnnouncement {
    let id: String
    let title: String
    let description: String
}

/// 新功能公告彈窗處理器
/// 有未讀的新功能公告時顯示
/// 單機模式：內建當前版本的功能公告
final class NewFeaturePopupHandler: PopupHandler {

    // MARK: - Properties

    /// 內建的新功能公告（單機模式）
    /// 每次 App 更新時更新此列表
    var announcements: [FeatureAnnouncement] = [
        FeatureAnnouncement(
            id: "v1.0.0_popup_chain",
            title: "彈窗連鎖顯示機制",
            description: "新增智慧彈窗管理系統，依優先順序為您呈現重要訊息，不再錯過任何通知！"
        )
    ]

    /// 當前顯示的公告
    private var currentAnnouncement: FeatureAnnouncement?

    // MARK: - PopupHandler

    let popupType: PopupType = .newFeature

    func shouldDisplay(state: PopupUserState) -> Bool {
        // 找出第一個未讀的公告
        currentAnnouncement = announcements.first { announcement in
            !state.hasSeenFeature(id: announcement.id)
        }
        return currentAnnouncement != nil
    }

    func display(on viewController: UIViewController, completion: @escaping (PopupResult) -> Void) {
        guard let announcement = currentAnnouncement else {
            completion(.dismissed)
            return
        }

        let alert = UIAlertController(
            title: "🆕 \(announcement.title)",
            message: announcement.description,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "了解更多", style: .default) { _ in
            // TODO: 導航到新功能詳細頁面
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
        if let announcement = currentAnnouncement {
            storage.markFeatureSeen(id: announcement.id)
        }
    }
}

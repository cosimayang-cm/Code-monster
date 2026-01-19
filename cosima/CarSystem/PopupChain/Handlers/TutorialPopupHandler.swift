//
//  TutorialPopupHandler.swift
//  CarSystem
//
//  Created by PopupChain Feature
//  彈窗連鎖顯示機制 (Popup Response Chain)
//
//  User Story 1: 新用戶首次進入 App（新手教學）
//

import UIKit

/// 新手教學彈窗處理器
/// 用戶從未看過新手教學時顯示
/// 關閉後繼續檢查下一個彈窗（照流程圖）
final class TutorialPopupHandler: PopupHandler {

    // MARK: - PopupHandler

    let popupType: PopupType = .tutorial

    // 照流程圖：關閉後繼續檢查下一個彈窗（使用預設值 false）

    func shouldDisplay(state: PopupUserState) -> Bool {
        // 只在用戶從未看過新手教學時顯示
        return !state.hasSeenTutorial
    }

    func display(on viewController: UIViewController, completion: @escaping (PopupResult) -> Void) {
        let alert = UIAlertController(
            title: "歡迎使用",
            message: "讓我們開始新手教學，了解 App 的核心功能吧！",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "開始教學", style: .default) { _ in
            // TODO: 可以在這裡導航到完整的教學流程
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
        storage.markTutorialSeen()
    }
}

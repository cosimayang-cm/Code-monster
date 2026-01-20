//
//  PopupPresenter.swift
//  CarSystem
//
//  Created by PopupChain Feature
//  彈窗連鎖顯示機制 (Popup Response Chain)
//

import UIKit

/// 彈窗呈現器
/// 提供統一的彈窗呈現邏輯，支援不同類型的彈窗 UI
final class PopupPresenter {

    // MARK: - Singleton

    static let shared = PopupPresenter()

    private init() {}

    // MARK: - Public Methods

    /// 呈現 Alert 樣式的彈窗
    /// - Parameters:
    ///   - title: 標題
    ///   - message: 訊息內容
    ///   - primaryAction: 主要按鈕（標題, 動作）
    ///   - secondaryAction: 次要按鈕（標題, 動作），可選
    ///   - viewController: 用於呈現的 ViewController
    ///   - completion: 完成回調
    func presentAlert(
        title: String,
        message: String,
        primaryAction: (title: String, handler: (() -> Void)?),
        secondaryAction: (title: String, handler: (() -> Void)?)? = nil,
        on viewController: UIViewController,
        completion: @escaping (PopupResult) -> Void
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: primaryAction.title, style: .default) { _ in
            primaryAction.handler?()
            completion(.completed)
        })

        if let secondary = secondaryAction {
            alert.addAction(UIAlertAction(title: secondary.title, style: .cancel) { _ in
                secondary.handler?()
                completion(.dismissed)
            })
        }

        DispatchQueue.main.async {
            viewController.present(alert, animated: true)
        }
    }

    /// 呈現自訂 View 的彈窗
    /// - Parameters:
    ///   - customView: 自訂的彈窗 View
    ///   - viewController: 用於呈現的 ViewController
    ///   - completion: 完成回調
    func presentCustomView(
        _ customView: UIView,
        on viewController: UIViewController,
        completion: @escaping (PopupResult) -> Void
    ) {
        // TODO: 實作自訂 View 的呈現邏輯
        // 可以使用 UIViewController containment 或 overlay 方式
        completion(.dismissed)
    }

    /// 關閉當前顯示的彈窗
    /// - Parameter viewController: 呈現彈窗的 ViewController
    func dismiss(from viewController: UIViewController, animated: Bool = true) {
        DispatchQueue.main.async {
            viewController.dismiss(animated: animated)
        }
    }
}

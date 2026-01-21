//
//  UIKitPopupPresenter.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/20.
//

import UIKit

/// UIKit implementation of PopupPresenter
public class UIKitPopupPresenter: PopupPresenter {
    
    private weak var rootViewController: UIViewController?
    private var currentAlert: UIAlertController?
    private var currentCompletion: (() -> Void)?
    
    public var isPresenting: Bool {
        currentAlert != nil
    }
    
    public var currentPopupType: PopupType? {
        guard currentAlert != nil else { return nil }
        return _currentPopupType
    }
    
    private var _currentPopupType: PopupType?
    
    public init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }
    
    public func present(
        type: PopupType,
        from viewController: UIViewController,
        completion: @escaping () -> Void
    ) {
        // Use the root view controller we saved, not the parameter
        guard let presentingVC = rootViewController else {
            print("❌ No root view controller available")
            completion()
            return
        }
        
        currentCompletion = completion
        _currentPopupType = type
        
        let alert = UIAlertController(
            title: type.displayName,
            message: messageForPopupType(type),
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "確定", style: .default) { [weak self] _ in
            self?.handleDismiss()
        })
        
        currentAlert = alert
        
        DispatchQueue.main.async {
            presentingVC.present(alert, animated: true)
        }
    }
    
    public func dismiss(type: PopupType) {
        guard _currentPopupType == type else { return }
        
        currentAlert?.dismiss(animated: true) { [weak self] in
            self?.handleDismiss()
        }
    }
    
    private func handleDismiss() {
        let completion = currentCompletion
        currentAlert = nil
        currentCompletion = nil
        _currentPopupType = nil
        
        completion?()
    }
    
    private func messageForPopupType(_ type: PopupType) -> String {
        switch type {
        case .tutorial:
            return "歡迎使用 CodeMonster！讓我們開始新手教學。"
        case .interstitialAd:
            return "🎯 贊助廣告\n感謝您的支持！"
        case .newFeature:
            return "🎉 新功能上線\n快來體驗全新功能！"
        case .dailyCheckIn:
            return "📅 每日簽到\n恭喜！獲得簽到獎勵。"
        case .predictionResult:
            return "🔮 預測結果\n您的預測結果已出爐！"
        }
    }
}

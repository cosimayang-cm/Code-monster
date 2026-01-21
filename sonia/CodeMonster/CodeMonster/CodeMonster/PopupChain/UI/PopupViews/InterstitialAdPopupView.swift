//
//  InterstitialAdPopupView.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/20.
//

import UIKit

/// Simple alert-based view for Interstitial Ad popup
public class InterstitialAdPopupView {
    
    /// Presents the interstitial ad popup as an alert
    public static func present(
        from viewController: UIViewController,
        completion: @escaping () -> Void
    ) {
        let alert = UIAlertController(
            title: "廣告",
            message: "這是插頁式廣告。感謝您的支持！",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "關閉", style: .default) { _ in
            completion()
        })
        
        viewController.present(alert, animated: true)
    }
}

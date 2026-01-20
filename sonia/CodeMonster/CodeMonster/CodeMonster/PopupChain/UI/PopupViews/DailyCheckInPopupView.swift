//
//  DailyCheckInPopupView.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/20.
//

import UIKit

/// Simple alert-based view for Daily Check-in popup
public class DailyCheckInPopupView {
    
    /// Presents the daily check-in popup as an alert
    public static func present(
        from viewController: UIViewController,
        completion: @escaping () -> Void
    ) {
        let alert = UIAlertController(
            title: "每日簽到",
            message: "恭喜您完成今日簽到！",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "領取獎勵", style: .default) { _ in
            completion()
        })
        
        viewController.present(alert, animated: true)
    }
}

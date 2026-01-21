//
//  TutorialPopupView.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/20.
//

import UIKit

/// Simple alert-based view for Tutorial popup
public class TutorialPopupView {
    
    /// Presents the tutorial popup as an alert
    public static func present(
        from viewController: UIViewController,
        completion: @escaping () -> Void
    ) {
        let alert = UIAlertController(
            title: "歡迎使用",
            message: "這是新手教學彈窗。點擊確定開始使用應用程式。",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "確定", style: .default) { _ in
            completion()
        })
        
        viewController.present(alert, animated: true)
    }
}

//
//  NewFeaturePopupView.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/20.
//

import UIKit

/// Simple alert-based view for New Feature popup
public class NewFeaturePopupView {
    
    /// Presents the new feature popup as an alert
    public static func present(
        from viewController: UIViewController,
        completion: @escaping () -> Void
    ) {
        let alert = UIAlertController(
            title: "新功能發布",
            message: "我們推出了全新功能！快來體驗吧。",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "了解", style: .default) { _ in
            completion()
        })
        
        viewController.present(alert, animated: true)
    }
}

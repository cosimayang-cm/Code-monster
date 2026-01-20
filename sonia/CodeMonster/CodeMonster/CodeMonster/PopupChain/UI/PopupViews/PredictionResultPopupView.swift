//
//  PredictionResultPopupView.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/20.
//

import UIKit

/// Simple alert-based view for Prediction Result popup
public class PredictionResultPopupView {
    
    /// Presents the prediction result popup as an alert
    public static func present(
        from viewController: UIViewController,
        completion: @escaping () -> Void
    ) {
        let alert = UIAlertController(
            title: "猜多空結果",
            message: "您的預測結果已出爐！",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "查看結果", style: .default) { _ in
            completion()
        })
        
        viewController.present(alert, animated: true)
    }
}

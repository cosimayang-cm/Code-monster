//
//  ToastView.swift
//  CarSystem
//
//  Monster5 - TCA + UIKit 整合實戰
//

import UIKit

/// 自訂 Toast 通知視圖
/// 顯示在畫面頂部，支援淡入淡出動畫
final class ToastView: UIView {

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(message: String) {
        super.init(frame: .zero)
        setupUI(message: message)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI(message: String) {
        backgroundColor = UIColor.systemRed.withAlphaComponent(0.9)
        layer.cornerRadius = 10
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        alpha = 0

        messageLabel.text = message
        addSubview(messageLabel)

        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissToast))
        addGestureRecognizer(tapGesture)
    }

    @objc private func dismissToast() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }

    // MARK: - Static Show

    /// 在指定視圖中顯示 Toast
    static func show(in view: UIView, message: String, duration: TimeInterval = 3.0) {
        // 移除已有的 Toast
        view.subviews
            .compactMap { $0 as? ToastView }
            .forEach { $0.removeFromSuperview() }

        let toast = ToastView(message: message)
        view.addSubview(toast)

        NSLayoutConstraint.activate([
            toast.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            toast.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            toast.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])

        // 淡入
        UIView.animate(withDuration: 0.3) {
            toast.alpha = 1
        }

        // 自動淡出
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            toast.dismissToast()
        }
    }
}

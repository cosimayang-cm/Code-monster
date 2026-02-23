//
//  ErrorToastView.swift
//  CodeMonster - Monster 5: TCA + UIKit Integration
//
//  Created by Claude on 2026-02-10.
//

import UIKit

/// Error toast overlay displayed at top of screen
final class ErrorToastView: UIView {

    // MARK: - UI Components

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup

    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        layer.cornerRadius = 8
        alpha = 0 // Initially hidden
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(messageLabel)

        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Public Methods

    /// Show toast with message in given superview
    func show(message: String, in superview: UIView) {
        messageLabel.text = message

        // Add to superview if not already added
        if self.superview == nil {
            superview.addSubview(self)

            NSLayoutConstraint.activate([
                topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: 16),
                leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 16),
                trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -16)
            ])
        }

        // Fade in animation
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }

    /// Hide toast with fade animation
    func hide() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        }
    }
}

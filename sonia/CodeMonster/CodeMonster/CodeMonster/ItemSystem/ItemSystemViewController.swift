//
//  ItemSystemViewController.swift
//  CodeMonster
//
//  Monster 4: RPG Item / Inventory System - Template-Instance, Factory, Serialization
//

import UIKit

final class ItemSystemViewController: UIViewController {

    // MARK: - UI Components

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "⚔️ Item System\n\n（UI 實作待補）\n\nEngine 層已完成：\nItemFactory / Inventory / Avatar\nAffixGenerator / SetBonusCalculator"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "⚔️ Item System"
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        view.addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
}

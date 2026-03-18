//
//  ViewController.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/8.
//
//  CodeMonster Hub — 六個任務的入口頁面。
//

import UIKit
import ComposableArchitecture

final class ViewController: UIViewController {

    // MARK: - Data

    private struct MonsterItem {
        let title: String
        let color: UIColor
    }

    private let monsters: [MonsterItem] = [
        MonsterItem(title: "🚗  Monster 1：Car System",           color: .systemOrange),
        MonsterItem(title: "💬  Monster 2：Popup Response Chain",  color: .systemTeal),
        MonsterItem(title: "↩️  Monster 3：Undo / Redo System",    color: .systemGreen),
        MonsterItem(title: "⚔️  Monster 4：RPG Item System",       color: .systemRed),
        MonsterItem(title: "🍎  Monster 5：TCA + UIKit",           color: .systemBlue),
        MonsterItem(title: "🎮  Monster 6：Board Games",           color: .systemPurple)
    ]

    // MARK: - UI Components

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "🧟 CodeMonster"
        view.backgroundColor = .systemBackground
        setupUI()
    }

    // MARK: - Setup

    private func setupUI() {
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])

        for (index, item) in monsters.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(item.title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
            button.contentHorizontalAlignment = .left
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            button.layer.cornerRadius = 14
            button.backgroundColor = item.color.withAlphaComponent(0.15)
            button.setTitleColor(item.color, for: .normal)
            button.heightAnchor.constraint(equalToConstant: 54).isActive = true
            button.tag = index
            button.addTarget(self, action: #selector(monsterButtonTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }

    // MARK: - Actions

    @objc private func monsterButtonTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            navigationController?.pushViewController(CarSystemViewController(), animated: true)
        case 1:
            navigationController?.pushViewController(PopupDebugViewController(), animated: true)
        case 2:
            navigationController?.pushViewController(UndoRedoDemoViewController(), animated: true)
        case 3:
            navigationController?.pushViewController(ItemSystemViewController(), animated: true)
        case 4:
            let store = Store(initialState: AppFeature.State()) { AppFeature() }
            let coordinator = AppCoordinator(store: store)
            coordinator.modalPresentationStyle = .fullScreen
            present(coordinator, animated: true)
        case 5:
            navigationController?.pushViewController(MenuViewController(), animated: true)
        default:
            break
        }
    }
}

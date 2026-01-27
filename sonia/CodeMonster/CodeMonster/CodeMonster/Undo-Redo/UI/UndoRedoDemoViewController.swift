//
//  UndoRedoDemoViewController.swift
//  CodeMonster
//
//  Created by Claude on 2026/1/23.
//

import UIKit

/// Demo Hub - Undo/Redo 系統展示入口頁面
/// FR-028: 展示入口頁面
/// FR-029: 導覽至文字編輯器與畫布編輯器
final class UndoRedoDemoViewController: UIViewController {

    // MARK: - UI Elements

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Undo/Redo 系統展示"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "選擇一個編輯器來體驗 Command Pattern"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var textEditorButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("📝 文字編輯器", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(textEditorTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var canvasEditorButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🎨 畫布編輯器", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(canvasEditorTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [textEditorButton, canvasEditorButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Undo/Redo Demo"

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Button Stack
            buttonStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            // Button Heights
            textEditorButton.heightAnchor.constraint(equalToConstant: 56),
            canvasEditorButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    // MARK: - Actions

    @objc private func textEditorTapped() {
        let textEditorVC = TextEditorViewController()
        navigationController?.pushViewController(textEditorVC, animated: true)
    }

    @objc private func canvasEditorTapped() {
        let canvasEditorVC = CanvasEditorViewController()
        navigationController?.pushViewController(canvasEditorVC, animated: true)
    }
}

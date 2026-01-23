//
//  UndoRedoToolbarView.swift
//  CodeMonster
//
//  Created by Claude on 2026/1/23.
//

import UIKit

/// 可重用的 Undo/Redo 工具列視圖
/// FR-037: 共用的 Undo/Redo 按鈕元件
final class UndoRedoToolbarView: UIView {

    // MARK: - Callbacks

    /// Undo 按鈕點擊回調
    var onUndo: (() -> Void)?

    /// Redo 按鈕點擊回調
    var onRedo: (() -> Void)?

    // MARK: - UI Elements

    private lazy var undoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.uturn.backward"), for: .normal)
        button.setTitle("Undo", for: .normal)
        button.addTarget(self, action: #selector(undoTapped), for: .touchUpInside)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var redoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.uturn.forward"), for: .normal)
        button.setTitle("Redo", for: .normal)
        button.addTarget(self, action: #selector(redoTapped), for: .touchUpInside)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [undoButton, redoButton])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup

    private func setupUI() {
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    // MARK: - Public Methods

    /// 更新按鈕狀態
    /// - Parameters:
    ///   - canUndo: 是否可以 Undo
    ///   - canRedo: 是否可以 Redo
    func updateState(canUndo: Bool, canRedo: Bool) {
        undoButton.isEnabled = canUndo
        redoButton.isEnabled = canRedo
    }

    // MARK: - Actions

    @objc private func undoTapped() {
        onUndo?()
    }

    @objc private func redoTapped() {
        onRedo?()
    }
}

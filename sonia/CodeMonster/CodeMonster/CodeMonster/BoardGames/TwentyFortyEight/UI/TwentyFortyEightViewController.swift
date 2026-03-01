//
//  TwentyFortyEightViewController.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/3/1.
//

import UIKit

// MARK: - TwentyFortyEightViewController
// 2048 UIKit 輸入層。
// VC = 搖桿輸入：↑↓←→ 滑動 + Swipe 手勢。遊戲狀態透過 print(renderer.render()) 輸出至 Xcode console。

final class TwentyFortyEightViewController: UIViewController {

    // MARK: - State

    private var game = TwentyFortyEightGame()
    private var renderer: TwentyFortyEightRenderer { TwentyFortyEightRenderer(game: game) }
    private static let directions: [Direction] = [.up, .down, .left, .right]

    // MARK: - UI

    private let upButton    = TwentyFortyEightViewController.makeArrow("↑", tag: 0)
    private let downButton  = TwentyFortyEightViewController.makeArrow("↓", tag: 1)
    private let leftButton  = TwentyFortyEightViewController.makeArrow("←", tag: 2)
    private let rightButton = TwentyFortyEightViewController.makeArrow("→", tag: 3)

    private let continueButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Keep Going 🚀", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        b.backgroundColor = .systemGreen.withAlphaComponent(0.15)
        b.setTitleColor(.systemGreen, for: .normal)
        b.layer.cornerRadius = 10
        b.isHidden = true
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let newGameButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("New Game", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        b.backgroundColor = .systemBlue.withAlphaComponent(0.15)
        b.setTitleColor(.systemBlue, for: .normal)
        b.layer.cornerRadius = 10
        b.isHidden = true
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private static func makeArrow(_ title: String, tag: Int) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 28, weight: .medium)
        b.backgroundColor = .secondarySystemBackground
        b.layer.cornerRadius = 12
        b.tag = tag
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "2048"
        view.backgroundColor = .systemBackground
        setupUI()
        setupSwipeGestures()
        startGame()
    }

    private func setupUI() {
        // D-pad 佈局：上中下三列，中間列是 ← (空白) →
        func sp() -> UIView { UIView() }
        let upRow   = UIStackView(arrangedSubviews: [sp(), upButton, sp()])
        let midRow  = UIStackView(arrangedSubviews: [leftButton, sp(), rightButton])
        let downRow = UIStackView(arrangedSubviews: [sp(), downButton, sp()])
        [upRow, midRow, downRow].forEach {
            $0.axis = .horizontal; $0.spacing = 8; $0.distribution = .fillEqually
        }
        let dpad = UIStackView(arrangedSubviews: [upRow, midRow, downRow])
        dpad.axis = .vertical; dpad.spacing = 8; dpad.translatesAutoresizingMaskIntoConstraints = false

        let bottomRow = UIStackView(arrangedSubviews: [continueButton, newGameButton])
        bottomRow.axis = .horizontal; bottomRow.spacing = 12
        bottomRow.distribution = .fillEqually; bottomRow.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(dpad)
        view.addSubview(bottomRow)

        [upButton, downButton, leftButton, rightButton].forEach {
            $0.addTarget(self, action: #selector(directionTapped(_:)), for: .touchUpInside)
            NSLayoutConstraint.activate([
                $0.widthAnchor.constraint(equalToConstant: 72),
                $0.heightAnchor.constraint(equalToConstant: 60)
            ])
        }
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        newGameButton.addTarget(self, action: #selector(newGameTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            bottomRow.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            bottomRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            bottomRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            bottomRow.heightAnchor.constraint(equalToConstant: 40),

            dpad.bottomAnchor.constraint(equalTo: bottomRow.topAnchor, constant: -16),
            dpad.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupSwipeGestures() {
        let pairs: [(UISwipeGestureRecognizer.Direction, Int)] = [
            (.up, 0), (.down, 1), (.left, 2), (.right, 3)
        ]
        for (swipeDir, tag) in pairs {
            let gr = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
            gr.direction = swipeDir
            _ = tag  // direction mapped via sender.direction in callback
            view.addGestureRecognizer(gr)
        }
    }

    // MARK: - Game

    private func startGame() {
        game.restart()
        updateUI()
        print(renderer.render())
    }

    private func updateUI() {
        let isActive = game.state == .playing || game.state == .wonCanContinue
        [upButton, downButton, leftButton, rightButton].forEach { $0.isEnabled = isActive }
        continueButton.isHidden = game.state != .wonCanContinue
        newGameButton.isHidden = game.state == .playing
    }

    // MARK: - Actions

    @objc private func directionTapped(_ sender: UIButton) {
        performMove(Self.directions[sender.tag])
    }

    @objc private func swiped(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .up:    performMove(.up)
        case .down:  performMove(.down)
        case .left:  performMove(.left)
        case .right: performMove(.right)
        default: break
        }
    }

    private func performMove(_ direction: Direction) {
        guard game.state == .playing || game.state == .wonCanContinue else { return }
        try? game.apply(move: direction)
        updateUI()
        print(renderer.render())
    }

    @objc private func continueTapped() {
        continueButton.isHidden = true
        newGameButton.isHidden = true
    }

    @objc private func newGameTapped() { startGame() }
}

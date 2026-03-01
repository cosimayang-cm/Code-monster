//
//  ReversiViewController.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/3/1.
//

import UIKit

// MARK: - ReversiViewController
// 黑白棋 UIKit 輸入層。
// VC = 搖桿輸入：↑↓←→ 移動游標，✓ 放子，Pass 跳過。遊戲狀態透過 print(renderer.render()) 輸出至 Xcode console。

final class ReversiViewController: UIViewController {

    // MARK: - State

    private var game = ReversiGame()
    private var cursor = (row: 3, col: 3)
    private let ai = ReversiAI()

    private var renderer: ReversiRenderer {
        let showCursor = game.state == .playing && game.currentPlayer == .human
        return ReversiRenderer(game: game, cursor: showCursor ? cursor : nil)
    }

    // MARK: - UI

    private let upButton    = ReversiViewController.makeDPad("↑", tag: 0)
    private let downButton  = ReversiViewController.makeDPad("↓", tag: 1)
    private let leftButton  = ReversiViewController.makeDPad("←", tag: 2)
    private let rightButton = ReversiViewController.makeDPad("→", tag: 3)

    private let confirmButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("✓", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        b.backgroundColor = .systemGreen.withAlphaComponent(0.2)
        b.setTitleColor(.systemGreen, for: .normal)
        b.layer.cornerRadius = 26
        b.tag = 4
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let passButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Pass ⏭", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        b.backgroundColor = .systemOrange.withAlphaComponent(0.15)
        b.setTitleColor(.systemOrange, for: .normal)
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

    private static func makeDPad(_ title: String, tag: Int) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        b.backgroundColor = .secondarySystemBackground
        b.layer.cornerRadius = 10
        b.tag = tag
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Reversi"
        view.backgroundColor = .systemBackground
        setupUI()
        startGame()
    }

    private func setupUI() {
        let dpad = makeDPadStack()
        let bottomRow = UIStackView(arrangedSubviews: [passButton, newGameButton])
        bottomRow.axis = .horizontal; bottomRow.spacing = 12
        bottomRow.distribution = .fillEqually
        bottomRow.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(dpad)
        view.addSubview(bottomRow)

        [upButton, downButton, leftButton, rightButton, confirmButton].forEach {
            $0.addTarget(self, action: #selector(dpadTapped(_:)), for: .touchUpInside)
            NSLayoutConstraint.activate([
                $0.widthAnchor.constraint(equalToConstant: 52),
                $0.heightAnchor.constraint(equalToConstant: 52)
            ])
        }
        passButton.addTarget(self, action: #selector(passTapped), for: .touchUpInside)
        newGameButton.addTarget(self, action: #selector(newGameTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            bottomRow.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            bottomRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            bottomRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            bottomRow.heightAnchor.constraint(equalToConstant: 40),

            dpad.bottomAnchor.constraint(equalTo: bottomRow.topAnchor, constant: -12),
            dpad.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func makeDPadStack() -> UIStackView {
        func row(_ buttons: [UIButton?]) -> UIStackView {
            let s = UIStackView(); s.axis = .horizontal; s.spacing = 6; s.alignment = .center
            for b in buttons {
                if let b { s.addArrangedSubview(b) } else {
                    let sp = UIView()
                    NSLayoutConstraint.activate([
                        sp.widthAnchor.constraint(equalToConstant: 52),
                        sp.heightAnchor.constraint(equalToConstant: 52)
                    ])
                    s.addArrangedSubview(sp)
                }
            }
            return s
        }
        let s = UIStackView(arrangedSubviews: [
            row([nil, upButton, nil]),
            row([leftButton, confirmButton, rightButton]),
            row([nil, downButton, nil])
        ])
        s.axis = .vertical; s.spacing = 6; s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }

    // MARK: - Game

    private func startGame() {
        game.restart()
        cursor = (row: 3, col: 3)
        updateUI()
        print(renderer.render())
    }

    private func updateUI() {
        let isHumanTurn = game.state == .playing && game.currentPlayer == .human
        [upButton, downButton, leftButton, rightButton, confirmButton].forEach { $0.isEnabled = isHumanTurn }
        passButton.isHidden = !(isHumanTurn && game.isPassRequired())
        newGameButton.isHidden = game.state == .playing
    }

    // MARK: - Actions

    @objc private func dpadTapped(_ sender: UIButton) {
        guard game.state == .playing, game.currentPlayer == .human else { return }
        switch sender.tag {
        case 0: cursor.row = max(0, cursor.row - 1)    // ↑
        case 1: cursor.row = min(7, cursor.row + 1)    // ↓
        case 2: cursor.col = max(0, cursor.col - 1)    // ←
        case 3: cursor.col = min(7, cursor.col + 1)    // →
        case 4:                                         // ✓ place
            do {
                try game.apply(move: ReversiMove(row: cursor.row, col: cursor.col))
                updateUI()
                print(renderer.render())
                triggerAIIfNeeded()
                return
            } catch { }
        default: break
        }
        updateUI()
        print(renderer.render())
    }

    @objc private func passTapped() {
        try? game.pass()
        updateUI()
        print(renderer.render())
        triggerAIIfNeeded()
    }

    private func triggerAIIfNeeded() {
        guard game.state == .playing, game.currentPlayer == .ai else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self else { return }
            if let move = self.ai.bestMove(for: self.game) {
                try? self.game.apply(move: move)
            } else {
                try? self.game.pass()  // AI無子可下，跳過
            }
            self.updateUI()
            print(self.renderer.render())
            // AI 仍輪到自己（對手也無子）則繼續
            if self.game.state == .playing && self.game.currentPlayer == .ai {
                self.triggerAIIfNeeded()
            }
        }
    }

    @objc private func newGameTapped() { startGame() }
}

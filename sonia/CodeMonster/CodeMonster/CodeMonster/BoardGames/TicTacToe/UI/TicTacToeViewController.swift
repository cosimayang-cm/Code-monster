//
//  TicTacToeViewController.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/3/1.
//

import UIKit

// MARK: - TicTacToeViewController
// 井字棋 UIKit 輸入層。
// VC = 搖桿輸入：↑↓←→ 移動游標，✓ 放子。遊戲狀態透過 print(renderer.render()) 輸出至 Xcode console。

final class TicTacToeViewController: UIViewController {

    // MARK: - State

    private var game = TicTacToeGame()
    private var cursor = (row: 0, col: 0)
    private let ai = TicTacToeAI()

    private var renderer: TicTacToeRenderer {
        let showCursor = game.state == .playing && game.currentPlayer == .human
        return TicTacToeRenderer(game: game, cursor: showCursor ? cursor : nil)
    }

    // MARK: - UI

    private let upButton     = TicTacToeViewController.makeDPad("↑", tag: 0)
    private let downButton   = TicTacToeViewController.makeDPad("↓", tag: 1)
    private let leftButton   = TicTacToeViewController.makeDPad("←", tag: 2)
    private let rightButton  = TicTacToeViewController.makeDPad("→", tag: 3)

    private let confirmButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("✓", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        b.backgroundColor = .systemGreen.withAlphaComponent(0.2)
        b.setTitleColor(.systemGreen, for: .normal)
        b.layer.cornerRadius = 30
        b.tag = 4
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let newGameButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("New Game", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        b.backgroundColor = .systemBlue.withAlphaComponent(0.15)
        b.setTitleColor(.systemBlue, for: .normal)
        b.layer.cornerRadius = 12
        b.isHidden = true
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private static func makeDPad(_ title: String, tag: Int) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 22, weight: .medium)
        b.backgroundColor = .secondarySystemBackground
        b.layer.cornerRadius = 10
        b.tag = tag
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tic-Tac-Toe"
        view.backgroundColor = .systemBackground
        setupUI()
        startGame()
    }

    // MARK: - Setup

    private func setupUI() {
        // D-pad: 上中下三列
        let dpad = makeDPadStack()
        view.addSubview(dpad)
        view.addSubview(newGameButton)

        [upButton, downButton, leftButton, rightButton, confirmButton].forEach {
            $0.addTarget(self, action: #selector(dpadTapped(_:)), for: .touchUpInside)
            NSLayoutConstraint.activate([
                $0.widthAnchor.constraint(equalToConstant: 60),
                $0.heightAnchor.constraint(equalToConstant: 60)
            ])
        }
        newGameButton.addTarget(self, action: #selector(newGameTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            dpad.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dpad.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            newGameButton.bottomAnchor.constraint(equalTo: dpad.topAnchor, constant: -16),
            newGameButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newGameButton.widthAnchor.constraint(equalToConstant: 160),
            newGameButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func makeDPadStack() -> UIStackView {
        func row(_ buttons: [UIButton?]) -> UIStackView {
            let s = UIStackView()
            s.axis = .horizontal; s.spacing = 8; s.alignment = .center
            for b in buttons {
                if let b {
                    s.addArrangedSubview(b)
                } else {
                    let sp = UIView()
                    NSLayoutConstraint.activate([
                        sp.widthAnchor.constraint(equalToConstant: 60),
                        sp.heightAnchor.constraint(equalToConstant: 60)
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
        s.axis = .vertical; s.spacing = 8; s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }

    // MARK: - Game

    private func startGame() {
        game.restart()
        cursor = (row: 0, col: 0)
        updateUI()
        print(renderer.render())
    }

    private func updateUI() {
        let isHumanTurn = game.state == .playing && game.currentPlayer == .human
        [upButton, downButton, leftButton, rightButton, confirmButton].forEach { $0.isEnabled = isHumanTurn }
        newGameButton.isHidden = game.state == .playing
    }

    // MARK: - Actions

    @objc private func dpadTapped(_ sender: UIButton) {
        guard game.state == .playing, game.currentPlayer == .human else { return }
        switch sender.tag {
        case 0: cursor.row = max(0, cursor.row - 1)        // ↑
        case 1: cursor.row = min(2, cursor.row + 1)        // ↓
        case 2: cursor.col = max(0, cursor.col - 1)        // ←
        case 3: cursor.col = min(2, cursor.col + 1)        // →
        case 4:                                             // ✓ place
            do {
                try game.apply(move: TicTacToeMove(row: cursor.row, col: cursor.col))
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

    private func triggerAIIfNeeded() {
        guard game.state == .playing, game.currentPlayer == .ai else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self else { return }
            if let move = self.ai.bestMove(for: self.game) {
                try? self.game.apply(move: move)
                self.updateUI()
                print(self.renderer.render())
            }
        }
    }

    @objc private func newGameTapped() { startGame() }
}

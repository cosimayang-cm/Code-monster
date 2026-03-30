//
//  ConnectFourViewController.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/3/1.
//

import UIKit

// MARK: - ConnectFourViewController
// 四子棋 UIKit 輸入層。
// VC = 搖桿輸入：← → 選欄，▼ 投子。遊戲狀態透過 print(renderer.render()) 輸出至 Xcode console。

final class ConnectFourViewController: UIViewController {

    // MARK: - State

    private var game = ConnectFourGame()
    private var cursorCol = ConnectFourBoard.cols / 2
    private let ai = ConnectFourAI()

    private var renderer: ConnectFourRenderer {
        let showCursor = game.state == .playing && game.currentPlayer == .human
        return ConnectFourRenderer(game: game, cursor: showCursor ? cursorCol : nil)
    }

    // MARK: - UI

    private let leftButton  = ConnectFourViewController.makeCtrl("←", tag: 0)
    private let dropButton  = ConnectFourViewController.makeCtrl("▼", tag: 1)
    private let rightButton = ConnectFourViewController.makeCtrl("→", tag: 2)

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

    private static func makeCtrl(_ title: String, tag: Int) -> UIButton {
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
        title = "Connect Four"
        view.backgroundColor = .systemBackground
        setupUI()
        startGame()
    }

    private func setupUI() {
        let ctrlRow = UIStackView(arrangedSubviews: [leftButton, dropButton, rightButton])
        ctrlRow.axis = .horizontal
        ctrlRow.spacing = 16
        ctrlRow.distribution = .fillEqually
        ctrlRow.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(ctrlRow)
        view.addSubview(newGameButton)

        [leftButton, dropButton, rightButton].forEach {
            $0.addTarget(self, action: #selector(ctrlTapped(_:)), for: .touchUpInside)
            NSLayoutConstraint.activate([$0.heightAnchor.constraint(equalToConstant: 68)])
        }
        newGameButton.addTarget(self, action: #selector(newGameTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            ctrlRow.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ctrlRow.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ctrlRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            ctrlRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            newGameButton.bottomAnchor.constraint(equalTo: ctrlRow.topAnchor, constant: -16),
            newGameButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newGameButton.widthAnchor.constraint(equalToConstant: 160),
            newGameButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // MARK: - Game

    private func startGame() {
        game.restart()
        cursorCol = ConnectFourBoard.cols / 2
        updateUI()
        print(renderer.render())
    }

    private func updateUI() {
        let isHumanTurn = game.state == .playing && game.currentPlayer == .human
        leftButton.isEnabled = isHumanTurn
        rightButton.isEnabled = isHumanTurn
        dropButton.isEnabled = isHumanTurn && !game.board.isColumnFull(cursorCol)
        newGameButton.isHidden = game.state == .playing
    }

    // MARK: - Actions

    @objc private func ctrlTapped(_ sender: UIButton) {
        guard game.state == .playing, game.currentPlayer == .human else { return }
        switch sender.tag {
        case 0: cursorCol = max(0, cursorCol - 1)                       // ←
        case 2: cursorCol = min(ConnectFourBoard.cols - 1, cursorCol + 1) // →
        case 1:                                                           // ▼ drop
            do {
                try game.apply(move: ConnectFourMove(column: cursorCol))
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
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

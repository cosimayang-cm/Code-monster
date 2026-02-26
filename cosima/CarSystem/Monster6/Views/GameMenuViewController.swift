//
//  GameMenuViewController.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import UIKit

final class GameMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "🎮 Board Games"
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let games: [(String, Selector)] = [
            ("Tic-Tac-Toe 井字棋", #selector(openTicTacToe)),
            ("Connect Four 四子棋", #selector(openConnectFour)),
            ("Reversi 黑白棋", #selector(openReversi)),
            ("2048", #selector(open2048))
        ]

        for (title, action) in games {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
            button.backgroundColor = .systemBlue.withAlphaComponent(0.1)
            button.layer.cornerRadius = 12
            button.heightAnchor.constraint(equalToConstant: 56).isActive = true
            button.addTarget(self, action: action, for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    @objc private func openTicTacToe() {
        let vc = TicTacToeViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func openConnectFour() {
        let vc = ConnectFourViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func openReversi() {
        let vc = ReversiViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func open2048() {
        let vc = Game2048ViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

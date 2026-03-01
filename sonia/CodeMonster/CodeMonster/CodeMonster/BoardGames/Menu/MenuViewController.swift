//
//  MenuViewController.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/3/1.
//

import UIKit

// MARK: - MenuViewController
// 棋盤遊戲清單選擇入口。
// 顯示四款遊戲，點擊後 push 對應遊戲 ViewController。

final class MenuViewController: UIViewController {

    private enum Game: Int, CaseIterable {
        case ticTacToe = 0
        case connectFour
        case reversi
        case twentyFortyEight

        var title: String {
            switch self {
            case .ticTacToe:        return "Tic-Tac-Toe 井字棋"
            case .connectFour:      return "Connect Four 四子棋"
            case .reversi:          return "Reversi 黑白棋"
            case .twentyFortyEight: return "2048"
            }
        }

        var subtitle: String {
            switch self {
            case .ticTacToe:        return "3×3 · Minimax AI"
            case .connectFour:      return "7×6 · Alpha-Beta AI"
            case .reversi:          return "8×8 · 位置權重 AI"
            case .twentyFortyEight: return "4×4 · 單人挑戰"
            }
        }
    }

    private lazy var tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "🎮 Board Games"
        setupTableView()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "GameCell")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource

extension MenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Game.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath)
        let game = Game.allCases[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = game.title
        config.secondaryText = game.subtitle
        config.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc: UIViewController
        switch Game.allCases[indexPath.row] {
        case .ticTacToe:        vc = TicTacToeViewController()
        case .connectFour:      vc = ConnectFourViewController()
        case .reversi:          vc = ReversiViewController()
        case .twentyFortyEight: vc = TwentyFortyEightViewController()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

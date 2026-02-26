//
//  TicTacToeViewController.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import UIKit

final class TicTacToeViewController: UIViewController {

    private var engine: GameEngine<TicTacToeBoard, TicTacToeRenderer, TicTacToeAI>!
    private var buttons: [UIButton] = []
    private var gridStackView: UIStackView!
    private var replayButton: UIButton!
    private var menuButton: UIButton!
    private var endGameStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tic-Tac-Toe"
        view.backgroundColor = .systemBackground
        setupEngine()
        setupUI()
        engine.startGame()
    }

    // MARK: - Setup

    private func setupEngine() {
        let board = TicTacToeBoard()
        let renderer = TicTacToeRenderer()
        let ai = TicTacToeAI()
        engine = GameEngine(board: board, renderer: renderer, ai: ai)
        engine.delegate = self
    }

    private func setupUI() {
        // 3x3 grid of buttons
        gridStackView = UIStackView()
        gridStackView.axis = .vertical
        gridStackView.spacing = 8
        gridStackView.alignment = .center
        gridStackView.translatesAutoresizingMaskIntoConstraints = false

        let labels = ["A1", "A2", "A3", "B1", "B2", "B3", "C1", "C2", "C3"]

        for row in 0..<3 {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 8

            for col in 0..<3 {
                let index = row * 3 + col
                let button = UIButton(type: .system)
                button.setTitle(labels[index], for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
                button.backgroundColor = .systemGray5
                button.layer.cornerRadius = 8
                button.tag = index
                button.addTarget(self, action: #selector(cellTapped(_:)), for: .touchUpInside)
                button.widthAnchor.constraint(equalToConstant: 72).isActive = true
                button.heightAnchor.constraint(equalToConstant: 72).isActive = true
                buttons.append(button)
                rowStack.addArrangedSubview(button)
            }

            gridStackView.addArrangedSubview(rowStack)
        }

        // End game buttons
        replayButton = UIButton(type: .system)
        replayButton.setTitle("再玩一局", for: .normal)
        replayButton.titleLabel?.font = .systemFont(ofSize: 18)
        replayButton.addTarget(self, action: #selector(replayTapped), for: .touchUpInside)

        menuButton = UIButton(type: .system)
        menuButton.setTitle("回選單", for: .normal)
        menuButton.titleLabel?.font = .systemFont(ofSize: 18)
        menuButton.addTarget(self, action: #selector(menuTapped), for: .touchUpInside)

        endGameStackView = UIStackView(arrangedSubviews: [replayButton, menuButton])
        endGameStackView.axis = .horizontal
        endGameStackView.spacing = 24
        endGameStackView.alignment = .center
        endGameStackView.translatesAutoresizingMaskIntoConstraints = false
        endGameStackView.isHidden = true

        view.addSubview(gridStackView)
        view.addSubview(endGameStackView)

        NSLayoutConstraint.activate([
            gridStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gridStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            endGameStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            endGameStackView.topAnchor.constraint(equalTo: gridStackView.bottomAnchor, constant: 32)
        ])
    }

    // MARK: - Actions

    @objc private func cellTapped(_ sender: UIButton) {
        let move = TicTacToeMove(position: sender.tag)
        try? engine.applyHumanMove(move)
    }

    @objc private func replayTapped() {
        engine.reset()
        gridStackView.isHidden = false
        endGameStackView.isHidden = true
        for button in buttons {
            button.isEnabled = true
        }
        engine.startGame()
    }

    @objc private func menuTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - GameEngineDelegate

extension TicTacToeViewController: GameEngineDelegate {
    func gameEngineDidUpdateState(_ state: GameState) {
        if case .gameOver = state {
            gridStackView.isHidden = true
            endGameStackView.isHidden = false
        }
    }

    func gameEngineDidUpdateBoard(_ boardString: String) {
        print(boardString)
    }
}

//
//  ConnectFourViewController.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import UIKit

final class ConnectFourViewController: UIViewController {

    private var engine: GameEngine<ConnectFourBoard, ConnectFourRenderer, ConnectFourAI>!
    private var columnButtons: [UIButton] = []
    private var buttonStackView: UIStackView!
    private var replayButton: UIButton!
    private var menuButton: UIButton!
    private var endGameStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Connect Four"
        view.backgroundColor = .systemBackground
        setupEngine()
        setupUI()
        engine.startGame()
    }

    // MARK: - Setup

    private func setupEngine() {
        let board = ConnectFourBoard()
        let renderer = ConnectFourRenderer()
        let ai = ConnectFourAI()
        engine = GameEngine(board: board, renderer: renderer, ai: ai)
        engine.delegate = self
    }

    private func setupUI() {
        buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 8
        buttonStackView.alignment = .center
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false

        for col in 0..<7 {
            let button = UIButton(type: .system)
            button.setTitle("Col \(col + 1)", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
            button.backgroundColor = .systemGray5
            button.layer.cornerRadius = 8
            button.tag = col
            button.addTarget(self, action: #selector(columnTapped(_:)), for: .touchUpInside)
            button.widthAnchor.constraint(equalToConstant: 48).isActive = true
            button.heightAnchor.constraint(equalToConstant: 48).isActive = true
            columnButtons.append(button)
            buttonStackView.addArrangedSubview(button)
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

        view.addSubview(buttonStackView)
        view.addSubview(endGameStackView)

        NSLayoutConstraint.activate([
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            endGameStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            endGameStackView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 32)
        ])
    }

    // MARK: - Actions

    @objc private func columnTapped(_ sender: UIButton) {
        let move = ConnectFourMove(column: sender.tag)
        try? engine.applyHumanMove(move)
    }

    @objc private func replayTapped() {
        engine.reset()
        buttonStackView.isHidden = false
        endGameStackView.isHidden = true
        for button in columnButtons {
            button.isEnabled = true
        }
        engine.startGame()
    }

    @objc private func menuTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - GameEngineDelegate

extension ConnectFourViewController: GameEngineDelegate {
    func gameEngineDidUpdateState(_ state: GameState) {
        if case .gameOver = state {
            buttonStackView.isHidden = true
            endGameStackView.isHidden = false
        }
    }

    func gameEngineDidUpdateBoard(_ boardString: String) {
        print(boardString)
    }
}

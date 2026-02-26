//
//  Game2048ViewController.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import UIKit

final class Game2048ViewController: UIViewController {

    private var engine: GameEngine<Game2048Board, Game2048Renderer, Game2048DummyAI>!
    private var directionStackView: UIStackView!
    private var replayButton: UIButton!
    private var menuButton: UIButton!
    private var endGameStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "2048"
        view.backgroundColor = .systemBackground
        setupEngine()
        setupUI()
        engine.startGame()
    }

    // MARK: - Setup

    private func setupEngine() {
        let board = Game2048Board()
        let renderer = Game2048Renderer()
        let ai = Game2048DummyAI()
        engine = GameEngine(board: board, renderer: renderer, ai: ai)
        engine.delegate = self
    }

    private func setupUI() {
        // Direction buttons
        let upButton = makeDirectionButton(title: "⬆", direction: .up)
        let downButton = makeDirectionButton(title: "⬇", direction: .down)
        let leftButton = makeDirectionButton(title: "⬅", direction: .left)
        let rightButton = makeDirectionButton(title: "➡", direction: .right)

        let centerSpacer = UIView()
        centerSpacer.widthAnchor.constraint(equalToConstant: 60).isActive = true
        centerSpacer.heightAnchor.constraint(equalToConstant: 60).isActive = true

        let horizontalStack = UIStackView(arrangedSubviews: [leftButton, centerSpacer, rightButton])
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 8
        horizontalStack.alignment = .center

        directionStackView = UIStackView(arrangedSubviews: [upButton, horizontalStack, downButton])
        directionStackView.axis = .vertical
        directionStackView.spacing = 8
        directionStackView.alignment = .center
        directionStackView.translatesAutoresizingMaskIntoConstraints = false

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

        view.addSubview(directionStackView)
        view.addSubview(endGameStackView)

        NSLayoutConstraint.activate([
            directionStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            directionStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            endGameStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            endGameStackView.topAnchor.constraint(equalTo: directionStackView.bottomAnchor, constant: 32)
        ])
    }

    private func makeDirectionButton(title: String, direction: Direction) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 32)
        button.backgroundColor = .systemGray5
        button.layer.cornerRadius = 12
        button.widthAnchor.constraint(equalToConstant: 60).isActive = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.tag = directionTag(direction)
        button.addTarget(self, action: #selector(directionTapped(_:)), for: .touchUpInside)
        return button
    }

    private func directionTag(_ direction: Direction) -> Int {
        switch direction {
        case .up: return 0
        case .down: return 1
        case .left: return 2
        case .right: return 3
        }
    }

    private func tagToDirection(_ tag: Int) -> Direction {
        switch tag {
        case 0: return .up
        case 1: return .down
        case 2: return .left
        default: return .right
        }
    }

    // MARK: - Actions

    @objc private func directionTapped(_ sender: UIButton) {
        let direction = tagToDirection(sender.tag)
        let move = Game2048Move(direction: direction)
        try? engine.applyHumanMove(move)
    }

    @objc private func replayTapped() {
        engine.reset()
        directionStackView.isHidden = false
        endGameStackView.isHidden = true
        engine.startGame()
    }

    @objc private func menuTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - GameEngineDelegate

extension Game2048ViewController: GameEngineDelegate {
    func gameEngineDidUpdateState(_ state: GameState) {
        if case .gameOver = state {
            directionStackView.isHidden = true
            endGameStackView.isHidden = false
        }
    }

    func gameEngineDidUpdateBoard(_ boardString: String) {
        print(boardString)
    }
}

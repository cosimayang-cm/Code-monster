//
//  Game2048ViewController.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import UIKit

final class Game2048ViewController: UIViewController {

    private var engine: GameEngine<Game2048Board, Game2048Renderer, Game2048DummyAI>!
    private var tileLabels: [[UILabel]] = []
    private var scoreLabel: UILabel!
    private var gridView: UIView!
    private var directionStackView: UIStackView!
    private var replayButton: UIButton!
    private var menuButton: UIButton!
    private var endGameStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "2048"
        view.backgroundColor = UIColor(red: 0.98, green: 0.97, blue: 0.94, alpha: 1)
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
        // Score label
        scoreLabel = UILabel()
        scoreLabel.text = "Score: 0"
        scoreLabel.font = .systemFont(ofSize: 20, weight: .bold)
        scoreLabel.textAlignment = .center
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false

        // 4x4 Grid
        let gap: CGFloat = 8
        let tileSize: CGFloat = 72
        let gridSize = tileSize * 4 + gap * 5

        gridView = UIView()
        gridView.backgroundColor = UIColor(red: 0.73, green: 0.68, blue: 0.63, alpha: 1)
        gridView.layer.cornerRadius = 8
        gridView.translatesAutoresizingMaskIntoConstraints = false

        for row in 0..<4 {
            var rowLabels: [UILabel] = []
            for col in 0..<4 {
                let tile = UIView()
                tile.backgroundColor = UIColor(red: 0.80, green: 0.75, blue: 0.71, alpha: 1)
                tile.layer.cornerRadius = 6
                tile.frame = CGRect(
                    x: gap + CGFloat(col) * (tileSize + gap),
                    y: gap + CGFloat(row) * (tileSize + gap),
                    width: tileSize,
                    height: tileSize
                )
                gridView.addSubview(tile)

                let label = UILabel()
                label.font = .systemFont(ofSize: 24, weight: .bold)
                label.textAlignment = .center
                label.frame = tile.bounds
                label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                tile.addSubview(label)
                rowLabels.append(label)
            }
            tileLabels.append(rowLabels)
        }

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

        view.addSubview(scoreLabel)
        view.addSubview(gridView)
        view.addSubview(directionStackView)
        view.addSubview(endGameStackView)

        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            gridView.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 20),
            gridView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gridView.widthAnchor.constraint(equalToConstant: gridSize),
            gridView.heightAnchor.constraint(equalToConstant: gridSize),

            directionStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            directionStackView.topAnchor.constraint(equalTo: gridView.bottomAnchor, constant: 32),

            endGameStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            endGameStackView.topAnchor.constraint(equalTo: directionStackView.bottomAnchor, constant: 24)
        ])
    }

    private func updateTiles() {
        let cells = engine.board.cells
        for row in 0..<4 {
            for col in 0..<4 {
                let value = cells[row][col]
                let label = tileLabels[row][col]
                label.text = value == 0 ? "" : "\(value)"
                label.textColor = value <= 4 ? UIColor(red: 0.47, green: 0.43, blue: 0.40, alpha: 1) : .white
                label.superview?.backgroundColor = tileColor(value)
            }
        }
        scoreLabel.text = "Score: \(engine.board.score)"
    }

    private func tileColor(_ value: Int) -> UIColor {
        switch value {
        case 0:    return UIColor(red: 0.80, green: 0.75, blue: 0.71, alpha: 1)
        case 2:    return UIColor(red: 0.93, green: 0.89, blue: 0.85, alpha: 1)
        case 4:    return UIColor(red: 0.93, green: 0.88, blue: 0.79, alpha: 1)
        case 8:    return UIColor(red: 0.95, green: 0.69, blue: 0.47, alpha: 1)
        case 16:   return UIColor(red: 0.96, green: 0.58, blue: 0.39, alpha: 1)
        case 32:   return UIColor(red: 0.96, green: 0.49, blue: 0.37, alpha: 1)
        case 64:   return UIColor(red: 0.96, green: 0.37, blue: 0.23, alpha: 1)
        case 128:  return UIColor(red: 0.93, green: 0.81, blue: 0.45, alpha: 1)
        case 256:  return UIColor(red: 0.93, green: 0.80, blue: 0.38, alpha: 1)
        case 512:  return UIColor(red: 0.93, green: 0.78, blue: 0.31, alpha: 1)
        case 1024: return UIColor(red: 0.93, green: 0.76, blue: 0.25, alpha: 1)
        default:   return UIColor(red: 0.93, green: 0.74, blue: 0.18, alpha: 1)
        }
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
        updateTiles()
    }
}

//
//  ConnectFourViewController.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import UIKit

final class ConnectFourViewController: UIViewController {

    private let cols = 7
    private let rows = 6
    private let cellSize: CGFloat = 44
    private let gap: CGFloat = 4

    private var engine: GameEngine<ConnectFourBoard, ConnectFourRenderer, ConnectFourAI>!
    private var columnButtons: [UIButton] = []
    private var buttonStackView: UIStackView!
    private var gridView: UIView!
    private var cellViews: [[UIView]] = [] // [row][col], row 0 = top
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
        // Column drop buttons (▼ 1..7) at the top
        buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = gap
        buttonStackView.alignment = .center
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false

        for col in 0..<cols {
            let button = UIButton(type: .system)
            button.setTitle("▼", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
            button.tintColor = .systemRed
            button.tag = col
            button.addTarget(self, action: #selector(columnTapped(_:)), for: .touchUpInside)
            button.widthAnchor.constraint(equalToConstant: cellSize).isActive = true
            button.heightAnchor.constraint(equalToConstant: 32).isActive = true
            columnButtons.append(button)
            buttonStackView.addArrangedSubview(button)
        }

        // 6x7 grid
        let gridW = CGFloat(cols) * cellSize + CGFloat(cols + 1) * gap
        let gridH = CGFloat(rows) * cellSize + CGFloat(rows + 1) * gap

        gridView = UIView()
        gridView.backgroundColor = UIColor(red: 0.10, green: 0.30, blue: 0.80, alpha: 1) // 藍色棋盤
        gridView.layer.cornerRadius = 8
        gridView.translatesAutoresizingMaskIntoConstraints = false

        for row in 0..<rows {
            var rowViews: [UIView] = []
            for col in 0..<cols {
                let circle = UIView()
                circle.backgroundColor = .systemBackground
                circle.layer.cornerRadius = cellSize / 2
                circle.frame = CGRect(
                    x: gap + CGFloat(col) * (cellSize + gap),
                    y: gap + CGFloat(row) * (cellSize + gap),
                    width: cellSize,
                    height: cellSize
                )
                gridView.addSubview(circle)
                rowViews.append(circle)
            }
            cellViews.append(rowViews)
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
        view.addSubview(gridView)
        view.addSubview(endGameStackView)

        NSLayoutConstraint.activate([
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),

            gridView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 4),
            gridView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gridView.widthAnchor.constraint(equalToConstant: gridW),
            gridView.heightAnchor.constraint(equalToConstant: gridH),

            endGameStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            endGameStackView.topAnchor.constraint(equalTo: gridView.bottomAnchor, constant: 24)
        ])
    }

    private func updateGrid() {
        let board = engine.board
        // columns[col] stores pieces from bottom (index 0) to top
        // display row 0 = top (data row = rows - 1)
        for displayRow in 0..<rows {
            let dataRow = rows - 1 - displayRow
            for col in 0..<cols {
                let cell = board.columns[col].count > dataRow ? board.columns[col][dataRow] : .empty
                let circle = cellViews[displayRow][col]
                switch cell {
                case .empty:  circle.backgroundColor = .systemBackground
                case .red:    circle.backgroundColor = .systemRed
                case .yellow: circle.backgroundColor = .systemYellow
                }
            }
        }

        // Disable full columns
        for col in 0..<cols {
            columnButtons[col].isEnabled = board.columns[col].count < rows
        }
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
        for button in columnButtons { button.isEnabled = true }
        for row in cellViews { for circle in row { circle.backgroundColor = .systemBackground } }
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
        updateGrid()
    }
}

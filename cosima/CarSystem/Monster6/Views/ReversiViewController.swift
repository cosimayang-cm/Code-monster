//
//  ReversiViewController.swift
//  CarSystem
//
//  Monster6 - Console Board Game 棋盤遊戲引擎
//

import UIKit

final class ReversiViewController: UIViewController {

    private var engine: GameEngine<ReversiBoard, ReversiRenderer, ReversiAI>!
    private var collectionView: UICollectionView!
    private var currentBoard = ReversiBoard()
    private var replayButton: UIButton!
    private var menuButton: UIButton!
    private var endGameStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Reversi"
        view.backgroundColor = .systemBackground
        setupEngine()
        setupUI()
        engine.startGame()
    }

    // MARK: - Setup

    private func setupEngine() {
        let board = ReversiBoard()
        let renderer = ReversiRenderer()
        let ai = ReversiAI()
        engine = GameEngine(board: board, renderer: renderer, ai: ai)
        engine.delegate = self
    }

    private func setupUI() {
        // 8x8 collection view
        let layout = UICollectionViewFlowLayout()
        let cellSize: CGFloat = 40
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGray4
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false

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

        view.addSubview(collectionView)
        view.addSubview(endGameStackView)

        let totalSize: CGFloat = cellSize * 8 + 7 // 8 cells + 7 gaps
        NSLayoutConstraint.activate([
            collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            collectionView.widthAnchor.constraint(equalToConstant: totalSize),
            collectionView.heightAnchor.constraint(equalToConstant: totalSize),
            endGameStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            endGameStackView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 32)
        ])
    }

    // MARK: - Actions

    @objc private func replayTapped() {
        engine.reset()
        currentBoard = ReversiBoard()
        collectionView.isHidden = false
        endGameStackView.isHidden = true
        collectionView.reloadData()
        engine.startGame()
    }

    @objc private func menuTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UICollectionView

extension ReversiViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        64 // 8x8
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let row = indexPath.item / 8
        let col = indexPath.item % 8
        let cellState = currentBoard.cells[row][col]

        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.backgroundColor = UIColor(red: 0.0, green: 0.55, blue: 0.15, alpha: 1.0) // 棋盤綠

        switch cellState {
        case .empty:
            // 顯示可下點提示
            let legalMoves = currentBoard.legalMoves()
            if legalMoves.contains(where: { $0.row == row && $0.col == col }) {
                let dot = UIView()
                dot.backgroundColor = UIColor.white.withAlphaComponent(0.3)
                dot.layer.cornerRadius = 6
                dot.translatesAutoresizingMaskIntoConstraints = false
                cell.contentView.addSubview(dot)
                NSLayoutConstraint.activate([
                    dot.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                    dot.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                    dot.widthAnchor.constraint(equalToConstant: 12),
                    dot.heightAnchor.constraint(equalToConstant: 12)
                ])
            }
        case .black, .white:
            let piece = UIView()
            piece.backgroundColor = cellState == .black ? .black : .white
            piece.layer.cornerRadius = 16
            piece.layer.borderWidth = cellState == .white ? 0.5 : 0
            piece.layer.borderColor = UIColor.lightGray.cgColor
            piece.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(piece)
            NSLayoutConstraint.activate([
                piece.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                piece.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                piece.widthAnchor.constraint(equalToConstant: 32),
                piece.heightAnchor.constraint(equalToConstant: 32)
            ])
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.item / 8
        let col = indexPath.item % 8

        // Find matching legal move
        let moves = currentBoard.legalMoves()
        guard let move = moves.first(where: { $0.row == row && $0.col == col }) else { return }
        try? engine.applyHumanMove(move)
    }
}

// MARK: - GameEngineDelegate

extension ReversiViewController: GameEngineDelegate {
    func gameEngineDidUpdateState(_ state: GameState) {
        if case .gameOver = state {
            collectionView.isHidden = true
            endGameStackView.isHidden = false
        }
    }

    func gameEngineDidUpdateBoard(_ boardString: String) {
        currentBoard = engine.board
        collectionView.reloadData()
    }
}

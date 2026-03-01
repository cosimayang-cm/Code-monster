import UIKit

final class ReversiViewController: UIViewController {
    private let engine = ReversiEngine()
    private let ai = ReversiAI()
    private let renderer = ReversiRenderer()
    private var collectionView: UICollectionView!
    private var validMovePositions: Set<Int> = []  // indexPath.item values for valid moves

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Reversi"
        setupCollectionView()
        setupResetButton()
        engine.onStateChanged = { [weak self] _, _ in }
        printBoard()
        refreshCollectionView()
    }

    private func setupCollectionView() {
        let size = ReversiBoard.size
        let cellSize = (min(view.bounds.width, 400) - CGFloat(size + 1) * 2) / CGFloat(size)

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor(red: 0.1, green: 0.55, blue: 0.1, alpha: 1)
        collectionView.register(ReversiCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.layer.cornerRadius = 8
        view.addSubview(collectionView)

        let totalSize = CGFloat(size) * cellSize + CGFloat(size + 1) * 2
        NSLayoutConstraint.activate([
            collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            collectionView.widthAnchor.constraint(equalToConstant: totalSize),
            collectionView.heightAnchor.constraint(equalToConstant: totalSize)
        ])
    }

    private func setupResetButton() {
        var config = UIButton.Configuration.filled()
        config.title = "Reset"
        config.baseBackgroundColor = .systemRed
        let resetButton = UIButton(configuration: config)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.addTarget(self, action: #selector(resetGame), for: .touchUpInside)
        view.addSubview(resetButton)
        NSLayoutConstraint.activate([
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            resetButton.widthAnchor.constraint(equalToConstant: 120)
        ])
    }

    private func refreshCollectionView() {
        guard case .playing(let current) = engine.state else {
            validMovePositions = []
            collectionView.reloadData()
            return
        }
        let moves = engine.validMoves(for: current, on: engine.board)
        validMovePositions = Set(moves.map { $0.row * ReversiBoard.size + $0.col })
        collectionView.reloadData()
    }

    private func printBoard() {
        guard case .playing(let current) = engine.state else {
            if case .finished(let result) = engine.state {
                let boardStr = renderer.render(engine.board)
                switch result {
                case .win(let player):
                    let symbol = player == .playerOne ? "⚫ Black" : "⚪ White"
                    print("\n\(boardStr)\n\n🎉 \(symbol) wins!")
                case .draw:
                    print("\n\(boardStr)\n\n🤝 Draw!")
                }
            }
            return
        }

        let validMoves = engine.validMoves(for: current, on: engine.board)
        let validPositions = validMoves.map { ($0.row, $0.col) }
        var flipCounts: [String: Int] = [:]
        let rowLetters = ["A","B","C","D","E","F","G","H"]

        for move in validMoves {
            let flips = engine.flippedCells(for: move, player: current, board: engine.board)
            let key = "\(rowLetters[move.row])\(move.col + 1)"
            flipCounts[key] = flips.count
        }

        let boardStr = renderer.render(engine.board, validMoves: validPositions, flipCounts: flipCounts)
        let symbol = current == .playerOne ? "⚫" : "⚪"
        let flipInfo = flipCounts.map { "\($0.key)→\($0.value)" }.joined(separator: ", ")
        print("\n\(boardStr)\n\nPlayer \(symbol)'s turn | Flips: \(flipInfo)")
    }

    private func triggerAIIfNeeded() {
        guard case .playing(let current) = engine.state, current == .playerTwo else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }
            if let aiMove = self.ai.bestMove(for: self.engine.board) {
                _ = self.engine.applyMove(aiMove)
                self.printBoard()
                self.refreshCollectionView()
            }
        }
    }

    @objc private func resetGame() {
        engine.reset()
        print("\n--- Game Reset ---")
        printBoard()
        refreshCollectionView()
    }
}

extension ReversiViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        ReversiBoard.size * ReversiBoard.size
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ReversiCell
        let row = indexPath.item / ReversiBoard.size
        let col = indexPath.item % ReversiBoard.size
        let piece = engine.board.cells[row][col]
        let isValid = validMovePositions.contains(indexPath.item)
        cell.configure(piece: piece, isValidMove: isValid, row: row, col: col)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard case .playing(let current) = engine.state, current == .playerOne else { return }
        let row = indexPath.item / ReversiBoard.size
        let col = indexPath.item % ReversiBoard.size
        let move = ReversiMove(row: row, col: col)
        if engine.applyMove(move) {
            printBoard()
            refreshCollectionView()
            triggerAIIfNeeded()
        }
    }
}

// MARK: - Custom Cell

private final class ReversiCell: UICollectionViewCell {
    private let pieceView = UIView()
    private let dotView = UIView()
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 0.1, green: 0.55, blue: 0.1, alpha: 1)
        layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
        layer.borderWidth = 0.5

        // Coordinate label (top-left corner)
        label.font = .systemFont(ofSize: 8)
        label.textColor = .white.withAlphaComponent(0.6)
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 1)
        ])

        // Valid move dot (small dot in center)
        dotView.backgroundColor = .white.withAlphaComponent(0.4)
        dotView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dotView)
        NSLayoutConstraint.activate([
            dotView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dotView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dotView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3),
            dotView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.3)
        ])

        // Piece view (circle)
        pieceView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(pieceView)
        NSLayoutConstraint.activate([
            pieceView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            pieceView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            pieceView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            pieceView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        pieceView.layer.cornerRadius = pieceView.bounds.width / 2
        dotView.layer.cornerRadius = dotView.bounds.width / 2
    }

    func configure(piece: Player, isValidMove: Bool, row: Int, col: Int) {
        let rowLetters = ["A","B","C","D","E","F","G","H"]
        label.text = "\(rowLetters[row])\(col + 1)"

        switch piece {
        case .playerOne:
            pieceView.isHidden = false
            pieceView.backgroundColor = .black
            dotView.isHidden = true
        case .playerTwo:
            pieceView.isHidden = false
            pieceView.backgroundColor = .white
            dotView.isHidden = true
        case .none:
            pieceView.isHidden = true
            dotView.isHidden = !isValidMove
        }

        // Highlight valid move cells
        if isValidMove && piece == .none {
            backgroundColor = UIColor(red: 0.15, green: 0.65, blue: 0.15, alpha: 1)
        } else {
            backgroundColor = UIColor(red: 0.1, green: 0.55, blue: 0.1, alpha: 1)
        }
    }
}

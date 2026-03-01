import UIKit

// MARK: - ConnectFourViewController
// 四子棋 UIKit 輸入層。
// 7 個欄位按鈕 + 棋盤格顯示。每次操作後 print(renderer.render()) 到 Console。

final class ConnectFourViewController: UIViewController {

    private var game = ConnectFourGame()
    private var renderer: ConnectFourRenderer { ConnectFourRenderer(game: game) }
    private let ai = ConnectFourAI()

    // MARK: - UI Components

    private let statusLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 18, weight: .medium)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    /// 棋盤格 grid (rows × cols UIView)
    private var cellViews: [[UIView]] = []
    private let boardGrid: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 3
        s.distribution = .fillEqually
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    /// 底部欄位選擇按鈕
    private var columnButtons: [UIButton] = []
    private let columnStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 3
        s.distribution = .fillEqually
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Connect Four"
        view.backgroundColor = .systemBackground
        setupUI()
        startGame()
    }

    // MARK: - Setup

    private func setupUI() {
        view.addSubview(statusLabel)
        view.addSubview(boardGrid)
        view.addSubview(columnStack)
        view.addSubview(newGameButton)

        // Build board grid: row 5 (top) → row 0 (bottom)
        for _ in 0..<ConnectFourBoard.rows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 3
            rowStack.distribution = .fillEqually
            var rowViews: [UIView] = []
            for _ in 0..<ConnectFourBoard.cols {
                let cell = UIView()
                cell.backgroundColor = .secondarySystemBackground
                cell.layer.cornerRadius = 4
                rowViews.append(cell)
                rowStack.addArrangedSubview(cell)
            }
            cellViews.append(rowViews)
            boardGrid.addArrangedSubview(rowStack)
        }

        // Column buttons (drop arrows)
        for col in 0..<ConnectFourBoard.cols {
            let b = UIButton(type: .system)
            b.setTitle("▼", for: .normal)
            b.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
            b.tag = col
            b.addTarget(self, action: #selector(columnButtonTapped(_:)), for: .touchUpInside)
            columnButtons.append(b)
            columnStack.addArrangedSubview(b)
        }

        newGameButton.addTarget(self, action: #selector(newGameTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            columnStack.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 12),
            columnStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            columnStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            columnStack.heightAnchor.constraint(equalToConstant: 36),

            boardGrid.topAnchor.constraint(equalTo: columnStack.bottomAnchor, constant: 6),
            boardGrid.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            boardGrid.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            boardGrid.heightAnchor.constraint(equalTo: boardGrid.widthAnchor, multiplier: CGFloat(ConnectFourBoard.rows) / CGFloat(ConnectFourBoard.cols)),

            newGameButton.topAnchor.constraint(equalTo: boardGrid.bottomAnchor, constant: 24),
            newGameButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newGameButton.widthAnchor.constraint(equalToConstant: 160),
            newGameButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func startGame() {
        game.restart()
        updateUI()
        print(renderer.render())
    }

    // MARK: - Update UI

    private func updateUI() {
        // Update board cells — cellViews[0] = top row visually (row 5 data)
        for displayRow in 0..<ConnectFourBoard.rows {
            let dataRow = ConnectFourBoard.rows - 1 - displayRow
            for col in 0..<ConnectFourBoard.cols {
                let cell = cellViews[displayRow][col]
                switch game.board[dataRow, col] {
                case .human: cell.backgroundColor = .systemRed
                case .ai:    cell.backgroundColor = .systemYellow
                case nil:    cell.backgroundColor = .secondarySystemBackground
                }
            }
        }

        // Update column buttons
        let isPlaying = game.state == .playing && game.currentPlayer == .human
        for (col, button) in columnButtons.enumerated() {
            button.isEnabled = isPlaying && !game.board.isColumnFull(col)
            button.alpha = button.isEnabled ? 1.0 : 0.3
        }

        // Status
        switch game.state {
        case .playing:
            statusLabel.text = game.currentPlayer == .human ? "Your turn 🔴" : "AI thinking... 🟡"
        case .won(let p):
            statusLabel.text = p == .human ? "🏆 You win!" : "🤖 AI wins!"
        case .draw:
            statusLabel.text = "🤝 Draw!"
        default:
            statusLabel.text = ""
        }

        newGameButton.isHidden = game.state == .playing
    }

    // MARK: - Actions

    @objc private func columnButtonTapped(_ sender: UIButton) {
        let col = sender.tag
        guard game.state == .playing, game.currentPlayer == .human else { return }

        do {
            try game.apply(move: ConnectFourMove(column: col))
            updateUI()
            print(renderer.render())
        } catch { return }

        guard game.state == .playing else { return }

        // Disable buttons during AI thinking
        columnButtons.forEach { $0.isEnabled = false }
        statusLabel.text = "AI thinking... 🟡"

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self else { return }
            if let aiMove = self.ai.bestMove(for: self.game) {
                try? self.game.apply(move: aiMove)
                self.updateUI()
                print(self.renderer.render())
            }
        }
    }

    @objc private func newGameTapped() {
        startGame()
    }
}

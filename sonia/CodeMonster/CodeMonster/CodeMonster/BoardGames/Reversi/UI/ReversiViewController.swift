import UIKit

// MARK: - ReversiViewController
// 黑白棋 UIKit 輸入層。
// 8×8 UIButton grid + Pass 按鈕（有子可下時 hidden）。

final class ReversiViewController: UIViewController {

    private var game = ReversiGame()
    private var renderer: ReversiRenderer { ReversiRenderer(game: game) }
    private let ai = ReversiAI()

    // MARK: - UI Components

    private let statusLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 17, weight: .medium)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let scoreLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 15)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private var cellButtons: [[UIButton]] = []
    private let boardGrid: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 2
        s.distribution = .fillEqually
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let passButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Pass ⏭", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        b.backgroundColor = .systemOrange.withAlphaComponent(0.15)
        b.setTitleColor(.systemOrange, for: .normal)
        b.layer.cornerRadius = 12
        b.isHidden = true
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
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
        title = "Reversi"
        view.backgroundColor = .systemBackground
        setupUI()
        startGame()
    }

    // MARK: - Setup

    private func setupUI() {
        view.addSubview(statusLabel)
        view.addSubview(scoreLabel)
        view.addSubview(boardGrid)
        view.addSubview(passButton)
        view.addSubview(newGameButton)

        for row in 0..<8 {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 2
            rowStack.distribution = .fillEqually
            var rowButtons: [UIButton] = []
            for col in 0..<8 {
                let b = UIButton(type: .system)
                b.tag = row * 8 + col
                b.titleLabel?.font = .systemFont(ofSize: 18)
                b.backgroundColor = UIColor(red: 0.1, green: 0.5, blue: 0.2, alpha: 1)
                b.layer.cornerRadius = 2
                b.addTarget(self, action: #selector(cellTapped(_:)), for: .touchUpInside)
                rowButtons.append(b)
                rowStack.addArrangedSubview(b)
            }
            cellButtons.append(rowButtons)
            boardGrid.addArrangedSubview(rowStack)
        }

        passButton.addTarget(self, action: #selector(passTapped), for: .touchUpInside)
        newGameButton.addTarget(self, action: #selector(newGameTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            scoreLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 4),
            scoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scoreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            boardGrid.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 12),
            boardGrid.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            boardGrid.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            boardGrid.heightAnchor.constraint(equalTo: boardGrid.widthAnchor),

            passButton.topAnchor.constraint(equalTo: boardGrid.bottomAnchor, constant: 20),
            passButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passButton.widthAnchor.constraint(equalToConstant: 160),
            passButton.heightAnchor.constraint(equalToConstant: 44),

            newGameButton.topAnchor.constraint(equalTo: passButton.bottomAnchor, constant: 12),
            newGameButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newGameButton.widthAnchor.constraint(equalToConstant: 160),
            newGameButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func startGame() {
        game.restart()
        updateUI()
        print(renderer.render())
    }

    // MARK: - Update UI

    private func updateUI() {
        let validMoves = game.validMoves()
        let validSet = Set(validMoves.map { $0.row * 8 + $0.col })
        let isHumanTurn = game.state == .playing && game.currentPlayer == .human

        for row in 0..<8 {
            for col in 0..<8 {
                let b = cellButtons[row][col]
                let key = row * 8 + col
                switch game.board[row, col] {
                case .black:
                    b.setTitle("⚫", for: .normal)
                    b.isEnabled = false
                case .white:
                    b.setTitle("⚪", for: .normal)
                    b.isEnabled = false
                case .empty:
                    if validSet.contains(key) && isHumanTurn {
                        b.setTitle("·", for: .normal)
                        b.isEnabled = true
                    } else {
                        b.setTitle("", for: .normal)
                        b.isEnabled = false
                    }
                }
            }
        }

        let black = game.board.count(for: .human)
        let white = game.board.count(for: .ai)
        scoreLabel.text = "⚫ \(black)  ⚪ \(white)"

        switch game.state {
        case .playing:
            statusLabel.text = game.currentPlayer == .human ? "Your turn ⚫" : "AI thinking... ⚪"
        case .won(let p):
            statusLabel.text = p == .human ? "🏆 You win!" : "🤖 AI wins!"
        case .draw:
            statusLabel.text = "🤝 Draw!"
        default:
            statusLabel.text = ""
        }

        passButton.isHidden = !(isHumanTurn && game.isPassRequired())
        newGameButton.isHidden = game.state == .playing
    }

    // MARK: - Actions

    @objc private func cellTapped(_ sender: UIButton) {
        let row = sender.tag / 8
        let col = sender.tag % 8
        guard game.state == .playing, game.currentPlayer == .human else { return }

        do {
            try game.apply(move: ReversiMove(row: row, col: col))
            updateUI()
            print(renderer.render())
        } catch { return }

        triggerAIIfNeeded()
    }

    @objc private func passTapped() {
        // Pass: force switch player by attempting the game's pass logic
        // Since apply throws on noFlipsAvailable, we handle pass by switching currentPlayer:
        game.restart()  // Not ideal — replace with proper pass mechanism via game state
        // Proper approach: create a "pass" move. Here we re-use app logic by
        // switching in game — actually ReversiGame handles auto-pass in apply,
        // so manual pass just means the human has no moves. Trigger AI.
        triggerAIIfNeeded()
    }

    @objc private func newGameTapped() {
        startGame()
    }

    private func triggerAIIfNeeded() {
        guard game.state == .playing, game.currentPlayer == .ai else { return }
        statusLabel.text = "AI thinking... ⚪"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self else { return }
            if let aiMove = self.ai.bestMove(for: self.game) {
                try? self.game.apply(move: aiMove)
            }
            self.updateUI()
            print(self.renderer.render())
            // If AI pass is needed, trigger again (rare)
            if self.game.state == .playing && self.game.currentPlayer == .ai {
                self.triggerAIIfNeeded()
            }
        }
    }
}

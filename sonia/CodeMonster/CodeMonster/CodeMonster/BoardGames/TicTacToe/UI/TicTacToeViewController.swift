import UIKit

// MARK: - TicTacToeViewController
// 井字棋 UIKit 輸入層。
// VC = Input Only：3×3 UIButton grid。每次操作後 print(renderer.render()) 到 Console。

final class TicTacToeViewController: UIViewController {

    // MARK: - Properties

    private var game = TicTacToeGame()
    private var renderer: TicTacToeRenderer { TicTacToeRenderer(game: game) }
    private let ai = TicTacToeAI()

    // MARK: - UI Components

    private let gridStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 8
        s.distribution = .fillEqually
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private var cellButtons: [[UIButton]] = []

    private let statusLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 18, weight: .medium)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
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
        title = "Tic-Tac-Toe"
        view.backgroundColor = .systemBackground
        setupUI()
        startGame()
    }

    // MARK: - Setup

    private func setupUI() {
        view.addSubview(statusLabel)
        view.addSubview(gridStack)
        view.addSubview(newGameButton)

        // Build 3×3 grid
        for row in 0..<3 {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 8
            rowStack.distribution = .fillEqually

            var rowButtons: [UIButton] = []
            for col in 0..<3 {
                let button = UIButton(type: .system)
                button.tag = row * 3 + col
                button.titleLabel?.font = .systemFont(ofSize: 36)
                button.backgroundColor = .secondarySystemBackground
                button.layer.cornerRadius = 12
                button.addTarget(self, action: #selector(cellButtonTapped(_:)), for: .touchUpInside)
                rowStack.addArrangedSubview(button)
                rowButtons.append(button)
            }
            cellButtons.append(rowButtons)
            gridStack.addArrangedSubview(rowStack)
        }

        newGameButton.addTarget(self, action: #selector(newGameTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            gridStack.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 24),
            gridStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            gridStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            gridStack.heightAnchor.constraint(equalTo: gridStack.widthAnchor),

            newGameButton.topAnchor.constraint(equalTo: gridStack.bottomAnchor, constant: 32),
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
        // Update cell buttons
        for row in 0..<3 {
            for col in 0..<3 {
                let button = cellButtons[row][col]
                switch game.board[row, col] {
                case .human:
                    button.setTitle("❌", for: .normal)
                    button.isEnabled = false
                case .ai:
                    button.setTitle("⭕", for: .normal)
                    button.isEnabled = false
                case nil:
                    button.setTitle("", for: .normal)
                    button.isEnabled = (game.state == .playing)
                }
            }
        }

        // Status label
        switch game.state {
        case .playing:
            statusLabel.text = game.currentPlayer == .human ? "Your turn ❌" : "AI thinking... ⭕"
        case .won(let p):
            statusLabel.text = p == .human ? "🏆 You win!" : "🤖 AI wins!"
        case .draw:
            statusLabel.text = "🤝 Draw!"
        default:
            statusLabel.text = ""
        }

        // New Game button
        let isOver = game.state != .playing
        newGameButton.isHidden = !isOver
    }

    // MARK: - Actions

    @objc private func cellButtonTapped(_ sender: UIButton) {
        let row = sender.tag / 3
        let col = sender.tag % 3
        guard game.state == .playing else { return }

        do {
            try game.apply(move: TicTacToeMove(row: row, col: col))
            updateUI()
            print(renderer.render())
        } catch {
            return
        }

        // AI turn
        guard game.state == .playing else { return }
        updateUI()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
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

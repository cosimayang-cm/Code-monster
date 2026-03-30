import UIKit

final class TicTacToeViewController: UIViewController {
    private let engine = TicTacToeEngine()
    private let ai = TicTacToeAI()
    private let renderer = TicTacToeRenderer()
    private var buttons: [[UIButton]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Tic-Tac-Toe"
        setupButtons()
        setupResetButton()
        engine.onStateChanged = { [weak self] state, board in
            self?.handleStateChange(state: state, board: board)
        }
        printBoard()
    }

    private func setupButtons() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 240)
        ])

        for row in 0..<3 {
            var rowButtons: [UIButton] = []
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 8
            rowStack.distribution = .fillEqually

            for col in 0..<3 {
                var config = UIButton.Configuration.filled()
                config.title = "\(["A","B","C"][row])\(col+1)"
                config.baseForegroundColor = .white
                config.baseBackgroundColor = .systemBlue
                let button = UIButton(configuration: config)
                button.tag = row * 3 + col
                button.addTarget(self, action: #selector(cellTapped(_:)), for: .touchUpInside)
                button.heightAnchor.constraint(equalToConstant: 70).isActive = true
                rowStack.addArrangedSubview(button)
                rowButtons.append(button)
            }
            buttons.append(rowButtons)
            stackView.addArrangedSubview(rowStack)
        }
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

    @objc private func cellTapped(_ sender: UIButton) {
        guard case .playing(let current) = engine.state, current == .playerOne else { return }
        let row = sender.tag / 3
        let col = sender.tag % 3
        let move = TicTacToeMove(row: row, col: col)
        if engine.applyMove(move) {
            printBoard()
            triggerAIIfNeeded()
        }
    }

    private func triggerAIIfNeeded() {
        guard case .playing(let current) = engine.state, current == .playerTwo else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self else { return }
            if let aiMove = self.ai.bestMove(for: self.engine.board) {
                _ = self.engine.applyMove(aiMove)
                self.printBoard()
            }
        }
    }

    private func printBoard() {
        let boardStr = renderer.render(engine.board)
        switch engine.state {
        case .playing(let player):
            let symbol = player == .playerOne ? "X" : "O"
            print("\n\(boardStr)\n\nPlayer \(symbol)'s turn")
        case .finished(let result):
            switch result {
            case .win(let player):
                let symbol = player == .playerOne ? "X" : "O"
                print("\n\(boardStr)\n\nPlayer \(symbol) wins!")
            case .draw:
                print("\n\(boardStr)\n\nDraw!")
            }
        case .waiting:
            print("\n\(boardStr)")
        }
    }

    private func handleStateChange(state: GameState, board: TicTacToeBoard) {
        // Board state is rendered to console via printBoard()
    }

    @objc private func resetGame() {
        engine.reset()
        print("\n--- Game Reset ---")
        printBoard()
    }
}

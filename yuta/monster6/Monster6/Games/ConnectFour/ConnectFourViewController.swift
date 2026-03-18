import UIKit

final class ConnectFourViewController: UIViewController {
    private let engine = ConnectFourEngine()
    private let ai = ConnectFourAI()
    private let renderer = ConnectFourRenderer()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Connect Four"
        setupButtons()
        setupResetButton()
        engine.onStateChanged = { [weak self] _, _ in }
        printBoard()
    }

    private func setupButtons() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 350),
            stackView.heightAnchor.constraint(equalToConstant: 60)
        ])

        for col in 0..<7 {
            var config = UIButton.Configuration.filled()
            config.title = "\(col + 1)"
            config.baseBackgroundColor = .systemBlue
            let button = UIButton(configuration: config)
            button.tag = col
            button.addTarget(self, action: #selector(columnTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
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

    @objc private func columnTapped(_ sender: UIButton) {
        guard case .playing(let current) = engine.state, current == .playerOne else { return }
        let move = ConnectFourMove(col: sender.tag)
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
            let symbol = player == .playerOne ? "Red" : "Yellow"
            print("\n\(boardStr)\n\nPlayer \(symbol)'s turn | Select column (1-7):")
        case .finished(let result):
            switch result {
            case .win(let player):
                let symbol = player == .playerOne ? "Red" : "Yellow"
                print("\n\(boardStr)\n\nPlayer \(symbol) wins!")
            case .draw:
                print("\n\(boardStr)\n\nDraw!")
            }
        case .waiting:
            print("\n\(boardStr)")
        }
    }

    @objc private func resetGame() {
        engine.reset()
        print("\n--- Game Reset ---")
        printBoard()
    }
}

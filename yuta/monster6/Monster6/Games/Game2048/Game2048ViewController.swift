import UIKit

final class Game2048ViewController: UIViewController {
    private let engine = Game2048Engine()
    private let renderer = Game2048Renderer()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "2048"
        setupButtons()
        setupResetButton()
        engine.onStateChanged = { [weak self] _, _ in }
        printBoard()
    }

    private func setupButtons() {
        let directions: [(String, Game2048Direction)] = [("Up", .up), ("Down", .down), ("Left", .left), ("Right", .right)]
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 300),
            stackView.heightAnchor.constraint(equalToConstant: 70)
        ])

        for (title, direction) in directions {
            var config = UIButton.Configuration.filled()
            config.title = title
            config.baseForegroundColor = .white
            config.baseBackgroundColor = .systemOrange
            config.buttonSize = .large
            let button = UIButton(configuration: config)
            button.addAction(UIAction { [weak self] _ in
                self?.handleDirection(direction)
            }, for: .touchUpInside)
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

    private func handleDirection(_ direction: Game2048Direction) {
        guard case .playing = engine.state else { return }
        if engine.applyMove(direction) {
            printBoard()
        }
    }

    private func printBoard() {
        let boardStr = renderer.render(engine.board)
        switch engine.state {
        case .playing:
            print("\n\(boardStr)")
        case .finished:
            print("\n\(boardStr)\n\nGame Over! No valid moves.")
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

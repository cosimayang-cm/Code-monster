import UIKit

final class RootViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Board Games"
        setupMenu()
    }

    private func setupMenu() {
        let games: [(String, UIViewController)] = [
            ("Tic-Tac-Toe", TicTacToeViewController()),
            ("Connect Four", ConnectFourViewController()),
            ("Reversi", ReversiViewController()),
            ("2048", Game2048ViewController())
        ]

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 250)
        ])

        for (name, vc) in games {
            var config = UIButton.Configuration.filled()
            config.title = name
            config.baseBackgroundColor = .systemBlue
            let button = UIButton(configuration: config)
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
            button.addAction(UIAction { [weak self] _ in
                self?.navigationController?.pushViewController(vc, animated: true)
            }, for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }
}

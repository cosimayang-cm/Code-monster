import UIKit

// MARK: - TwentyFortyEightViewController
// 2048 UIKit 輸入層。
// 4×4 tile grid + D-pad 方向 UIButton + swipe gestures。

final class TwentyFortyEightViewController: UIViewController {

    private var game = TwentyFortyEightGame()
    private var renderer: TwentyFortyEightRenderer { TwentyFortyEightRenderer(game: game) }

    // Direction enum tag mapping: 0=up 1=down 2=left 3=right
    private static let directions: [Direction] = [.up, .down, .left, .right]

    // MARK: - UI Components

    private let scoreLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let statusLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 15)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // 4×4 tile labels
    private var tiles: [[UILabel]] = []
    private let boardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.6, alpha: 1)
        v.layer.cornerRadius = 8
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let continueButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Keep Going 🚀", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        b.backgroundColor = .systemGreen.withAlphaComponent(0.15)
        b.setTitleColor(.systemGreen, for: .normal)
        b.layer.cornerRadius = 10
        b.isHidden = true
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let newGameButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("New Game", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        b.backgroundColor = .systemBlue.withAlphaComponent(0.15)
        b.setTitleColor(.systemBlue, for: .normal)
        b.layer.cornerRadius = 10
        b.isHidden = true
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // D-pad buttons
    private let upButton    = TwentyFortyEightViewController.makeArrow("⬆", tag: 0)
    private let downButton  = TwentyFortyEightViewController.makeArrow("⬇", tag: 1)
    private let leftButton  = TwentyFortyEightViewController.makeArrow("⬅", tag: 2)
    private let rightButton = TwentyFortyEightViewController.makeArrow("➡", tag: 3)

    private static func makeArrow(_ title: String, tag: Int) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 30)
        b.tag = tag
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "2048"
        view.backgroundColor = .systemBackground
        setupBoard()
        setupControls()
        setupSwipeGestures()
        startGame()
    }

    // MARK: - Setup

    private func setupBoard() {
        view.addSubview(scoreLabel)
        view.addSubview(statusLabel)
        view.addSubview(boardView)
        view.addSubview(continueButton)
        view.addSubview(newGameButton)

        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            scoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scoreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            statusLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 4),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            boardView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            boardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            boardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            boardView.heightAnchor.constraint(equalTo: boardView.widthAnchor),

            continueButton.topAnchor.constraint(equalTo: boardView.bottomAnchor, constant: 16),
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            continueButton.widthAnchor.constraint(equalToConstant: 160),
            continueButton.heightAnchor.constraint(equalToConstant: 40),

            newGameButton.topAnchor.constraint(equalTo: continueButton.bottomAnchor, constant: 8),
            newGameButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newGameButton.widthAnchor.constraint(equalToConstant: 160),
            newGameButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        newGameButton.addTarget(self, action: #selector(newGameTapped), for: .touchUpInside)

        let gap: CGFloat = 6
        let tileWrapper = UIView()
        tileWrapper.translatesAutoresizingMaskIntoConstraints = false
        boardView.addSubview(tileWrapper)
        NSLayoutConstraint.activate([
            tileWrapper.topAnchor.constraint(equalTo: boardView.topAnchor, constant: gap),
            tileWrapper.leadingAnchor.constraint(equalTo: boardView.leadingAnchor, constant: gap),
            tileWrapper.trailingAnchor.constraint(equalTo: boardView.trailingAnchor, constant: -gap),
            tileWrapper.bottomAnchor.constraint(equalTo: boardView.bottomAnchor, constant: -gap)
        ])

        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = gap
        grid.distribution = .fillEqually
        grid.translatesAutoresizingMaskIntoConstraints = false
        tileWrapper.addSubview(grid)
        NSLayoutConstraint.activate([
            grid.topAnchor.constraint(equalTo: tileWrapper.topAnchor),
            grid.leadingAnchor.constraint(equalTo: tileWrapper.leadingAnchor),
            grid.trailingAnchor.constraint(equalTo: tileWrapper.trailingAnchor),
            grid.bottomAnchor.constraint(equalTo: tileWrapper.bottomAnchor)
        ])

        for _ in 0..<4 {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = gap
            row.distribution = .fillEqually
            var rowLabels: [UILabel] = []
            for _ in 0..<4 {
                let lbl = UILabel()
                lbl.textAlignment = .center
                lbl.font = .systemFont(ofSize: 20, weight: .bold)
                lbl.layer.cornerRadius = 4
                lbl.clipsToBounds = true
                rowLabels.append(lbl)
                row.addArrangedSubview(lbl)
            }
            tiles.append(rowLabels)
            grid.addArrangedSubview(row)
        }
    }

    private func setupControls() {
        let dpad = UIStackView()
        dpad.axis = .vertical
        dpad.alignment = .center
        dpad.spacing = 4
        dpad.translatesAutoresizingMaskIntoConstraints = false

        let hRow = UIStackView()
        hRow.axis = .horizontal
        hRow.spacing = 20
        hRow.addArrangedSubview(leftButton)
        hRow.addArrangedSubview(downButton)
        hRow.addArrangedSubview(rightButton)

        dpad.addArrangedSubview(upButton)
        dpad.addArrangedSubview(hRow)

        view.addSubview(dpad)
        NSLayoutConstraint.activate([
            dpad.topAnchor.constraint(equalTo: newGameButton.bottomAnchor, constant: 16),
            dpad.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        [upButton, downButton, leftButton, rightButton].forEach {
            $0.addTarget(self, action: #selector(directionTapped(_:)), for: .touchUpInside)
        }
    }

    private func setupSwipeGestures() {
        let gestures: [(UISwipeGestureRecognizer.Direction, Int)] = [
            (.up, 0), (.down, 1), (.left, 2), (.right, 3)
        ]
        for (swipeDir, tag) in gestures {
            let gr = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
            gr.direction = swipeDir
            gr.view?.tag = tag  // won't work this way; use manual mapping
            view.addGestureRecognizer(gr)
        }
        // Use separate selectors for each direction via UISwipeGestureRecognizer
    }

    private func startGame() {
        game.restart()
        updateUI()
        print(renderer.render())
    }

    // MARK: - Update UI

    private func updateUI() {
        for r in 0..<4 {
            for c in 0..<4 {
                let v = game.board[r, c]
                let lbl = tiles[r][c]
                lbl.text = v == 0 ? "" : "\(v)"
                lbl.backgroundColor = tileColor(for: v)
                lbl.textColor = v <= 4 ? .darkText : .white
            }
        }

        let formatted = NumberFormatter.localizedString(from: NSNumber(value: game.score), number: .decimal)
        scoreLabel.text = "Score: \(formatted)"

        switch game.state {
        case .playing:
            statusLabel.text = "Swipe or use buttons"
            continueButton.isHidden = true
            newGameButton.isHidden = true
        case .wonCanContinue:
            statusLabel.text = "🏆 You reached 2048!"
            continueButton.isHidden = false
            newGameButton.isHidden = false
        case .draw:
            statusLabel.text = "💀 No moves left!"
            continueButton.isHidden = true
            newGameButton.isHidden = false
        default:
            break
        }
    }

    private func tileColor(for value: Int) -> UIColor {
        switch value {
        case 0:    return UIColor(white: 0.8, alpha: 1)
        case 2:    return UIColor(red: 0.93, green: 0.89, blue: 0.85, alpha: 1)
        case 4:    return UIColor(red: 0.93, green: 0.88, blue: 0.79, alpha: 1)
        case 8:    return UIColor(red: 0.95, green: 0.69, blue: 0.47, alpha: 1)
        case 16:   return UIColor(red: 0.96, green: 0.58, blue: 0.39, alpha: 1)
        case 32:   return UIColor(red: 0.96, green: 0.49, blue: 0.37, alpha: 1)
        case 64:   return UIColor(red: 0.96, green: 0.37, blue: 0.23, alpha: 1)
        case 128:  return UIColor(red: 0.93, green: 0.81, blue: 0.45, alpha: 1)
        case 256:  return UIColor(red: 0.93, green: 0.80, blue: 0.38, alpha: 1)
        case 512:  return UIColor(red: 0.93, green: 0.78, blue: 0.31, alpha: 1)
        case 1024: return UIColor(red: 0.93, green: 0.76, blue: 0.24, alpha: 1)
        case 2048: return UIColor(red: 0.93, green: 0.74, blue: 0.15, alpha: 1)
        default:   return UIColor(red: 0.24, green: 0.23, blue: 0.21, alpha: 1)
        }
    }

    // MARK: - Actions

    @objc private func directionTapped(_ sender: UIButton) {
        performMove(Self.directions[sender.tag])
    }

    @objc private func swiped(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .up:    performMove(.up)
        case .down:  performMove(.down)
        case .left:  performMove(.left)
        case .right: performMove(.right)
        default: break
        }
    }

    private func performMove(_ direction: Direction) {
        guard game.state == .playing || game.state == .wonCanContinue else { return }
        try? game.apply(move: direction)
        updateUI()
        print(renderer.render())
    }

    @objc private func continueTapped() {
        // Already in .wonCanContinue state — just dismiss the overlay
        statusLabel.text = "Keep going..."
        continueButton.isHidden = true
        newGameButton.isHidden = true
    }

    @objc private func newGameTapped() {
        startGame()
    }
}

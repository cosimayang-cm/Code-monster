import UIKit

// MARK: - ReversiViewController
// 黑白棋 UIKit 輸入層。
// VC = Input Only：UICollectionView 8×8 + Pass 按鈕（動態顯示/隱藏）。
// Pass 按鈕：有子可下時 hidden，無子可下時顯示。
// TODO: T4-6 實作

final class ReversiViewController: UIViewController {

    private var game = ReversiGame()
    private var renderer: ReversiRenderer { ReversiRenderer(game: game) }
    private let ai = ReversiAI()

    // TODO: UICollectionView（8×8 cell）
    // TODO: Pass UIButton（動態 hidden）
    // TODO: New Game UIButton

    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: setupUI, startGame
    }

    @objc private func passTapped() {
        // TODO: 切換回合（Pass），print(renderer.render())，觸發 AI 回合
    }

    @objc private func newGameTapped() {
        // TODO
    }

    private func updatePassButtonVisibility() {
        // TODO: passButton.isHidden = !game.isPassRequired()
    }
}

// MARK: - UICollectionViewDataSource / Delegate
// TODO: T4-6 實作 cell tap → apply(move:)

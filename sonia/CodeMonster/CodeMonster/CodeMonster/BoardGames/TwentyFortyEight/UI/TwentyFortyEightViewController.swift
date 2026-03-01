import UIKit

// MARK: - TwentyFortyEightViewController
// 2048 UIKit 輸入層。
// VC = Input Only：4 個方向 UIButton（⬆ ⬇ ⬅ ➡）。
// TODO: T5-5 實作

final class TwentyFortyEightViewController: UIViewController {

    private var game = TwentyFortyEightGame()
    private var renderer: TwentyFortyEightRenderer { TwentyFortyEightRenderer(game: game) }

    // TODO: 4 個方向 UIButton
    // TODO: Continue UIButton（達成 2048 後顯示）
    // TODO: New Game UIButton

    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: setupUI, startGame
    }

    @objc private func directionTapped(_ sender: UIButton) {
        // TODO: Direction from sender.tag
        //       game.apply(move: direction)
        //       print(renderer.render())
        //       更新 UI（Win/GameOver 狀態）
    }

    @objc private func continueTapped() {
        // TODO: 已達成 2048，繼續遊玩（state 已為 .wonCanContinue，繼續接受輸入）
    }

    @objc private func newGameTapped() {
        // TODO
    }
}

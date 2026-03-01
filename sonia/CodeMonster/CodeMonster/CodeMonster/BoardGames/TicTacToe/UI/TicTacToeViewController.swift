import UIKit

// MARK: - TicTacToeViewController
// 井字棋 UIKit 輸入層。
// VC = Input Only：只有 3×3 UIButton grid，不顯示任何棋盤資訊。
// 每次操作後呼叫 print(renderer.render()) 輸出到 Console。
// TODO: T2-6 實作

final class TicTacToeViewController: UIViewController {

    // MARK: - Properties

    private var game = TicTacToeGame()
    private var renderer: TicTacToeRenderer { TicTacToeRenderer(game: game) }
    private let ai = TicTacToeAI()

    // MARK: - TODO: UI Components
    // - 3×3 UIButton grid（programmatic layout）
    // - New Game UIButton（遊戲結束時顯示）

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: setupUI, startGame
    }

    // MARK: - Actions

    /// 使用者點擊棋盤格子
    @objc private func cellButtonTapped(_ sender: UIButton) {
        // TODO: 1. 取得 (row, col) from button tag
        //       2. game.apply(move:)
        //       3. print(renderer.render())
        //       4. 如果遊戲繼續，觸發 AI 回合
        //       5. 遊戲結束時 updateUI
    }

    /// 使用者點擊 New Game
    @objc private func newGameTapped() {
        // TODO: game.restart(), updateUI, print(renderer.render())
    }
}

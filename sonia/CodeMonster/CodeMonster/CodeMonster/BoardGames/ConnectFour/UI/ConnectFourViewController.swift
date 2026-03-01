import UIKit

// MARK: - ConnectFourViewController
// 四子棋 UIKit 輸入層。
// VC = Input Only：7 個欄位 UIButton（每欄一個），欄滿時 disabled。
// TODO: T3-6 實作

final class ConnectFourViewController: UIViewController {

    private var game = ConnectFourGame()
    private var renderer: ConnectFourRenderer { ConnectFourRenderer(game: game) }
    private let ai = ConnectFourAI()

    // TODO: 7 個 UIButton（每欄一個）
    // TODO: New Game UIButton

    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: setupUI, startGame
    }

    @objc private func columnButtonTapped(_ sender: UIButton) {
        // TODO: 1. column = sender.tag
        //       2. game.apply(move:)
        //       3. print(renderer.render())
        //       4. 更新 disabled 欄
        //       5. 觸發 AI 回合
    }

    @objc private func newGameTapped() {
        // TODO
    }
}
